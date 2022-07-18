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

;	LDA !level_status_flags_1    ; this logic is a bit involved,
;	AND #!level_status_flag_enable_slip
;	BEQ .out
; enable slippery block functionality
	LDA #$00
	CMP !mario_slip
	BEQ .no_slip
	STA !mario_slip
	LDA #!slip_block_slipperyness
.no_slip
	STA !level_slippery

; sprite slippery
; TODO it would be nice to put this somewhere sprites are already looped,
; if possible...then we could get rid of the above flag
;	LDX #!num_sprites-1
;.spr_loop
;	LDA #$00
;	CMP !spr_sprite_slip,x
;	BEQ .no_slip_spr
;	STA !spr_sprite_slip,x
;	LDA #!slip_block_slipperyness
;.no_slip_spr
;	STA !spr_sprite_slip_f,x
;	DEX
;	BPL .spr_loop
;
.out
	RTL

