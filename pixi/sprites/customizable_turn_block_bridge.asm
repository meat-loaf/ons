; Customizable Turn Block Bridge
; by meatloaf, based upon my own disassembly

!brick_block_tile  = $C2
!turn_block_tile  = $C4
!qmark_block_tile = $C0
!onoff_block_tile = $C6
!note_block_tile  = $48
!side_bounce_blk_tile = !turn_block_tile
!turn_block_bridge_tile = !turn_block_tile

get_mario_clipping = $03B664|!bank
check_contact      = $03B72B|!bank

print "INIT ", hex(cturn_block_bridge_init)
print "MAIN ", hex(cturn_block_bridge_main)

; toggle to flip the rightmost/topmost bridge tile, like in vanilla
!flip_last_tile = 0

!bridge_length = !151C
!bridge_tile   = !1602

!layer_1_x     = $1A
!layer_1_y     = $1C

cturn_block_bridge_init:
	PHB : PHK : PLB
	LDY #$00
	LDA !extra_byte_1,x
	AND #$F8
	BEQ .no_trigger
	LDY #$08
.no_trigger:
	; initial state index is 
	STY $00
	LDA !extra_byte_1,x
	AND #$07
	ORA $00
	TAY
	LDA .initial_state,y
	STA !C2,x

	LDA !extra_byte_1,x
	AND #$04
	BEQ .pal_tileset
	LDA #$20
	STA !bridge_length,x
.pal_tileset:
	; tile/palette index is trigger index * 2 + extra_bit
	LDA !extra_byte_1,x
	AND #$F8
	LSR #2
	STA $00
	LDA !extra_bits,x
	AND #$04
	LSR #2
	ORA $00
	TAY
	LDA .tile,y
	STA !bridge_tile,x
	LDA .pal_15f6_val,y
	STA !sprite_oam_properties,x
	PLB
	RTL

.pal_15f6_val:
	; no trigger
	db $00,$02
	; first trigger
	db $5<<1,$4<<1
	; second trigger
	db $3<<1,$1<<1
.tile:
	; no trigger
	db !turn_block_tile,!turn_block_tile
	; first trigger
	db !turn_block_tile,!turn_block_tile
	; second trigger
	db !qmark_block_tile,!qmark_block_tile
.initial_state:
	db $00,$00,$02,$02
	db $01,$01,$03,$03
	db $03,$01,$03,$01
	db $00,$00,$02,$02


print "MAIN ", pc
cturn_block_bridge_main:
	PHB : PHK : PLB
	LDA !14C8,x
	ORA $9D
	EOR #$08
	BNE .done
	%SubOffScreen()
	JSR turn_block_bridge_gfx
	JSR turn_block_bridge_handle_interact
.done:
	PLB
	RTL

; ripped directly from SMW, unchanged except for addition of shared routines/defines
turn_block_bridge_gfx:
	%GetDrawInfo()
	STZ $00
	STZ $01
	STZ $02
	STZ $03
	LDA !C2,x
	AND #$02
	TAY
	LDA !bridge_length,x
	STA $00|!dp,y
	LSR
	STA $01|!dp,y
	LDY !sprite_oam_index,x
	LDA !sprite_y_low,x
	SEC
	SBC !layer_1_y
	STA $0301+$10|!addr,y
	PHA
	PHA
	PHA
	SEC
	SBC $02
	STA $0301+$08|!addr,y
	PLA
	SEC
	SBC $03
	STA $0301+$0C|!addr,y
	PLA
	CLC
	ADC $02
	STA $0301+$00|!addr,y
	PLA
	CLC
	ADC $03
	STA $0301+$04|!addr,Y
	LDA !sprite_x_low,x
	SEC
	SBC !layer_1_x
	STA $0300+$10|!addr,y
	PHA
	PHA
	PHA
	SEC
	SBC $00
	STA $0300+$08|!addr,y
	PLA
	SEC
	SBC $01
	STA $0300+$0C|!addr,y
	PLA
	CLC
	ADC $00
	STA $0300+$00|!addr,y
	PLA
	CLC
	ADC $01
	STA $0300+$04|!addr,y

	LDA !bridge_tile,x
	STA $0302+$04|!addr,y
	STA $0302+$0C|!addr,y
	STA $0302+$10|!addr,y
	STA $0302+$08|!addr,y
	STA $0302+$00|!addr,y
	LDA !sprite_oam_properties,x
	ORA $64
	STA $0303+$0C|!addr,y
	STA $0303+$04|!addr,y
	STA $0303+$08|!addr,y
	STA $0303+$10|!addr,y
if !flip_last_tile
	ORA #$60
endif
	STA.W $0303+$00|!addr,y
	LDA $00
	PHA
	LDA $02
	PHA
	LDA #$04
	LDY #$02
	%FinishOAMWrite()
	PLA
	STA $02
	PLA
	STA $00
	RTS

turn_block_bridge_handle_interact:
	LDA !sprite_off_screen,x
	BNE .ret
	LDA $71
	CMP #$01
	BCS .ret
	JSR turn_block_bridge_check_interact
	BCC .ret
	LDA !sprite_y_low,x
	SEC
	SBC !layer_1_y
	STA $02
	SEC
	SBC $0D
	STA $09
	LDA $80
	CLC
	ADC #$18
	CMP $09
	BCS ADDR_01B8B2
	LDA $7D
	BMI .ret
	STZ $7D
	LDA #$01
	STA $1471|!addr
	LDA $0D
	CLC
	ADC #$1F
	LDY $187A|!addr
	BEQ .no_yoshi
	CLC
	ADC #$10
.no_yoshi:
	STA $00
	LDA !sprite_y_low,x
	SEC
	SBC.B $00
	STA $96
	LDA.W !sprite_x_high,x
	SBC.B #$00
	STA $96+$01
	LDY.B #$00
	LDA.W $1491|!addr
	BPL +
	DEY
+
	CLC
	ADC $94
	STA $94
	TYA
	ADC $94+$01
	STA $94+$01
.ret:
	RTS
ADDR_01B8B2:
	LDA $02
	CLC
	ADC $0D
	STA $02
	LDA #$FF
	LDY $73
	BNE +
	LDY $19
	BNE ++
+
	LDA #$08
++
	CLC
	ADC $80
	CMP $02
	BCC ADDR_01B8D5
	LDA $7D
	BPL +
	LDA #$10
	STA $7D
+
	RTS

ADDR_01B8D5:
	LDA $0E
	CLC
	ADC #$10
	STA $00
	LDY #$00
	LDA !sprite_x_low,X
	SEC
	SBC !layer_1_x
	CMP $7E
	BCC +
	LDA $00
	EOR #$FF
	INC A
	STA $00
	DEY
+
	LDA !sprite_x_low,X
	CLC
	ADC $00
	STA $94
	TYA
	ADC !sprite_y_high,x
	STA $94+$01
	STZ $7B
	RTS


turn_block_bridge_check_interact:
	LDA $00
	STA $0E
	LDA $02
	STA $0D
	LDA !sprite_x_low,x
	SEC
	SBC $00
	STA $04
	LDA !sprite_y_high,x
	SBC #$00
	STA $0A
	LDA $00
	ASL
	CLC
	ADC #$10
	STA $06
	LDA !sprite_y_low,x
	SEC
	SBC $02
	STA $05
	LDA !sprite_x_high,x
	SBC #$00
	STA $0B
	LDA $02
	ASL
	CLC
	ADC #$10
	STA $07
	JSL get_mario_clipping
	JSL check_contact
	RTS

