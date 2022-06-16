incsrc "../main.asm"

org $00F1F1
	JMP blocks

org $00FF93
blocks:
	LDA $04 : STA $57
	JSL $028752|!bank
	LDA $57 : CMP #$06
	BEQ +
	JSR $C00D
	SEP #$10
+
	JMP $F1F5
warnpc $00FFC0
print "bank 0 ends at $", pc
