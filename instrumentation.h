#ifndef SIGN_INSTRUMENTATION_H
#define SIGN_INSTRUMENTATION_H

#include "SignedDomain.h"
#include "mlir/IR/Value.h"

namespace sign {
    void assertion(Kind kind, mlir::Value value);
} // namespace sign

#endif // SIGN_INSTRUMENTATION_H