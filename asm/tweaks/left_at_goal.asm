incsrc "../main.asm"

!GoalTile = $B6

; pre peace-sign goal routine override
org $00C97A|!bank
pre_peace_hijack:
autoclean \
	JSL   set_player_dir_and_get_walk_dir
	LDA.l goal_walk_speed_tbl|!bank,x
	STA   !player_x_spd
.done:
assert .done == $00C984|!bank

; post peace-sign goal routine override
org $00C9C5
	JSL set_goal_walk_direction|!bank

freecode
set_player_dir_and_get_walk_dir:
	JSL set_goal_walk_direction|!bank
	LSR
	EOR #$01
	STA !player_dir
	TAX
	RTL

set_goal_walk_direction:
	LDA !sprite_memory_header
	BIT #!level_status_flag_goal_move_left
	BNE .left
.right:
	LDA #%00000001        ; force holding right
	BRA .set_controller
.left:
	LDA #%00000010        ; force holding left
.set_controller:
	STA !byetudlr_hold    ; store to held buttons
	RTL

goal_walk_speed_tbl:
	db $FB : db $05
pushpc
;; goal tape gfx override
org $01C135|!bank
goal_tape_gfx_hijack:
	JML.l goal_gfx_set_props|!bank
.done:
	LDA $00
	BCS .nosub         ; carry set when we're drawing flipped goalpost.
	SEC
	SBC #$08
.nosub:
	STA $0300|!addr,y
	CLC
	ADC #$08
	STA $0304|!addr,y
	CLC
	ADC #$08
	STA $0308|!addr,y

	LDA $01
	CLC
	ADC #$08
	STA $0301|!addr,y
	STA $0305|!addr,y
	STA $0309|!addr,y
	LDY #$00
	LDA #$02
	JMP finish_oam_write+$4
	; 18 bytes of original routine left over
warnpc $01C16E|!bank
;
pullpc
goal_gfx_set_props:
	LDA !sprite_memory_header
	AND #!level_status_flag_goal_move_left
	BEQ .cont                ; continue as normal
	LDA #%01000000           ; set x-flip
.cont
	ORA #$32                 ; original properties + flip flag
	STA $0303|!addr,y        ;\ tile 1 props
	STA $0307|!addr,y        ;| tile 2 props
	STA $030B|!addr,y        ;/ tile 3 props
	ROL #2                   ; shift `x' part into carry.
	LDA #!GoalTile           ; load goal tile gfx
	BCS .gfx_reverse
	STA $0302|!addr,y
	INC A
	STA $030A|!addr,y
	BRA .return
.gfx_reverse
	STA $030A|!addr,y
	INC A
	STA $0302|!addr,y
.return
	STA $0306|!addr,y
	JML goal_tape_gfx_hijack_done|!bank
