#!/bin/bash
# Interestingness test for llvm-reduce: exit 0 = interesting, non-zero = not.
# Property: a CHAIN of facts that starts at an unknown argument:
#   %a = and %arg, ...   -> zero or positive
#   %b = add ..., %a ... -> positive          (uses %a as an operand)
#   %c = mul ..., %b ... -> negative          (uses %b as an operand)

PASS="zero-analysis"

IN="$1"
HERE="$(cd "$(dirname "$0")" && pwd)"

PLUGIN=""
for candidate in "$HERE"/../build/SignedAnalysis.dylib "$HERE"/../build/SignedAnalysis.so; do
  if [ -f "$candidate" ]; then PLUGIN="$candidate"; break; fi
done
[ -n "$PLUGIN" ] || exit 1

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mlir-translate --import-llvm "$IN" -o "$TMP/in.mlir" 2>/dev/null || exit 1

mlir-opt --load-pass-plugin="$PLUGIN" \
         --pass-pipeline="builtin.module($PASS)" \
         "$TMP/in.mlir" -o /dev/null 2> "$TMP/out.txt" >/dev/null || exit 1

OUT="$TMP/out.txt"

result_of() {
  grep -E "$1" "$OUT" | head -n1 | sed -E 's/^ *(%[0-9]+) =.*/\1/'
}

A=$(result_of 'llvm\.and .*%arg[0-9]+.*// %[0-9]+ is zero or positive$')
[ -n "$A" ] || exit 1

B=$(result_of "llvm\\.add [^/]*${A}[,: ].*// %[0-9]+ is positive\$")
[ -n "$B" ] || exit 1

grep -Eq "llvm\\.mul [^/]*${B}[,: ].*// %[0-9]+ is negative\$" "$OUT"