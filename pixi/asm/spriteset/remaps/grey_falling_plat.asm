includefrom "remaps.asm"

org $03848E|!bank
grey_falling_plat_tiles:
	db $86,$87,$87,$88

; move to page 1
org $0384AC+$1|!bank
	db $02
