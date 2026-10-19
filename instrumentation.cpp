#include "Instrumentation.h"

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/raw_ostream.h"

#include <string>

namespace sign {

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