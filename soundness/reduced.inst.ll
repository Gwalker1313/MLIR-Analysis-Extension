; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:o-n32:64-S128-Fn32-p270:32:32:32:32-p271:32:32:32:32-p272:64:64:64:64-i64:64-i128:128-p0:64:64:64:64-i1:8-i8:8-i16:16-i32:32-f16:16-f64:64-f128:128"
target triple = "arm64-apple-macosx15.0.0"

@__sign_failure_message_2 = private constant [145 x i8] c"Sign assertion failed in @f\0A  %%16 = llvm.add %%0, %%8 : i32\0A  location: loc(\22soundness/reduced.mlir\22:5:10)\0A  expected: positive\0A  actual: %lld\0A\00"
@__sign_failure_message_1 = private constant [163 x i8] c"Sign assertion failed in @f\0A  %%8 = llvm.mlir.constant(2147483647 : i32) : i32\0A  location: loc(\22soundness/reduced.mlir\22:4:10)\0A  expected: positive\0A  actual: %lld\0A\00"
@__sign_failure_message_0 = private constant [154 x i8] c"Sign assertion failed in @f\0A  %%0 = llvm.mlir.constant(1 : i32) : i32\0A  location: loc(\22soundness/reduced.mlir\22:3:10)\0A  expected: positive\0A  actual: %lld\0A\00"

declare i32 @dprintf(i32, ptr, ...)

define i32 @f() {
  br i1 true, label %3, label %1

1:                                                ; preds = %0
  %2 = call i32 (i32, ptr, ...) @dprintf(i32 2, ptr @__sign_failure_message_0, i64 1)
  call void @llvm.trap()
  unreachable

3:                                                ; preds = %0
  br i1 true, label %6, label %4

4:                                                ; preds = %3
  %5 = call i32 (i32, ptr, ...) @dprintf(i32 2, ptr @__sign_failure_message_1, i64 2147483647)
  call void @llvm.trap()
  unreachable

6:                                                ; preds = %3
  br i1 false, label %9, label %7

7:                                                ; preds = %6
  %8 = call i32 (i32, ptr, ...) @dprintf(i32 2, ptr @__sign_failure_message_2, i64 -2147483648)
  call void @llvm.trap()
  unreachable

9:                                                ; preds = %6
  ret i32 -2147483648
}

define i32 @main() {
  %1 = call i32 @f()
  ret i32 %1
}

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #0

attributes #0 = { cold noreturn nounwind memory(inaccessiblemem: write) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
