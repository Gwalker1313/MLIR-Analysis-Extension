# MLIR Sign Analysis

An out-of-tree MLIR dataflow analysis, built as an `mlir-opt` plugin, that
determines the sign of integer values in the LLVM dialect. Values whose sign is
known are annotated; values at top or bottom are omitted. The pass can also
insert runtime assertions for every proven fact, to check the analysis for
soundness bugs dynamically.

The lattice is `Bottom < {Neg, Zero, Pos} < {ZeroNeg, ZeroPos} < Top`, with
transfer functions for `add`, `sub`, `mul`, `sdiv`, `and`, `icmp sgt`, `icmp eq`,
and constants. Everything else is `top`.

## Requirements

CMake 3.20+, and an LLVM built with MLIR and plugins enabled. `llvm-config`,
`mlir-opt`, `mlir-translate`, `llvm-reduce`, and `clang` must be on `PATH`. On
macOS, Homebrew's `llvm` works, and the Makefile puts it first on `PATH`
automatically. On Debian/Ubuntu, install `llvm-dev` and `libmlir-dev`.

## Quick start

```sh
make build    # configure (first time) and build the plugin
make test     # run the ctest suite
make run      # print the annotated listing for test/zero.mlir
```

Run `make help` for the full target list. The plain CMake commands also work:

```sh
cmake -S . -B build        # add -DMLIR_DIR=<prefix>/lib/cmake/mlir if needed
cmake --build build
ctest --test-dir build --output-on-failure
```

## Makefile targets

| Target                                 | Purpose                                                            |
| -------------------------------------- | ------------------------------------------------------------------ |
| `make build`                           | Configure (first time) and build the plugin                        |
| `make test`                            | Run the ctest suite                                                |
| `make run [INPUT=file.mlir]`           | Print the annotated listing for `INPUT` (default `test/zero.mlir`) |
| `make check-reductions`                | Confirm all three original reduction inputs are interesting        |
| `make reduce1` / `reduce2` / `reduce3` | Run one `llvm-reduce` reduction                                    |
| `make reduce-all`                      | Regenerate all three `reductions/reducedN.mlir` files              |
| `make soundness [ARGS=n]`              | Instrument `soundness/prog.c`, compile it, and run it              |
| `make soundness-sweep`                 | Run the instrumented program on edge values                        |
| `make reduce-soundness`                | Reduce the program to a minimal failing case                       |
| `make clean` / `make distclean`        | Remove generated files / also delete `build/`                      |

Variables can be overridden on the command line: `PASS` (pass name, default
`zero-analysis`), `INPUT`, `ARGS`, `EDGE_VALUES`, `BUILD`, `CMAKE_ARGS`.

## Run

`make run` invokes `mlir-opt` on `INPUT`. To do it by hand (`.dylib` on macOS,
`.so` on Linux):

```sh
mlir-opt --load-pass-plugin=build/SignedAnalysis.dylib \
         --pass-pipeline='builtin.module(zero-analysis)' input.mlir -o /dev/null
```

The annotated listing (a `// %N is <sign>` comment on each value whose sign is
known) goes to stderr; stdout is the unchanged IR.

## Getting input from C

Compile with `-O1` so locals are promoted to SSA values. At `-O0` everything
goes through memory and the analysis only sees `top`.

```sh
clang -O1 -S -emit-llvm -o - input.c | mlir-translate --import-llvm > input.mlir
make run INPUT=input.mlir
```

### Example: a non-trivial fact

```c
// example.c
int f(int x) { return (x & 255) + 1; }
```

```sh
clang -O1 -S -emit-llvm -o - example.c | mlir-translate --import-llvm > example.mlir
make run INPUT=example.mlir
```

`x` is unknown (`top`), yet the analysis proves the result is strictly
positive:

```
%1 = llvm.and %arg0, %c255 : i32    // is zero or positive
%2 = llvm.add %1, %c1 : i32         // is positive
```

The exact SSA names, wording and layout depend on your build.

### Larger input: SQLite

```sh
clang -O1 -S -emit-llvm -o - sqlite-amalgamation-3530400/sqlite3.c \
  | mlir-translate --import-llvm > sqlite3.mlir
make run INPUT=sqlite3.mlir
```

## Reductions

`reductions/` holds three `llvm-reduce` runs. Each has `inputN.ll` (original
program), `testN.sh` (interestingness test), and `reducedN.mlir` (result).

The three tests preserve these dataflow chains:

1. an unknown argument is masked to a nonnegative value, propagated through
   addition to a positive value, and multiplied by a negative constant to
   prove a negative result;
2. an unknown argument is masked with a positive constant, proving the result
   nonnegative;
3. a zero constant is multiplied by an unknown argument, proving the product
   zero regardless of the argument's value.

An interestingness test must exit with status `0` when its input is
interesting. Each script converts the candidate LLVM IR to MLIR with
`mlir-translate`, runs the sign analysis through `mlir-opt`, and searches the
annotated listing with `grep -E`. A candidate that fails to import or makes the
plugin fail is rejected, so the reducer cannot shrink the input into something
that is not analyzable. Each pattern requires an operation that uses a function
argument (which the analysis treats as unknown), so the reducer cannot replace
the example with an unrelated constant expression. `test1.sh` also requires
each link of the chain to use the previous result as an operand.

```sh
make check-reductions   # confirm all original inputs are interesting
make reduce1            # run one reduction
make reduce-all         # regenerate all three reducedN.mlir files
```

`llvm-reduce` writes an intermediate `reducedN.ll`, and a separate
`mlir-translate --import-llvm` step creates the required `reducedN.mlir`.

## Dynamic soundness checking

Passing the `instrument` option makes the pass also transform the code: after
the analysis converges, every integer value with a known sign gets a runtime
check inserted right after its definition. The checks turn dataflow facts into
assertions:

| Fact      | Inserted check |
| --------- | -------------- |
| `Neg`     | `value < 0`    |
| `Zero`    | `value == 0`   |
| `Pos`     | `value > 0`    |
| `ZeroNeg` | `value <= 0`   |
| `ZeroPos` | `value >= 0`   |

Each check is a signed `llvm.icmp` against zero followed by a conditional
branch. The failing edge goes to a block that prints the operation, its source
location, the expected sign, and the actual value to stderr, then traps.
`Top`, `Bottom`, `i1` values, and values outside `llvm.func` bodies are not
checked. Without the option, the pass leaves the IR unchanged.

```sh
mlir-opt --load-pass-plugin=build/SignedAnalysis.dylib \
         --pass-pipeline='builtin.module(zero-analysis{instrument=true})' \
         prog.mlir -o prog.inst.mlir
```

The `make soundness` pipeline does the whole conversion on `soundness/prog.c`:
C to LLVM IR (with `-O1 -fwrapv`), to MLIR, instrument, back to LLVM IR, and
compile. `-fwrapv` makes signed overflow defined, so a failed check means the
analysis is unsound rather than the program having undefined behavior.

```sh
make soundness ARGS=0      # passes
make soundness ARGS=1      # fails an assertion and traps (exit 133)
make soundness-sweep       # INT_MIN, -1, 0, 1, INT_MAX
make reduce-soundness      # shrink the failing program
```

### Bug found

The transfer tables for `add`, `sub`, and `mul` model mathematical integers and
ignore wraparound. For `(x & 0x7fffffff) + 0x7fffffff` the analysis proves the
result `positive`, but with `x = 1` it is `INT_MIN`, and the instrumented
program reports:

```
Sign assertion failed in @f
  %16 = llvm.add %8, %0 overflow<nuw> : i32
  expected: positive
  actual: -2147483648
```

This bug was present in the analysis unintentionally; none had to be inserted.
The `overflow<nuw>` flag does not help, since it only rules out unsigned wrap.

## Layout

| File                           | Purpose                                                                   |
| ------------------------------ | ------------------------------------------------------------------------- |
| `Makefile`                     | Build, test, reduction, and soundness-checking targets                    |
| `SignedDomain.h`               | Lattice and join                                                          |
| `SignedAnalysis.{h,cpp}`       | Transfer functions and MLIR sparse-analysis glue                          |
| `Annotate.{h,cpp}`             | Prints IR with per-value comments                                         |
| `Instrumentation.{h,cpp}`      | Inserts runtime sign checks for the `instrument` option                   |
| `Plugin.cpp`                   | The pass and `mlir-opt` plugin entry point                                |
| `test/`, `cmake/RunTest.cmake` | Test input, expected facts, and runner                                    |
| `reductions/`                  | `llvm-reduce` inputs, interestingness tests, and reduced outputs          |
| `soundness/`                   | Program, interestingness script, and generated files for dynamic checking |
