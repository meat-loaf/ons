init:
	LDA #!level_status_flag_always_slip
	STA !level_status_flags_1
	RTL
