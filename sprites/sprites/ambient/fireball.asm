includefrom "ambient_list.asm"
!ambient_fireball_ix = $3D

%alloc_ambient_sprite_grav(!ambient_fireball_ix, "fireball", fireballz, !ambient_twk_check_offscr|!ambient_twk_has_grav, $04, $30)

%set_free_start("bank2_altspr1")
; todo sprite interaction! the last piece of the puzzle...
fireballz:
	lda !ambient_misc_2,x
	and #$000C
	lsr
	tay
	lda .props,y
	sta !ambient_props,x
	jsr ambient_basic_gfx
	lda !ambient_sprlocked_mirror
	bne .exit
	inc !ambient_misc_2,x
	jsr ambient_physics
	jsr ambient_obj_interact
	bcc .exit
	inc !ambient_misc_1,x
	lda !ambient_misc_1,x
	and #$00FF
	cmp #$0002
	bcs .kill_to_smoke
	lda.w #$D000
	sta !ambient_y_speed,x
	bra .exit_no_obji_fc
.exit:
	lda !ambient_misc_1,x
	and #$FF00
	sta !ambient_misc_1,x
.exit_no_obji_fc:
	lda $0e
	beq .exit_real
	dec !ambient_playerfireballs
.exit_real:
	rts

.kill_to_smoke:
	rep #$20
	dec !ambient_playerfireballs
	lda #ambient_initer
	sta !ambient_rt_ptr,x
	lda #$0100
	sta !ambient_misc_1,x
	lda #$0008
	sta !ambient_gen_timer,x
	rts
; todo
.props:	
	dw $042C,$042D
	dw $C42C,$C42D
fireballz_done:
%set_free_finish("bank2_altspr1", fireballz_done)
