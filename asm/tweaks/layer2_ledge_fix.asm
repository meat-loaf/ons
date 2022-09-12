incsrc "../main.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Layer 2 ledge drop fix, by mario90
;; 
;; This fixes the higher fall speed Mario has when walking off ledges on layer 2
;; Needs 1 byte of freeram to keep track of Mario's Layer 2 status 
;  since the air flag is set the next frame after determining Mario is on layer 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00EE35
autoclean JSL AirFlagTweak

org $00EF60
autoclean JML Layer2Flag

freecode

AirFlagTweak:
	LDA #$24		;Original code to flag if Mario is in the air
	STA $72
	LDA $1402|!addr		;Ignore the tweak if on a noteblock
	BNE Return
	LDA !asstd_state_flags_1	;If Mario was on Layer 2, jump to speed tweak
	BIT #!state_flag_player_l2_lastf
	BNE Layer2
Return:
	STZ !asstd_state_flags_1	;Clear the flag
	RTL
Layer2:
	LDA #$06		;Vanilla Y speed setting when Mario is on ground
	STA $7D
	LDA #!state_flag_player_l2_lastf
	TRB !asstd_state_flags_1	;Clear the flag
	RTL	
	
Layer2Flag:
	LDX $8E			;Check for Mario on Layer 2
	BPL NormalY
	TAX
	LDA #!state_flag_player_l2_lastf
	TSB !asstd_state_flags_1
	TXA
NormalY:
	STA $7D			;Restore original code
	TAX
	BPL CODE_00EF68
	JML $00EF65|!bank
CODE_00EF68:
	JML $00EF68|!bank
