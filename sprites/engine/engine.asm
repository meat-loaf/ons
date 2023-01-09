; some temporary shims for long-calling original rts routines
incsrc "jslshims.asm"

; old sprite types -> new ambient sprites
incsrc "ambient.asm"

; core code
incsrc "load.asm"
incsrc "run.asm"

; generic bank-specific stuff
incsrc "bank1.asm"
; ambient sprites impl
incsrc "bank2.asm"
incsrc "bank3.asm"
; routines only
incsrc "bank4.asm"
incsrc "bank6.asm"

; spriteset engine code (todo could use reorganization)
!spriteset_offset = !spr_spriteset_off
incsrc "spritesets/spritesets.asm"
