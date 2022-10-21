;---------------------------------------------------------
; sakasakasa
;---------------------------------------------------------
; smw style
;---------------------------------------------------------
; ExBit - clr - Buzzy Beetle
;         set - Spiny
;---------------------------------------------------------
; no change it
;---------------------------------------------------------
!pose = !1504
!sakasa = !C2
;---------------------------------------------------------
; table
;---------------------------------------------------------
walk_speed:
	db $08,$F8
shell_speed:
	db $24,$DC
tilemap:
	db $20,$22,$28,$24,$26,$24
	db $00,$02,$2E,$2A,$2C,$2A
flipmap:
	db $00,$00,$00,$00,$00,$40
;---------------------------------------------------------
; init
;---------------------------------------------------------

Print "INIT ",pc
	%BES(+)
	LDA #$0D
	STA !15F6,x
+
	%SubHorzPos()
	TYA
	STA !157C,x
	RTL

;---------------------------------------------------------
; main
;---------------------------------------------------------

Print "MAIN ",pc
	PHB
	PHK
	PLB
	
	CMP #$07
	BEQ yoshimode
;	PHA
	
;	LDA #$11
;	STA !sprite_num,x
	
;	PLA
	CMP #$08
	BNE shellmode
	JSR sprite
	PLB
	RTL
	
;---------------------------------------------------------
; $07 yoshi mode
;---------------------------------------------------------

yoshimode:
;	LDA #$04
;	STA !sprite_num,x
	LDA #$02
	STA !sakasa,x
	PLB
	RTL

;---------------------------------------------------------
; not $07 $08 shell mode
;---------------------------------------------------------

shellmode:
	PHA
	LDA #$02
	STA !sakasa,x
	PLA
	CMP #$02
	BEQ isdead
	CMP #$0A
	BEQ +
-
	LDA #$02
	STA !pose,x
	BRA ++
+
	LDA $14
	LSR #2
	AND #$03
	CLC
	ADC #$02
	STA !pose,x
++
	JSR gfx
+++
	PLB
	RTL
isdead:
	LDA !15F6,x
	ORA #$80
	STA !15F6,x
	BRA -
;---------------------------------------------------------
; $08 normal mode
;---------------------------------------------------------

return:
	RTS

sprite:
	LDA #$00
	%SubOffScreen()
	JSR gfx
	
	%BES(+)
	LDA !166E,x
	ORA #$10
	STA !166E,x
+
	LDA $9D
	BNE return

	LDY !157C,x
	LDA walk_speed,y
	STA !sprite_speed_x,x
	LDA $14
	LSR #3
	AND #$01
	STA !pose,x
	
	LDA !sprite_blocked_status,x
	AND #$03
	BEQ +
	LDA !157C,x
	EOR #$01
	STA !157C,x
+
	JSL $018032|!BankB
	%BEC(+)
	LDA !1656,x
	AND #$EF
	STA !1656,x
+
	JSL $01A7DC|!BankB
	LDA !1656,x
	ORA #$10
	STA !1656,x
	
	LDA !sakasa,x
	BEQ +
	DEC
	BEQ jpeg
	BRA png
+
	LDA !sprite_speed_y,x
	SEC
	SBC #$02
	CMP #$E8
	BMI +
	LDA #$E8
+
	STA !sprite_speed_y,x
	JSL $019138|!BankB
	LDA !sprite_blocked_status,x
	AND #$08
	BEQ +
	STZ !sprite_speed_y,x
+
	JSL $01801A|!BankB
	JSL $018022|!BankB
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #$0020
	CMP #$0040
	BCS +
	SEP #$20
	%SubVertPos()
	TYA
	BNE +
	INC !sakasa,x
+
	SEP #$20
	RTS
jpeg:
	LDA $14
	LSR #2
	AND #$03
	CLC
	ADC #$02
	STA !pose,x
	STZ !sprite_speed_x,x
	JSL $01802A|!BankB
	LDA !sprite_blocked_status,x
	AND #$04
	BEQ +
	LDA #$0A
	STA !sprite_status,x
	%SubHorzPos()
	LDA shell_speed,y
	STA !sprite_speed_x,x
	LDA !15F6,x
	ORA #$80
	STA !15F6,x
+
	RTS
png:
	LDA !sprite_blocked_status,x
	AND #$08
	BEQ +
	STZ !sprite_speed_y,x
+
	LDA !sprite_blocked_status,x
	AND #$04
	BEQ ++
	LDY #$00
	LDA !sprite_slope,x
	BEQ +
	LDY #$18
+
	STY !sprite_speed_y,x
++
	JSL $01802A|!BankB

	RTS

;---------------------------------------------------------
; Graphics routine
;---------------------------------------------------------

gfx:
	%GetDrawInfo()
;-------------------
;xpos and flip
	LDA !157C,x
	EOR #$01
	ASL #2
	STA $02
;-------------------
;shell buruburu
	STZ $03
	LDA !1540,x
	CMP #$30
	BCS +
	AND #$01
	STA $03
+
;-------------------
;v flip index
	STZ $04
	LDA !15F6,x
	STA $07
	LDA !sakasa,x
	CMP #$02
	BNE ++
	LDA !15F6,x
	AND #$80
	BEQ +
++
	LDA #$04
	STA $04
+
;-------------------
;anime
	%BES(+)
	LDA #$00
	BRA ++
+
	LDA #$06
++
	CLC
	ADC !pose,x
	STA $05
	
	LDA !pose,x
	TAX
	LDA flipmap,x
	ORA $07
	STA $07
	
;-------------------
	LDA $00
	CLC
	ADC $03
	STA $0300|!Base2,y
	LDA $01
	STA $0301|!Base2,y
;-------------------
	LDX $05
	LDA tilemap,x
	STA $0302|!Base2,y
;-------------------
	LDA $07

	LDX $02
	BEQ +
	EOR #$40
+
	LDX $04
	BEQ .no_y_flip
	ORA #$80
.no_y_flip:
	ORA $64
	STA $0303|!Base2,y

	; something about the shell state causes the original
	; game code to draw a junk tile (koopa shell eyes?).
	; Figure out what to remove this code.
	TYA
	CLC : ADC #$08
	TAY
	LDA #$F0
	STA $0301|!addr,y

	LDX $15E9|!addr
	LDA #$00
	LDY #$02
	JSL finish_oam_write
	RTS
