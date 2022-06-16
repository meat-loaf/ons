	STA $0B
	PHX
	LDA.l .cluster_oam,x
	TAY
	LDA !cluster_y_low,x
	STA $00
	SEC
	SBC $1C
	STA $06
	LDA !cluster_y_high,x
	STA $01
	LDA !cluster_x_low,x
	STA $02
	SEC
	SBC $1A
	STA $07
	LDA !cluster_x_high,x
	STA $03
	SBC $1B
	STA $08
	TYA
	LSR : LSR
	TAX
	LDA $0B
	BPL +
	LDA $0420|!addr,x
	AND #$02
+	STA $0420|!addr,x
	LDX #$00
	LDA $0200|!addr,y
	SEC
	SBC $07
	BPL +
	DEX
+	CLC
	ADC $02
	STA $04
	TXA
	ADC $03
	STA $05
	REP #$20
	LDA $04
	SEC
	SBC $1A
	CMP #$0100
	SEP #$20
	BCC +
	TYA
	LSR : LSR
	TAX
	LDA $0420|!addr,x
	ORA #$01
	STA $0420|!addr,x
+	PLX
	RTL
.cluster_oam
	db $40,$44,$48,$4C,$50,$54,$58,$5C,$60,$64,$68,$6C,$80,$84,$88,$8C,$B0,$B4,$B8,$BC