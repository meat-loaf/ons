if !sprites_have_exbytes

load_next_sprite   = $02A82E|!bank
load_normal_sprite = $02A8DD|!bank

; y here 'points' to the current sprite's x position value, so must be
; incremented once to get to that sprite's id in the case of normal,
; 3-byte sprites, as required
org $02A846|!bank
	jml sprite_loader_prep_for_next_sprite

; completely skip loading any other sprite type.
; this frees up indices C9-FF for normal sprites,
; at the expense of everything else (not much of a loss)
org $02A866|!bank
spr_type_hack:
	jmp.w load_normal_sprite

warnpc load_normal_sprite

;org $02A978|!bank
;autoclean \
;	jml load_new_sprite_dat

; y here points to the current loading sprite's id, as required
org $02A9D7|!bank
	ldx $02
autoclean \
	jml sprite_loader_prep_for_next_sprite_no_y_adj

freecode
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
	jml load_next_sprite
endif
