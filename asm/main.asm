incsrc "headers/consts.asm"
incsrc "headers/toggles.asm"
incsrc "headers/macros.asm"
incsrc "headers/routines.asm"
incsrc "headers/ram.asm"
incsrc "headers/ssp.asm"

if not(defined("sa1def_incl"))
	incsrc "pixi/asm/sa1def.asm"
endif

incsrc "headers/structs.asm"
