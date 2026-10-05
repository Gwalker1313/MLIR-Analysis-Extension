
define i32 @target(i32 %x) {
entry:
  %low = and i32 %x, 1
  %pos = add i32 %low, 1
  %m = mul i32 -1, %pos
  ret i32 %m
}
