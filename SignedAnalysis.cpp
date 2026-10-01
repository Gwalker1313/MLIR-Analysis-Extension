#include "SignedAnalysis.h"

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/Matchers.h"

using namespace mlir;

namespace sign {

using TransferFunctions = Kind[KindCount][KindCount];

constexpr Kind Bot = Kind::Bottom;
constexpr Kind Neg = Kind::Neg;
constexpr Kind Zer = Kind::Zero;
constexpr Kind Pos = Kind::Pos;
constexpr Kind ZeN = Kind::ZeroNeg;
constexpr Kind ZeP = Kind::ZeroPos;
constexpr Kind Top = Kind::Top;

static SignState evaluate(const TransferFunctions &table, SignState lhs, SignState rhs) {
  return table[index(lhs.kind)][index(rhs.kind)];
}

constexpr TransferFunctions AddLookupTable = {
  //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top
  /* Bot */     {Bot, Bot, Bot, Bot, Bot, Bot, Bot},
  /* Neg */     {Bot, Neg, Neg, Top, Neg, Top, Top},
  /* Zer */     {Bot, Neg, Zer, Pos, ZeN, ZeP, Top},
  /* Pos */     {Bot, Top, Pos, Pos, Top, Pos, Top},
  /* ZeN */     {Bot, Neg, ZeN, Top, ZeN, Top, Top},
  /* ZeP */     {Bot, Top, ZeP, Pos, Top, ZeP, Top},
  /* Top */     {Bot, Top, Top, Top, Top, Top, Top},
};

constexpr TransferFunctions SubLookupTable = {
  //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top
  /* Bot */     {Bot, Bot, Bot, Bot, Bot, Bot, Bot},
  /* Neg */     {Bot, Top, Neg, Neg, Top, Neg, Top},
  /* Zer */     {Bot, Pos, Zer, Neg, ZeP, ZeN, Top},
  /* Pos */     {Bot, Pos, Pos, Top, Pos, Top, Top},
  /* ZeN */     {Bot, Top, ZeN, Neg, Top, ZeN, Top},
  /* ZeP */     {Bot, Pos, ZeP, Top, ZeP, Top, Top},
  /* Top */     {Bot, Top, Top, Top, Top, Top, Top},
};

constexpr TransferFunctions MultLookupTable = {
  //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top
  /* Bot */     {Bot, Bot, Bot, Bot, Bot, Bot, Bot},
  /* Neg */     {Bot, Pos, Zer, Neg, ZeP, ZeN, Top},
  /* Zer */     {Bot, Zer, Zer, Zer, Zer, Zer, Zer},
  /* Pos */     {Bot, Neg, Zer, Pos, ZeN, ZeP, Top},
  /* ZeN */     {Bot, ZeP, Zer, ZeN, ZeP, ZeN, Top},
  /* ZeP */     {Bot, ZeN, Zer, ZeP, ZeN, ZeP, Top},
  /* Top */     {Bot, Top, Zer, Top, Top, Top, Top},
};

constexpr TransferFunctions DivLookupTable = {
  //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top
  /* Bot */     {Bot, Bot, Bot, Bot, Bot, Bot, Bot},
  /* Neg */     {Bot, ZeP, Bot, ZeN, ZeP, ZeN, Top},
  /* Zer */     {Bot, Zer, Bot, Zer, Zer, Zer, Zer},
  /* Pos */     {Bot, ZeN, Bot, ZeP, ZeN, ZeP, Top},
  /* ZeN */     {Bot, ZeP, Bot, ZeN, ZeP, ZeN, Top},
  /* ZeP */     {Bot, ZeN, Bot, ZeP, ZeN, ZeP, Top},
  /* Top */     {Bot, Top, Bot, Top, Top, Top, Top},
};

constexpr TransferFunctions GreaterThanLookupTable = {
  //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top
  /* Bot */     {Bot, Bot, Bot, Bot, Bot, Bot, Bot},
  /* Neg */     {Bot, ZeP, Zer, Zer, ZeP, Zer, ZeP},
  /* Zer */     {Bot, Pos, Zer, Zer, ZeP, Zer, ZeP},
  /* Pos */     {Bot, Pos, Pos, ZeP, Pos, ZeP, ZeP},
  /* ZeN */     {Bot, ZeP, Zer, Zer, ZeP, Zer, ZeP},
  /* ZeP */     {Bot, Pos, ZeP, ZeP, ZeP, ZeP, ZeP},
  /* Top */     {Bot, ZeP, ZeP, ZeP, ZeP, ZeP, ZeP},
};

constexpr TransferFunctions EqualLookupTable = {
  //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top
  /* Bot */     {Bot, Bot, Bot, Bot, Bot, Bot, Bot},
  /* Neg */     {Bot, ZeP, Zer, Zer, ZeP, Zer, ZeP},
  /* Zer */     {Bot, Zer, Pos, Zer, ZeP, ZeP, ZeP},
  /* Pos */     {Bot, Zer, Zer, ZeP, Zer, ZeP, ZeP},
  /* ZeN */     {Bot, ZeP, ZeP, Zer, ZeP, ZeP, ZeP},
  /* ZeP */     {Bot, Zer, ZeP, ZeP, ZeP, ZeP, ZeP},
  /* Top */     {Bot, ZeP, ZeP, ZeP, ZeP, ZeP, ZeP},
};

constexpr TransferFunctions AndLookupTable = {
  //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top
  /* Bot */     {Bot, Bot, Bot, Bot, Bot, Bot, Bot},
  /* Neg */     {Bot, Neg, Zer, ZeP, ZeN, ZeP, Top},
  /* Zer */     {Bot, Zer, Zer, Zer, Zer, Zer, Zer},
  /* Pos */     {Bot, ZeP, Zer, ZeP, ZeP, ZeP, ZeP},
  /* ZeN */     {Bot, ZeN, Zer, ZeP, ZeN, ZeP, Top},
  /* ZeP */     {Bot, ZeP, Zer, ZeP, ZeP, ZeP, ZeP},
  /* Top */     {Bot, Top, Zer, ZeP, Top, ZeP, Top},
};

void SignAnalysis::setToEntryState(SignLattice *lattice) {
  propagateIfChanged(lattice, lattice->join(SignState::top()));
}

LogicalResult
SignAnalysis::visitOperation(Operation *op,
                             ArrayRef<const SignLattice *> operands,
                             ArrayRef<SignLattice *> results) {
  // Raising a result to top says "this operation could produce anything",
  // which is always a sound answer and is what every unhandled case does.
  auto unknown = [&] {
    setAllToEntryStates(results);
    return success();
  };

  // Only single-result integer operations are interesting here.  Calls, loads,
  // floats, and vectors all land in `unknown`.
  if (op->getNumResults() != 1 || !op->getResult(0).getType().isIntOrIndex())
    return unknown();
  SignLattice *result = results[0];

  // Rule 1: zero, one, negative, or positive
  IntegerAttr value;
  if (matchPattern(op, m_Constant(&value))) {
    SignState state;
    if (value.getValue().isZero()) {
      state = Kind::Zero;
    } else if (value.getValue().isStrictlyPositive()) {
      state = Kind::Pos;
    } else if (value.getValue().isNegative()) {
      state = Kind::Neg;
    }

    propagateIfChanged(result, result->join(state));
    return success();
  }

  // Rule 2: binary operations look up their result in a transfer table.
  // If the amount of operands is incorrect, trivially this is unknown.
  if (operands.size() != 2) {
    return unknown();
  }

  const TransferFunctions *table = nullptr;
  if (isa<LLVM::AddOp>(op)) {
    table = &AddLookupTable;
  }
  if (isa<LLVM::SubOp>(op)) {
    table = &SubLookupTable;
  }
  if (isa<LLVM::MulOp>(op)) {
    table = &MultLookupTable;
  }
  if (isa<LLVM::SDivOp>(op)) {
    table = &DivLookupTable;
  }
  if (isa<LLVM::AndOp>(op)) {
    table = &AndLookupTable;
  }
    
  
  if (auto compare = dyn_cast<LLVM::ICmpOp>(op)) {
    if (compare.getPredicate() == LLVM::ICmpPredicate::sgt)
    table = &GreaterThanLookupTable;
    else if (compare.getPredicate() == LLVM::ICmpPredicate::eq)
    table = &EqualLookupTable;
  }
  
  SignState lhs = operands[0]->getValue();
  SignState rhs = operands[1]->getValue();
  if (table != nullptr) {
    propagateIfChanged(result, result->join(evaluate(*table, lhs, rhs)));
    return success();
  }

  return unknown();
}

} // namespace sign
