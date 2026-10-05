; One zero seed flows through and, mul, sdiv, sub, add and icmp,
; and each result stays provably zero even though %x and %y are unknown.
declare i32 @opaque(i32)

; Noise.
define i32 @noise(i32 %a, i32 %b) {
entry:
  %t = xor i32 %a, %b
  %r = call i32 @opaque(i32 %t)
  ret i32 %r
}

define i32 @target(i32 %x, i32 %y) {
entry:
  %z0 = and  i32 0, %x            ; Zero & Top    -> zero
  %z1 = mul  i32 %y, %z0          ; Top * Zero    -> zero
  %z2 = sdiv i32 %z1, %x          ; Zero / Top    -> zero
  %z3 = sub  i32 %z2, %z0         ; Zero - Zero   -> zero
  %z4 = add  i32 %z3, %z1         ; Zero + Zero   -> zero
  %b  = icmp sgt i32 %z4, %z0     ; 0 > 0 is false -> zero
  %ext = zext i1 %b to i32        ; no rule        -> top
  %mix = add i32 %ext, %x         ; top
  ret i32 %mix
}