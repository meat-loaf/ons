includefrom "remaps.asm"
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
