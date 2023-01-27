includefrom "ambient_list.asm"
!ambient_fireball_ix       = $3D
!ambient_fireball_enemy    = $3C
!ambient_fireball_enemy_ng = $3B


%alloc_ambient_sprite_grav(!ambient_fireball_ix, "fireball", fireballz, !ambient_twk_check_offscr|!ambient_twk_has_grav, $04, $30)
%alloc_ambient_sprite_grav(!ambient_fireball_enemy, "enemy_fireball", fireballz, !ambient_twk_check_offscr|!ambient_twk_has_grav, $04, $30)
%alloc_ambient_sprite(!ambient_fireball_enemy_ng, "enemy_fireball_nograv", fireballz, !ambient_twk_check_offscr)

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
	bne ambient_fb_checkobj_spr_exit_real
	inc !ambient_misc_2,x
	jsr ambient_physics
	lda !ambient_misc_1+1,x
	and #$00FF
	asl
	tay
	lda.w .interaction_rts-(!ambient_fireball_enemy_ng*2),y
	sta $02
	jmp ($0002)
.interaction_rts:
	dw ambient_fb_checkplayer
	dw ambient_fb_checkplayer
	dw ambient_fb_checkobj_spr
.props:	
	dw $042C,$042D
	dw $C42C,$C42D

ambient_fb_checkplayer:
	rts

print "ambient_fb_checkobj_spr: $", pc
ambient_fb_checkobj_spr:
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
fireballz_done:
%set_free_finish("bank2_altspr1", fireballz_done)
