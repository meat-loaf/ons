includefrom "engine.asm"

%set_free_start("bank2_altspr1")
ambient_sub_off_screen:
	; clear x high bit in tilesz props
	lda !ambient_twk_tilesz,x
	and #$FFFE
	sta !ambient_twk_tilesz,x

	bit #!ambient_twk_check_offscr
	beq .ok
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
	; todo consider merging with the above checks?
	lda !ambient_x_pos,x
	sec
	sbc !layer_1_xpos_curr
	cmp #$0100
	bcc .do_store
	lsr !ambient_twk_tilesz,x
	sec
	rol !ambient_twk_tilesz,x
.do_store:
	sta $00
	lda !ambient_y_pos,x
	sec
	sbc !layer_1_ypos_curr
	bpl .yok
	lda #$00F0
.yok:
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
.no_oam_left:
	; immediately terminate the ambient sprite routine
	; by destroying this return val
	pla
	rts

ambient_physics:
	sep #$30
	lda !ambient_x_speed+1,x
	beq .no_x_upd
	asl #4
	clc
	adc !ambient_x_speed,x
	sta !ambient_x_speed,x
	php
	ldy #$00
	lda.w !ambient_x_speed+1,x
	lsr
	lsr
	lsr
	lsr
	cmp.b #$08
	bcc .x_not_neg
	ora #$f0
	dey
.x_not_neg:
	plp
	adc !ambient_x_pos,x
	sta !ambient_x_pos,x
	tya
	adc !ambient_x_pos+1,x
	sta !ambient_x_pos+1,x
.no_x_upd:
	lda !ambient_y_speed+1,x
	beq .no_y_upd
	asl #4
	clc
	adc !ambient_y_speed,x
	sta !ambient_y_speed,x
	php
	ldy #$00
	lda.w !ambient_y_speed+1,x
	lsr
	lsr
	lsr
	lsr
	cmp.b #$08
	bcc .y_not_neg
	ora #$f0
	dey
.y_not_neg:
	plp
	adc !ambient_y_pos,x
	sta !ambient_y_pos,x
	tya
	adc !ambient_y_pos+1,x
	sta !ambient_y_pos+1,x
.no_y_upd:
	lda !ambient_twk_tilesz+1,x
	and.b #(!ambient_twk_has_grav>>8)
	beq .exit
	lda !ambient_y_speed+1,x
	cmp #$30
	bpl .exit
	clc
	adc #$02
	sta !ambient_y_speed+1,x
.exit:
	rep #$30
	rts

; TODO spritesets (if applicable)
ambient_initer:
	lda !ambient_misc_1,x
	asl
	tay
	lda ambient_twk_tsz,y
	sta !ambient_twk_tilesz,x
	lda ambient_rts,y
	sta !ambient_rt_ptr,x
	stz !ambient_misc_1,x
	; decremented by sprite caller,
	; fix timer to account for init if set
	; ugly but it is what it is, i think its better than
	; comparing the routine ptr to this init in the main loop
	lda !ambient_gen_timer,x
	beq .exit
	inc !ambient_gen_timer,x
.exit:
	rts
ambient_twk_tsz:
	skip !ambient_sprid_max*2
ambient_rts:
	skip !ambient_sprid_max*2
.done
%set_free_finish("bank2_altspr1", ambient_rts_done)

%set_free_start("bank2_altspr2")
ambient_kill_on_timer:
	lda !ambient_gen_timer,x
	bne .ok
	stz !ambient_gen_timer,x
	; destroy the return, exiting out of the sprite code entirely
	pla
.ok:
	rts
; basic 'check despawn and draw single tile' ambient gfx routine.
ambient_basic_gfx:
	jsr ambient_sub_off_screen
	; todo put spriteset offset in high nybble of low byte
	;lda !ambient_twk_tilesz,x
	;and #$00F0
	;xba
	;sta $02

	lda $00
	sta $0200|!addr,y
	lda !ambient_props,x
	;clc
	;adc $02
	sta $0202|!addr,y
	tya
	lsr #2
	tay

	; smw was not designed with 16-bit oam access in mind...
	; this is better than alternatives, i think
	sep #$20
	lda !ambient_twk_tilesz,x
	and #$03
	sta $0420|!addr,y
	rep #$20
	rts

; input: a = ambient sprite id to spawn
;        $45 = ambient sprite xpos
;        $47 = ambient sprite ypos
;        $49 = ambient timer val
;        $4B = x speed - if it doesn't use physics it is never applied
;        $4C = y speed - if it doesn't use physics it is never applied
; output:
;       carry set: failure, clear: success
;       y: ambient slot index
ambient_get_slot:
	rep #$30
	and #$00FF
	pha
	ldy.w #(!num_ambient_sprs*2)-2
.loop:
	; todo make ring
	lda !ambient_rt_ptr,y
	beq .found
	dey : dey
	bpl .loop
	sep #$30
	sec
	rtl
.found:
	pla
	sta !ambient_misc_1,y
	lda #ambient_initer
	sta !ambient_rt_ptr,y
	
	lda $45
	sta !ambient_x_pos,y
	lda $47
	sta !ambient_y_pos,y
	lda $49
	and #$00FF
	sta !ambient_gen_timer,y

	sep #$30

	lda #$00
	sta !ambient_x_speed,y
	sta !ambient_y_speed,y
	lda $4B
	sta !ambient_x_speed+1,y
	lda $4C
	sta !ambient_y_speed+1,y
	clc
	rtl
.done
%set_free_finish("bank2_altspr2", ambient_get_slot_done)