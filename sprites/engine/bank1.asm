org $01801A|!bank
spr_upd_y_no_grv_l:
	jsr.w _spr_upd_y_no_grav
	rtl
spr_upd_x_no_grv_l:
	jsr.w _spr_upd_x_no_grav
	rtl
spr_upd_yx_no_grav_l:
	jsr.w _spr_upd_y_no_grav
	jsr.w _spr_upd_x_no_grav
	rtl
warnpc $018029|!bank

; todo i don't feel like relocating these...
org $01AB75|!bank
spr_display_contact_gfx_s_nosnd_alt:
	bne .exit
	phy

	lda !sprite_x_low,x
	sta !ambient_get_slot_xpos
	lda !sprite_x_high,x
	sta !ambient_get_slot_xpos+1
	lda !sprite_y_low,x
	sta !ambient_get_slot_ypos
	lda !sprite_y_high,x
	sta !ambient_get_slot_ypos+1
	lda #$08
	sta !ambient_get_slot_timer
	lda #$30

	jsl ambient_get_slot
	ply
.exit:
	rtl
warnpc $01AB99|!bank

org $01AB9C|!bank
spr_display_contact_gfx_p_alt:
	bne .exit
	phy

	lda #$08
	sta !ambient_get_slot_timer
	rep #$30

	lda !player_x_next
	sta !ambient_get_slot_xpos

	lda #$0014
	ldy !player_on_yoshi
	beq .not_on_yoshi
	lda #$001E
.not_on_yoshi:
	clc
	adc !player_y_next
	sta !ambient_get_slot_ypos

;	stz !ambient_get_slot_xspd

	lda #$0030
	jsl ambient_get_slot

	ply
.exit:
	rtl
warnpc $01ABCC|!bank
