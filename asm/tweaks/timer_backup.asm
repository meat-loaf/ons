incsrc "../main.asm"

org $0584D7|!addr
timer_table:
	db $00,$03,$04,$05

org $058581|!bank
do_you_have_the_time:
	BNE.b .in_sublvl
	LDA.l $0584D7|!bank,x
	STA.w !time_huns_bak
	STA.w $0F31|!addr
	STZ.w $0F32|!addr
	STZ.w $0F33|!addr
.in_sublvl:
	LDA.b $00
	AND.b #$07
	STA.w $192D|!addr
	LDA.b $00
	AND.b #$38
	LSR   #3
	STA.w $192E|!addr
	INY
	LDA.b [$65],y
	AND.b #$0F
	STA.w $1931|!addr
.done:
assert .done == $0585AC|!bank
