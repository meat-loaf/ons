; smb2 cobrat
; uses extra bit: chases if clear, otherwise jumps and shoots

!sprite_state       = !C2
!y_low_backup       = !1534

!wait_shoot_timer   = !1540
!shoot_time         = $FF

!sprite_direction   = !157C
!sprite_frame_index = !1602


!projectile_num = $00+!ExtendedOffset

print "INIT ",pc

	%SubHorzPos()
	TYA
	STA !sprite_direction,x

	%BES(jump_n_shoot)

	LDA #$FC
	STA !sprite_speed_y,x

	RTL

jump_n_shoot:
	LDA #$C0
	STA !sprite_speed_y,x

	LDA #$04
	STA !sprite_state,x

	LDA !sprite_y_low,x
	AND #$F0
	STA !y_low_backup,x

	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR cobrat_main
	PLB

	RTL

x_speed_tbl:
	db $14,-$14

main_ret:
	RTS

cobrat_main:
	JSR graphics

	LDA $9D
	ORA !14C8,x
	EOR #$08
	BNE main_ret

	%SubOffScreen()

	JSL $01A7DC|!bank
	JSL $018032|!bank

	INC !sprite_misc_1504,x

	TXY
	LDA !sprite_state,x
	ASL  ; pointers are two bytes
	TAX
	JMP (sprite_state_table,x)

sprite_state_table:
	dw waiting_ground
	dw jumping_chase
	dw chasing
	dw shooting
	dw doing_shoot
	dw waiting_shoot

waiting_ground:
	TYX
	STZ !sprite_frame_index,x

	%SubHorzPos()
	TYA
	STA !sprite_direction,x

	LDA !sprite_misc_1504,x
	AND #$1F
	BNE +
	LDA !sprite_speed_y,x
	EOR #$FF : Inc
	STA !sprite_speed_y,x
+
	LDY #$D1
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #$0054
	CMP #$00A8
	SEP #$20
	BCS .not_in_range
	INC !sprite_state,x
	LDA #$B8
	STA !sprite_speed_y,x
.not_in_range
	JSL $01801A|!bank          ; update y pos no gravity
	RTS

jumping_chase:
	TYX
	LDA $14
	AND #$08
        ROR #2
	STA !sprite_frame_index,x

	%SubHorzPos()
	TYA
	STA !sprite_direction,x

	PHY
	JSL $01802A|!bank
	PLY

	LDA !1588,x
	AND #$04
	BEQ .not_blocked

	INC !sprite_state,x
	LDA #!shoot_time
	STA !wait_shoot_timer,x

	LDA x_speed_tbl,y
	STA !sprite_speed_x,x
.not_blocked
	RTS


chasing:
	TYX
	LDA $14
	AND #$08 : RoR #2
	STA !sprite_frame_index,x

	JSR chase_shoot

	LDA !wait_shoot_timer,x
	BNE .keep_waiting

	INC !sprite_state,x

	%SubHorzPos()
	TYA : StA !sprite_direction,x

	LDA x_speed_tbl,y
	STA !sprite_speed_x,x

	LDA #$15
	STA !wait_shoot_timer,x
.keep_waiting
	RTS

shooting:
	TYX
	LDA #$04
	STA !sprite_frame_index,x

	JSR chase_shoot

	LDA !wait_shoot_timer,x
	BNE chasing_keep_waiting
	DEC !sprite_state,x

shoot:
	LDY #$07
-	LDA $170B|!addr,y
	BEQ .found
	DEY
	BPl -
	BRA .noslots
.found

	PHX

	LDA #!projectile_num
-	STA $170B|!addr,y

	LDA #$00
	STA $173D|!addr,y
	STA $1765|!addr,y

	LDA !E4,x
	CLC
	AdC #$04
	STA $171F|!addr,y
	LDA !14E0,x
	ADC #$00
	STA $1733|!addr,y

	LDA !D8,x
	CLC : AdC #$03
	STA $1715|!addr,y
	LDA !14D4,x
	ADC #$00
	STA $1729|!addr,y

	LDA !sprite_direction,x
	TAX
	LDA .x_speeds,x
	STA $1747|!addr,y

	PLX
.noslots
	LDA #$FF
	STA !wait_shoot_timer,x
	RTS

.x_speeds
	db $24,$24^$FF+1

doing_shoot:
	TYX
	LDA $14
	AND #$08
	ROR #2
	STA !sprite_frame_index,x

	LDA !1686,x
	ORA #$80
	STA !1686,x
	JSL $01802A|!bank

	LDA !sprite_misc_1504,x
	CMP #$0B
	BCC +
	CMP #$20
	BEQ .projectile
	BCS +
	LDA #$04
	STA !sprite_frame_index,x
+
	LDA !sprite_speed_y,x
	BMI +
	LDA !sprite_y_low,x
	AND #$F0
	CMP !y_low_backup,x
	BNE +

	INC !sprite_state,x

	LDA #$FC
	STA !sprite_speed_y,x
	STZ !sprite_misc_1504,x
+
	RTS
.projectile
	JMP shoot

waiting_shoot:
	TYX
	STZ !sprite_frame_index,x

	%SubHorzPos()
	TYA
	STA !sprite_direction,x

	LDA !sprite_misc_1504,x
	CMP #$A0
	BEQ .jump

	AND #$1F               ; \
	BNE +                  ; | invert speed if timer divisible by
	LDA !sprite_speed_y,x  ; | 32 to achive 'bobbing' motion
	EOR #$FF               ; |
	INC                    ; |
	STA !sprite_speed_y,x  ; /
+
	JSL $01801A|!bank

	RTS

.jump
	DEC !sprite_state,x

	LDA #$C0
	STA !sprite_speed_y,x

	STZ !sprite_misc_1504,x

	RTS

chase_shoot:
	JSL $01802A|!bank

	LDA !1588,x
	AND #$03
	BEQ .no_flip
	LDA !sprite_direction,x
	EOR #$01
	STA !sprite_direction,x
.no_flip
	LDA $14
	AND #$3F
	BNE +
	%SubHorzPos()
	TYA
	STA !sprite_direction,x
+
	LDY !sprite_direction,x
	LDA x_speed_tbl,y
	STA !sprite_speed_x,x

	RTS


;; graphics ;;
properties:
	db $49
	db $09

tilemap:
	db $86,$C0
	db $8A,$E0
	db $E4,$E0
VertDisp:
	db $FF,$0F,$FF

graphics:
	%GetDrawInfo()

	LDA $64
	STA $06

	LDA !sprite_state,x
	STA $02

	CMP #$04
	BCS .neg_prio ; state 5, 6
	DEC
	BMI .neg_prio ; state 0
	LDA !sprite_speed_y,x
	BPL .above
.neg_prio
	STZ $06
.above
	LDA !sprite_frame_index,x
	STA $03
	LDA !sprite_direction,x
	STA $04
	LDA !14C8,x
	STA $05

	LDX #$01
.draw_loop                     ; maybe im missing something but this loop seems like
	LDA $00                ; a complete clusterfuck. It could probably stand to be
	STA $0300|!addr,y      ; rewritten

	PHX
	LDA $05
	CMP #$02
	BNE +
	INX

+	LDA $01
	CLC
	ADC VertDisp,x
	STA $0301|!addr,y

	LDA $02
	CMP #$02
	BCC +
	CMP #$04
	BCS +
	LDA $14
	AND #$03
	BNE +
	LDA $0301|!addr,y
	INC
	STA $0301|!addr,y
+
	PLA
	PHA

	ORA $03
	TAX
	LDA tilemap,x
	STA $0302|!addr,y

	LDX $04
	LDA properties,x
	PHA
	LDA $05
	CMP #$02
	BNE +
	PLA
	ORA #$80
	PHA
+	PLA
	ORA $06
	STA $0303|!addr,y

	PLX

	INY #4

	DEX
	BPL .draw_loop

	LDX $15E9|!addr
	LDY #$02
	LDA #$01
	JSL $01B7B3|!bank ; finish oam write

	RTS
