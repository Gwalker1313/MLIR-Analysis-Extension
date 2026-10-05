; Anding anything with a positive constant clears the sign bit,
; so the result is non-negative even though %x is unknown.
declare i32 @opaque(i32)

; Noise.
define i32 @noise(i32 %a) {
entry:
  %c = icmp slt i32 %a, 10
  br i1 %c, label %small, label %big
small:
  %s = call i32 @opaque(i32 %a)
  ret i32 %s
big:
  %b = shl i32 %a, 2
  ret i32 %b
}

define i32 @target(i32 %x, i32 %mask) {
entry:
  %m    = and i32 %x, 1023        ; Top & Pos  -> zero pos
  %neg1 = and i32 %x, -1          ; Top & Neg  -> top (unannotated)
  %same = and i32 %x, %mask       ; Top & Top  -> top (unannotated)
  %d    = add i32 %m, %same       ; top
  %e    = add i32 %d, %neg1       ; top
  ret i32 %e
}