; ==================================
;  EERIE DISASSEMBLY
;  DISASSEMBLED BY ERSANIO
;  USES EXTRA BIT: YES
;  When you set the extra bit,
;  The Eerie will be in wave motion
; ==================================
print "INIT ", hex(beezo_e_init)
print "MAIN ", hex(beezo_e_main)

beezo_e_init:
	%SubHorzPos()
	TYA
	STA.w !157C,x
	TAX
	LDA.l .x_spd_init,x       ; Store Eerie's speed
	LDX.w $15E9|!addr
	STA   !B6,x               ; depending on which side Mario is
	JSL.l $01ACF9|!bank
	STA.w !1570,x             ; Start with a random animation frame
	RTL

.x_spd_init:
	db $10,$F0	;X speed table: Right, left
y_speeds:
	db $18,$E8	;Y speed acceleration table: down, up (?)

y_accel:
	db $01,$FF	;Y Acceleration stuff

beezo_e_main:
	PHB
	PHK
	PLB

	LDA #$03
	%SubOffScreen()

	LDA !14C8,x
	EOR #$08
	ORA $9D
	BNE graphics

	JSL $018022|!bank       ; Update X pos without gravity

	LDA !spr_extra_bits,x
	AND #$04
	BEQ interact            ; if extra bit set, do the wave

	LDA !C2,x               ; Load y accel direction
	AND #$01                ;
	TAY                     ; Y is index to y accel table
	LDA !AA,x               ;\
	CLC                     ; | Load Y speed
	ADC y_accel,y           ; | Accelerate it
	STA !AA,x               ;/
	CMP y_speeds,y          ; If it didn't reach the desired Y speed
	BNE .novchg             ; Continue processing the sprite
	INC !C2,x               ; If it reached the desired speed, change Y direction
.novchg:
	JSL $01801A|!bank       ; Update Y pos without gravity

interact:
	JSL $01A7DC|!bank       ; Mario<->sprite interact routine
	INC !1570,x             ; update animation frame counter
	LDA !1570,x
	LSR #3
	AND #$01
	STA !1602,x             ; store to ani frame table

; uses tile numbers from eerie (act-as in cfg)
graphics:
	JML.l sub_spr_gfx_2_long_no_push_bank|!bank
