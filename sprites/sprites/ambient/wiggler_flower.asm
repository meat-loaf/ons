
!ambient_wiggler_flower_id = $02
%alloc_ambient_sprite(!ambient_wiggler_flower_id, "wiggler_flower", wiggler_flower_main, \
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_twk_check_offscr)


%set_free_start("bank2_altspr2")
skip 1
wiggler_flower_main:
	lda !ambient_gen_timer,x
	bne .no_inv
	sep #$20
	lda !ambient_x_speed+1,x
	eor #$FF
	inc
	sta !ambient_x_speed+1,x
	lda #$08
	sta !ambient_gen_timer,x
	rep #$20
.no_inv:
	lda !sprite_level_props-1
	and #$FF00
	ora #$01ff
	sta !ambient_props,x
	jmp ambient_basic_gfx
wiggler_flower_done:
%set_free_finish("bank2_altspr2", wiggler_flower_done)