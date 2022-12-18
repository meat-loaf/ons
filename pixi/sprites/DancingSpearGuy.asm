;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dancing Spear Guy
;; by Sonikku
;;     A sprite that dances and hops back and forth with a spear.
;;     If the Extra Bit is set, it won't move horizontally.
;; 
!FeetPal =	$04		; Set to $FF if to use the sprite's palette.
!PlaySFX =	$00		; Should "chanting" SFX play?
	!ChantSFX1 =	$00	; SFX to play; plays 3 times.
	!ChantSFX2 =	$00	; SFX to play; plays 1 time.
	!ChantSFXBank =	$1DFC	; SFX Bank of above two SFX.

!CollideType =	$01		; If $00, sprite collision will be a 3-tile-high unstompable collision box.
				; If $01, sprite collision will include a stompable 16x16 hitbox (at the ShyGuy's position),
				;         alongside a separate unstompable 8x32 collision box for the spear.

print "INIT", hex(spear_guy_init)
print "MAIN", hex(spear_guy_main)

spear_guy_init:
	%SubHorzPos()
	TYA
	STA !157C,x
	STA !151C,x
	STZ !1510,x
	LDA #$20
	STA !1540,x
	RTL

spear_guy_main:
	PHB
	PHK
	PLB
	JSR spear_guy_gfx
	JSR spear_guy_main_rt
	PLB
	RTL

spear_guy_main_rt:
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BNE .return
	LDA !14C8,x
	CMP #$08
	BEQ +
.return	RTS
+
if !PlaySFX
	LDY #!ChantSFX1
	LDA $14
	AND #$3F
	BNE ++
	LDA $14
	LSR #6
	AND #$03
	BNE +
	LDY #!ChantSFX2
+	STY !ChantSFXBank|!addr
++
endif
	JSL $01802A|!bank
	DEC !AA,x
;; handle on-ground stuff
	LDA !1588,x
	AND #$04
	BEQ .InAir
	STA !1510,x
	STZ !AA,x
	STZ !B6,x
	BRA +
;; turn around before it falls off a ledge
.InAir	LDA !1510,x
	BEQ +
	STZ !1510,x
	LDA !AA,x
	BMI +
	JSR .TouchWalls
;; setup state
+	LDA !C2,x
	AND #$07
	STA !C2,x
	TAY
	LSR #2
	STA $00
	TYA
	AND #$03
	STA $01
	ASL
	TAX
	JSR (.ptr,x)

	LDX $15E9|!addr
;; turn around when touching walls
	LDA !1588,x
	AND #$03
	BEQ .NoWalls
.TouchWalls
	LDA !B6,x
	EOR #$FF
	INC
	STA !B6,x
	LDA !15AC,x
	BNE .NoWalls
	LDA #$10
	STA !15AC,x
	LDA !157C,x
	EOR #$01
	STA !157C,x
.NoWalls
	JSL $018032|!bank
if !CollideType

	JSL $01A7DC|!bank
	LDA !sprite_off_screen_horz,x
	BNE .NoContact
.do_spear_collision:
	LDY !1602,x
	STZ $00
	LDA spear_guy_gfx_Spear_XDisp,y
	LDY !151C,x
	BNE +
	EOR #$FF
	INC
	CLC
	ADC #$08
+	BPL +
	DEC $00
+	CLC
	ADC !E4,x
	STA $04
	LDA $00
	ADC !14E0,x
	STA $0A
	LDA #$08
	STA $06
	LDA #$E0
	CLC
	ADC !D8,x
	STA $05
	LDA #$FF
	ADC !14D4,x
	STA $0B
	LDA #$20
	STA $07
else
	LDA !E4,x
	CLC
	ADC #$04
	STA $04
	LDA !14E0,x
	ADC #$00
	STA $0A
	LDA #$08
	STA $06
	LDA !D8,x
	CLC
	ADC #$E0
	STA $05
	LDA !14D4,x
	ADC #$FF
	STA $0B
	LDA #$30
	STA $07
endif
	JSL $03B664|!bank
	JSL $03B72B|!bank
	BCC .NoContact
	LDA !154C,x
	BNE .NoContact
	LDA #$08
	STA !154C,x
	%SpriteEdgeTop()
	BCC .HurtMario
	LDA $7D
	BMI .HurtMario
	LDA $140D|!addr
	ORA $187A|!addr
	BNE .SpinJump
.HurtMario
	LDA $187A|!addr
	BEQ .no_yoshi
	%LoseYoshi()
	RTS
.no_yoshi:
	JSL $00F5B7|!bank
.NoContact
	RTS
.SpinJump
	LDA #$02
	STA $1DF9|!addr
	JSL $01AA33|!bank
	JSL $01AB99|!bank
	RTS

.ptr	dw .Seq_Dance
	dw .Seq_LongHop
	dw .Seq_StationaryHop
	dw .Seq_Twirl

.Seq_Dance
	LDX $15E9|!addr
;; play dance/shaking animation
	LDA !1570,x
	INC !1570,x
-	LSR #2
	LDY $00
	BEQ +
	CLC
	ADC #$07
+	TAY
	LDA .anim_1,y
	BPL .SetFrame00
	STZ !1570,x
	JSR .DecrementTime
	LDA #$00
	BRA -
.SetFrame00
	STA !1602,x
	LDA .anim_1_dir,y
	EOR !157C,x
	STA !151C,x
	RTS
.anim_1	db $0F,$10,$10,$0F,$10,$10,$FF
	db $00,$01,$02,$03,$04,$05,$FF
.anim_1_dir
	db $00,$00,$01,$01,$01,$00,$FF
	db $00,$00,$00,$00,$00,$00,$FF

.Seq_LongHop
	LDX $15E9|!addr
;; jump when it's time to
	LDA !1540,x
	CMP #$0C
	BNE +
	PHA
	LDA #$F0
	STA !AA,x
	LDY !157C,x
	JSR .SetXSpeed
	PLA
+	LSR #2
;; force frame if index is ever above x05
	CMP #$05
	BCC +
	LDA #$05
+	TAY
;; force timer while airborne
	LDA !1588,x
	AND #$04
	STA $00
	BNE .OnGround
	LDA #$07
	STA !1540,x
;; display airborne frames
	LDY #$04
	LDA !AA,x
	BMI .OnGround
	INY
.OnGround
	LDA .anim_2,y
	STA !1602,x
;; don't change state if sprite is airborne
	LDY $00
	BEQ +
	JSR .DecrementTime
+	RTS
.anim_2
	db $07,$03,$00,$06
	db $01,$02

.Seq_StationaryHop
	LDX $15E9|!addr
	LDY #$00
	LDA !1588,x
	AND #$04
	BEQ ++
;; jump every few frames (but only while on the ground) until timer is up
	LDA !1570,x
	INC !1570,x
	AND #$03
	BNE +
	PHY
	JSR .DecrementTime
	PLY
	BCS +
	LDA #$F0
	STA !AA,x
+	INY
++	LDA .anim_3,y
	STA !1602,x
	RTS
.anim_3
	db $00,$06

.Seq_Twirl
	LDX $15E9|!addr
;; set x speed
	LDY !157C,x
	INY #2
	JSR .SetXSpeed
;; play twirl animation
	LDA !1570,x
	INC !1570,x
-	LSR #2
	TAY
	LDA .anim_4,y
	BPL .SetFrame04
	STZ !1570,x
	JSR .DecrementTime
	LDA #$00
	BRA -
.SetFrame04
	STA !1602,x
	LDA .anim_4_dir,y
	EOR !157C,x
	STA !151C,x
	RTS
.anim_4
	db $08,$09,$0A,$0B,$0B,$0A,$09,$08,$FF
.anim_4_dir
	db $01,$01,$01,$01,$00,$00,$00,$00

.SetXSpeed
	LDA !7FAB10,x
	AND #$04
	BNE +
	LDA .XSpeed,y
	STA !B6,x
+	RTS

.XSpeed	db $1C,$E4
	db $F8,$08

.DecrementTime
	LDA !1540,x
	BNE +
	PHY
	LDY $01
	LDA .Timer,y
	PLY
	STA !1540,x
	INC !C2,x
	STZ !1570,x
	SEC
	RTS
+	CLC
	RTS
.Timer	db $0F,$18,$18,$20

!0300	= $0300|!addr
!0301	= $0301|!addr
!0302	= $0302|!addr
!0303	= $0303|!addr
!0460	= $0460|!addr

spear_guy_gfx:
	%GetDrawInfo()
	LDA #$FF
	STA $0F

	LDA !151C,x
	STA $02

	LDA !1602,x
	STA $03
	ASL
	STA $05

	LDA !15F6,x
	STA $04

	PHX
	JSR .Draw_Body
	JSR .Draw_Feet
	JSR .Draw_Spear
	PLX

	LDA $0F
	LDY #$FF
	JSL finish_oam_write|!bank
	RTS

.Draw_Body
	LDX $03
	LDA .Body_XDisp,x
	PHX
	LDX $02
	BNE +
	EOR #$FF
	INC
+	PLX
	CLC
	ADC $00
	STA !0300,y

	LDA .Body_YDisp,x
	CLC
	ADC $01
	STA !0301,y

	LDA .Body_Tilemap,x
	STA !0302,y

	JSR .SetProps
	PHX
	LDX $02
	BNE +
	EOR #$40
+	PLX
	STA !0303,y

	LDA #$02
	JSR .SetTileSize

	JSR .IncreaseTile
	RTS

.Draw_Spear
	LDX #$03
-	TXA
	ASL #3
	PHX
	LDX $03
	CLC
	ADC .Spear_YDisp,x
	CLC
	ADC $01
	STA !0301,y

	LDA .Spear_XDisp,x
	PHX
	LDX $02
	BNE +
	EOR #$FF
	INC
	CLC
	ADC #$08
+	PLX
	CLC
	ADC $00
	STA !0300,y

	JSR .SetProps
	ORA .Spear_Properties,x
	PHX
	LDX $02
	BNE +
	EOR #$40
+	PLX
	STA !0303,y
	PLX

	PHX
	TXA
	LDX #$00
	CMP #$00
	BEQ +
	INX
+	LDA .Spear_Tilemap,x
	PLX
	STA !0302,y

	LDA #$00
	JSR .SetTileSize
	JSR .IncreaseTile

	DEX
	BPL -
	RTS

.Draw_Feet
	LDX #$01
-	PHX
	TXA
	CLC
	ADC $05
	TAX
	LDA .Feet_XDisp,x
	PHX
	LDX $02
	BNE +
	EOR #$FF
	INC
	CLC
	ADC #$08
+	PLX
	CLC
	ADC $00
	STA !0300,y

	LDA .Feet_YDisp,x
	CLC
	ADC $01
	STA !0301,y

	LDA .Feet_Tilemap,x
	STA !0302,y

	LDA $04
	PHA
if !FeetPal != $FF
	AND #$01
	ORA #!FeetPal
	STA $04
endif
	JSR .SetProps
	ORA .Feet_Properties,x
	PHX
	LDX $02
	BNE +
	EOR #$40
+	PLX
	STA !0303,y
	PLA
	STA $04

	LDA #$00
	JSR .SetTileSize
	JSR .IncreaseTile
	PLX

	DEX
	BPL -

.IncreaseTile
	INY #4
	INC $0F
	RTS

.SetProps
	PHX
	LDA $04
	ORA $64
;	LDX $02
;	BNE +
;	ORA #$40
+	PLX
	RTS

.SetTileSize
	XBA
	PHY
	TYA
	LSR #2
	TAY
	XBA
	STA !0460,y
	PLY
	RTS

.Body_XDisp
	db $02,$01,$00,$FE,$FF,$00,$02,$FE
	db $00,$00,$00,$00,$00,$00,$00,$01
	db $00

.Body_YDisp
	db $FC,$FB,$FB,$FC,$FB,$FB,$FF,$FF
	db $FA,$FB,$FC,$FB,$FE,$FD,$FA,$FD
	db $FD

.Body_Tilemap
	db $00,$00,$00,$02,$02,$02,$00,$02
	db $04,$06,$08,$0A,$00,$02,$02,$0C
	db $0A

.Feet_Tilemap
	db $1F,$0F : db $1F,$0F : db $1F,$0F : db $1F,$0F : db $1F,$0F : db $1F,$0F : db $1F,$0F : db $1F,$0F
	db $1F,$1F : db $1F,$1F : db $1F,$1F : db $1F,$1F : db $1F,$1F : db $1F,$1F : db $0F,$0F : db $1F,$1F
	db $1F,$1F

.Feet_XDisp
	db $08,$FF : db $0A,$FC : db $FD,$0C : db $01,$09 : db $FE,$0D : db $0B,$FD : db $07,$00 : db $01,$09
	db $02,$06 : db $07,$02 : db $09,$02 : db $0B,$00 : db $08,$00 : db $08,$00 : db $09,$01 : db $09,$FF
	db $09,$FF

.Feet_YDisp
	db $0B,$02 : db $08,$03 : db $08,$03 : db $0B,$02 : db $08,$03 : db $08,$03 : db $0B,$04 : db $0B,$04
	db $09,$08 : db $08,$0B : db $06,$0B : db $06,$0A : db $0B,$0B : db $0B,$0B : db $08,$08 : db $0B,$0B
	db $0B,$0B

.Feet_Properties
	db $40,$40 : db $00,$40 : db $40,$00 : db $00,$00 : db $40,$00 : db $00,$40 : db $40,$40 : db $00,$00
	db $00,$00 : db $00,$00 : db $00,$00 : db $00,$00 : db $40,$00 : db $40,$00 : db $40,$00 : db $40,$00
	db $40,$00

.Spear_XDisp
	db $0C,$0B,$0A,$08,$09,$0A,$0C,$08
	db $01,$FE,$FF,$02,$0A,$0A,$0A,$03
	db $04
.Spear_YDisp
	db $E0,$DF,$DE,$DC,$DB,$DD,$E3,$DF
	db $DE,$DF,$E0,$DF,$E2,$DF,$DA,$E0
	db $DF
.Spear_Properties
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$40
	db $40

.Spear_Tilemap
	db $0E,$1E
