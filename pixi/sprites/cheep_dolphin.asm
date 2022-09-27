;=======================================================
; Cheep Cheep Dolphin Thing
; By Erik557
;=======================================================
; Description: A cheep-cheep that follows a pattern
; similar to an original game dolphin.
; Uses first extra bit: YES
; When clear, the fish will act like a vertical dolphin.
; Else, it will act like an horizontal one.
;=======================================================

print "INIT ", hex(cheep_dolphin_init)
print "MAIN ", hex(cheep_dolphin_main)

cheep_dolphin_main:
	; update animation frame
	LDA $14
	LSR #3
	AND #$01
	STA !1602,x
	; graphics
	JSL sub_spr_gfx_2_long|!bank

	LDA !14C8,x
	EOR #$08
	ORA $9D
	BNE cheep_dolphin_init
	LDY #$02
	%SubOffScreen()
	JSL $01801A|!bank
	JSL $018022|!bank
	LDA !AA,x
	BMI +
	CMP #$3F
	BCS .dontIncSpeed
+
	INC !AA,x
.dontIncSpeed
	TXA
	EOR $13
	LSR
	BCC +
	JSL $019138|!bank
+
	LDA !AA,x
	BMI .dontSetSpeed
	LDA !164A,x
	BEQ .dontSetSpeed
	LDA !AA,x
	BEQ .dontZeroSpeed
	SEC
	SBC #$08
	STA !AA,x
	BPL .dontZeroSpeed
	STZ !AA,x
.dontZeroSpeed
	LDA !extra_bits,x
	AND #$04
	BEQ .dontSetX
	LDA !AA,x
	BNE .dontSetSpeed
	LDA !C2,x
	AND #$01
	TAX
	LDA.l .XSpeeds,x
	LDX $15E9|!addr
	STA !B6,x
.dontSetX
	INC !C2,x
	LDA #$C0
	STA !AA,x
.dontSetSpeed
	LDA !C2,x
	AND #$01
	STA !157C,x
.interRet
	JML $01A7DC|!bank
.XSpeeds:
	db $E8,$18
cheep_dolphin_init:
	RTL
