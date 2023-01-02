load_next_sprite       = $02A82E|!bank
load_normal_sprite     = $02A8DD|!bank
load_normal_sprite_fin = $02A9C9|!bank

; y here 'points' to the current sprite's x position value, so must be
; incremented once to get to that sprite's id in the case of normal,
; 3-byte sprites, as required
org $02A846|!bank
	jmp sprite_loader_prep_for_next_sprite

; completely skip loading any other sprite type.
; this frees up indices C9-FF for normal sprites,
; at the expense of everything else (not much of a loss)
; TODO figure out what to do for shooters (probably part of ambient sprite
;      rework) and enable loading said ambient sprites directly
org $02A866|!bank
spr_type_hack:
	jmp.w load_normal_sprite
sprite_loader_prep_for_next_sprite:
	iny
.no_y_adj:
	phx
	lda [!level_sprite_data_ptr],y
	tax
	tya
	clc
	adc.l sprite_size_table,x
	; subtract 2
	adc #$FE
	bpl .no_update_spr_data_ptr
	clc
	adc !level_sprite_data_ptr
	sta !level_sprite_data_ptr
	
	lda #$00
	bcc .no_update_spr_data_ptr
	inc !level_sprite_data_ptr+1
.no_update_spr_data_ptr:
	tay
	plx
	inx
	jmp.w load_next_sprite

warnpc load_normal_sprite

; here y = sprite id
; this skips the koopa shell finangling, special world koopa
; color changes, and sprites turning into moving coins if the
; silver p-switch is active.
org $02A978|!bank
load_new_sprite_dat:
	phy
	; go to spr y pos: get extra bits
	dey #2
	lda [!level_sprite_data_ptr],y
	and #$0C
	lsr #2
	sta !spr_extra_bits,x
	lda $05
	sta !sprite_num,x
	phx
	ldx $05
	lda.l sprite_size_table,x
	plx
	sec
	sbc #03
	beq .fin
	sta $07
	iny #3
	lda [!level_sprite_data_ptr],y
	sta !spr_extra_byte_1,x
	dec $07
	beq .fin
	iny
	lda [!level_sprite_data_ptr],y
	sta !spr_extra_byte_2,x
	dec $07
	beq .fin
	iny
	lda [!level_sprite_data_ptr],y
	sta !spr_extra_byte_3,x
	dec $07
	beq .fin
	iny
	lda [!level_sprite_data_ptr],y
	sta !spr_extra_byte_4,x
.fin:
	ply
	bra load_normal_sprite_fin
warnpc load_normal_sprite_fin

; y here points to the current loading sprite's id, as required
org $02A9D7|!bank
	; restore 'sprite index in level' count
	ldx $02
	jmp.w sprite_loader_prep_for_next_sprite_no_y_adj
