includefrom "engine.asm"

%set_free_start("bank2_altspr1")
ambient_sub_off_screen:
	lda !ambient_y_pos,x
	cmp !exlvl_screen_size
	bpl .erase
	sec
	sbc !layer_1_ypos_curr
	cmp !scr_max_y_off_sprspawn
	bpl .erase
	sec
	sbc !scr_min_y_off_sprspawn
	eor #$8000
	bpl .erase
.check_offscr_x:
	lda !layer_1_xpos_curr
	clc
	adc #$0130
	cmp !ambient_x_pos,x
	bcc .erase
	lda !layer_1_xpos_curr
	clc
	adc #$FFC0
	bmi .ok
	cmp !ambient_x_pos,x
	; TODO fix this, when all the way to the left, moving
	;      ambient sprites won't despawn when offscreen to the left
	bcs .erase
.ok:

	; TODO probably can do this at the same time as above...
	; TODO check if we actually need to draw
	lda !ambient_x_pos,x
	sec
	sbc !layer_1_xpos_curr
	sta $00
	lda !ambient_y_pos,x
	sec
	sbc !layer_1_ypos_curr
	sta $01
	lda !next_oam_index
	cmp #$0100
	bcs .no_oam_left
	tay
	adc #$0004
	sta !next_oam_index
	rts
.erase:
	stz !ambient_rt_ptr,x
.no_oam_left
	; immediately terminate the ambient sprite routine
	; by destroying this return val
	pla
	rts
ambient_get_draw_info:
	rts
ambient_finish_oam_write:
	rts
; TODO spritesets (if applicable)
ambient_initer:
	lda !ambient_misc_1,x
	asl
	tay
	lda ambient_tsz,y
	sta !ambient_ss_tilesz,x
	lda ambient_rts,x
	sta !ambient_rt_ptr,x
	rts
ambient_tsz:
	skip !ambient_sprid_max*2
ambient_rts:
	skip !ambient_sprid_max*2
.done
%set_free_finish("bank2_altspr1", ambient_rts_done)

%set_free_start("bank2_altspr2")
; input: a = ambient sprite id to spawn
;        $45 = ambient sprite xpos
;        $47 = ambient sprite ypos
;        $49 = ambient timer val
; output:
;       carry set: failure, clear: success
; clobbers:
;       y
ambient_get_slot:
	phx
	rep #$30
	and #$00FF
	pha
	ldy.w #(!num_ambient_sprs*2)-2
.loop:
	lda !ambient_rt_ptr,y
	beq .found
	dey : dey
	bpl .loop
	sec
	rtl
.found:
	pla
	asl
	tax
	; TODO generic initer
	lda.l ambient_rts,x
	sta !ambient_rt_ptr,y
	lda $45
	sta !ambient_x_pos,y
	lda $47
	sta !ambient_y_pos,y
	lda $49
	sta !ambient_gen_timer,y
	sep #$30
	plx
	rtl
.done
%set_free_finish("bank2_altspr2", ambient_get_slot_done)
