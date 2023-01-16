includefrom "list.def"

!hoopster_sprnum = $1E
%alloc_sprite(!hoopster_sprnum, "smb3_hoopster", hoopster_init, hoopster_main, 1, 1, \
	$30, $00, $0D, $19, $00, $01)
%alloc_sprite_sharedgfx_entry_2(!hoopster_sprnum, $09, $0B)


%set_free_start("bank1_koopakids")
hoopster_init:
	lda $96
	cmp !sprite_y_low,x
	lda $97
	sbc !sprite_y_high,x
	bpl .exit
	inc !sprite_misc_157c,x
.exit:
	rtl

hoopster_main:
	jsr.w spr_sub_gfx_2
	; ??
	inc !sprite_misc_1570,x
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne .exit
	jsl sub_off_screen
	ldy !sprite_misc_157c,x
	lda !player_x_next
	sec
	sbc !sprite_x_low,x
	clc
	adc #$18
	cmp #$30
	bcs .not_near_mario
;	lda #$01
;	sta !sprite_misc_1504,x
	iny #2
.not_year_mario:
	lda .y_speed,y
	sta !sprite_speed_y,x
	jsl spr_upd_y_no_grav_l
	jsl spr_obj_interact
;	lda $
.exit:
	rtl
.y_speed:
	db $08,$FA
	db $16,$F0
hoopster_done:
%set_free_finish("bank1_koopakids", hoopster_done)
