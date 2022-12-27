; a generic 32x32 sprite routine
; inputs:

; 15f6,x: oam props
; 157c,x: horizontal direction, controls flipping
; 1602,x: animation frame. Made for spritesets, so first frame is $00, second is $08, third is $10, fourth is $18

!first_32x32_sprnum = $B9

spr_gfx_32x32:
;	stz $0E
;	stz $0F
.alt:
	jsr.w _get_draw_info_bank3
.no_getdrawinfo:
	ldy !sprite_num,x
	lda .tile_off_x_base-!first_32x32_sprnum,y
	sta $02
	lda .tile_off_y_base-!first_32x32_sprnum,y
	sta $03

	ldy !1602,x
	lda .tile_index,y
	sta $04

	ldy #$00
	lda !157C,x
	bne .no_x_flip
	ldy #$40
.no_x_flip:
	tya
	ora !sprite_oam_properties,x
	ora !sprite_level_props
	sta $05

	ldy !157C,x
	lda .tile_loop_ixval,y
	ldy !sprite_oam_index,x
	tax
; todo this might be best unrolled
.draw_loop:
	lda $00
	clc
	adc $02
	adc .tile_offsets_x,x
	sta $0300|!addr,y
	lda $01
	clc
	adc $03
	adc .tile_offsets_y,x
	sta $0301|!addr,y

	lda $04
	sta $0302|!addr,y
	inc : inc
	sta $04

	lda $05
	sta $0303|!addr,y
	iny #4

	txa
	and #$03
	dex
	dec
	bpl .draw_loop

	ldx !current_sprite_process
	lda #$03
	ldy #$02

	jsl finish_oam_write
.ret:
	rts
; per-sprite tables, x/y offset applied to each sprite tile
; most 32x32 sprites are drawn with slightly different offsets
; (see mega mole, where sprite position is at the bottom-left, or
;   the porcu-puffer, where its sprite position is at its center,
;   or the castle block which has the posotion at the top-left)
.tile_off_x_base:
	db $00,$00,$00,$00,$F2,$00,$00,$00,$00,$00,$08
.tile_off_y_base:
	db $00,$00,$00,$00,$00,$00,$F0,$00,$00,$00,$F8
; helper tables
.tile_loop_ixval:
	db $03,$07
.tile_index:
	db $00,$08,$10,$18
.tile_offsets_x:
	db $00,$10,$00,$10
	db $10,$00,$10,$00
.tile_offsets_y:
	db $10,$10,$00,$00
	db $10,$10,$00,$00

; set $0E and $0F as needed for 
spr_dyn_gfx_rt:
	; do this first to abort remainder if we're not going to draw anyway
	jsr.w _get_draw_info_bank3
	jsr spr_dyn_allocate_slot
	bcs spr_gfx_32x32_ret
	jmp spr_gfx_32x32_no_getdrawinfo

spr_dyn_allocate_slot_long:
	jsr spr_dyn_allocate_slot
	rtl

; call as follows:
; $0E: frame number to upload to scratch
; $0F: id of graphics to pull frame from
;  * note: X is restored to the current sprite index by the routine
; output:
;  carry: clear if slot available, set if not
; clobbers:
;  $0660-$0662

!spr_dyn_alloc_slot_arg_frame_num = $0E
!spr_dyn_alloc_slot_arg_gfx_id    = $0F
!dyn_spr_slot_tbl                 = !1602
spr_dyn_allocate_slot:
	; preserve calling value
	lda !dyn_slots
	cmp #!dyn_max_slots-1
	bcc .slots_avail
	ldx !current_sprite_process
	sec
	rts

.slots_avail:
	lda !spr_dyn_alloc_slot_arg_gfx_id
	asl
	adc !spr_dyn_alloc_slot_arg_gfx_id
	tax

	; setup rom gfx address
	lda.l .gfx,x
	sta !dyn_slot_ptr+0
	lda.l .gfx+1,x
	sta !dyn_slot_ptr+1
	lda.l .gfx+2,x
	sta !dyn_slot_ptr+2
	; a = frame index
	lda !spr_dyn_alloc_slot_arg_frame_num
	; lsb to carry
	lsr
	; preserve carry
	php
	; clear carry (clamp frame to even values)
	clc
	; multiply by 4 (multiply even-valued frame by 2)
	asl #2
	; restore carry - add 1 if frame value is odd
	plp
	adc !dyn_slot_ptr+1
	sta !dyn_slot_ptr+1

	; setup ram buffer address
	clc
	ldx !dyn_slots
	lda.l .buffer_offs_hi,x
	inx
	stx !dyn_slots
	adc.b #(!dynamic_buffer>>8)&$FF
	sta !dyn_slot_dest+1
	lda.b #!dynamic_buffer
	sta !dyn_slot_dest

	rep #$10
	stz $4300
	lda #$80
	sta $4301

	; setup wram write addr
	ldx !dyn_slot_dest
	stx $2181
	lda.b #(!dynamic_buffer>>16)&$FF
	sta $2183

	ldx !dyn_slot_ptr
	stx $4302
	; bank
	lda !dyn_slot_ptr+2
	sta $4304
	ldx #$0100
	stx $4305

	; initiate transfer
	lda #$01
	sta $420B

	; second line transfer - only need to setup addr offsets and reset size
	lda !dyn_slot_dest+1
	adc #$02
	sta $2182

	lda !dyn_slot_ptr+1
	adc #$02
	sta $4303

	ldx #$0100
	stx $4305

	; initiate transfer
	lda #$01
	sta $420B

	sep #$10
	ldx !current_sprite_process
	lda !dyn_slots
	dec
	sta !dyn_spr_slot_tbl,x
	clc
	rts
; slots are 2 8x16 strips
.buffer_offs_hi:
	db $00,$01
	db $04,$05
.gfx:
	dl yi_pswitch
	dl starcoin_gfx


