includefrom "remaps.asm"

org $038734|!bank
lava_plat_tiles:
	db $00,$01,$00

org $03873A|!bank
grey_lava_plat:
	; get draw info
	JSR.w $03B760|!bank
	LDX.b #$02
.loop:
	LDA.b $00
	STA.w $0300|!addr,y
	CLC
	ADC.b #$10
	STA.b $00
	LDA.b $01
	STA.w $0301|!addr,y
	LDA.w lava_plat_tiles,x
	STA.w $0302|!addr,y
	LDA.w $038737|!bank,x
	ORA.b $64
	STA.w $0303|!addr,y
	INY   #4
	DEX
	BPL .loop
	LDX.w $15E9|!addr
	LDY.b #$02
	TYA
	JSL.l finish_oam_write
	RTS
warnpc $03876E|!bank
