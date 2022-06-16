;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cluster GetDrawInfo v0.8

	LDA.l .OAMSlots,x
	TAY

	LDA !cluster_x_low,x
	SEC
	SBC $1A
	STA $00
	LDA !cluster_x_high,x
	SBC $1B
	STA $01

	LDA !cluster_y_low,x
	SEC
	SBC $1C
	STA $05
	LDA !cluster_y_high,x
	SBC $1D
	STA $06
	REP #$21
	LDA $00
	ADC #$0040
	CMP #$0180
	BCS .KillSpr
	LDA $05
	ADC #$0030
	CMP #$0160
	BCC +
.KillSpr
	SEP #$20
	LDA #$F0
	STA $05
	STZ !cluster_num,x
	RTL

+	LDA $00
	ADC #$0010
	CMP #$0110
	BCS .HideSpr
	LDA $05
	ADC #$0010
	CMP #$0100
	BCC +
.HideSpr
	SEP #$20
	LDA #$F0
	STA $05
+	SEP #$20
	LDA !cls_spriteset_off,x
	STA !tile_off_scratch
	RTL
.OAMSlots
   db $40,$44,$48,$4C,$50,$54,$58,$5C,$60,$64,$68,$6C,$80,$84,$88,$8C,$B0,$B4,$B8,$BC
