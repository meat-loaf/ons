includefrom "status.asm"
status_bar_tilemap_score_convert = $009012|!bank
hex_to_dec               = $009045|!bank

macro two_digit_counter(name,total_ram,tilemap_base,use_blank_tens,has_adder,adder_ram)
.update_<name>_load<name>:
if <has_adder>
	LDA.w <adder_ram>
	BEQ.b .<name>_adder_done
	DEC.w <adder_ram>
	INC.w <total_ram>
.<name>_adder_done:
endif
	LDA.w <total_ram>
.update_<name>_no_load:
	JSR.w hex_to_dec
if <use_blank_tens>
	TXY
	BNE.b .<name>_no_blank
	LDX.b #!blank_digit_ix
.<name>_no_blank
endif
	STA.w <tilemap_base>+1
	STX.w <tilemap_base>
endmacro

pushpc
org $008E1A|!bank
status_bar_update_counters:
	LDA.w !end_level_timer
	ORA.b !sprites_locked
	BNE.b .update_score
	DEC.w !timer_frame
	BPL.b .update_score
	LDA.b #!timer_frames_to_dec
	STA.w !timer_frame
	LDA.w !timer_hundreds
	ORA.w !timer_tens
	ORA.w !timer_ones
	BEQ.b .update_score
	LDX.b #$02
.timer_update_loop:
	DEC.w !timer_hundreds,x
	BPL.b .timer_update_done
	LDA.b #$09
	STA.w !timer_hundreds,x
	DEX
	BPL.b .timer_update_loop
.timer_update_done:
	LDA.w !timer_hundreds
	BNE.b .no_fast
	LDA.w !timer_tens
	AND.w !timer_ones
	CMP.b #$09
	BNE.b .no_fast
	LDA.b #$FF
	STA.w !spc_io_1_sfx_1DF9
.no_fast:
	LDA.w !timer_hundreds
	ORA.w !timer_tens
	ORA.w !timer_ones
	BNE.b .update_score
	JSL.l kill_mario|!bank
; originally, both marios and luigi's score was updated here.
.update_score:
	LDA !player_score+2
	STA.b $00
	STZ.b $01
	REP.b #$20
	LDA.w !player_score
	SEC
	SBC.w #$423F
	LDA.b $00
	SBC.w #$000F
	SEP.b #$20
	BCC.b ..ram_done
	LDA.b #$0F
	STA.w !player_score+2
	LDA.b #$42
	STA.w !player_score+1
	LDA.b #$3F
	STA.w !player_score
..ram_done:
	LDA.w !player_score+2
	STA.b $00
	STZ.b $01
	LDA.w !player_score+1
	STA.b $03
	LDA.w !player_score+0
	STA.b $02
	LDX.b #$14
	LDY.b #$00
	JSR.w status_bar_tilemap_score_convert|!bank
	LDX.b #$00
..clean_leading_zero_loop:
	LDA.w !status_bar_tilemap+$30,x
	BNE.b .update_coins
	LDA.b #!blank_digit_ix
	STA.w !status_bar_tilemap+$30,x
	INX
	CPX.b #$06
	BNE.b ..clean_leading_zero_loop
.update_coins:
	LDA.w !coin_adder
	BEQ.b .update_lives_loadlives
	DEC.w !coin_adder
	INC.w !curr_player_coins
	LDA.w !curr_player_coins
	CMP.b #100
	BCC.b .update_lives_loadlives
	SEC
	SBC.b #100
	STA.w !curr_player_coins
	INC.w !give_player_lives
	LDA.w !curr_player_lives
	CMP.b #99
	BCC.b .update_lives_no_load
	DEC.w !curr_player_lives
	%two_digit_counter(lives,!curr_player_lives,!status_bar_tilemap+$1D,!true,!false,$0000)
	%two_digit_counter(coins,!curr_player_coins,!status_bar_tilemap+$1A,!true,!true,!coin_adder)
	%two_digit_counter(red_coins,!red_coin_total,!status_bar_tilemap+$01,!true,!true,!red_coin_adder)
.s_coins:
	LDX.b #$00
	LDA.w !yoshi_coins_collected
	STA.b $00
..loop:
	CLC
	LDA.b #!empty_coin_tile_ix
	ROR.b $00
	BCC.b ..empty
	LDA.b #!coin_tile_ix
..empty:
	STA.w !status_bar_tilemap+$6,x
	INX
	CPX.b #$05
	BNE.b ..loop
..done
	RTS
warnpc $008FFA|!bank
pullpc
