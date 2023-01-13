!turning_turn_block_ambient_id = $03

%alloc_ambinet_spr(!turning_turn_block_ambient_id, "turning_turn_block_bounce", ambient_bounce_spr,\
	0)

ambient_bounce_spr:
	lda !sprites_locked
	bne .exit
	lda !ambient_misc_1,x
	bne .alt
	inc !ambient_misc_1,x
	lda #$0009
.spawn_block:
	; make sure the high byte is 0
	sta $9C
	lda !ambient_y_pos,x
	and #$FFF0
	sta $98
	lda !ambient_x_pos,x
	and #$FFF0
	sta $9A
	; todo handle being on layer 2
	jsl generate_tile
	rts
;	jsr ambient_kill_on_timer
.alt:
	lda !ambient_gen_timer,x
	bne .exit
	stz !ambient_gen_timer,x
	lda #$000C
	bra .spawn_block
.exit:
	rts
