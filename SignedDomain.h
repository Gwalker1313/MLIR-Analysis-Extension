//===- SignDomain.h - The abstract domain --------------------------===//
//
// A seven-point lattice recording whether an integer value is known to be zero or signed.
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

#ifndef SIGN_DOMAIN_H
#define SIGN_DOMAIN_H

#include "llvm/Support/raw_ostream.h"

namespace sign {

enum class Kind { Bottom, Neg, Zero, Pos, ZeroNeg, ZeroPos, Top };

inline const char* name(Kind kind) {
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

inline constexpr unsigned index(Kind kind) {
  switch (kind) {
    case Kind::Bottom:
    return 0;
    case Kind::Neg:
    return 1;
    case Kind::Zero:
    return 2;
    case Kind::Pos:
    return 3;
    case Kind::ZeroNeg:
    return 4;
    case Kind::ZeroPos:
    return 5;
    case Kind::Top:
    return 6;
  }
  return 6;
}

inline constexpr unsigned KindCount = 7;

struct SignState {
  Kind kind = Kind::Bottom;

  SignState() = default;
  /* implicit */ SignState(Kind kind) : kind(kind) {}

  static SignState bottom() { return Kind::Bottom; }
  static SignState top() { return Kind::Top; }

  bool isBottom() const { return kind == Kind::Bottom; }

  /// Least upper bound.
  static SignState join(const SignState &lhs, const SignState &rhs) {
    constexpr Kind Bot = Kind::Bottom;
    constexpr Kind Neg = Kind::Neg;
    constexpr Kind Zer = Kind::Zero;
    constexpr Kind Pos = Kind::Pos;
    constexpr Kind ZeN = Kind::ZeroNeg;
    constexpr Kind ZeP = Kind::ZeroPos;
    constexpr Kind Top = Kind::Top;

    static constexpr Kind JoinLookupTable[KindCount][KindCount] = {
      //             Bot  Neg  Zer  Pos  ZeN  ZeP  Top      
      /* Bot */     {Bot, Neg, Zer, Pos, ZeN, ZeP, Top},
      /* Neg */     {Neg, Neg, ZeN, Top, ZeN, Top, Top},
      /* Zer */     {Zer, ZeN, Zer, ZeP, ZeN, ZeP, Top},
      /* Pos */     {Pos, Top, ZeP, Pos, Top, ZeP, Top},
      /* ZeN */     {ZeN, ZeN, ZeN, Top, ZeN, Top, Top},
      /* ZeP */     {ZeP, Top, ZeP, ZeP, Top, ZeP, Top},
      /* Top */     {Top, Top, Top, Top, Top, Top, Top},
    };

    return JoinLookupTable[index(lhs.kind)][index(rhs.kind)];
  }

  bool operator==(const SignState &other) const { return kind == other.kind; }
  bool operator!=(const SignState &other) const { return kind != other.kind; }

  void print(llvm::raw_ostream &os) const { os << name(kind); }
};

inline llvm::raw_ostream &operator<<(llvm::raw_ostream &os,
                                     const SignState &state) {
  state.print(os);
  return os;
}

} // namespace sign

#endif
