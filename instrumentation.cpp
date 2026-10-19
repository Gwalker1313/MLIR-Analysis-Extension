#include "Instrumentation.h"

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/raw_ostream.h"

#include <string>

namespace sign {

    void assertion(Kind kind, mlir::Value value) {
        

        switch (kind) {
            case Kind::Bottom:
                return;
            case Kind::Neg:
                break;
            case Kind::Zero:
                break;
            case Kind::Pos:
                break;
            case Kind::ZeroNeg:
                break;
            case Kind::ZeroPos:
                break;
            case Kind::Top:
                return;
        }
        return;
    }

} // namespace sign