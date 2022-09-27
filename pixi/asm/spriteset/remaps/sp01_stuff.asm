includefrom "remaps.asm"

!springboard_full_tile  = $0E
!springboard_pcomp_tile = $0F
!springboard_fcomp_tile = $1E
!springboard_empty_tile = $71

!brick_block_tile  = $C2
!turn_block_tile  = $C4
!qmark_block_tile = $C0
!onoff_block_tile = $C6
!note_block_tile  = $48
!side_bounce_blk_tile = !turn_block_tile
!turn_block_bridge_tile = !turn_block_tile

!spinning_coin_tile_full = $CA
!spinning_coin_top       = $40
!spinning_coin_bottom    = $50

!wing_out_tile = $EC
!wing_in_tile  = $FE

; key tile
org $01A1FA|!bank
	db $42
; top of keyhole
org $01E251|!bank
	db $41
; bottom of keyhole
org $01E256|!bank
	db $51
; turn block bridge
;org $01B77E|!bank
;	db !turn_block_tile
; disable turn block bridge tile flip
;org $01B79C
;	ORA.b #$00

org $01B779|!bank
tbb_gfx_mod:
;	LDA #!turn_block_bridge_tile
	LDA !1602,x
	STA.w $0302+$10,y
	STA.w $0302+$0C,y
	STA.w $0302+$08,y
	STA.w $0302+$04,y
	STA.w $0302+$00,y
	LDA.b $64
	ORA.w !sprite_oam_properties,x
	STA.w $0303+$10,y
	STA.w $0303+$0C,y
	STA.w $0303+$08,y
	STA.w $0303+$04,y
	STA.w $0303+$00,y
	LDA $00
	PHA
	LDA $02
	PHA
	LDA #$04
	JSR.w $01B37E|!bank
	PLA
	STA $02
	PLA
	STA $00
	RTS
warnpc $01B7B2|!bank

;horz/vert turn block bridges
%replace_pointer($01822f|!bank,turn_block_bridge_init|!bank)

%replace_pointer($01867E|!bank,turn_block_bridge_main|!bank)
%replace_pointer($018680|!bank,turn_block_bridge_main|!bank)

; turn block bridge: faster on extra bit set
org $01B6A0|!bank
turn_block_bridge_length:
	db $20,$00
	db $20,$00
turn_block_bridge_speed:
	db $01,$FF
	db $02,$FE
turn_block_bridge_timing:
	db $40,$40
	db $20,$20
turn_block_bridge_main:
	; suboffscreen
	JSR.w $01AC31|!bank
	; turn block bridge gfx
	JSR.w $01B710|!bank
	; handle mario
	JSR.w $01B852|!bank
	LDA   !C2,x
	AND.b #$01
	STA.b $00
	LDA   !extra_bits,x
	AND.b #$04
	LSR
	ORA   $00
	; Y in [0,3]
	; 0 or 1 if exbit unset, 2 or 3 if exbit set
	TAY
	LDA.w !151C,x
	CMP.w turn_block_bridge_length,y
	BEQ.b .next_phase
	LDA.w !1540,x
	ORA.b !sprites_locked
	BNE.b .done
	LDA.w !151C,x
	CLC
	ADC.w turn_block_bridge_speed,y
	STA.w !151C,x
.done:
	RTS
.next_phase:
	JML tbb_next_phase_free|!bank
tbb_cont:
pullpc
tbb_next_phase_free:
	PHB : PHK : PLB
	LDA !extra_byte_1,x
	AND #$F8
	BEQ .no_trigger
	LSR #2
	TAX
	JSR (.triggers-2,x)
	LDA !1558,x
	BNE .done
.no_trigger:
	LDA !154C,x
	BNE .no_timer
	TYX
	LDA.l turn_block_bridge_timing,x
	LDX $15E9|!addr
	STA.w !1540,x
.no_timer:

;	AND #$08
;	BEQ .no_onoff
;	LDA !on_off_state
;	CMP !1534,x
;	BEQ .done
;	STA !1534,x
;	INC !154C,x
;.no_onoff:
;	LDA !154C,x
;	BNE .notimer
;	LDA.w turn_block_bridge_timing,y
;	STA.w !1540,x
;.notimer:
	LDA !extra_byte_1,x
	AND #$03
	CMP #$02
	BEQ .v_only
	LDY   !C2,x
	INY
	LDA !extra_byte_1,x
	AND #$03
	CMP #$01
	; TODO this is hella fugly
	BNE .hv
.h_only:
	TYA
	AND #$01
	TAY
.hv:
	TYA
	STA !C2,x
	PLB
	JML turn_block_bridge_main_done|!bank
.v_only:
	LDA !C2,x
	INC
	CMP #$04
	BCC .nofix
	LDA #$02
.nofix:
	STA !C2,x
.done:
	PLB
	JML turn_block_bridge_main_done|!bank
.triggers:
	dw on_off
	dw blue_pow
on_off:
	LDX $15E9|!addr
	LDA !on_off_state
	CMP !1534,x
	BEQ dont_trigger
	STA !1534,x
	INC !154C,x
	RTS
blue_pow:
	LDA #$00
	LDX !blue_pswitch_timer
	BEQ .check
	INC
.check:
	LDX $15E9|!addr
	CMP !1534,x
	BEQ dont_trigger
	STA !1534,x
	INC !154C,x
	RTS
dont_trigger:
	INC !1558,x
	RTS
pushpc

org tbb_cont
; bit 0: only horiz if set
; bit 1: only vert if set
; same behavior if both are set or both are unset (vert and horiz movement), except
; it starts by expanding vertically.
turn_block_bridge_init:
	PHX
	LDY #$00
	LDA !extra_byte_1,x
	AND #$F8
	BEQ .no_trigger
	LDY #$08
.no_trigger:
	STY $00
	LDA !extra_byte_1,x
	AND #$07
	ORA $00
	TAX
	LDA.l tbb_initial_state,x
	PLX
	STA !C2,x
	LDA !extra_byte_1,x
	AND #$04
	BEQ .no_extend
	LDA #$20
	STA !151C,x
.no_extend:
	JML tbb_palset|!bank
warnpc $01B710|!bank
pullpc
tbb_initial_state:
	db $00,$00,$02,$02
	db $01,$01,$03,$03
	db $03,$01,$03,$01
	db $00,$00,$02,$02
tbb_palset:
	LDA !extra_byte_1,x
	AND #$F8
	LSR #2
	STA $00
	LDA !extra_bits,x
	AND #$04
	LSR #2
	ORA $00
	TAX
	LDA.l tbb_tile,x
	TAY
	LDA.l tbb_15f6_val,x
	LDX $15E9|!addr
	STA !15F6,x
	TYA
	STA !1602,x
	JML turn_block_bridge_main_done|!bank
tbb_15f6_val:
	; no trigger
	db $00,$02
	; first trigger
	db $5<<1,$4<<1
	; second trigger
	db $3<<1,$1<<1
tbb_tile:
	; no trigger
	db !turn_block_tile,!turn_block_tile
	; first trigger
	db !turn_block_tile,!turn_block_tile
	; second trigger
	db !qmark_block_tile,!qmark_block_tile
pushpc


; moving coin normal sprite: 16x16
org $01C653|!bank
	db !spinning_coin_tile_full
; moving coin normal sprite: 8x8s
org $01C66D|!bank
	db !spinning_coin_top
	db !spinning_coin_bottom
	db !spinning_coin_top

org $01C4CF|!bank
	JSL.l spinning_coin_red_exbit|!bank
pullpc
spinning_coin_red_exbit:
	LDA   !spr_extra_bits,x
	AND.b #$04
	BNE.b .red
	JML.l $05B34A|!bank    ; coin + sfx
.red:
	INC.w !red_coin_adder
	LDY.b #!red_coin_sfx_id
	LDA.w !red_coin_total
	CLC
	ADC.w !red_coin_adder
	CMP.b #20
	BCC.b .not_final_coin
	INY
.not_final_coin:
	STY.w !red_coin_sfx_port
	
	LDY.w $1865|!addr
	BPL.b .nofix
	LDY.b #$03
	STY.w $1865|!addr
.nofix:
	LDA.b #$02
	STA.w $17D0|!addr,y

	LDA   !D8,x
	STA.w $17D4|!addr,y
	LDA.w !14D4,x
	STA.w $17E8|!addr,y
	LDA   !E4,x
	STA.w $17E0|!addr,y
	LDA.w !14E0,x
	STA.w $17EC|!addr,y

	LDA.b #$D0
	STA.w $17D8|!addr,y

	DEC $1865|!addr

	PLA                ; \
	PLA                ; | destroy the JSL
	PLA                ; /
	JML $01C4FA|!addr  ; 'return' to an RTS
pushpc

; goomba wings
org $018DE1|!bank
	db !wing_out_tile, !wing_out_tile
	db !wing_in_tile, !wing_in_tile

; sprite spinjump smoke tiles
org $019A4E|!bank
	db $E4,$E2,$E0,$E2
; extended smoke tiles
org $02A347|!bank
	db $E6,$E4,$E0,$E2
; water splash tiles
org $028D42|!bank
	db $E8,$E8,$EA,$EA,$EA,$E2,$E2,$E2
	db $E4,$E4,$E4,$E4,$E6

; pswitch - jsr to jmp (why does it write the tile again...?)
org $01A21D|!bank
	db $4C

org shared_spr_routines_tile_addr($3E)
	db $6A

; pswitch skooshed frame
org $01E723|!addr
	db $1F

; springboard
org shared_spr_routines_tile_addr($2F)|!bank
	db !springboard_full_tile,!springboard_full_tile,!springboard_full_tile,!springboard_full_tile
	db !springboard_pcomp_tile,!springboard_pcomp_tile,!springboard_pcomp_tile,!springboard_pcomp_tile
	db !springboard_empty_tile,!springboard_empty_tile,!springboard_fcomp_tile,!springboard_fcomp_tile

; throw block
org shared_spr_routines_tile_addr($53)|!bank
	db $C2
; koopas
; koopa wings
org $019E1C|!bank
	db !wing_in_tile, !wing_out_tile
	db !wing_in_tile, !wing_out_tile

; point all shelless koopas at the same tmap
org $019C7F|!bank
	db $10,$10,$10,$10

; koopa tilemap
org shared_spr_routines_tile_addr($02)
	db $CE,$CC,$CC
	skip 1
	db $80,$00,$00
; make all shelless koopas kick shells
org $01A713|!bank
	db $03     ; immediate argument to CMP
	db $F0     ; BEQ opcode
skip 1
cont:

org $01A77F|!bank
	db $02

; yellow takes branch here: overwrites now-unused 'jump in shell' code
org $01A72E|!bank
	STA.w !187B,y
	BRA.b cont
warnpc $01A75D|!bank

; powerups

!mush_tile = $24
!flower_tile = $26
!star_tile = $28
!feather_tile = $22

org $01C609|!bank
	db !mush_tile
	db !flower_tile
	db !star_tile
	db !feather_tile

; smoke sprite tiles
org $0296D8|!bank
	db $E6,$E6,$E4,$E2,$E0,$E2,$E0
org $029922|!bank
	db $E6,$E6,$E4,$E2,$E2

; spinning coin from block sprite tiles
; 16x16
org $029A4F|!bank
	db !spinning_coin_tile_full
; 8x8s
org $029A6E|!bank
	db !spinning_coin_top
	db !spinning_coin_bottom
	db !spinning_coin_top

org $0291F1|!bank
	db !turn_block_tile
	db !note_block_tile
	db !qmark_block_tile
	db !side_bounce_blk_tile
	db $EA  ; transparent bounce block tile
	db !onoff_block_tile
	db !turn_block_tile

; coin sparkle minor extended sprite
org $028ECC|!bank
	db $E6

; score sprites - 2, 3, 5up
org $02AD5A|!bank
	db $4B, $5B, $5A
