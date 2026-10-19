#include "Instrumentation.h"

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/raw_ostream.h"

#include <string>

namespace sign {

    // Output to stderr before trap so that original output is not lost
    // in a stdio buffer.
    void printFailure(mlir::OpBuilder& builder, mlir::Value value, llvm::StringRef description) {
        auto location = value.getLoc();
        auto module = value.getParentBlock()->getParentOp()->getParentOfType<mlir::ModuleOp>();
        auto pointer = mlir::LLVM::LLVMPointerType::get(builder.getContext());
        auto functionType = mlir::LLVM::LLVMFunctionType::get(builder.getI32Type(), {builder.getI32Type(), pointer}, true);
        auto printer = module.lookupSymbol<mlir::LLVM::LLVMFuncOp>("dprintf");
        if (!printer) {
            mlir::OpBuilder::InsertionGuard guard(builder);
            builder.setInsertionPointToStart(module.getBody());
            printer = mlir::LLVM::LLVMFuncOp::create(builder, location, "dprintf", functionType);
        }

        // Escape SSA '%' characters for printf.
        std::string format;
        for (char character : description) {
            format += character;
            if (character == '%')
                format += '%';
        }

        llvm::SmallVector<mlir::Value> actual;
        unsigned width = llvm::cast<mlir::IntegerType>(value.getType()).getWidth();
        if (width <= 64) {
            format += "  actual: %lld\n";
            actual.push_back(width == 64 ? value : mlir::LLVM::SExtOp::create(builder, location, builder.getI64Type(), value).getResult());
        } 
        else {
            // Preserve wider integers as hexadecimal.
            format += "  actual: 0x";
            for (unsigned chunk = (width - 1) / 64 + 1; chunk > 0; --chunk) {
                unsigned shift = (chunk - 1) * 64;
                mlir::Value bits = value;
                if (shift) {
                    auto amount = mlir::LLVM::ConstantOp::create(builder, location, value.getType(), builder.getIntegerAttr(value.getType(), shift));
                    bits = mlir::LLVM::LShrOp::create(builder, location, value, amount.getResult()).getResult();
                }
                actual.push_back(mlir::LLVM::TruncOp::create(builder, location, builder.getI64Type(), bits).getResult());
                format += chunk == (width - 1) / 64 + 1 ? "%llx" : "%016llx";
            }
            format += "\n";
        }
        format += '\0';
        unsigned index = 0;
        std::string symbol;
        do {
            symbol = "__sign_failure_message_" + std::to_string(index++);
        } while (module.lookupSymbol(symbol));
        auto message = mlir::LLVM::createGlobalString(location, builder, symbol, format, mlir::LLVM::Linkage::Private);
        auto stderrFd = mlir::LLVM::ConstantOp::create(builder, location, builder.getI32Type(), builder.getI32IntegerAttr(2));
        llvm::SmallVector<mlir::Value> arguments{stderrFd.getResult(), message};
        arguments.append(actual);
        mlir::LLVM::CallOp::create(builder, location, printer, arguments);
    }

    void assertion(Kind kind, mlir::Value value) {
        auto type = llvm::dyn_cast<mlir::IntegerType>(value.getType());
        mlir::Block *block = value.getParentBlock();
        if (!type || type.getWidth() == 1 || !block ||
            !llvm::isa<mlir::LLVM::LLVMFuncOp>(block->getParentOp())) {
                return;
            }
        if (kind == Kind::Top || kind == Kind::Bottom) {
            return;
        }

        // A check after a terminator would be invalid IR.
        if (auto *def = value.getDefiningOp())
            if (def->hasTrait<mlir::OpTrait::IsTerminator>()) {
                return;
            }

        // Describe the original value before any splitting happens.
        std::string description;
        llvm::raw_string_ostream message(description);
        auto function = llvm::cast<mlir::LLVM::LLVMFuncOp>(block->getParentOp());
        message << "Sign assertion failed in @" << function.getSymName() << "\n  ";
        if (auto *definingOp = value.getDefiningOp())
            definingOp->print(message);
        else
            message << "block argument "
                    << llvm::cast<mlir::BlockArgument>(value).getArgNumber();
        message << "\n  location: " << value.getLoc()
                << "\n  expected: " << name(kind) << "\n";

        mlir::OpBuilder builder(value.getContext());
        builder.setInsertionPointAfterValue(value);
        mlir::Location location = value.getLoc();

        auto zero = mlir::LLVM::ConstantOp::create(
            builder, location, value.getType(),
            builder.getIntegerAttr(value.getType(), 0));

        mlir::LLVM::ICmpPredicate predicate;
            switch (kind) {
            case Kind::Zero:    
                predicate = mlir::LLVM::ICmpPredicate::eq;  
                break;
            case Kind::Neg:     
                predicate = mlir::LLVM::ICmpPredicate::slt; 
                break;
            case Kind::ZeroNeg: 
                predicate = mlir::LLVM::ICmpPredicate::sle; 
                break;
            case Kind::Pos:     
                predicate = mlir::LLVM::ICmpPredicate::sgt; 
                break;
            case Kind::ZeroPos: 
                predicate = mlir::LLVM::ICmpPredicate::sge; 
                break;
            default:            
                return;
            }

        auto compare = mlir::LLVM::ICmpOp::create(builder, location, predicate,
                                                    value, zero.getResult());
        mlir::Value condition = compare.getResult();

        // Everything after the compare (including the terminator) moves on.
        mlir::Block *original = compare->getBlock();
        mlir::Block *continuation = original->splitBlock(compare->getNextNode());

        // Failure block: print, trap, unreachable.
        mlir::Block *failure = builder.createBlock(continuation);
        printFailure(builder, value, description);
        mlir::LLVM::Trap::create(builder, location);
        mlir::LLVM::UnreachableOp::create(builder, location);

        // The original block needs a terminator again.
        builder.setInsertionPointToEnd(original);
        mlir::LLVM::CondBrOp::create(builder, location, condition, continuation,
                                    failure);
    }

} // namespace sign