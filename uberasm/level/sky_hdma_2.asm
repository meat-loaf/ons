
;=======================================
; Mode 2 + Mode 0 COLDATA Gradient
; Channels: Red, Green, Blue
; Table Size: 221
; No. of Writes: 224
;
; Generated by GradientTool
;=======================================

; Set up the HDMA gradient.
; Uses HDMA channels 3 and 4.
init:
	REP   #$20 ; 16-bit A

	; Set transfer modes.
	LDA   #$3202
	STA   $4330 ; Channel 3
	LDA   #$3200
	STA   $4340 ; Channel 4

	; Point to HDMA tables.
	LDA   #sky_color_2_hdma_RedGreenTable
	STA   $4332
	LDA   #sky_color_2_hdma_BlueTable
	STA   $4342

	SEP   #$20 ; 8-bit A

	; Store program bank to $43x4.
	;PHK
	;PLA
	LDA.b #(init>>16)
	STA   $4334 ; Channel 3
	STA   $4344 ; Channel 4

	; Enable channels 3 and 4.
	LDA.b #%00011000
	TSB   $0D9F|!addr

	RTL

; --- HDMA Tables below this line ---
sky_color_2_hdma_RedGreenTable:
db $1A,$22,$42
db $05,$22,$43
db $03,$23,$43
db $08,$23,$44
db $08,$24,$45
db $03,$24,$46
db $05,$25,$46
db $06,$25,$47
db $02,$26,$47
db $08,$26,$48
db $07,$26,$49
db $01,$27,$49
db $07,$27,$4A
db $08,$27,$4B
db $08,$27,$4C
db $08,$27,$4D
db $08,$27,$4E
db $08,$27,$4F
db $07,$27,$50
db $08,$27,$51
db $08,$27,$52
db $08,$27,$53
db $03,$27,$54
db $04,$28,$54
db $01,$29,$54
db $02,$29,$55
db $04,$2A,$55
db $02,$2B,$55
db $01,$2B,$56
db $04,$2C,$56
db $02,$2D,$56
db $01,$2D,$57
db $03,$2E,$57
db $04,$2F,$57
db $02,$30,$57
db $02,$30,$58
db $04,$31,$58
db $04,$32,$58
db $02,$33,$58
db $01,$33,$59
db $04,$34,$59
db $0E,$35,$59
db $00

sky_color_2_hdma_BlueTable:
db $16,$83
db $05,$84
db $06,$85
db $05,$86
db $05,$87
db $05,$88
db $05,$89
db $05,$8A
db $06,$8B
db $05,$8C
db $06,$8D
db $0B,$8E
db $0C,$8F
db $0C,$90
db $0B,$91
db $0C,$92
db $0C,$93
db $0B,$94
db $0C,$95
db $0C,$96
db $13,$97
db $19,$98
db $00