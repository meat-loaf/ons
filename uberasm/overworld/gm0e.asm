main:
	LDY #$44
	LDA #$50
	STA $0200,y
	STA $0201,y
	LDA #$E6
	STA $0202,y
	LDA #$06
	STA $0203,y
	TYA
	LSR
	LSR
	TAY
	LDA #$02
	;STA $0460,y
	STA $0420,y
	RTL
