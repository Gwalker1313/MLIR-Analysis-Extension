; ModuleID = 'prog.c'
source_filename = "prog.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1, !dbg !0

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define range(i32 2147483647, -1) i32 @f(i32 noundef %0) local_unnamed_addr #0 !dbg !21 {
    #dbg_value(i32 %0, !26, !DIExpression(), !28)
  %2 = and i32 %0, 2147483647, !dbg !29
    #dbg_value(i32 %2, !27, !DIExpression(), !28)
  %3 = add nuw i32 %2, 2147483647, !dbg !30
  ret i32 %3, !dbg !31
}

; Function Attrs: nofree nounwind ssp uwtable(sync)
define noundef i32 @main(i32 noundef %0, ptr nofree noundef readonly captures(none) %1) local_unnamed_addr #1 !dbg !32 {
    #dbg_value(i32 %0, !38, !DIExpression(), !41)
    #dbg_value(ptr %1, !39, !DIExpression(), !41)
  %3 = icmp sgt i32 %0, 1, !dbg !42
  br i1 %3, label %4, label %8, !dbg !43

4:                                                ; preds = %2
  %5 = getelementptr inbounds nuw i8, ptr %1, i64 8, !dbg !44
  %6 = load ptr, ptr %5, align 8, !dbg !44, !tbaa !45
  %7 = tail call i32 @atoi(ptr noundef %6), !dbg !48
  br label %8, !dbg !49

8:                                                ; preds = %2, %4
  %9 = phi i32 [ %7, %4 ], [ 1, %2 ], !dbg !50
    #dbg_value(i32 %9, !40, !DIExpression(), !41)
  %10 = tail call i32 @f(i32 noundef %9), !dbg !51
  %11 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str, i32 noundef %10), !dbg !52
  ret i32 0, !dbg !53
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(read)
declare !dbg !54 i32 @atoi(ptr noundef captures(none)) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare !dbg !60 noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #3

attributes #0 = { mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nofree nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(read) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { nofree nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!7, !8, !9, !10, !11, !12}
!llvm.dbg.cu = !{!13}
!llvm.ident = !{!15}
!llvm.errno.tbaa = !{!16}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 13, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "prog.c", directory: "/Users/griffinwalker/Documents/Development/CS6475/assignments/HW3/MLIR-Analysis-Extension/soundness", checksumkind: CSK_MD5, checksum: "c3ab3d3d80e8acd6d685ff227a7d5310")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 32, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 4)
!7 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 5]}
!8 = !{i32 7, !"Dwarf Version", i32 5}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{i32 8, !"PIC Level", i32 2}
!11 = !{i32 7, !"uwtable", i32 1}
!12 = !{i32 7, !"frame-pointer", i32 4}
!13 = distinct !DICompileUnit(language: DW_LANG_C11, file: !2, producer: "Homebrew clang version 23.1.1", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, globals: !14, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk", sdk: "MacOSX15.sdk")
!14 = !{!0}
!15 = !{!"Homebrew clang version 23.1.1"}
!16 = !{!17, !18, i64 0}
!17 = !{!"__libc_errno", !18, i64 0}
!18 = !{!"int", !19, i64 0}
!19 = !{!"omnipotent char", !20, i64 0}
!20 = !{!"Simple C/C++ TBAA"}
!21 = distinct !DISubprogram(name: "f", scope: !2, file: !2, line: 4, type: !22, scopeLine: 5, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !13, retainedNodes: !25, keyInstructions: true)
!22 = !DISubroutineType(types: !23)
!23 = !{!24, !24}
!24 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!25 = !{!26, !27}
!26 = !DILocalVariable(name: "x", arg: 1, scope: !21, file: !2, line: 4, type: !24)
!27 = !DILocalVariable(name: "a", scope: !21, file: !2, line: 6, type: !24)
!28 = !DILocation(line: 0, scope: !21)
!29 = !DILocation(line: 6, column: 15, scope: !21, atomGroup: 1, atomRank: 2)
!30 = !DILocation(line: 7, column: 14, scope: !21, atomGroup: 3, atomRank: 2)
!31 = !DILocation(line: 7, column: 5, scope: !21, atomGroup: 3, atomRank: 1)
!32 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 10, type: !33, scopeLine: 11, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !13, retainedNodes: !37, keyInstructions: true)
!33 = !DISubroutineType(types: !34)
!34 = !{!24, !24, !35}
!35 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !36, size: 64)
!36 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4, size: 64)
!37 = !{!38, !39, !40}
!38 = !DILocalVariable(name: "argc", arg: 1, scope: !32, file: !2, line: 10, type: !24)
!39 = !DILocalVariable(name: "argv", arg: 2, scope: !32, file: !2, line: 10, type: !35)
!40 = !DILocalVariable(name: "x", scope: !32, file: !2, line: 12, type: !24)
!41 = !DILocation(line: 0, scope: !32)
!42 = !DILocation(line: 12, column: 18, scope: !32, atomGroup: 2, atomRank: 2)
!43 = !DILocation(line: 12, column: 13, scope: !32, atomGroup: 2, atomRank: 1)
!44 = !DILocation(line: 12, column: 29, scope: !32)
!45 = !{!46, !46, i64 0}
!46 = !{!"p1 omnipotent char", !47, i64 0}
!47 = !{!"any pointer", !19, i64 0}
!48 = !DILocation(line: 12, column: 24, scope: !32)
!49 = !DILocation(line: 12, column: 13, scope: !32)
!50 = !DILocation(line: 12, column: 13, scope: !32, atomGroup: 1, atomRank: 2)
!51 = !DILocation(line: 13, column: 20, scope: !32)
!52 = !DILocation(line: 13, column: 5, scope: !32)
!53 = !DILocation(line: 14, column: 5, scope: !32, atomGroup: 4, atomRank: 1)
!54 = !DISubprogram(name: "atoi", scope: !55, file: !55, line: 150, type: !56, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!55 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk/usr/include/_stdlib.h", directory: "", checksumkind: CSK_MD5, checksum: "17a3e5580239ce2f2af260c9c943ad9b")
!56 = !DISubroutineType(types: !57)
!57 = !{!24, !58}
!58 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !59, size: 64)
!59 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4)
!60 = !DISubprogram(name: "printf", scope: !61, file: !61, line: 34, type: !62, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!61 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk/usr/include/_printf.h", directory: "", checksumkind: CSK_MD5, checksum: "2d37517bd0342aa326aa1d3660ad4ab4")
!62 = !DISubroutineType(types: !63)
!63 = !{!24, !64, null}
!64 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !58)
