; spawns a red coin at current block pos

	INC !red_coin_adder
	LDX #!red_coin_sfx_id
	LDA !red_coin_total
	CLC
	ADC !red_coin_adder
	CMP #20
	BCC .not_final_coin
	INX
.not_final_coin:
	STX !red_coin_sfx_port

	rep #$20
	lda !block_xpos
	sta !ambient_get_slot_xpos
	lda !block_ypos
	sta !ambient_get_slot_ypos
	lda #$d000
	sta !ambient_get_slot_xspd
	stz !ambient_get_slot_timer
	lda #$0011
	jml ambient_get_slot_rt
