includefrom "remaps.asm"

!blurp_sprnum       = $26
!blurp_tile_mclosed = $0A
!blurp_tile_mopen   = $0C

org spr_tweaker_1656_tbl+!blurp_sprnum
	db $00
org spr_tweaker_1662_tbl+!blurp_sprnum
	db $00
org spr_tweaker_166E_tbl+!blurp_sprnum
	db $CB
org spr_tweaker_167A_tbl+!blurp_sprnum
	db $01
org spr_tweaker_1686_tbl+!blurp_sprnum
	db $10
org spr_tweaker_190F_tbl+!blurp_sprnum
	db $00

org shared_spr_routines_tile_addr(!blurp_sprnum)|!bank
	db !blurp_tile_mclosed
	db !blurp_tile_mopen

%replace_sprite_rt(!blurp_sprnum, _spr_inits_start, blurp_init)
%replace_sprite_rt(!blurp_sprnum, _spr_mains_start, blurp_main)

;org !bank1_thwomp_free
!blurp_wave_phase = !C2
!blurp_ani_timer  = !1570
!blurp_facing_dir = !157C
!fast_blurp_flag  = !1594

org !bank1_koopakids_free
blurp_init:
	lda !spr_extra_bits,x
	lsr
	and #$02
	sta !fast_blurp_flag,x
	beq .no_alt_pal
	lda #$07
	sta !sprite_oam_properties,x
.no_alt_pal:
	jmp.w _spr_face_mario_rt
.done:

blurp_main:
	JSR.w sub_spr_gfx_2
	LDA !sprites_locked
	BNE .exit
	JSR.w _suboffscr0_bank1
	JSR.w _spr_set_ani_frame
	LDA !blurp_ani_timer,x
	AND #$03
	BNE .no_speed_upd
	LDA !blurp_wave_phase,x
	AND #$01
	ORA !fast_blurp_flag,x
	TAY
	LDA !sprite_speed_y,x
	CLC
	ADC .accel_y,y
	STA !sprite_speed_y,x
	CMP .speed_max_y,y
	BNE .no_speed_upd
	INC !blurp_wave_phase,x
.no_speed_upd:
	LDA !blurp_facing_dir,x
	ORA !fast_blurp_flag,x
	TAY
	LDA .speed_x,y
	STA !sprite_speed_x,x
	JSR.w _spr_upd_y_no_grav
	JSR.w _spr_upd_x_no_grav
	JMP.w _sprspr_mario_spr_rt
.exit:
	RTS
.accel_y:
	db $01,$FF
	db $02,$FE
.speed_max_y:
	db $04,$FC
	db $06,$FA
.speed_x:
	db $08,$F8
	db $0C,$F4
.done:
warnpc !bank1_koopakids_end
!bank1_koopakids_free = blurp_main_done
