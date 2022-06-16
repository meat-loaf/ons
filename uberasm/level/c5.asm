init:
	REP #$20
	LDA $94
	CLC : ADC #$0008
	STA $94
	SEP #$20
main:
	STZ $15 : STZ $16
	STZ $17 : STZ $18
	RTL
