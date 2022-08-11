includefrom "remaps.asm"

!springboard_full_tile  = $0E
!springboard_pcomp_tile = $0F
!springboard_fcomp_tile = $1E
!springboard_empty_tile = $71

!turn_block_tile  = $C4
!qmark_block_tile = $C0
!onoff_block_tile = $C6
!note_block_tile  = $48
!side_bounce_blk_tile = !turn_block_tile

!spinning_coin_tile_full = $CA
!spinning_coin_top       = $40
!spinning_coin_bottom    = $50

!wing_out_tile = $EC
!wing_in_tile  = $FE

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
	INC.w !red_coin_counter
	LDY.b #!red_coin_sfx_id
	LDA.w !red_coin_total
	CLC
	ADC.w !red_coin_counter
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
	db $C0
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
