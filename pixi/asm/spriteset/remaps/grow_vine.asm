includefrom "remaps.asm"

!growvine_sprnum = $29

%replace_sprite_rt(!growvine_sprnum, _spr_inits_start, growing_vine_init)
%replace_sprite_rt(!growvine_sprnum, _spr_mains_start, growing_vine_main)

org spr_tweaker_1656_tbl+!growvine_sprnum
	db $00
org spr_tweaker_1662_tbl+!growvine_sprnum
	db $00
org spr_tweaker_166E_tbl+!growvine_sprnum
	db $3B
org spr_tweaker_167A_tbl+!growvine_sprnum
	db $82
org spr_tweaker_1686_tbl+!growvine_sprnum
	db $29
org spr_tweaker_190F_tbl+!growvine_sprnum
	db $40

; use jumpin' piranha plant tiles
;!gvoff #= read1(shared_spr_routines_tile_offset($4F))
org shared_spr_routines_tile_offset(!growvine_sprnum)
;	db !gvoff
	db $3A
;undef "gvoff"

; original routine
org $01C183|!bank
!growvine_block_spawn_timer = !1540
!growvine_ani_timer         = !1570
growing_vine_main:
	lda !sprite_level_props
	pha
	lda !growvine_block_spawn_timer,x
	cmp #$20
	bcc .still_in_block
	lda #$10
	sta !sprite_level_props
.still_in_block:
	jsr.w sub_spr_gfx_2
	pla
	sta !sprite_level_props
	lda !sprites_locked
	bne .exit
	jsr.w _spr_set_ani_frame
	lda #$F0
	sta !sprite_speed_y,x
	jsr.w _spr_upd_y_no_grav
	lda !growvine_block_spawn_timer,x
	cmp #$20
	bcs .check_spawn_vine
	jsr.w _spr_obj_interact
	lda !sprite_blocked_status,x
	bne .deleet
	lda !sprite_x_high,x
	bpl .check_spawn_vine
.deleet
	jmp.w $01AC80|!bank

.check_spawn_vine
	lda !sprite_y_low,x
	and #$0F
	bne .exit
	lda !sprite_x_low,x
	sta !block_xpos
	lda !sprite_x_high,x
	sta !block_xpos+1

	lda !sprite_y_low,x
	sta !block_ypos
	lda !sprite_y_high,x
	sta !block_ypos+1
	lda #$03
	sta !block_to_generate
	jsl write_item_memory
	jsl generate_block
.exit:
	rts
.done:
org growing_vine_main_exit
growing_vine_init:
	rts
warnpc $01C1EE|!bank
