#!/bin/bash
# Interestingness test: exit 0 iff the instrumented program fails a sign check.
IN="$1"
HERE="$(cd "$(dirname "$0")" && pwd)"

PLUGIN=""
for candidate in "$HERE"/../build/SignedAnalysis.dylib "$HERE"/../build/SignedAnalysis.so; do
  if [ -f "$candidate" ]; then PLUGIN="$candidate"; break; fi
done
[ -n "$PLUGIN" ] || exit 1

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mlir-translate --import-llvm "$IN" -o "$TMP/a.mlir" 2>/dev/null || exit 1
mlir-opt --load-pass-plugin="$PLUGIN" \
         --pass-pipeline='builtin.module(zero-analysis{instrument=true})' \
         "$TMP/a.mlir" -o "$TMP/b.mlir" 2>/dev/null || exit 1
mlir-translate --mlir-to-llvmir "$TMP/b.mlir" -o "$TMP/b.ll" 2>/dev/null || exit 1
clang -Wno-override-module "$TMP/b.ll" -o "$TMP/prog" 2>/dev/null || exit 1

# Run with the failing input; the failure message goes to stderr.
"$TMP/prog" 1 > /dev/null 2> "$TMP/err.txt"
grep -q "Sign assertion failed" "$TMP/err.txt"