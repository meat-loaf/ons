includefrom "engine.asm"

; this replaces old sprite types with ambient ones.
; see 'bank2.asm' for the ambient sprite caller

org $00FE56|!bank
mario_turn_smoke_spawn_hijack:
	bne .ret
org $00FE65|!bank
	bcc .ret
	lda !player_x_next
	sta $45
	lda !player_x_next+1
	sta $46
	lda !player_y_next
	ldy !player_on_yoshi
	beq .no_yoshi
	adc #$10
.no_yoshi:
	sta $47
	lda !player_y_next+1
	sta $48
	lda #$00
	jsl ambient_generic_init
.ret:
	rts
warnpc $00FE93|!bank
