; some temporary shims for long-calling original rts routines
incsrc "jslshims.asm"

; core code
incsrc "load.asm"
incsrc "run.asm"

; sprite-agnostic bank-specific code
incsrc "bank3.asm"
incsrc "bank6.asm"

; spriteset engine code (todo could use reorganization)
!spriteset_offset = !spr_spriteset_off
incsrc "spritesets/spritesets.asm"
