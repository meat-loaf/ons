init:
	REP #$20
	LDA $94
	SEC : SBC #$0008
	STA $94
	SEP #$20
	RTL
main:
	LDA !levelasm_scratch_byte
	CMP #$02
	BCS .done
	LDX !num_sprites-$01
.loop
	LDA $9E,x
	CMP #$BF
	BNE .next
	LDA $167A,x
	ORA #$04
	STA $167A,x
	INC !levelasm_scratch_byte
.next
	DEX
	BPL .loop
.done
	RTL
