#!/bin/bash
# Interestingness test for llvm-reduce: exit 0 = interesting, non-zero = not.
# Property: an `and` with an UNKNOWN function argument as an operand is proven
# zero or positive (the constant mask clears the sign bit).

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

grep -Eq 'llvm\.and .*%arg[0-9]+.*// %[0-9]+ is zero or positive$' "$TMP/out.txt"