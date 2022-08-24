incsrc "../main.asm"

; moons use item memory
org $00F31B|!bank
	INC.w !moon_counter
	JSL write_item_memory|!bank
	BRA moon_done
org $00F36B|!bank
moon_done:

org $00F1F1|!bank
	JMP blocks

org $00FF93|!bank
blocks:
	LDA $04 : STA $57
	JSL $028752|!bank
	LDA $57 : CMP #$06
	BEQ +
	JSR $C00D
	SEP #$10
+
	JMP $F1F5
warnpc $00FFC0|!bank
; print "bank 0 ends at $", pc
