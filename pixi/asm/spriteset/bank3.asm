includefrom "remaps.asm"

org $01878E|!bank
bank3_sprcaller:
	jsl bank3_callspr_main
	rts

org $038007|!bank
incsrc "bank3/bank3_callspr.asm"
incsrc "bank3/dyn_spr_rts.asm"
incsrc "bank3/starcoin.asm"
incsrc "bank3/yi_pswitch.asm"
incsrc "bank3/mega_mole.asm"
incsrc "bank3/castle_block.asm"
incsrc "bank3/woozy.asm"

warnpc $03B56C|!bank
