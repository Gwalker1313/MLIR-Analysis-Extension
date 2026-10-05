# LLVM reductions

Each reduced file ("reduction") consists of an original LLVM IR file
(`input#.ll`), it's reduced form (`reduced#.ll`), a respective
"interestingness" test (`test#.sh`), and a reduced result
(`reduced#.mlir`).

The aforementioned tests per input program preserve the following
dataflow chains:

1. an unknown argument is masked to a nonnegative value, propagated through
   addition to a positive value, and multiplied by a negative constant to
   prove a negative result;
2. an unknown argument is masked with a positive constant, proving the result
   nonnegative;
3. a zero constant is multiplied by an unknown argument, proving the product
   zero regardless of the argument's value.

Each part (testing, reducing, regenerating) can be run from the repository
root with the following, after building the plugin:


```sh
# If on macOS, then first run the following with Homebrew:
export PATH="$(brew --prefix llvm)/bin:$PATH"

# Confirm all original inputs are interesting (interesting inputs print 0)
for n in 1 2 3; do
  ./reductions/test$n.sh reductions/input$n.ll; echo "input$n: $?"
done

# Run any single reduction (case 1 as an example below)
n=1
llvm-reduce --test=$PWD/reductions/test$n.sh \
            -o reductions/reduced$n.ll reductions/input$n.ll
mlir-translate --import-llvm reductions/reduced$n.ll -o reductions/reduced$n.mlir

# Regenerate all three reduced#.mlir files
for n in 1 2 3; do
  llvm-reduce --test=$PWD/reductions/test$n.sh \
              -o reductions/reduced$n.ll reductions/input$n.ll
  mlir-translate --import-llvm reductions/reduced$n.ll -o reductions/reduced$n.mlir
done
```

An interestingness test must exit with status `0` when its input is
interesting. Each script converts the candidate LLVM IR to MLIR with
`mlir-translate`, runs the sign analysis through `mlir-opt`, and searches the
annotated listing (written to stderr) with `grep -E`. A candidate that fails
to import or makes the plugin fail is rejected outright, so the reducer cannot
shrink the input into something that is not analyzable.

The patterns in each script are not input programs. They describe the
annotated operations that must remain. Each requires an operation that uses a
function argument (`%arg0`, which the analysis treats as unknown), so the
reducer cannot replace the example with an unrelated constant expression.
`test1.sh` goes further: a small `result_of` helper extracts the SSA name of
each matching result (for example `%2`), and the next link of the chain must
use that exact value as an operand. This keeps the `and`, `add`, and `mul`
connected rather than letting them become independent constant operations.

`llvm-reduce` writes an intermediate `reduced#.ll`; a separate
`mlir-translate --import-llvm` step then creates the required `reduced#.mlir`.
The `.ll` files are intermediate outputs and can be kept or excluded from Git.
