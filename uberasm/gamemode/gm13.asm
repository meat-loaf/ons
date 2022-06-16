incsrc "../../asm/main.asm"

decompress_gfx_file = $0FF900|!bank

!decomp_buffer = $7F1500
init:
    STZ $10
-
    LDA $10
    BEQ -
    STZ $10

    STZ $4200
    LDA #$80
    STA $2100

    JSR SpriteSetHandler

    LDA #$81
    STA $4200
    RTL

SpriteSetHandler:
	PHP
	LDA !current_spriteset
	REP #$30
	AND #$00FF
	ASL : ASL : ASL : ASL
	TAY
	LDX #$0000
.Loop
	STZ $00
	LDA #$7F15
	STA $01
	LDA SpriteSetGFXList,y
	CMP #$007F
	BEQ .skip
	JSL decompress_gfx_file
	TXA
	XBA
	EOR #$7E00
	JSR UploadVRAMData
.skip
	INY : INY
	INX : INX
	CPX #$0010
	BCC .Loop
	PLP
	RTS



;NOTE: the VRAM uploads happen backwards, so the first item is the bottom-most (16 pixel high) row of SP4,
;NOTE: the second row is the second-bottom-most 16-pixel row, and so on.
SpriteSetGFXList:
	dw $007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F		; spriteset 00: none
	dw $007F,$007F,$010F,$0108,$010C,$010E,$0107,$010D		; spriteset 01: wiggler, volcano lotus, piranha plants, platforms, mega mole
	dw $007F,$007F,$010D,$0108,$010B,$010A,$0104,$0103		; spriteset 02: chargin, clappin chucks, cloud drop, platforms, piranha plants
	dw $007F,$007F,$007F,$010D,$0100,$0112,$0111,$0110		; spriteset 03: boos, big boo
	dw $007F,$007F,$007F,$0115,$0102,$0108,$0116,$010D		; spriteset 04: piranhas, forest falling leaves, fish, lakitu + hedgehog spiny, (todo: nippers)
	dw $007F,$007F,$007F,$007F,$007F,$0115,$0118,$010D		; spriteset 05: piranhas, pipes, pipe lakitu
	dw $007F,$007F,$010B,$010A,$0108,$0105,$0104,$0103		; spriteset 06: alternate of 02: +pitchin/kickin chucks, -piranha plants
;	dw $0080,$0081,$0082,$0083,$0099,$00A7,$00A4,$00A5		; spriteset 07
;	dw $007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F		; spriteset 08


UploadVRAMData:
	PHY
	PHP
	SEP #$10
	LDY #$80
	STY $2115
	STA $2116
	LDA #$1801
	STA $4300
	LDA.w #!decomp_buffer
	STA $4302
	LDY.b #!decomp_buffer>>16
	STY $4304
	;LDA $8D
	LDA #$0400
	STA $4305
	LDY #$01
	STY $420B
	PLP
	PLY
	RTS
