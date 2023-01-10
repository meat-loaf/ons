includefrom "list.def"

!ambient_player_dust_id = $00

%alloc_ambient_sprite(!ambient_player_dust_id, "turn_dust", ambient_dust_main, 0)

;org $029922|!bank
;	db $E6,$E6,$E4,$E2,$E2

%set_free_start("bank2_altspr2")
ambient_basic_gfx:
	jsr ambient_sub_off_screen
	;jsr ambient_get_draw_info
	lda $00
	sta $0200|!addr,y
	lda !ambient_props,x
	sta $0202|!addr,y
	tya
	lsr #2
	tay

	lda $0420|!addr,y
	and #$FFF0
	ora $0e
	sta $0420|!addr,y
	rts

ambient_dust_main:
	lda !ambient_gen_timer,x
	bne .cont
.bad_ambient_default:
	stz !ambient_rt_ptr,x
	rts
.cont:
	lsr #2
	asl
	;and #$000e
	tay
	lda !sprite_level_props-1
	and #$FF00
	ora .prop_tiles_tbl,y
	stz $0e
	sta !ambient_props,x
	jmp ambient_basic_gfx
.prop_tiles_tbl:
	dw $00E6,$00E6,$00E4,$00E2,$00E2,$00E2
.done:
%set_free_finish("bank2_altspr2", ambient_dust_main_done)
