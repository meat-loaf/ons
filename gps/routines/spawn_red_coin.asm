; spawns a red coin at current block pos
; xoff in $00
; yoff in $01

	INC !red_coin_counter
	LDX #!red_coin_sfx_id
	LDA !red_coin_total
	CLC
	ADC !red_coin_counter
	CMP #20
	BCC .not_final_coin
	INX
.not_final_coin:
	STX $1DFC|!addr

	LDX $1865|!addr
	BPL .nofix
	LDX #$03
	STX $1865|!addr
.nofix:
	LDA #$02
	STA $17D0|!addr,x
	LDA $98
	AND #$F0
	CLC : ADC $01
	STA $17D4|!addr,x
	LDA $99
	;ADC #$00
	STA $17E8|!addr,x
	LDA $9A
	AND #$F0
	CLC : ADC $00
	STA $17E0|!addr,x
	LDA $9B
	;ADC #$00
	STA $17EC|!addr,x
	LDA #$D0
	STA $17D8|!addr,x

	DEC $1865|!addr

	RTL
