; stinky gas bubble
;org $02E372|!bank
;	db $00,$02,$04,$06,$08,$09,$0A,$0C
;	db $08,$09,$0A,$0C,$00,$02,$04,$06

!y_update_freq = $03
!y_accel       = $01
!y_speed_max   = $10

!x_update_freq = $03
!x_accel       = $01
!x_speed_max   = $10

!max_x_speed_tmr  = $20
!const_x_speed = $10

; replace init
%replace_wide_pointer($01829D|!bank,stinky_bubble_init|!bank)
; replace main JSL location
%replace_long_pointer($0187C0+1|!bank,stinky_bubble_main|!bank)

org !bank1_bossfire_free
stinky_bubble_init:
	LDA !extra_bits,x
	AND #$04
	BNE .end
	LDA !extra_byte_1,x
	AND #$04
	BEQ .asdf1
	JSR _sub_horz_pos_bank1
	TYA
	EOR #$01
	BRA .asdf2
.asdf1:
	LDA !extra_byte_1,x
	AND #$01
.asdf2:
	STA !1534,x
	LDA !extra_byte_1,x
	AND #$02
	STA !1504,x
.end:
	RTS
.done:
warnpc !bank1_bossfire_end
!bank1_bossfire_free = stinky_bubble_init_done

; original start of directional coins routine; overwriting
org $02E1F9|!bank
stinky_bubble_main:
	PHB
	PHK
	PLB
	JSR stinky_bubble_gfx
	LDA !sprites_locked
	BNE .done
	JSR .y_movement
.x_movement:
	LDA !1504,x
	BEQ .constant
	LDA !1540,x
	BNE .common
if !x_update_freq != $00
	LDA $14
	AND #!x_update_freq
	BNE .common
endif
	LDA !1534,x
	AND #$01
	TAY
	LDA !sprite_speed_x,x
	CLC
	ADC .x_accel,y
	STA !sprite_speed_x,x
	CMP .x_speed_max,y
	BNE .common
	INC !1534,x
	LDA #!max_x_speed_tmr
	STA !1540,x
	BRA .common
.constant:
	LDY !1534,x
	LDA .x_speed_const,y
	STA !sprite_speed_x,x
.common:
	INC !1570,x
	; suboffscreen 0: bank 2
	JSR.w $02D025|!bank
	JSL $018022|!bank
	JSL $01801A|!bank
	JSL $01A7DC|!bank
.done:
	PLB
	RTL
casio:
	

.y_movement:
if !y_update_freq != 00
	LDA $14
	AND #!y_update_freq
	BNE ..skip
endif
	LDA !1594,x
	AND #$01
	TAY
	LDA !sprite_speed_y,x
	CLC
	ADC .y_accel,y
	STA !sprite_speed_y,x
	CMP .y_speed_max,y
	BNE ..skip
	INC !1594,x
..skip:
	RTS

.y_accel:
	db !y_accel,-!y_accel
.y_speed_max:
	db !y_speed_max,-!y_speed_max
.x_accel:
	db -!x_accel, !x_accel
.x_speed_max:
	db -!x_speed_max,!x_speed_max
.x_speed_const
	db -!const_x_speed,!const_x_speed

; pretty much ripped from the disasm real lazy-like
DATA_02E352:
	db $00,$10,$20,$30,$00,$10,$20,$30
	db $00,$10,$20,$30,$00,$10,$20,$30
DATA_02E362:
	db $00,$00,$00,$00,$10,$10,$10,$10
	db $20,$20,$20,$20,$30,$30,$30,$30
DATA_02E372:
	db $00,$02,$04,$06,$08,$09,$0A,$0C
	db $08,$09,$0A,$0C,$00,$02,$04,$06
DATA_02E382:
	db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	db $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB
DATA_02E392:
	db $00,$00,$02,$02,$00,$00,$02,$02
	db $01,$01,$03,$03,$01,$01,$03,$03
DATA_02E3A2:
	db $00,$01,$02,$01
DATA_02E3A6:
	db $02,$01,$00,$01
stinky_bubble_gfx:
	JSR.w $02D378|!bank
	LDA.W !1570,X
	LSR A
	LSR A
	LSR A
	AND.B #$03
	TAY
	LDA.W DATA_02E3A2,Y
	STA.B $02
	LDA.W DATA_02E3A6,Y
	STA.B $03
	LDY.W !sprite_oam_index,X
	PHX
	LDX.B #$0F
CODE_02E3C6:
	LDA.B $00
	CLC
	ADC.W DATA_02E352,X
	PHA
	LDA.W DATA_02E392,X
	AND.B #$02
	BNE CODE_02E3DA
	PLA
	CLC
	ADC.B $02
	BRA +

CODE_02E3DA:
	PLA
	SEC
	SBC.B $02
	+
	STA.W $0300|!addr,Y
	LDA.B $01
	CLC
	ADC.W DATA_02E362,X
	PHA
	LDA.W DATA_02E392,X
	AND.B #$01
	BNE CODE_02E3F5
	PLA
	CLC
	ADC.B $03
	BRA +

CODE_02E3F5:
	PLA
	SEC
	SBC.B $03
	+ STA.W $0301|!addr,Y
	LDA.W DATA_02E372,X
	STA.W $0302|!addr,Y
	LDA.W DATA_02E382,X
	STA.W $0303|!addr,Y
	INY
	INY
	INY
	INY
	DEX
	BPL CODE_02E3C6
	PLX
	LDY.B #$02
	LDA.B #$0F
	JSL finish_oam_write|!bank
	RTS

;error pc
warnpc $02E414|!bank
