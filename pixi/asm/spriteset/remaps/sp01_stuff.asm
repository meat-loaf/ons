includefrom "remaps.asm"


!wing_out_tile = $EC
!wing_in_tile  = $FE
; goomba wings
org $018DE1|!bank
	db !wing_out_tile, !wing_out_tile
	db !wing_in_tile, !wing_in_tile

; sprite spinjump smoke tiles
org $019A4E|!bank
	db $E4,$E2,$E0,$E2

; koopas

; koopa wings
org $019E1C|!bank
	db !wing_in_tile, !wing_out_tile
	db !wing_in_tile, !wing_out_tile

; point all shelless koopas at the same tmap
org $019C7F|!bank
	db $10,$10,$10,$10

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
