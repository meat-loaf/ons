incsrc "../main.asm"

org $00F5B9
	BNE hurt_branch_return
org $00F5C4
	BNE hurt_branch_return

org $00F5F1
	BRA hurt_branch
org $00F604
	BRA powerdown_branch
org $00F61B
	STZ !vert_scroll_setting
	LDA #$30
powerdown_branch:
	STA !player_ani_timer
	STA !sprites_locked
hurt_branch:
	STZ !flight_phase
.return
	RTL
