includefrom "remaps.asm"

!springboard_full_tile  = $0E
!springboard_pcomp_tile = $0F
!springboard_fcomp_tile = $1E
!springboard_empty_tile = $71

!turn_block_tile  = $C2
!qmark_block_tile = $C4
!onoff_block_tile = $C6
!note_block_tile  = $48
!side_bounce_blk_tile = !turn_block_tile

!wing_out_tile = $EC
!wing_in_tile  = $FE
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
	db $4E
; 8x8s
org $029A6E|!bank
	db $40,$50,$40

org $0291F1|!bank
	db !turn_block_tile
	db !note_block_tile
	db !qmark_block_tile
	db !side_bounce_blk_tile
	db $EA
	db !onoff_block_tile
	db !turn_block_tile
