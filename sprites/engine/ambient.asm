includefrom "engine.asm"

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
org $028792|!addr
; todo - theres a lot of stuff here
