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

# ---- Dynamic soundness checking ---------------------------------------------
# Source files live in soundness/; everything generated goes in soundness/out/.
SDIR := soundness
OUT  := $(SDIR)/out

$(OUT):
	mkdir -p $@

$(OUT)/prog.ll: $(SDIR)/prog.c | $(OUT)
	clang -O1 -g -fwrapv -S -emit-llvm -o $@ $<

$(OUT)/prog.mlir: $(OUT)/prog.ll
	mlir-translate --import-llvm $< -o $@

# `build` is order-only: make ensures the plugin exists without treating it as
# a reason to redo this step every time.
$(OUT)/prog.inst.mlir: $(OUT)/prog.mlir | build
	mlir-opt --load-pass-plugin=$(PLUGIN) \
	  --pass-pipeline='$(INSTRUMENT_PIPELINE)' \
	  $< -o $@ 2> $(OUT)/annotated.txt

$(OUT)/prog.inst.ll: $(OUT)/prog.inst.mlir
	mlir-translate --mlir-to-llvmir $< -o $@

$(OUT)/prog: $(OUT)/prog.inst.ll
	clang -Wno-override-module $< -o $@

soundness-build: $(OUT)/prog  ## Instrument soundness/prog.c and compile it

soundness: $(OUT)/prog  ## Run the instrumented program with ARGS (default 1)
	@./$(OUT)/prog $(ARGS); echo "exit: $$?"

soundness-sweep: $(OUT)/prog  ## Run it on edge values (EDGE_VALUES)
	@for x in $(EDGE_VALUES); do \
	  ./$(OUT)/prog $$x > /dev/null 2>&1; echo "x=$$x exit=$$?"; \
	done

# Reduced results are deliverables, so they live outside $(OUT).
reduce-soundness: $(OUT)/prog.ll | build  ## Reduce to a minimal failing case
	chmod +x $(SDIR)/reduce.sh
	llvm-reduce --test=$(CURDIR)/$(SDIR)/reduce.sh \
	  -o $(SDIR)/reduced.ll $(OUT)/prog.ll
	mlir-translate --import-llvm $(SDIR)/reduced.ll -o $(SDIR)/reduced.mlir

# ---- Cleanup ----------------------------------------------------------------
clean:  ## Remove generated intermediates (keeps sources, reduced results, and the plugin)
	rm -rf $(OUT)

distclean: clean  ## Also delete the build directory (the plugin)
	rm -rf $(BUILD)