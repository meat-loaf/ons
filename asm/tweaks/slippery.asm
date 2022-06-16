incsrc "../main.asm"

;dispose of invert accumulator subroutine

org $0197DA : EOR #$FF : INC a
org $0197E1 : EOR #$FF : INC a
org $01C45C : EOR #$FF : INC a

;shift this up by two bytes, which is now freed due to above change
org $01804D
spr_slip_reloc:
	LDA !sprite_blocked_status,x
	BEQ .ret
	LDA $13
	AND #$03
	ORA !spr_sprite_slip_f,x
warnpc $018059
org $018072
.ret
	RTS

; remap subroutine calls to above
org $0189E3
	JSR spr_slip_reloc
org $018A5F
	JSR spr_slip_reloc
org $01E3C0
	JSR spr_slip_reloc

; this fits in place nicely with some small changes
org $0189C5
	LDA #$02
	LDY !spr_sprite_slip_f,x
	BEQ +
	LSR A
	NOP
+
	warnpc $0199CE
