	LDA #$14
	STA $01
	LDA $05
	SEC
	SBC $01
	ROL $00
	CMP $D3
	PHP
	LSR $00
	LDA $0B
	SBC #$00
	PLP
	SBC $D4
	BMI .Fail
.Pass	SEC
	RTL
.Fail	CLC
	RTL