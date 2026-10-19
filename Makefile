# Makefile for the MLIR sign-analysis plugin.
# Run `make help` for a list of targets.

# ---- Configuration (override on the command line, e.g. make run INPUT=x.mlir)
BUILD      ?= build
PASS       ?= zero-analysis     # must match getArgument() in Plugin.cpp
INPUT      ?= test/zero.mlir    # file for `make run`
ARGS       ?= 1                 # argument passed to the instrumented program
EDGE_VALUES ?= -2147483648 -1 0 1 2147483647

# Prefer Homebrew's LLVM when present, so clang, mlir-opt, mlir-translate and
# llvm-reduce all come from the same version the plugin is built against.
LLVM_PREFIX := $(shell brew --prefix llvm 2>/dev/null)
ifneq ($(LLVM_PREFIX),)
export PATH := $(LLVM_PREFIX)/bin:$(PATH)
endif
CMAKE_ARGS ?= $(if $(LLVM_PREFIX),-DMLIR_DIR=$(LLVM_PREFIX)/lib/cmake/mlir -DLLVM_DIR=$(LLVM_PREFIX)/lib/cmake/llvm)

# Plugin path: .dylib on macOS, .so on Linux. Recursively expanded (=) so it is
# looked up after the build has produced it.
PLUGIN = $(firstword $(wildcard $(BUILD)/SignedAnalysis.dylib $(BUILD)/SignedAnalysis.so))
MLIR_OPT_PIPELINE = builtin.module($(PASS))
INSTRUMENT_PIPELINE = builtin.module($(PASS){instrument=true})

REDUCE_TARGETS := reduce1 reduce2 reduce3

.DEFAULT_GOAL := help
.PHONY: help build test run check-reductions $(REDUCE_TARGETS) reduce-all \
        soundness soundness-build soundness-sweep reduce-soundness clean distclean

help:  ## Show this list
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | \
	  sed -E 's/:.*## /\t/' | column -t -s "$$(printf '\t')"

# ---- Build and test --------------------------------------------------------
$(BUILD)/CMakeCache.txt:
	cmake -S . -B $(BUILD) $(CMAKE_ARGS)

build: $(BUILD)/CMakeCache.txt  ## Configure (first time) and build the plugin
	cmake --build $(BUILD)

test: build  ## Run the ctest suite
	ctest --test-dir $(BUILD) --output-on-failure

run: build  ## Print the annotated listing for INPUT (default test/zero.mlir)
	mlir-opt --load-pass-plugin=$(PLUGIN) --pass-pipeline='$(MLIR_OPT_PIPELINE)' \
	  $(INPUT) -o /dev/null 2>&1 1>/dev/null

# ---- llvm-reduce (reductions/) ---------------------------------------------
check-reductions: build  ## Confirm all three original inputs are interesting
	@for n in 1 2 3; do \
	  if ./reductions/test$$n.sh reductions/input$$n.ll; then \
	    echo "input$$n: interesting"; \
	  else \
	    echo "input$$n: NOT interesting"; exit 1; \
	  fi; \
	done

$(REDUCE_TARGETS): reduce%: build  ## reduce1 / reduce2 / reduce3: run one reduction
	llvm-reduce --test=$(CURDIR)/reductions/test$*.sh \
	  -o reductions/reduced$*.ll reductions/input$*.ll
	mlir-translate --import-llvm reductions/reduced$*.ll \
	  -o reductions/reduced$*.mlir

reduce-all: $(REDUCE_TARGETS)  ## Regenerate all three reducedN.mlir files

# ---- Dynamic soundness checking (soundness/) --------------------------------
# Pipeline: C -> LLVM IR -> MLIR -> instrumented MLIR -> LLVM IR -> executable.
# -fwrapv makes signed overflow defined, so a failed check means the analysis
# is unsound rather than the program having undefined behavior.
soundness-build: build  ## Instrument soundness/prog.c and compile it
	clang -O1 -g -fwrapv -S -emit-llvm -o soundness/prog.ll soundness/prog.c
	mlir-translate --import-llvm soundness/prog.ll -o soundness/prog.mlir
	mlir-opt --load-pass-plugin=$(PLUGIN) \
	  --pass-pipeline='$(INSTRUMENT_PIPELINE)' \
	  soundness/prog.mlir -o soundness/prog.inst.mlir 2> soundness/annotated.txt
	mlir-translate --mlir-to-llvmir soundness/prog.inst.mlir -o soundness/prog.inst.ll
	clang -Wno-override-module soundness/prog.inst.ll -o soundness/prog

soundness: soundness-build  ## Run the instrumented program with ARGS (default 1)
	@./soundness/prog $(ARGS); echo "exit: $$?"

soundness-sweep: soundness-build  ## Run it on edge values (EDGE_VALUES)
	@for x in $(EDGE_VALUES); do \
	  ./soundness/prog $$x > /dev/null 2>&1; echo "x=$$x exit=$$?"; \
	done

reduce-soundness: soundness-build  ## Reduce prog.ll to a minimal failing case
	chmod +x soundness/reduce.sh
	llvm-reduce --test=$(CURDIR)/soundness/reduce.sh \
	  -o soundness/reduced.ll soundness/prog.ll
	mlir-translate --import-llvm soundness/reduced.ll -o soundness/reduced.mlir

# ---- Cleanup -----------------------------------------------------------------
clean:  ## Remove generated soundness files and compiled objects, keep CMake config
	rm -f soundness/prog soundness/*.ll soundness/*.inst.mlir soundness/prog.mlir \
	      soundness/annotated.txt
	-cmake --build $(BUILD) --target clean

distclean: clean  ## Also delete the build directory
	rm -rf $(BUILD)