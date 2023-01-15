!turning_turn_block_ambient_id = $03
!question_block_ambient_id     = $04

%alloc_ambient_sprite_grav(!turning_turn_block_ambient_id, "turning_turn_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)

%alloc_ambient_sprite_grav(!question_block_ambient_id, "question_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)

; TODO sprit einteraction
%set_free_start("bank2_altspr2")
ambient_spawn_block:
	sta $9C
	lda !ambient_y_pos,x
	and #$FFF0
	sta !block_ypos
	lda !ambient_x_pos,x
	and #$FFF0
	sta !block_xpos
	; todo handle being on layer 2
	jsl generate_tile
	rts

ambient_bounce_spr:
	lda !ambient_misc_1,x
	bit #$0002
	bne .nogfx
	xba
	and #$00FF
	asl
	tay
	lda .block_tile-(!turning_turn_block_ambient_id*2),y
	sta !ambient_props,x
	jsr ambient_basic_gfx
.nogfx:
	lda !ambient_sprlocked_mirror
	bne .phases_do_bounce_exit
	lda !ambient_misc_1,x
	and #$00FF
	asl
	tay
	lda .phases,y
	sta $00
	jmp ($0000)
.block_draw_death:
	dw $0005,$000D
.block_tile:
	dw $00C4,$00C0
.phases:
	dw ..spawn_solid
	dw ..do_bounce
	dw ..write_block_die
; in 9C format
; todo use a different routine (port gps' or something), for other block
;      kinds.
..spawn_solid:
	; todo interact with sprites here
	inc !ambient_misc_1,x
	lda #$0009
	jmp ambient_spawn_block
..do_bounce:
	lda !ambient_gen_timer,x
	bne ...exit
	inc !ambient_misc_1,x
...exit:
	rts
..write_block_die:
	lda !ambient_misc_1+1,x
	and #$00FF
	asl
	tay
	lda .block_draw_death-($3*2),y
	; todo handle spinning turn block
	stz !ambient_rt_ptr,x
	jmp ambient_spawn_block

ambient_bounce_done:
%set_free_finish("bank2_altspr2", ambient_bounce_done)
