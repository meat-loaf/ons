includefrom "remaps.asm"

!ball_n_chain_chain = $0C
!ball_n_chain_tile = $0E
!rotating_plat_ball = !brown_plat_ball_tile_num 

org $02D844|!bank
wood_plat_tiles:
	db !brown_plat_ball_tile_num
	db $86
	db $87
	db $88

; chain of ball 'n' chain
org $02D7A4|!bank
	db !ball_n_chain_chain

org $02D7AA|!bank
	db !rotating_plat_ball

org $02D7BB|!bank
;	JSR.w store_tile1_bank2
	STA $0302|!addr,y

;org $02D85F|!bank
;	JSR.w store_tile1_bank2

;org $02D754|!bank
;	JSR.w bnc_ball_draw_call_hijack

org $02D732|!bank
	JSL.l rot_plat_exbit_slip|!bank

org $02D74B|!bank
	JSR.w rot_plat_gfx_stuff|!bank

; TODO revisit this, perhaps overall better as a JML hijack?
org $02D848|!bank
; get draw info called by hijack
plat_gfx:
	LDX.b #$03
.loop:
	LDA.w wood_plat_tiles,x
	STA.w $0302|!addr,y
	LDA.b $00
	ADC.w $02D840|!bank,x
	STA.w $0300|!addr,y
	LDA.b $01
	STA.w $0301|!addr,y
	LDA.b $02
	STA.w $0303|!addr,y
	INY #4
	DEX
	BPL .loop
	LDX.w $15E9|!addr
	RTS
warnpc $02D870|!bank

; ball 'n' chain ball
; TODO the add can be inlined here, potentially. The time wasting routine at $02D800
; can probably be shortened by one byte (it oesnt account for the cycles wasted by
; the call itself...) and we can shove the tile offset here without the JSR
org $02D82B|!bank
	LDA.b #!ball_n_chain_tile
	JSR.w store_tile1_bank2
	NOP

org $02D7BE|!bank
	LDA.b $02

pullpc
rot_plat_exbit_slip:
	LDA   !spr_extra_bits,x
	AND.b #$04
	BEQ .noslip
	STA !mario_slip
.noslip:
	JML.l $00E2BD|!bank
pushpc
