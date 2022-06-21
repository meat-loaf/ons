
init:
; gradient
	REP #$20
	LDA #$3200
	STA $4330
	LDA #.RedTable
	STA $4332
	LDY.b #.RedTable>>16
	STY $4334
	LDA #$3200
	STA $4340
	LDA #.GreenTable
	STA $4342
	LDY.b #.GreenTable>>16
	STY $4344
	LDA #$3200
	STA $4350
	LDA #.BlueTable
	STA $4352
	LDY.b #.BlueTable>>16
	STY $4354

	LDA.w #$3100
	STA.w $4360
	LDA.w #.color_math_table
	STA.w $4362
	LDY.b #.color_math_table>>16
	STY.w $4364

	SEP #$20

	LDA #%01111000
;	LDA #%00111000
	TSB $0D9F|!addr

	RTL

; scanline count, then data
.color_math_table
	db $80, %00100000
	db $3F, %00100000
;	db $21, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $01, %00100000
	db $01, %00110011
	db $00

.RedTable:           ;
   db $05 : db $2D   ;
   db $08 : db $2E   ;
   db $09 : db $2F   ;
   db $09 : db $30   ;
   db $08 : db $31   ;
   db $07 : db $32   ;
   db $05 : db $33   ;
   db $05 : db $34   ;
   db $09 : db $35   ;
   db $09 : db $36   ;
   db $08 : db $37   ;
   db $09 : db $38   ;
   db $06 : db $39   ;
   db $06 : db $3A   ;
   db $05 : db $3B   ;
   db $09 : db $3C   ;
   db $08 : db $3D   ;
   db $12 : db $3E   ;
   db $50 : db $3F   ;
   db $01 : db $3E   ;
   db $00            ;

.GreenTable:         ;
   db $5B : db $4A   ;
   db $09 : db $4B   ;
   db $08 : db $4C   ;
   db $11 : db $4D   ;
   db $09 : db $4E   ;
   db $09 : db $4F   ;
   db $08 : db $50   ;
   db $09 : db $51   ;
   db $11 : db $52   ;
   db $09 : db $53   ;
   db $08 : db $54   ;
   db $09 : db $55   ;
   db $09 : db $56   ;
   db $08 : db $57   ;
   db $03 : db $58   ;
   db $01 : db $57   ;
   db $00            ;

.BlueTable:          ;
   db $01 : db $92   ;
   db $04 : db $93   ;
   db $11 : db $92   ;
   db $11 : db $91   ;
   db $12 : db $90   ;
   db $08 : db $8F   ;
   db $11 : db $8E   ;
   db $09 : db $8F   ;
   db $11 : db $90   ;
   db $70 : db $91   ;
   db $04 : db $92   ;
   db $00            ;
