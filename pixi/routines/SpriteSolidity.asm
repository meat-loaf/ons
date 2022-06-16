	%GetSpriteEdges()
	ASL
	TAX
	JMP (.ptr,x)

.ptr	dw .SprTop
	dw .SprSide
	dw .SprBottom
.SprTop
	LDX $15E9|!Base2
	LDA !154C,x
	CMP #$08
	BCC ?+
.return0
	CLC
	RTL
?+	LDA $7D
	BMI .return0
	LDA #$03
	STA !154C,x
	LDA #$01
	STA $1471|!Base2
	LDA #$00
	LDY !AA,x
	BMI ?+
	TYA
	CLC
	ADC #$08
	CMP #$70
	BMI ?+
	LDA #$70
?+	STA $7D
	LDA #$1D
	STA $01
	LDA $05
	SEC
	SBC $01
	ROL $00
	LDY $187A|!Base2
	BEQ ?+
	SEC
	SBC #$10
?+	STA $96
	PHP
	LSR $00
	LDA $0B
	SBC #$00
	CPY #$01
	BNE ?+
	SBC #$00
?+	PLP
	STA $97
	LDA !AA,x
	BPL ?+
	LDA $77
	AND #$08
	BEQ ?+
	LDA #$18
	STA !154C,x
	LDA #$80
	SEC
	RTL
?+	LDA $77
	AND #$03
	BNE .ridingspr
	LDA !B6,x
	BEQ .ridingspr
	LDA !9E,x
	CMP #$0A
	BEQ .ridingspr
	LDY #$00
	LDA $1491|!Base2
	BPL ?+
	DEY
?+	CLC
	ADC $94
	STA $94
	TYA
	ADC $95
	STA $95
.ridingspr
	LDA #$00
	SEC
	RTL
.return	CLC
	RTL
.SprSide
	LDX $15E9|!Base2
	LDA !154C,x
	BEQ ?+
	LDA #$08
	STA !154C,x
	CLC
	RTL
?+	JSR .PushMario
	LDA .bit,y
	SEC
	RTL
.bit	db $01,$02
.PushMario
	%SubHorzPos()
	LDA $77
	AND .bit,y
	BNE ?++
	STZ $7B
	LDA !B6,x
	BEQ ?+
	INY : INY
?+	TYA
	PHY
	ASL
	TAY
	REP #$20
	LDA $94
	CLC
	ADC .MarioXOffset,y
	STA $94
	SEP #$20
	PLY
	LDA #$03
	SEC
	RTS
?++	CLC
	RTS
.MarioXOffset
	dw $0001,$FFFF
	dw $0002,$FFFE
.SprBottom
	LDX $15E9|!Base2
	LDA $77
	AND #$04
	BEQ .no_crush
	LDA $7D
	BMI ?+
	LDA !AA,x
	BMI ?+
	JSR .PushMario
	LDA #$83
	SEC
	RTL
?+	LDA !154C,x
	BEQ ?+
	LDA #$08
	STA !154C,x
	CLC
	RTL
?+	JSR .PushMario
	BRA .setbit
.no_crush
	LDA $7D
	BMI ?+
	CMP !AA,x
	BPL .SprSide
?+	LDA !AA,x
	BMI .spr_up
	CLC
	ADC #$08
	BRA ?+
.spr_up	LDA #$10
?+	STA $7D
	LDA #$01
	STA $1DF9|!Base2
?++	LDA #$0C
	STA !154C,x
.setbit	LDA #$03
	SEC
	RTL