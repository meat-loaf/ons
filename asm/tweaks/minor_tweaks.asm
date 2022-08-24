incsrc "../main.asm"

; bank 00: score sprite load: used to be pha/pla
; (saves...1 cycle. probably a waste of time to even write, but here we are.)
org $00F38A|!bank
obj_spawn_score_sprite:
	XBA
	skip 4
	XBA
