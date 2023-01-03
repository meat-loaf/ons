%set_free_start("bank4")
sub_horz_pos:
	ldy #$00
	lda $94
	sec
	sbc !E4,x
	sta $0E
	lda $95
	sbc !14E0,x
	sta $0F
	bpl .left
	iny
.left:
	rtl

; todo suboffscreen,
;      getdrawinfo maybe
spr_long_rts_done:
%set_free_finish("bank4", spr_long_rts_done)
