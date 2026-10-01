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

inline constexpr unsigned KindCount = 7;

struct SignedState {
  Kind kind = Kind::Bottom;

  SignedState() = default;
  /* implicit */ SignedState(Kind kind) : kind(kind) {}

  static SignedState bottom() { return Kind::Bottom; }
  static SignedState top() { return Kind::Top; }

  bool isBottom() const { return kind == Kind::Bottom; }

  /// Least upper bound.
  static SignedState join(const SignedState &lhs, const SignedState &rhs) {
    constexpr Bot = Kind::Bottom;
    constexpr Neg = Kind::Neg;
    constexpr Zer = Kind::Zero;
    constexpr Pos = Kind::Pos;
    constexpr ZeN = Kind::ZeroNeg;
    constexpr ZeP = Kind::ZeroPos;
    constexpr Top = Kind::Top;

    static constexpr Kind JoinLookupTable[KindCount][KindCount] = {
      //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top      
      /* Bot */     {Bot, Neg, Zer, Pos, ZeN, ZeP, Top},
      /* Neg */     {Neg, Neg, ZeN, Top, ZeN, Top, Top},
      /* Zer */     {Zer, ZeN, Zer, ZeP, ZeN, ZeP, Top},
      /* Pos */     {Pos, Top, ZeP, Pos, Top, ZeP, Top},
      /* ZeN */     {ZeN, ZeN, ZeN, Top, ZeN, Top, Top},
      /* ZeP */     {ZeP, Top, Zep, Zep, Top, Zep, Top},
      /* Top */     {Top, Top, Top, Top, Top, Top, Top},
    }
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
