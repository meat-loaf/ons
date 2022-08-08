includefrom "remaps.asm"


!wiggler_segment_buffer = $7F9A7B

; wiggler init
org $02EFF2|!bank
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
	STA.b [$D5],y
	DEY
	LDA.b !E4,x
	STA.b [$D5],y
	DEY
	BPL.b .seg_buff_init_loop
.seg_init_done:
	PLB
	RTL
wiggler_segment_ptr_init:
	LDY !160E,x
	LDA.b #!wiggler_segment_buffer
	CLC
	ADC.w $02EFEA|!bank,y
	STA.b $D5+$0
	LDA.b #!wiggler_segment_buffer>>8
	CLC
	ADC.w $02EFEE|!bank,y
	STA.b $D5+$1
	LDA.b #!wiggler_segment_buffer>>16
	STA.b $D5+$2
	RTS
warnpc $02F029|!bank

; very beginning of wiggler main (after the wrapper)
org $02F035|!bank
	JSR.w wiggler_segment_ptr_init|!bank

pullpc
wiggler_init_find_segslot:
	TYA               ; \ restore code
	STA.w !157C,x     ; /
	LDY #$03
.findslot_loop
	LDX.w !wiggler_segment_slots,y
	; check that we've spawned in a slot
	; that a wiggler sat in previously
	CPX.w $15E9|!addr
	BEQ .cont
	%sprite_num(LDA,x)
	CMP.b #$86
	BNE.b .cont
	LDA.w !14C8,x
	BEQ.b .cont
	DEY
	BPL.b .findslot_loop
.spawn_fail:
	LDX.w $15E9|!addr
	; kill self: no room to spawn (ensure enabling respawn)
	LDA.b #$00
	LDY.w !161A,x
	STA.w !14C8,x
	STA.w !1938,x
;	LDA.w !161A,x
;	TAX
;	LDA.b #$00
;	STA.l !7FAF00,x
	LDX.w $15E9|!addr
	JML.l wigini_seg_init_done|!bank
.cont:
	CPY.b #$00
	BEQ.b .done
	STY.b $00
; patch up the lower indexes: its possible for a wiggler to spawn in a slot
; and be assigned an index into the segment slots array, then a wiggler can
; spawn again later in that same slot with a different (higher) index into the
; segment slot array, effectively causing that wiggler to take up multiple chunks
; of the segment buffer, and causing less wigglers to be able to be spawned.
.fix_slots:
	DEY
	LDX.w !wiggler_segment_slots,y
	CPX.w $15E9|!addr
	BNE .next
	LDA.b #$FF
	STA.w !wiggler_segment_slots,y
.next
	DEY
	BPL.b .fix_slots
	LDY.b $00
.done:
	LDA.w $15E9|!addr
	; store this wigglers sprite slot number to
	; track what slot has what index
	STA.w !wiggler_segment_slots,y
	; x gets sprite slot
	TAX
	; a gets wiggler segment buffer index
	TYA
	; track the buffer index in a previously unused sprite table
	STA.w !160E,x
	JML.l wigini_segptr_init|!bank
pushpc

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
	LDA.w !1504,x
	ORA.w !151C,x
	JMP.w $02F277|!bank
	; pads the graphics routine
	NOP #7
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
	LDA.w !1504,x
	STA.b $0B
	LDA.w !1570,x     ; \ animation frame counter
	STA.b $03         ; /
	LDA.w !15F6,x     ; \ yxppccct
	STA.b $07         ; /
	LDA.w !151C,x     ; \ wiggler is angry flag
	STA.b $08         ; /
	LDA   !C2,x       ; \ bitfield: segment direction flag
	STA.b $02         ; /
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
	TAY
	STY.b $09         ; index to segment buffer
	LDA.b [$D5],y
	SEC
	SBC.b $1A
	LDY.b $0A
	STA.w $0300|!addr,y
	LDY.b $09
	INY
	LDA.b [$D5],y
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
;	CLC
;	ADC.b !tile_off_scratch
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
;	CLC
;	ADC.b !tile_off_scratch
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
	LDA.b #$00
	STA.w $0460|!addr,y
	LDA.b #$02
	STA.w $0461|!addr,y
	STA.w $0462|!addr,y
	STA.w $0463|!addr,y
	STA.w $0464|!addr,y
	STA.w $0465|!addr,y
	
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
