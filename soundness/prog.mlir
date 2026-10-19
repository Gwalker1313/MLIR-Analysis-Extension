#di_basic_type = #llvm.di_basic_type<tag = DW_TAG_base_type, name = "char", sizeInBits = 8, encoding = DW_ATE_signed_char>
#di_basic_type1 = #llvm.di_basic_type<tag = DW_TAG_base_type, name = "int", sizeInBits = 32, encoding = DW_ATE_signed>
#di_file = #llvm.di_file<"prog.c" in "/Users/griffinwalker/Documents/Development/CS6475/assignments/HW3/MLIR-Analysis-Extension/soundness">
#di_subprogram = #llvm.di_subprogram<recId = distinct[0]<>, isRecSelf = true>
#di_subprogram1 = #llvm.di_subprogram<recId = distinct[1]<>, isRecSelf = true>
#tbaa_root = #llvm.tbaa_root<id = "Simple C/C++ TBAA">
#di_compile_unit = #llvm.di_compile_unit<id = distinct[2]<>, sourceLanguage = DW_LANG_C11, file = #di_file, producer = "Homebrew clang version 23.1.1", isOptimized = true, emissionKind = Full, nameTableKind = Apple>
#di_composite_type = #llvm.di_composite_type<tag = DW_TAG_array_type, baseType = #di_basic_type, sizeInBits = 32, elements = #llvm.di_subrange<count = 4 : i64>>
#di_derived_type = #llvm.di_derived_type<tag = DW_TAG_pointer_type, baseType = #di_basic_type, sizeInBits = 64>
#di_local_variable = #llvm.di_local_variable<scope = #di_subprogram, name = "x", file = #di_file, line = 4, arg = 1, type = #di_basic_type1>
#di_local_variable1 = #llvm.di_local_variable<scope = #di_subprogram, name = "a", file = #di_file, line = 6, type = #di_basic_type1>
#di_local_variable2 = #llvm.di_local_variable<scope = #di_subprogram1, name = "argc", file = #di_file, line = 10, arg = 1, type = #di_basic_type1>
#di_local_variable3 = #llvm.di_local_variable<scope = #di_subprogram1, name = "x", file = #di_file, line = 12, type = #di_basic_type1>
#di_subroutine_type = #llvm.di_subroutine_type<types = #di_basic_type1, #di_basic_type1>
#di_derived_type1 = #llvm.di_derived_type<tag = DW_TAG_pointer_type, baseType = #di_derived_type, sizeInBits = 64>
#di_global_variable = #llvm.di_global_variable<file = #di_file, line = 13, type = #di_composite_type, isLocalToUnit = true, isDefined = true>
#di_subprogram2 = #llvm.di_subprogram<recId = distinct[0]<>, id = distinct[3]<>, compileUnit = #di_compile_unit, scope = #di_file, name = "f", file = #di_file, line = 4, scopeLine = 5, subprogramFlags = "Definition|Optimized", type = #di_subroutine_type, retainedNodes = [#di_local_variable, #di_local_variable1]>
#tbaa_type_desc = #llvm.tbaa_type_desc<id = "omnipotent char", members = {<#tbaa_root, 0>}>
#di_global_variable_expression = #llvm.di_global_variable_expression<var = #di_global_variable, expr = <>>
#di_local_variable4 = #llvm.di_local_variable<scope = #di_subprogram2, name = "x", file = #di_file, line = 4, arg = 1, type = #di_basic_type1>
#di_local_variable5 = #llvm.di_local_variable<scope = #di_subprogram2, name = "a", file = #di_file, line = 6, type = #di_basic_type1>
#di_local_variable6 = #llvm.di_local_variable<scope = #di_subprogram1, name = "argv", file = #di_file, line = 10, arg = 2, type = #di_derived_type1>
#di_subroutine_type1 = #llvm.di_subroutine_type<types = #di_basic_type1, #di_basic_type1, #di_derived_type1>
#di_subprogram3 = #llvm.di_subprogram<recId = distinct[1]<>, id = distinct[4]<>, compileUnit = #di_compile_unit, scope = #di_file, name = "main", file = #di_file, line = 10, scopeLine = 11, subprogramFlags = "Definition|Optimized", type = #di_subroutine_type1, retainedNodes = [#di_local_variable2, #di_local_variable6, #di_local_variable3]>
#tbaa_type_desc1 = #llvm.tbaa_type_desc<id = "any pointer", members = {<#tbaa_type_desc, 0>}>
#di_local_variable7 = #llvm.di_local_variable<scope = #di_subprogram3, name = "argv", file = #di_file, line = 10, arg = 2, type = #di_derived_type1>
#di_local_variable8 = #llvm.di_local_variable<scope = #di_subprogram3, name = "argc", file = #di_file, line = 10, arg = 1, type = #di_basic_type1>
#di_local_variable9 = #llvm.di_local_variable<scope = #di_subprogram3, name = "x", file = #di_file, line = 12, type = #di_basic_type1>
#tbaa_type_desc2 = #llvm.tbaa_type_desc<id = "p1 omnipotent char", members = {<#tbaa_type_desc1, 0>}>
#tbaa_tag = #llvm.tbaa_tag<base_type = #tbaa_type_desc2, access_type = #tbaa_type_desc2, offset = 0>
module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>, llvm.ident = "Homebrew clang version 23.1.1", llvm.module_asm = [], llvm.target_triple = "arm64-apple-macosx15.0.0"} {
  llvm.mlir.global private unnamed_addr constant @".str"("%d\0A\00") {addr_space = 0 : i32, alignment = 1 : i64, dbg_exprs = [#di_global_variable_expression], dso_local}
  llvm.module_flags [#llvm.mlir.module_flag<max, "Dwarf Version", 5 : i32>, #llvm.mlir.module_flag<warning, "Debug Info Version", 3 : i32>, #llvm.mlir.module_flag<min, "PIC Level", 2 : i32>, #llvm.mlir.module_flag<max, "uwtable", 1 : i32>, #llvm.mlir.module_flag<max, "frame-pointer", 4 : i32>]
  llvm.func local_unnamed_addr @f(%arg0: i32 {llvm.noundef}) -> (i32 {llvm.range = #llvm.constant_range<i32, 2147483647, -1>}) attributes {frame_pointer = #llvm.framePointerKind<"non-leaf-no-reserve">, memory_effects = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none, errnoMem = none, targetMem0 = none, targetMem1 = none>, no_inline, no_unwind, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "ssp", ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "apple-m1"]], target_cpu = "apple-m1", target_features = #llvm.target_features<["+aes", "+altnzcv", "+ccdp", "+ccidx", "+ccpp", "+complxnum", "+crc", "+dit", "+dotprod", "+flagm", "+fp-armv8", "+fp16fml", "+fptoint", "+fullfp16", "+jsconv", "+lse", "+neon", "+pauth", "+perfmon", "+predres", "+ras", "+rcpc", "+rdm", "+sb", "+sha2", "+sha3", "+specrestrict", "+ssbs", "+v8.1a", "+v8.2a", "+v8.3a", "+v8.4a", "+v8a"]>, tune_cpu = "apple-m5", uwtable_kind = #llvm.uwtableKind<sync>, will_return} {
    llvm.intr.dbg.value #di_local_variable4 = %arg0 : i32
    %0 = llvm.mlir.constant(2147483647 : i32) : i32
    %1 = llvm.and %arg0, %0 : i32
    llvm.intr.dbg.value #di_local_variable5 = %1 : i32
    %2 = llvm.add %1, %0 overflow<nuw> : i32
    llvm.return %2 : i32
  }
  llvm.func local_unnamed_addr @main(%arg0: i32 {llvm.noundef}, %arg1: !llvm.ptr {llvm.nocapture, llvm.nofree, llvm.noundef, llvm.readonly}) -> (i32 {llvm.noundef}) attributes {frame_pointer = #llvm.framePointerKind<"non-leaf-no-reserve">, no_unwind, passthrough = ["nofree", "ssp", ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "apple-m1"]], target_cpu = "apple-m1", target_features = #llvm.target_features<["+aes", "+altnzcv", "+ccdp", "+ccidx", "+ccpp", "+complxnum", "+crc", "+dit", "+dotprod", "+flagm", "+fp-armv8", "+fp16fml", "+fptoint", "+fullfp16", "+jsconv", "+lse", "+neon", "+pauth", "+perfmon", "+predres", "+ras", "+rcpc", "+rdm", "+sb", "+sha2", "+sha3", "+specrestrict", "+ssbs", "+v8.1a", "+v8.2a", "+v8.3a", "+v8.4a", "+v8a"]>, tune_cpu = "apple-m5", uwtable_kind = #llvm.uwtableKind<sync>} {
    llvm.intr.dbg.value #di_local_variable7 = %arg1 : !llvm.ptr
    llvm.intr.dbg.value #di_local_variable8 = %arg0 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : i64) : i64
    %2 = llvm.mlir.addressof @".str" : !llvm.ptr
    %3 = llvm.mlir.constant(0 : i32) : i32
    %4 = llvm.icmp "sgt" %arg0, %0 : i32
    llvm.cond_br %4, ^bb1, ^bb2(%0 : i32)
  ^bb1:  // pred: ^bb0
    %5 = llvm.getelementptr inbounds|nuw %arg1[%1] : (!llvm.ptr, i64) -> !llvm.ptr, i8
    %6 = llvm.load %5 {alignment = 8 : i64, tbaa = [#tbaa_tag]} : !llvm.ptr -> !llvm.ptr
    %7 = llvm.call tail @atoi(%6) {memory_effects = #llvm.memory_effects<other = read, argMem = read, inaccessibleMem = read, errnoMem = read, targetMem0 = read, targetMem1 = read>} : (!llvm.ptr {llvm.noundef}) -> i32
    llvm.br ^bb2(%7 : i32)
  ^bb2(%8: i32):  // 2 preds: ^bb0, ^bb1
    llvm.intr.dbg.value #di_local_variable9 = %8 : i32
    %9 = llvm.call tail @f(%8) {memory_effects = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none, errnoMem = none, targetMem0 = none, targetMem1 = none>} : (i32 {llvm.noundef}) -> i32
    %10 = llvm.call tail @printf(%2, %9) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr {llvm.dereferenceable = 1 : i64, llvm.nonnull, llvm.noundef}, i32 {llvm.noundef}) -> i32
    llvm.return %3 : i32
  }
  llvm.func local_unnamed_addr @atoi(!llvm.ptr {llvm.nocapture, llvm.noundef}) -> i32 attributes {frame_pointer = #llvm.framePointerKind<"non-leaf-no-reserve">, memory_effects = #llvm.memory_effects<other = read, argMem = read, inaccessibleMem = read, errnoMem = read, targetMem0 = read, targetMem1 = read>, no_unwind, nocallback, passthrough = ["mustprogress", "nofree", "nosync", ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "apple-m1"]], target_cpu = "apple-m1", target_features = #llvm.target_features<["+aes", "+altnzcv", "+ccdp", "+ccidx", "+ccpp", "+complxnum", "+crc", "+dit", "+dotprod", "+flagm", "+fp-armv8", "+fp16fml", "+fptoint", "+fullfp16", "+jsconv", "+lse", "+neon", "+pauth", "+perfmon", "+predres", "+ras", "+rcpc", "+rdm", "+sb", "+sha2", "+sha3", "+specrestrict", "+ssbs", "+v8.1a", "+v8.2a", "+v8.3a", "+v8.4a", "+v8a"]>, tune_cpu = "apple-m5", will_return}
  llvm.func local_unnamed_addr @printf(!llvm.ptr {llvm.nocapture, llvm.noundef, llvm.readonly}, ...) -> (i32 {llvm.noundef}) attributes {frame_pointer = #llvm.framePointerKind<"non-leaf-no-reserve">, no_unwind, passthrough = ["nofree", ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "apple-m1"]], target_cpu = "apple-m1", target_features = #llvm.target_features<["+aes", "+altnzcv", "+ccdp", "+ccidx", "+ccpp", "+complxnum", "+crc", "+dit", "+dotprod", "+flagm", "+fp-armv8", "+fp16fml", "+fptoint", "+fullfp16", "+jsconv", "+lse", "+neon", "+pauth", "+perfmon", "+predres", "+ras", "+rcpc", "+rdm", "+sb", "+sha2", "+sha3", "+specrestrict", "+ssbs", "+v8.1a", "+v8.2a", "+v8.3a", "+v8.4a", "+v8a"]>, tune_cpu = "apple-m5"}
}
