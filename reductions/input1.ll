; The sign of %x is unknown, but the result of the mul is provably negative.
declare i32 @opaque(i32)

; Noise: nothing here is relevant to the property.
define i32 @noise(i32 %a, i32 %b) {
entry:
  %or = or i32 %a, %b
  %sh = shl i32 %or, 3
  %r = call i32 @opaque(i32 %sh)
  ret i32 %r
}

define i32 @target(i32 %x, i32 %y) {
entry:
  %low = and i32 %x, 255          ; Top & Pos        -> zero pos
  %pos = add i32 %low, 1          ; ZeroPos + Pos    -> pos
  %neg = sub i32 0, %pos          ; Zero - Pos       -> neg
  %m   = mul i32 %neg, %pos       ; Neg * Pos        -> neg
  %junk = xor i32 %y, %x          ; unhandled        -> top
  %out = add i32 %m, %junk        ; Neg + Top        -> top
  ret i32 %out
}