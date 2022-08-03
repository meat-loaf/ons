;incsrc "../main.asm"
if read1($00FFD5) == $23
	if read1($00FFD7) == $0D ; full 6/8 mb sa-1 rom
		fullsa1rom
		!fullsa1 = 1
	else
		sa1rom
	endif
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!ramlo = $400000
	!ramhi = $410000

	!num_sprites = $16
else
	lorom
	!sa1 = 0
	!fullsa1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!bank8 = $80
	!ramlo = $7E0000
	!ramhi = $7F0000
	!num_sprites = $0C
endif

!level_general_purpose_1 = $1923|!addr
!level_general_purpose_2 = !level_general_purpose_1+$01
!sprites_locked          = $9D
!game_paused = $13D4|!addr
!layer_2_ypos_next = $1468|!addr
!layer_2_ypos_curr = $20
!spc_io_4_sfx_3          = $1DFC|!addr
!on_off_state           = $14AF|!addr
!mario_on_ground        = $13EF|!addr
!sspipes_dir = $60

org $00D0E7|!bank
;	db $18       ; gamemode to execute on death
	db $0B       ; gamemode to execute on death
warnpc $00D0E8|!bank

org $009468|!bank
gamemode_19:
	;LDA.b #$0B
	LDA.b #$10
	STA.w $0100|!addr
	LDA.w $0DAF|!addr
	EOR.b #$01
	STA.w $0DAF|!addr
	
;	LDA.b #$02
;	STA.w $0DB1
;	JSR.w $9F29
;	STZ.w $141A|!addr
;	STZ.b $71
	;STA.w $141D|!addr
	RTS
;l2_h:
;autoclean \
;	JML.l l2
warnpc $00968D|!bank


org $00A295|!addr
autoclean \
	JSL.l l2

org $00A2F0|!bank
	JMP.w $008494|!bank
freecode

!on_off_revert_timer = !level_general_purpose_1
!wave_state          = !level_general_purpose_2
l2:
	JSL.l $7F8000
	LDA $010B|!addr
	CMP #$37
	BNE .out
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
	;JML.l $008494|!bank
	;JML.l $008494|!bank
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
	STA !spc_io_4_sfx_3
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
	LDY #$FF
	LDA.l .wave_tbl,x
	BMI .high_byte_store_neg
	LDY #$00
.high_byte_store_neg:
	STY $01
	STA $00

	REP #$20
	LDA $00
	CLC
	ADC !layer_2_ypos_next
	STA !layer_2_ypos_next
	SEP #$20

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
