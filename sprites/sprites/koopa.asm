!koopa_sprnum = $04
!shell_sprnum = $05
!lame_parakoopa_sprnum = $06
!flyin_parakoopa_sprnum = $07

!koopa_is_winged_scr    = $45

!koopa_winged             = !sprite_misc_1528
!koopa_falling_last_frame = !sprite_misc_151c
!koopa_face_dir           = !sprite_misc_157c
!koopa_stays_on_ledges    = !sprite_misc_1594
!koopa_ani_frame          = !sprite_misc_1602
!koopa_jumping_over_shell = !sprite_misc_160e


!wing_out_tile = $EC
!wing_in_tile  = $FE

; todo reimplement the koopa wing gfx routine
; note - new sprites have walking parakoopas that stay on ledges,
;        the new version should account for this and not flare the wing
;        out for a frame in this case
; koopa wings
org $019E1C|!bank
	db !wing_in_tile, !wing_out_tile
	db !wing_in_tile, !wing_out_tile

%alloc_sprite(!koopa_sprnum, "koopas", koopa_init, koopa_main, 5, 0,\
	$10, $40, $00, $00, $02, $A0)
%alloc_sprite(!shell_sprnum, "koopa_shell", koopa_init_stun, koopa_main, 5, 0,\
	$10, $40, $00, $00, $02, $A0)
%alloc_sprite(!lame_parakoopa_sprnum, "lame_parakoopa", koopa_init, koopa_main, 3, 0,\
	$10, $40, $00, $00, $42, $B0)
%alloc_sprite(!flyin_parakoopa_sprnum, "flyin_parakoopa", koopa_init, koopa_main, 3, 0,\
	$10, $40, $00, $00, $52, $B0)

%alloc_sprite_sharedgfx_entry_9(!koopa_sprnum, $82,$A0,$82,$A2,$84,$A4,$8C,$8A,$8E)
%alloc_sprite_sharedgfx_entry_mirror(!shell_sprnum, !koopa_sprnum)
%alloc_sprite_sharedgfx_entry_mirror(!lame_parakoopa_sprnum, !koopa_sprnum)
%alloc_sprite_sharedgfx_entry_mirror(!flyin_parakoopa_sprnum, !koopa_sprnum)

%set_free_start("bank1_koopakids")
koopa_init_stun:
	; sprite init caller sets state to 08 before calling
	inc !sprite_status,x
koopa_init:
	ldy !spr_extra_bits,x
	lda .pals,y
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	cpy #$02
	bcc .exit
	inc !koopa_stays_on_ledges,x
.exit:
	jsr _spr_face_mario_rt
	rtl
.pals:
	; green, yellow, blue, red
	db $5*2,$2*2,$4*2,$3*2

koopa_gfx:
	; used as 'is parakoopa' scratch throughout sprite
	stz !koopa_is_winged_scr
	lda !sprite_num,x
	cmp #!koopa_sprnum
	beq .no_wings
	inc !koopa_is_winged_scr
.fly_entry:
	; todo port this routine, needs at least one fix
	jsr $9E28
.no_wings:
	; gfx
	lda !koopa_ani_frame,x
	lsr
	lda !sprite_y_low,x
	pha
	sbc #$0F
	sta !sprite_y_low,x
	lda !sprite_y_high,x
	pha
	sbc #$00
	sta !sprite_y_high,x
	jsr sub_spr_gfx_1
	pla
	sta !sprite_y_high,x
	pla
	sta !sprite_y_low,x
	rts

koopa_main:
	jsr koopa_gfx

	lda !sprites_locked
	bne .exit
	jsr _suboffscr0_bank1
	lda !koopa_is_winged_scr
	bne .ani_upd
	lda !koopa_falling_last_frame,x
	bne .no_ani_upd
.ani_upd:
	jsr _spr_set_ani_frame
.no_ani_upd:
	lda !sprite_blocked_status,x
	and #$08
	beq .not_blocked_top
	stz !sprite_speed_y,x
.not_blocked_top:
	ldy !koopa_face_dir,x
	lda !spr_extra_bits,x
	lsr
	bcc .not_fast
	iny #2
.not_fast:
	lda .speeds,y
	eor !sprite_slope,x
	asl
	lda .speeds,y
	bcc .slope_speed
	clc
	adc !sprite_slope,x
.slope_speed:
	sta !sprite_speed_x,x
	lda !sprite_blocked_status,x
	and #$04
	beq .airborne
	stz !koopa_jumping_over_shell,x
	stz !koopa_falling_last_frame,x
	jsr _set_some_y_spd
	lda !koopa_is_winged_scr
	beq .interact
	jsr _spr_jump_over_shell
	lda !sprite_speed_y,x
	bpl .interact
	inc !koopa_jumping_over_shell,x
	bra .interact

.airborne:
	lda !koopa_falling_last_frame,x
	bne .check_flip
	inc !koopa_falling_last_frame,x
.check_flip:
	and !koopa_stays_on_ledges,x
	beq .check_wings
	; only parakoopas jump over shells
	lda !koopa_jumping_over_shell,x
	bne .double_ani
	jsr _flip_sprite_dir
	bra .interact
.check_wings:
	lda !koopa_is_winged_scr
	beq .interact
	; double time
.double_ani:
	jsr _spr_set_ani_frame
.interact:
	jsr _sprspr_mario_spr_rt
	jsr _spr_upd_pos
	jsr _flip_if_side_blocked
.exit:
	rtl
.speeds:
	db $08,$F8,$0C,$F4

flyin_parakoopa_main:
	rtl
koopas_done:
%set_free_finish("bank1_koopakids", koopas_done)
