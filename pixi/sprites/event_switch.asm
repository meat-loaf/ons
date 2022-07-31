print "INIT ", hex(init)
print "MAIN", hex(main)

init:
	LDA !level_state_flags_curr
	AND !extra_byte_1,x
	BEQ +
	INC !1602,x
+
;	%sprite_init_do_pos_offset(!extra_byte_2,x)
	RTL

main:
	PHB
	PHK
	PLB
	JSR.w event_switch_rt
	PLB
	RTL

event_switch_rt:
	JSR gfx
	LDA $9D
	BNE .done
	LDA #$00
	%SubOffScreen()
	JSL $01B44F|!bank     ; make solid
	LDA !1602,x           ; ani frame/flag for skooshed switch
	BNE .done
	BCC .noskoosh         ; no contact
	INC !1602,x
	LDA !extra_byte_1,x
	TSB !level_state_flags_curr
	; TODO animation
.noskoosh:
.done:
	RTS
gfx:
	%GetDrawInfo()
	TXY
	LDX !15EA,y

	LDA !15F6,y
	STA $05

	LDA !1602,y
	TAY
	LDA .tiles_t_lo,y
	STA $02
	LDA .tiles_t_hi,y
	STA $03
	
	LDA .ntiles,y
	STA $04
	LDY #$00
.loop:
	LDA ($02),y
	STA $0302|!addr,x

	LDA $00
	ADC .tiles_off_x,y
	STA $0300|!addr,x

	LDA $01
	CLC
	ADC .tiles_off_y,y
	STA $0301|!addr,x

	LDA $05
	ORA $64
	STA $0303|!addr,x
	INY
	INX #4
	CPY $04
	BNE .loop
	TYA
	DEC
	LDY #$02
	LDX $15E9|!addr
	%FinishOAMWrite()
	RTS
.ntiles:
	db $04,$02
.tiles_big:
	db $00,$02,$04,$06
.tiles_skoosh:
	db $08,$0A
.tiles_off_x:
	db $00,$10,$00,$10
.tiles_off_y:
	db $F0,$F0,$00,$00
.tiles_t_lo:
	db (.tiles_big&$FF),(.tiles_skoosh&$FF)
.tiles_t_hi:
	db (.tiles_big>>8)&$FF,(.tiles_skoosh>>8)&$FF

