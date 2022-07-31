macro waterfall_timer()

	LDA !waterfall_reset_drop_timer
	BNE ?+
	STZ !waterfall_drop_timer
	BRA ?++
?+
	DEC !waterfall_reset_drop_timer
?++
endmacro

macro timer(addr)
	LDA <addr>
	BEQ ?+
	DEC <addr>
?+
endmacro

main:
	JSL ScreenScrollingPipes_SSPMaincode
	%waterfall_timer()
	%timer(!on_off_cooldown)

	LDA !level_status_flags_1
	AND #!level_status_flag_always_slip
	BNE .do_slip
        ; enable slippery block functionality
	LDA #$00
	CMP !mario_slip
	BEQ .no_slip
	STA !mario_slip
.do_slip:
	LDA #!slip_block_slipperyness
.no_slip:
	STA !level_slippery
.out:
	RTL

