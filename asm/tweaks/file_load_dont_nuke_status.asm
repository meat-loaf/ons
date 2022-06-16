incsrc "../main.asm"

org $009788|!bank
	JMP status_setup_done

org $009E1C|!bank
game_start_player_status_setup:
	LDA.w $0DB2|!addr            ; two player game?
	BEQ   .one_player            ; branch if not
	LDA.w $0DB3|!addr            ; character in play (from sram)
	ASL   #2                     ; x 2
	STA.w $0DD6|!addr            ; for score indexing
	LDX.w $0DB3|!addr            ; load non-score current player index
	BRA .load_vals
.one_player
	STA.w $0DB3|!addr            ; zero no matter what (one player)
	STA.w $0DD6|!addr            ; same
	TAX
.load_vals:
	; update current player lives
	LDA.w $0DB4|!addr,x
	STA.w $0DBE|!addr
	; update current player coins
	LDA.w $0DB6|!addr,x
	STA.w $0DBF|!addr
	; update current player powerup
	LDA.w $0DB8|!addr,x
	STA.b $19|!dp
	; update current player yoshi
	LDA.w $0DBA|!addr,x
	STA.w $13C7|!addr
	; update current player item box item
	LDA.w $0DBC|!addr,x
	STA.w $0DC2|!addr

	; other stuff that needs to be initialized
	STZ.w $0DD5|!addr
	STZ.w $13C9|!addr
status_setup_done:
	; keep mode active
	JSR $9F29
	LDY #$0B
	JMP $9C8B
print "done at: $", pc, ". free until $809E67"
warnpc $009E67|!bank
