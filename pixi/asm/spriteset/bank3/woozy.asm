!woozyguy_sprnum = $BA

%alloc_spr(!woozyguy_sprnum, woozyguy_init, bank3_sprcaller, \
	$30, $80, $01, $01, $00, $00)

!woozy_phase         = !C2
!woozy_phase_counter = !1534
!woozy_face_dir      = !157C
!woozy_ani_frame_id  = !160E

!jump_interval = $20
!squish_interval = $08

!jump_y_speed = $30

pushpc
org !bank1_koopakids_free
woozyguy_init:
	lda #!jump_interval
	sta !woozy_phase_counter,x

	lda !sprite_x_low,x
	lsr #4
	and #$03
	inc : inc
	clc
	asl
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	jmp.w _spr_face_mario_bank1
.done
warnpc !bank1_koopakids_end
!bank1_koopakids_free = woozyguy_init_done

pullpc
woozyguy_main:
	lda !woozy_ani_frame_id,x
	sta !spr_dyn_alloc_slot_arg_frame_num
	lda #$02
	sta !spr_dyn_alloc_slot_arg_gfx_id
	jsr spr_dyn_gfx_rt

	lda !sprite_oam_properties,x
	and #(~$C0)
	sta !sprite_oam_properties,x

	lda !sprite_status,x
	eor #$08
	ora !sprite_being_eaten,x
	ora !sprites_locked
	bne .exit
	lda !sprite_blocked_status,x
	and #$08
	beq .not_touching_ceiling
	stz !sprite_speed_y,x
.not_touching_ceiling:
	lda !sprite_blocked_status,x
	and #$03
	beq .not_touching_wall
	lda !woozy_face_dir,x
	eor #$01
	sta !woozy_face_dir,x
.not_touching_wall:

	lda !woozy_phase,x
	;lda #$00
	txy
	asl
	tax
	jsr (.behaviors,x)
	; mario interact
	jsl $01A7DC|!addr 
	; speed
	jsl $01802A|!addr
	; sprites
	jsl $018032|!addr
.exit:
	rts

.behaviors:
	dw ..wait
	dw ..squish
	dw ..jump
	dw ..rotating
	dw ..squish
..wait:
	tyx
	stz !woozy_ani_frame_id,x
	lda !sprite_blocked_status,x
	and #$04
	beq ...done
	dec !woozy_phase_counter,x
	bne ...done
	inc !woozy_phase,x
	lda #!squish_interval
	sta !woozy_phase_counter,x
...done:
	rts

..squish:
	tyx
	dec !woozy_phase_counter,x
	beq ...done
	lda #!squish_interval
	sec
	sbc !woozy_phase_counter,x
	bit #$04
	beq ...no_inv
	eor #$07
...no_inv:
	asl
	adc #$10
	sta !woozy_ani_frame_id,x
	rts
...done:
	ldy !woozy_phase,x
	lda ...next_phase-1,y
	sta !woozy_phase,x
	lda #!jump_interval
	sta !woozy_phase_counter,x
	rts
...next_phase:
	db $02,$00,$00,$00

..jump:
	tyx
	ldy !woozy_face_dir,x
	lda ..x_speed,y
	sta !sprite_speed_x,x
	lda #(~!jump_y_speed)-1
	sta !sprite_speed_y,x
	inc !woozy_phase,x
	rts

..rotating:
	tyx
	; gfx - TODO handle flipping
	dec !woozy_phase_counter,x
	lda !woozy_phase_counter,x
	bit #$10
	beq ..nofr
	pha
	;lda #$80
	;ora !sprite_oam_properties,x
	;sta !sprite_oam_properties,x
	pla
..nofr:
	and #$0F
	sta !woozy_ani_frame_id,x

	ldy !woozy_face_dir,x
	lda ..x_speed,y
	sta !sprite_speed_x,x
	lda !sprite_blocked_status,x
	and #$04
	beq ...done
	lda #!squish_interval
	sta !woozy_phase_counter,x
	inc !woozy_phase,x
	stz !woozy_ani_frame_id,x
	stz !sprite_speed_x,x
...done:
	rts

..x_speed:
	db $10,$F0
