#!/bin/bash
# Interestingness test for llvm-reduce: exit 0 = interesting, non-zero = not.
# Property: the sign analysis proves some `and` result is zero-or-positive.

PASS="zero-analysis"
PATTERN='llvm\.and .*// %[0-9]+ is zero or positive$'

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

grep -Eq "$PATTERN" "$TMP/out.txt"