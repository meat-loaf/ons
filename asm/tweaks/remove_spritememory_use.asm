incsrc "../main.asm"

; i think this routine is related to finding
; a sprite slot for yoshi during level load
org $00FC86|!bank
	BRA +
org $00FC8F|!bank
+

;org $0180D4|!bank
;	LDX.b #$00
;	NOP

; todo line rope code in bank 01

; gen sprite from block?
org $0288F2|!bank
	LDA.b #$00
	NOP

; load sprite from level
org $02A8E4|!bank
	LDY.b #$00
	NOP

; find free sprite slot
org $02A9EF|!bank
	LDY.b #$00
	NOP
