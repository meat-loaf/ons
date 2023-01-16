includefrom "ambient_list.def"

!spincoin_sprnum   = $10
!spincoin_r_sprnum = $11

; sprite's terminal velocity doesn't matter much, sprite kills itself once
; it exceeds it
%alloc_ambient_sprite_grav(!spincoin_sprnum, "spin_coin_normal", ambient_coin, \
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big, \
	$03, $21)
%alloc_ambient_sprite_grav(!spincoin_r_sprnum, "spin_coin_red", ambient_coin, \
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big,   \
	$03, $21)

%set_free_start("bank2_altspr1")
ambient_coin:
	lda !ambient_sprlocked_mirror
	bne .gfx
	lda !ambient_y_speed+1,x
	; todo proper check
	sep #$20
	cmp #$20
	rep #$20
	bmi .gfx
	; todo convert to score sprite
	lda #$0100
	sta !ambient_misc_1,x
	lda #$0018
	sta !ambient_gen_timer,x
	lda #ambient_initer
	sta !ambient_rt_ptr,x
	;stz !ambient_rt_ptr,x
	rts
.gfx:
	lda !effective_frame
;	lda !ambient_gen_timer,x
	and #$000C
	lsr
	sta $0C
	tay
	lda .frames,y
	sta $0E
	lda !ambient_misc_1+1,x
	and #$00FF
	asl
	tay
	lda .pals-(!spincoin_sprnum*2),y
	ora $0E
	sta !ambient_props,x
	jsr ambient_basic_gfx
	lda $0C
	bne .gfx_draw_bottom
	lda #$000C
	sta !ambient_gen_timer,x
	rts
; todo this could likely be better
.gfx_draw_bottom:
	lda $0420|!addr,y
	lsr
	lda #$0000
	bcc .not_xoff
	lda #$0101
.not_xoff:
	sta $0420|!addr,y
	jsr ambient_sub_off_screen_next_oam_slot
	lda $01FC|!addr,y
	inc #4
	sta $01FC|!addr,y
	clc
	adc #$0800
	sta $0200|!addr,y
	lda $01FE|!addr,y
	; y flip
	ora #$8000
	sta $0202|!addr,y
	;lda $0201|!addr,y
	; todo hopefully this isnt a problem
	;      it should never overflow as if we are
	;      offscreen, y-pos will be set to $F0
	;clc
	;adc #$0008
	;sta $0201|!addr,y
	rts
.frames:
	dw $00CA,$0040,$0050,$0040
.pals:
	dw $0400,$0800
ambient_coin_done:
%set_free_finish("bank2_altspr1", ambient_coin_done)
