incsrc "../main.asm"

org $0584D7|!addr
timer_table:
	db $00,$03,$04,$05

org $058581|!bank
do_you_have_the_time:
	BNE .in_sublvl
	LDA $0584D7|!bank,x
	STA !time_huns_bak
	STA $0F31|!addr
	STZ $0F32|!addr
	STZ $0F33|!addr
.in_sublvl:
	LDA $00
	AND #$07
	STA $192D|!addr
	LDA $00
	AND #$38
	LSR #3
	STA $192E|!addr
	INY
	LDA [$65],y
	AND.b #$0F
	STA $1931|!addr
.done:
print "timer pc $", pc
assert .done == $0585AC|!bank
