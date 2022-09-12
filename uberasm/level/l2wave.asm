!on_off_revert_timer = !level_general_purpose_1
!wave_state          = !level_general_purpose_2

load:
	LDA #$80
	STA !on_off_revert_timer
	STZ !wave_state
	RTL
main:
	LDA !sprites_locked
	ORA !game_paused
	BNE .out

	LDY #$FF
	LDA $17BC|!addr
	STA $0E
	BMI +
	LDY #$00
+	
	STY $0F
	REP #$20
	LDA $0E
	CLC
	ADC !layer_2_ypos_next
	STA !layer_2_ypos_next
	SEP #$20

	LDA !on_off_state                ; if on/off is off...
	BEQ .timer                       ; run timer code to auto-swap to on. otherwise...
	STZ !on_off_revert_timer
	JSR wave                         ; do the wave
	LDA !mario_on_ground             ; and do some other shit to fix moot's position
	CMP #$02                         ; on layer 2 only
	BEQ .fixpos
;	BRA .out
	LDA !sspipes_dir                 ; check if in a screen-scrolling pipe
	BEQ .out
	STZ $0E                          ; \ don't apply the layer delta to marios pos
	STZ $0F                          ; / when in a pipe, it looks like shit
.fixpos:
	; adjust mario's position if in pipe (means only pipes on layer 2)
	REP #$20
	LDA $96
	SEC
	SBC $00
	SBC $0E
	STA $96
	SEP #$20
.out
	RTL

.timer
	LDA !on_off_revert_timer
	BMI .out

	LDA !on_off_revert_timer
	BNE .dec
	LDA #85                     ; keep 7-bit. high bit used as 'entered-level flag (to keep off until on/off is first pressed.')
	STA !on_off_revert_timer
	BRA .out
.dec
	DEC
	STA !on_off_revert_timer
	BEQ .reset
	CMP #$1F
	BNE .out
.playsound
	LDA #$24	; play p-switch low sound
	STA !spc_io_4_sfx_1DFC
	BRA .out
.reset
	LDA #$01
	STA !on_off_state
	BRA .out

wave:
	LDA !wave_state
	CMP #80
	BNE +
	LDA #$00
	STA !wave_state
+
	TAX
	LDA #$FF
	LDY .wave_tbl,x
	BMI .high_byte_store_neg
	LDA #$00
.high_byte_store_neg:
	STA $01
	STY $00

	LDA $00
	CLC
	ADC !layer_2_ypos_next
	STA !layer_2_ypos_next

	INC !wave_state
	RTS

.wave_tbl
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $02, $02, $02, $02, $02, $02
	db $03, $03
	db $02, $02, $02, $02, $02, $02
	db $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	db $FE, $FE, $FE, $FE, $FE, $FE
	db $FD, $FD
	db $FE, $FE, $FE, $FE, $FE, $FE
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
