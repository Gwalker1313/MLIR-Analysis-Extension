
define i32 @target(i32 %x) {
entry:
  %m = and i32 %x, 1
  ret i32 %m
}
