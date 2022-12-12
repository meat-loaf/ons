includefrom "remaps.asm"


!wiggler_buffer_index     = !160E
!wiggler_segbuff_position = !1528
!wiggler_bloomer          = !1504

org $02EFEA|!bank
wiggler_seg_off_lo:
	db $00,$80,$00,$80
wiggler_seg_off_hi:
	db $00,$00,$01,$01
; wiggler init
;org $02EFF2|!bank
wigini:
	PHB
	PHK
	PLB
	JSR.w $02D4FA|!bank
	JML.l wiggler_init_find_segslot|!bank
.segptr_init:
	JSR.w wiggler_segment_ptr_init
	LDY.b #$7F
.seg_buff_init_loop:
	; todo sa1?
	LDA.b !D8,x
	STA.b [!wiggler_segment_ptr],y
	DEY
	LDA.b !E4,x
	STA.b [!wiggler_segment_ptr],y
	DEY
	BPL.b .seg_buff_init_loop
.seg_init_done:
	PLB
	RTL
wiggler_segment_ptr_init:
	LDY !wiggler_buffer_index,x
	LDA.b #!wiggler_segment_buffer
	CLC
	ADC.w wiggler_seg_off_lo|!bank,y
	STA.b !wiggler_segment_ptr+$0
	LDA.b #!wiggler_segment_buffer>>8
	CLC
	ADC.w wiggler_seg_off_hi|!bank,y
	STA.b !wiggler_segment_ptr+$1
	LDA.b #!wiggler_segment_buffer>>16
	STA.b !wiggler_segment_ptr+$2
	RTS
warnpc $02F029|!bank
assert wigini == $02EFF2|!bank, "wiggler init moved"


; very beginning of wiggler main (after the wrapper)
org $02F035|!bank
	JSR.w wiggler_segment_ptr_init|!bank
org $02F067|!bank
wiggler_offscreen_invoc:
	JMP.w wiggler_offscreen_call|!bank
.done

pullpc
wiggler_init_find_segslot:
	TYA               ; \ restore code
	STA.w !157C,x     ; /
	LDY #$03
.findslot_loop
	LDX.w !wiggler_segment_slots,y
	; if negative, a wiggler despawned and cleared the slot
	BMI .found
	; check that we've spawned in a slot
	; that a wiggler sat in previously
	CPX.w $15E9|!addr
	BEQ .found
	%sprite_num(LDA,x)
	CMP.b #$86
	BNE.b .found
	LDA.w !sprite_status,x
	BEQ.b .found
	DEY
	BPL.b .findslot_loop
.spawn_fail:
	LDX.w $15E9|!addr
	; kill self: no room to spawn (ensure enabling respawn)
	LDA.b #$00
	LDY.w !161A,x
	STA.w !14C8,x
	STA.w !1938,y
;	LDA.w !161A,x
;	TAX
;	LDA.b #$00
;	STA.l !7FAF00,x
;	LDX.w $15E9|!addr
	JML.l wigini_seg_init_done|!bank
.found:
	LDA.w $15E9|!addr
	; store this wigglers sprite slot number to
	; track what slot has what index
	STA.w !wiggler_segment_slots,y
	; x gets sprite slot
	TAX
	; a gets wiggler segment buffer index
	TYA
	; track the buffer index in a previously unused sprite table
	STA.w !wiggler_buffer_index,x
	JML.l wigini_segptr_init|!bank
pushpc

org $02F0DB|!bank
wiggler_update_segment_buffer:
	LDA   !wiggler_segbuff_position,x
	DEC
	DEC
	AND.b #$7E
	STA   !wiggler_segbuff_position,x
	TAY
	LDA   !sprite_x_low,x
	STA.b [!wiggler_segment_ptr],y
	INY
	LDA   !sprite_y_low,x
	STA.b [!wiggler_segment_ptr],y
	RTS
wiggler_offscreen_call:
	JSR.w $02D025|!bank
	LDA.w !sprite_status,x
	BNE.b .nodespawn
;	CMP.b #$08
;	BCS.b .nodie
	LDA.b #$80
	LDY.w !wiggler_buffer_index,x
	STA.w !wiggler_segment_slots,y
.nodespawn:
;	RTS
	JMP.w wiggler_offscreen_invoc_done
warnpc $02F104|!bank

; actual remap next

; note: init routine modified to make 1504 hold the extra bit.
;       the alternate face tile is tile $04 (extra bit or'd into head tile)
;       so bit 3 of the head tile should always be clear: there is one byte
;       available to change it into a clc : adc though

!wiggler_head_tile       = $00
!wiggler_angry_eyes_tile = $08
!wiggler_flower_tile     = $18
; yxppccct
!wiggler_flower_palette  = $0A

; this is relocated slightly
org $02F0D8|!bank
	JMP.w wiggler_gfx|!bank

; no angery on extra bit set
org $02F274|!bank
	JMP wiggler_no_angery_eb

org $02F2D3|!bank
wiggler_small_tile_xoffs:
	db $00,$08
	db $04,$04

org $02F103|!bank
wiggler_no_angery_eb:
	LDA.w !wiggler_bloomer,x
	ORA.w !151C,x
	JMP.w $02F277|!bank
	; pads the graphics routine
;	NOP #6
wiggler_segment_buff_offs:
	db $00,$1E,$3E,$5E,$7E
wiggler_segment_yoffs:
	db $00,$01,$02,$01
wiggler_body_tiles:
	db $02,$0D,$06,$02
wiggler_small_tiles:
	db !wiggler_flower_tile, !wiggler_flower_tile
	db !wiggler_angry_eyes_tile, !wiggler_angry_eyes_tile
wiggler_small_tile_yoffs:
	db $F8,$F8
	db $00,$00
wiggler_gfx:
	JSR.w $02D378|!bank
	LDA.w !wiggler_bloomer,x
	STA.b $0B
	LDA.w !1570,x     ; \ animation frame counter
	STA.b $03         ; /
	LDA.w !15F6,x     ; \ yxppccct
	STA.b $07         ; /
	LDA.w !151C,x     ; \ wiggler is angry flag
	STA.b $08         ; /
	LDA   !C2,x       ; \ bitfield: segment direction flag
	STA.b $02         ; /
	LDA   !wiggler_segbuff_position,x
	STA.b $0C
	LDX.b #$00
.draw_loop:
	INY   #4          ; angry face/flower tile drawn later
	STY.b $0A         ; > sprite OAM index
	STX.b $05
	LDA.b $03
	LSR   #3
	CLC
	ADC.b $05         ; current loop index
	AND.b #$03
	STA.b $06         ; body tile yoff table index
	LDA.w wiggler_segment_buff_offs,x
	LDY.b $08
	BEQ.b .no_angry
	LSR
	AND.b #$FE
.no_angry:
	CLC
	ADC.b $0C
	AND.b #$7E
	TAY
	STY.b $09         ; index to segment buffer
	LDA.b [!wiggler_segment_ptr],y
	SEC
	SBC.b $1A
	LDY.b $0A
	STA.w $0300|!addr,y
	LDY.b $09
	INY
	LDA.b [!wiggler_segment_ptr],y
	SEC
	SBC.b $1C
	LDX.b $06
	SEC
	SBC.w wiggler_segment_yoffs,x
	LDY.b $0A
	STA.w $0301|!addr,y
	LDA.b #!wiggler_head_tile
	ORA.b $0B
	LDX.b $05
	BEQ .draw_head
	LDX.b $06
	LDA.w wiggler_body_tiles,x
.draw_head:
	LDY.b $0A
	STA.w $0302|!addr,y
	LDA.b $07
	ORA.b $64
	LSR.B $02
	BCS .no_flip
	ORA.b #$40
.no_flip:
	STA.w $0303|!addr,y
	LDX.b $05
	; changing this to a DEX/BPL would require reversing the bitfield
	; in the C2 table, at least
	INX
	CPX.b #$05
	BNE.b .draw_loop
	LDX.w $15E9|!addr
	LDY.w !15EA,x
	LDA.b $08
	ASL
	ORA.w !157C,x           ; horz facing dir
	TAX
	LDA.w wiggler_small_tiles,x
	STA.w $0302|!addr,y
	; carry clear free from above: won't overflow
	LDA.w $0304|!addr,y
	ADC.w wiggler_small_tile_xoffs,x
	STA.w $0300|!addr,y
	LDA.w $0305|!addr,y
	CLC
	ADC.w wiggler_small_tile_yoffs,x
	STA.w $0301|!addr,y
	LDA.w $0307|!addr,y
	CPX.b #$02
	BCS.b .not_flower
	AND.b #$F1
	ORA.b #!wiggler_flower_palette
.not_flower:
	STA.w $0303|!addr,y
	TYA
	LSR   #2
	TAY
	; store tilesizes
	; this is shorter and less cycles than
	; staying in 8-bit mode
	REP.b #$20
	LDA.w #$0200
	STA.w $0460|!addr,y
	; is one byte larger but one cycle faster than two INCs
	LDA.w #$0202
	STA.w $0462|!addr,y
	STA.w $0464|!addr,y
	SEP.b #$20
	LDX.w $15E9|!addr
	LDA.b #$05
	LDY.b #$FF
	JSL.l $01B7B3|!bank
.fin:
assert .fin == $02F202|!bank
warnpc $02F202|!bank

; extended flower spawn
org $02F2E4|!bank
	JSR.w extsprite_spawn_bank2|!bank

; extended flower sprite: tile store
org $029D2F|!bank
	LDA.b #!wiggler_flower_tile
	JSR.w ext_store_tile1_lo_bank2|!bank
