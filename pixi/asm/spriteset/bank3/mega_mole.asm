includefrom "remaps.asm"

!megamole_sprnum = $BF

;%alloc_spr(!megamole_sprnum, megamole_init, bank3_sprcaller,\
;	$8E, $0E, $75, $9B, $B9, $46)

%alloc_spr_nocfg(!megamole_sprnum, mega_mole_init, bank3_sprcaller)

!mega_mole_falling_timer = !1540
!mega_mole_ride_timer    = !154C
!mega_mole_ani_timer     = !1570
!mega_mole_facing_dir    = !157C
!mega_mole_moving_dir    = !1594
!mega_mole_turning_timer = !15AC
!mega_mole_ani_frame     = !1602
pushpc
org !bank1_koopakids_free
mega_mole_init:
	jsr.w _sub_horz_pos_bank1
	tya
	sta !mega_mole_moving_dir,x
	sta !mega_mole_facing_dir,x
	rts
.done:
warnpc !bank1_koopakids_end
!bank1_koopakids_free = mega_mole_init_done
pullpc
mega_mole_main:
	jsr.w spr_gfx_32x32
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne yi_pswitch_main_exit
	; set next animation frame
	inc !mega_mole_ani_timer,x
	lda !mega_mole_ani_timer,x
	lsr #2
	and #$01
	sta !mega_mole_ani_frame,x

	jsr.w _suboffscr3_bank3
	ldy !mega_mole_moving_dir,x
	lda .speeds,y
	sta !sprite_speed_x,x
	lda !sprite_blocked_status,x
	and #$04
	pha
	jsl update_sprite_pos|!bank
	jsl spr_spr_interact|!bank
	lda !sprite_blocked_status,x
	and #$04
	beq .airborne
	stz !sprite_speed_y,x
	pla
	bra .grounded
.airborne:
	pla
	beq .falling
	lda #$0A
	sta !mega_mole_falling_timer,x
.falling:
	lda !mega_mole_falling_timer,x
	beq .grounded
	stz !sprite_speed_y,x
.grounded:
	ldy !mega_mole_turning_timer,x
	lda !sprite_blocked_status,x
	and #$03
	beq .noturn
	cpy #$00
	bne .no_upd_turning_timer
	lda #$10
	sta !mega_mole_turning_timer,x
.no_upd_turning_timer:
	lda !mega_mole_moving_dir,x
	eor #$01
	sta !mega_mole_moving_dir,x
.noturn:
	cpy #$00
	bne .no_upd_facing_dir
	lda !mega_mole_moving_dir,x
	sta !mega_mole_facing_dir,x
.no_upd_facing_dir:
	jsl mario_spr_interact_l
	bcc .exit
	jsr.w _sub_vert_pos_bank3
	; Todo was $0E??
	lda $0F
	cmp #$D8
	bmi .check_ride
	lda !mega_mole_ride_timer,x
	ora !sprite_being_eaten,x
	bne .exit
	jsl hurt_mario
.ret1
	rts
.check_ride:
	lda !player_y_speed
	bmi .exit
	lda #$01
	sta !player_on_solid_platform
	lda #$06
	sta !mega_mole_ride_timer,x
	stz !player_y_speed
	ldy !player_on_yoshi
	lda .riding_ypos,y
	clc
	adc !sprite_y_low,x
	sta !player_y_next

	lda !sprite_x_high,x
	adc #$ff
	sta !player_y_next+1

	ldy #$00
	lda !sprite_x_movement
	bpl .move_x_pos
	dey
.move_x_pos:
	clc
	adc !player_x_next
	sta !player_x_next
	tya
	adc !player_x_next+1
	sta !player_x_next+1
.exit:
	rts
.speeds:
	db $10,$F0
.riding_ypos:
	db $D6,$C6,$C6

warnpc $03889F|!bank
