#!/bin/bash
# Interestingness test for llvm-reduce: exit 0 = interesting, non-zero = not.
# Property: zero is produced by an operation touching an UNKNOWN argument,
# then propagates through at least two non-constant operations.

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

# Zero must be produced by an op that touches an unknown argument...
grep -Eq 'llvm\.(and|mul|sdiv) .*%arg[0-9]+.*// %[0-9]+ is zero$' "$OUT" || exit 1
# ...and must show up on at least two non-constant operations in total.
[ "$(grep -Ec 'llvm\.(and|mul|sdiv|sub|add) .*// %[0-9]+ is zero$' "$OUT")" -ge 2 ]