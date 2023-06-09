includefrom "remaps.asm"


; NOTE: the brown plat ball tile is in the main spritesets.asm file.
; NOTE: look for the `brown_plat_ball_tile_num' define.

org $01C9BB|!bank
brown_chain_plat_tiles:
	db $86,$87,$87,$88

org $01C8F7|!bank
	STA.w $0302|!addr,y

org $01C7E9|!bank
	LDA.b #!brown_plat_ball_tile_num
	STA.w $0302|!bank,y
org $01C870|!bank
	LDA.b #!brown_plat_ball_tile_num
	STA.w $0302|!bank,y
org $01C8C6|!bank
	LDA.b #!brown_plat_ball_tile_num
	STA.w $0302|!bank,y

; extra bit set: spin at extra byte speed
; see spritesets.asm for implementations
org $01C785|!bank
	JMP.w brown_plat_speed
org $01CA8C|!bank
	JMP.w brown_exb_alt

; init sets different value for props
org $01C7EE|!bank
	LDA.b !brown_plat_props_scratch
org $01C875|!bank
	LDA.b !brown_plat_props_scratch
org $01C8CB|!bank
	LDA.b !brown_plat_props_scratch
org $01C8FA|!bank
	LDA.b !brown_plat_props_scratch
