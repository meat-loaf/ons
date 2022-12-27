
!bank3_starting_sprite_num = $B9

bank3_callspr_main:
	phb
	phk
	plb
	jsr .do_call
	plb
	rtl
.do_call
	lda !sprite_num,x
	sec
	sbc #!bank3_starting_sprite_num
	asl
	tay
	lda .rts+1,y
	pha
	lda .rts,y
	pha
	rts
.rts:
	dw starcoin_main-1
	dw $0000
	dw $0000
	dw $0000
	dw yi_pswitch_main-1
	dw $0000
	dw mega_mole_main-1
