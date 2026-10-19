target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

define i32 @f() {
  %1 = add i32 1, 2147483647
  ret i32 %1
}

define i32 @main() {
  %1 = call i32 @f()
  ret i32 %1
}
