//===- SignedDomain.h - The abstract domain --------------------------===//
//
// A seven-point lattice recording whether an integer value is known to be zero.
//
//               Top             nothing is known
//            /       \
//     ZeroNeg        ZeroPos
//      |     \       /    |
//     Neg      Zero      Pos
//        \      |       / 
//             Bottom            unreachable, or not yet analyzed
//
//   * a default constructor, which must produce the bottom element, because the
//     solver starts every value optimistically and lowers it as facts arrive;
//   * a static join(), which must be commutative, associative, idempotent, and
//     monotone -- assertions in Lattice<> check monotonicity in debug builds;
//   * operator== and print().
//
//===----------------------------------------------------------------------===//

#ifndef SIGNED_DOMAIN_H
#define SIGNED_DOMAIN_H

#include "llvm/Support/raw_ostream.h"

namespace signed {

enum class Kind { Bottom, Neg, Zero, Pos, ZeroNeg, ZeroPos, Top };

inline const char *name(Kind kind) {
  switch (kind) {
  case Kind::Bottom:
    return "bottom";
  case Kind::Neg:
    return "neg";
  case Kind::Zero:
    return "zero";
  case Kind::Pos:
    return "pos";
  case Kind::ZeroNeg:
    return "zero neg";
  case Kind::ZeroPos:
    return "zero pos";
  case Kind::Top:
    return "top";
  }
  return "top";
}

struct SignedState {
  Kind kind = Kind::Bottom;

  SignedState() = default;
  /* implicit */ SignedState(Kind kind) : kind(kind) {}

  static SignedState bottom() { return Kind::Bottom; }
  static SignedState top() { return Kind::Top; }

  bool isBottom() const { return kind == Kind::Bottom; }

  /// Least upper bound.  Two disagreeing facts lose all information.
  static SignedState join(const SignedState &lhs, const SignedState &rhs) {
    if (lhs.kind == Kind::Bottom)
      return rhs;
    if (rhs.kind == Kind::Bottom)
      return lhs;
    if (lhs.kind == rhs.kind)
      return lhs;
    return top();
  }

  bool operator==(const SignedState &other) const { return kind == other.kind; }
  bool operator!=(const SignedState &other) const { return kind != other.kind; }

  void print(llvm::raw_ostream &os) const { os << name(kind); }
};

inline llvm::raw_ostream &operator<<(llvm::raw_ostream &os,
                                     const SignedState &state) {
  state.print(os);
  return os;
}

} // namespace zero

#endif
