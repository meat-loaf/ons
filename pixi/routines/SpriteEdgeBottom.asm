	LDA $09
	XBA
	LDA $01
	REP #$20
	STA $00
	SEP #$20
	LDA $0B
	XBA
	LDA $05
	STZ $08
	REP #$20
	CLC
	ADC $07
	SEC
	SBC $00
	CMP #$0006
	SEP #$20
	BPL .Fail
.Pass	SEC
	RTL
.Fail	CLC
	RTL