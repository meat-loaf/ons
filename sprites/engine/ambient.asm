includefrom "engine.asm"

; generic interaction - replace with stub
org $01AB64|!bank
	jsl spr_give_points

; this table is used as a 'bounce block id'.
; in the original game it was a bit weirder, but the new code
; uses it directly as an ambient sprite id.
org $00F05C|!bank
bounce_ids:
	; todo noteblock with item
	skip 1
	; on/off switch
	db $0D
	; noteblock
	skip 1
	; ? block with directional coins
	db $09
	; note blocks
	skip 2
	; item turn blocks
	db $04,$04,$04,$04,$04,$04,$04
	; turning turn block
	db $03
	; item ? blocks
	db $09,$09,$09,$09
	; multicoin ? block
	db $0A
	; remaining item ? blocks
	db $09,$09,$09,$09,$09
	; turn block with nothing
	db $04
	; side feather turn block, side bounce turn block
	skip 2
	; unused (tile 12c), green star block
	skip 2
	; unused (door tiles...?)
	skip 4
	; ! blocks (green, yellow)
	skip 2
warnpc $00F080|!bank

; this replaces old sprite types with ambient ones.
; see 'bank2.asm' for the ambient sprite caller
org $00FE56|!bank
mario_turn_smoke_spawn_hijack:
	bne .ret
org $00FE65|!bank
	bcc .ret
	rep #$20
	lda !player_x_next
	adc #$0004
	sta $45
	lda !player_y_next
	adc #$001A
	ldy !player_on_yoshi
	beq .no_yoshi
	adc #$0010
.no_yoshi:
	sta $47
	lda #$0018
	sta $49

	lda #$0000
	jsl ambient_get_slot
	; axy width cleaned up here
.ret:
	rts
warnpc $00FE93|!bank



; replace bounce block spawns
; $04 has the block id
org spawn_ambient_bounce_sprite|!bank
spawn_ambient_bounce_sprite_impl:
	rep #$20
	lda !block_xpos
	sta !ambient_get_slot_xpos
	lda !block_ypos
	sta !ambient_get_slot_ypos
	; y speed of $C0
	lda #$C000
	sta !ambient_get_slot_xspd
	lda #$0008
	sta !ambient_get_slot_timer
	lda $04
	and #$00FF
	jsl ambient_get_slot

	lda $05
	beq .done
	cmp #$08
	bcs .go_spawn_spr
	cmp #$06
	bcc .go_spawn_spr
	cmp #$07
	bne .spawn_coin
	; todo set multicoin timer
.spawn_coin:
	rep #$20
	lda !block_xpos
	sta !ambient_get_slot_xpos
	lda !block_ypos
	sec
	sbc #$0010
	sta !ambient_get_slot_ypos
	lda #$d000
	sta !ambient_get_slot_xspd
	lda #$0010
	jsl ambient_get_slot
	; inc coin adder, play sfx,
	; track green star block ram
	jml $05B34A|!bank
.done:
	rtl
.go_spawn_spr:
	jmp .spawn_spr
warnpc $0288A1|!bank

org $0288DC|!bank
.spawn_spr:
warnpc $02AD33|!bank
