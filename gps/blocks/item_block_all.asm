db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead


!map16_base        = $B1
!map16_coin_start  = $B2
!blk_map16_num_lo  = $03
; first entry is for small, second is for big
sprite_to_spawn:
	; vine
	db $29,$29
sprite_1540_vals:
	; vine
	db $3E,$3E

; ambient id
; todo the ambient spawner code uses a conversion table
;      that needs to be gotten rid of
bounce_spr_to_spawn:
	       ; conversion offset
	db $04+$01
	db $04+$01
MarioCorner:
MarioAbove:

Return:
MarioSide:
Fireball:
MarioInside:
MarioHead:
	rtl

SpriteH:
	%check_sprite_kicked_horizontal()
	bcs SpriteShared
	rtl

SpriteV:
	lda !14C8,x
	cmp #$09
	bcc Return
	lda !AA,x
	bpl Return
	lda #$10
	sta !AA,x

SpriteShared:
	%sprite_block_position()

MarioBelow:
Cape:

gen_item_block_spawn_item:
	phx
	phy
	lda !block_xpos
	pha
	and #$F0
	sta !block_xpos
	lda !block_ypos
	pha
	and #$F0
	sta !block_ypos

	ldx !blk_map16_num_lo
	lda bounce_spr_to_spawn-!map16_base,x
	sta $04
	phk
	lda.b #bank(spawn_ambient_bounce_sprite)
	pha
	plb
	jsl spawn_ambient_bounce_sprite
	plb
	jsl write_item_memory

	lda !blk_map16_num_lo
	cmp #!map16_coin_start
	bcc .do_spr_spawn
	jmp do_coin_spawn
.do_spr_spawn:
	ldx #!num_sprites-1
.loop:
	lda !sprite_status,x
	beq .found
	dex
	bpl .loop
	lda !powerup_ix_slot_overwrite
	dec
	bpl .no_fix
	lda #$01
.no_fix:
	sta !powerup_ix_slot_overwrite
	clc : adc #$0a
	tax
.found:
	ldy.b #$00
	lda.b !powerup
	beq .small
	iny
.small:
	lda !blk_map16_num_lo
	sec
	sbc #!map16_base
	asl
	cpy #$00
	beq .not_odd
	inc
.not_odd:
	tay
	lda sprite_to_spawn,y
	sta !sprite_num,x
	jsl init_sprite_tables

	lda #$01
	sta !sprite_status,x

	lda sprite_1540_vals,y
	sta !sprite_misc_1540,x

	lda.b !block_xpos
	sta.b !sprite_x_low,x
	lda.b !block_xpos+1
	sta.w !sprite_x_high,x
	lda.b !block_ypos
	sta.b !sprite_y_low,x
	lda.b !block_ypos+1
	sta.w !sprite_y_high,x

	lda #$d0
	sta !sprite_speed_y,x

	lda #$2C
	sta !sprite_misc_154c,x

	lda !sprite_tweaker_190f,x
	bpl .exit
	lda #$10
	sta !sprite_misc_15ac,x
.exit:
	pla
	sta !block_ypos
	pla
	sta !block_xpos
	ply
	plx
	rtl

do_coin_spawn:
	rep #$21
	lda !block_xpos
	sta !ambient_get_slot_xpos
	lda !block_ypos
	adc #(~$0010)+1
	sta !ambient_get_slot_ypos
	lda #$d000
	sta !ambient_get_slot_xspd
	stz !ambient_get_slot_timer
	lda #$000b
	jsl ambient_get_slot_rt
	bra gen_item_block_spawn_item_exit
print "A generic item block. Insert as an object to use item memory."
