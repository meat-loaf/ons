load:
	LDA #!level_status_flag_slope_no_dirt
	TSB !level_status_flags_1
	RTL
init:
; half-color bg
	LDA #%00000010
	STA $2130
	STA $44
	LDA #%01100000
	STA $2131
	STA $40

	STZ $2121

	STZ $2122
	STZ $2122
main:
; layer 2 scrolls 1/4th the rate of layer 1
	REP #$20
	LDA $1462|!addr
	LSR #3
	STA $1466

	LDA $1464
	LSR #3
	STA $1468
	SEP #$20
	RTL
