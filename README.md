# MLIR Sign Analysis

An out-of-tree MLIR dataflow analysis, built as an `mlir-opt` plugin, that
determines the sign of integer values in the LLVM dialect. Values whose sign is
known are annotated; values at top or bottom are omitted.

The lattice is `Bottom < {Neg, Zero, Pos} < {ZeroNeg, ZeroPos} < Top`, with
transfer functions for `add`, `sub`, `mul`, `sdiv`, `and`, `icmp sgt`, `icmp eq`,
and constants. Everything else is `top`.

## Requirements

CMake 3.20+, and an LLVM built with MLIR and plugins enabled. `llvm-config`,
`mlir-opt`, `mlir-translate`, and `clang` must be on `PATH`. On macOS,
Homebrew's `llvm` works. On Debian/Ubuntu, install `llvm-dev` and `libmlir-dev`.

## Build and test

```sh
cmake -S . -B build        # add -DMLIR_DIR=<prefix>/lib/cmake/mlir if needed
cmake --build build
ctest --test-dir build --output-on-failure
```

## Run

```sh
./run.sh input.mlir
```

This prints the IR with a `// %N is <sign>` comment on each value whose sign is
known. Or invoke `mlir-opt` directly (`.dylib` on macOS, `.so` on Linux):

```sh
mlir-opt --load-pass-plugin=build/SignedAnalysis.dylib \
         --pass-pipeline='builtin.module(sign-analysis)' input.mlir -o /dev/null
```

The annotated listing goes to stderr; stdout is the unchanged IR.

## Getting input from C

Compile with `-O1` so locals are promoted to SSA values. At `-O0` everything
goes through memory and the analysis only sees `top`.

```sh
clang -O1 -S -emit-llvm -o - input.c | mlir-translate --import-llvm > input.mlir
./run.sh input.mlir
```

### Example: a non-trivial fact

```c
// example.c
int f(int x) { return (x & 255) + 1; }
```

```sh
clang -O1 -S -emit-llvm -o - example.c | mlir-translate --import-llvm > example.mlir
./run.sh example.mlir
```

`x` is unknown (`top`), yet the analysis proves the result is strictly
positive:

```
%1 = llvm.and %arg0, %c255 : i32    // is zero pos   (anything & positive is non-negative)
%2 = llvm.add %1, %c1 : i32         // is pos        (non-negative + positive > 0)
```

The exact SSA names and layout depend on your LLVM version.

### Larger input: SQLite

```sh
clang -O1 -S -emit-llvm -o - test/sqlite-amalgamation-3530400/sqlite3.c \
  | mlir-translate --import-llvm > sqlite3.mlir
./run.sh sqlite3.mlir
```

## Layout

| File                           | Purpose                                          |
| ------------------------------ | ------------------------------------------------ |
| `SignedDomain.h`               | Lattice and join                                 |
| `SignedAnalysis.{h,cpp}`       | Transfer functions and MLIR sparse-analysis glue |
| `Annotate.{h,cpp}`             | Prints IR with per-value comments                |
| `Plugin.cpp`                   | The pass and `mlir-opt` plugin entry point       |
| `test/`, `cmake/RunTest.cmake` | Test input, expected facts, and runner           |
