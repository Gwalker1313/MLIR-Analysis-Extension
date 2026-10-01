//===- SignedAnalysis.h - Sparse forward analysis over SignedState ------------===//

#ifndef SIGNED_ANALYSIS_H
#define SIGNED_ANALYSIS_H

#include "SignedDomain.h"
#include "mlir/Analysis/DataFlow/SparseAnalysis.h"

namespace signed {

using SignLattice = mlir::dataflow::Lattice<SignedState>;

class SignedAnalysis
    : public mlir::dataflow::SparseForwardDataFlowAnalysis<SignedLattice> {
public:
  using SparseForwardDataFlowAnalysis::SparseForwardDataFlowAnalysis;

  /// Transfer function: given the states of `op`'s operands, set the states of
  /// its results.  Must be monotone in the operand states.
  mlir::LogicalResult
  visitOperation(mlir::Operation *op,
                 llvm::ArrayRef<const SignedLattice *> operands,
                 llvm::ArrayRef<SignedLattice *> results) override;

  /// The state of anything entering the analysis from outside: function
  /// arguments, and results the transfer function declines to reason about.
  void setToEntryState(SignedLattice *lattice) override;
};

} // namespace zero

#endif
