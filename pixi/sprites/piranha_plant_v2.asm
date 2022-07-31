;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Piranha Plant/Venus Fire Trap V2, by imamelia
;
; This sprite encompasses a wide variety of Classic Piranha Plants and Venus Fire Traps,
; using the extra bytes to determine which sprite to act like.
;
; Extra bit: Determines stem color. Unset is green, set is red.
;
; Extra bytes: 2
;
; Extra byte 1:
;
; Bit 0: Direction.  0 = up/left, 1 = right/down.
; Bit 1: Orientation.  0 = vertical, 1 = horizontal.
; Bit 2: Stem length.  0 = long, 1 = short.
; Bit 3: Color.  0 = green, 1 = red.  (Red ones move even when the player is near.)
; Bits 4-6: Sprite type.  0 = Piranha Plant, 1 = Venus Fire Trap, 2 = spreadshot Venus, 3 = shower Venus, 4 = aiming Venus, 5 = fire-spitting Piranha Plant, 6 = unused, 7 = unused.
; Bit 7: Spit ice balls instead of fireballs.
;
; Extra byte 2:
;
; Bits 0-1: Number of fireballs to spit.  Varies depending on the sprite type.
; Bits 2-7: Unused.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!ClusterSprite = $09	;$09 is the first custom cluster sprite

StatePtrs:
	dw S00_InPipe
	dw S01_MoveOut
	dw S02_OutOfPipe
	dw S03_MoveBack

; 2 different stem tiles - depends on orientation
; 2 different stem palettes - depends on color
; 4 different stem tile flips - depends on orientation and direction
; 8 different head tiles - depends on frame, type, and orientation
; 6-8 different head palettes - depends on color, type, and fire/ice status

HeadTileList:	;horz,vert,horz2,vert2
	db $AA,$AC,$AB,$AD
VenusTileList:	;same as above
	db $C6,$C6,$A6,$A6
StemTileList:	;horz,vert
	db $AE,$AF

!StemPalette1	= $0A
!StemPalette2	= $08

; indexed by sprite type, last index used by first 2 plants if the stem is short
; index 7 used as head when red and short stem
HeadTilePalette:
	db $08,$08,$04,$04,$02,$08,$FF,$0A,$08
HeadTilePaletteShort:
	db $0A,$0A,$04,$04,$02,$08,$FF,$FF,$0A

!HeadIcePalette	= $0E

; This tile will be invisible because it has sprite priority setting 0,
; but it will go in front of the plant tiles to cover it up when it is in a pipe.
; That way, the plant tiles don't need to have hardcoded priority.
; This tile should be as close to square as possible.

!CoverUpTile = $44			; the invisible tile used to cover up the sprite when it is in a pipe

; up, down, left, right
HeadXOffset:
	db $00,$00,$00,$10

HeadYOffset:
	db $00,$10,$00,$00

; note: some of these states are impossible. much easier to handle this way
; up, down, left, right, frame1, x flip
; up, down, left, right, frame2, x flip
; up, down, left, right, frame1, no flip
; up, down, left, right, frame2, no flip
; up, down, left, right, frame1, xy flip
; up, down, left, right, frame2, xy flip
; up, down, left, right, frame1, y flip
; up, down, left, right, frame2, y flip
VenusHeadYOffset:
	db $00,$10,$00,$00
	db $01,$0F,$00,$00
	db $00,$10,$00,$00
	db $00,$0F,$00,$00
	db $00,$10,$00,$00
	db $01,$10,$00,$00
	db $00,$10,$00,$00
	db $01,$10,$00,$00
StemXOffset:
	db $00,$00,$10,$08
StemYOffset:
	db $10,$08,$00,$00
TileXOffset:
	db $08,$08,$00,$00
TileYOffset:
	db $00,$00,$08,$08

TileFlip:
	db $00,$80,$00,$40
VenusFlip:
	db $40,$00,$C0,$80
StemFlip:
	db $40,$80
StemOffset:
	db $18,$00
HeadOffset:
	db $00,$18
HeadOffset2:
	db $08,$F8

; indexed by sprite type
HeadType:
	db $00,$01,$01,$01,$01,$00

; these tables are indexed by the direction and orientation
CoverUpXOffset:
	db $00,$00,$00,$10
CoverUpYOffset:
	db $00,$10,$00,$00
InitOffsetYLo:
	db $FF,$EF,$08,$08
InitOffsetYHi:
	db $FF,$FF,$00,$00
InitOffsetXLo:
	db $08,$08,$00,$F0
InitOffsetXHi:
	db $00,$00,$00,$FF

Clipping:
	db $01,$14

!TimeInState00 = $40
!TimeInState02 = $60
TimeInState01:
	db $20,$18

!Speed = $10

XSpeed:
	db $00,$00,(!Speed^$FF)+1,!Speed
YSpeed:
	db (!Speed^$FF)+1,!Speed,$00,$00

; indexed by sprite type
PlantType:
	db $00,$01,$01,$01,$01,$00

; indexed by sprite type and number of fireballs to spit
NumberToSpit:
	db $00,$00,$00,$00
	db $01,$02,$03,$04
	db $03,$04,$05,$07
	db $02,$03,$04,$05
	db $01,$02,$03,$04
	db $02,$04,$06,$08

!TimeUntilSpit = $30

TimeBetweenSpits:
	db $00,$50,$00,$0C,$16,$10



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	PHB
	PHK
	PLB
	LDA !7FAB40,x
	AND #%00000100
	STA $0F         ; short/long

	LDA !7FAB40,x
	STA !1510,x
	STA $00
	AND #$70
	LSR #4
	BEQ +
	LDY #$01			;Enable Cluster Sprite if it spawns them
	STY $18B8|!addr
+
	TAY
	LDA.w PlantType,y
	STA !1534,x
	PHY
	LDA !7FAB4C,x
	STA !160E,x
	LDY #!StemPalette1
	LDA !extra_bits,x
	AND #$04
	BEQ +
	LDY #!StemPalette2
+
	LDA $00
	AND #$03
	PHY
	TAY
	PLA
	ORA.w TileFlip,y
	STA !1FD6,x
	LDA !D8,x
	CLC
	ADC.w InitOffsetYLo,y
	STA !D8,x
	LDA !14D4,x
	ADC.w InitOffsetYHi,y
	STA !14D4,x
	LDA !E4,x
	CLC
	ADC.w InitOffsetXLo,y
	STA !E4,x
	LDA !14E0,x
	ADC.w InitOffsetXHi,y
	STA !14E0,x
	TYA
	LSR
	TAY
	LDA.w Clipping,y
	STA !1662,x
	LDA !D8,x
	STA !151C,x
	LDA !E4,x
	STA !1528,x
	LDA #!TimeInState00
	STA !1504,x
	
	LDA $00
	AND #$03
	TAY
	LDA.w TileFlip,y
	STA $01
	PLY
	BIT $00
	BPL +
	LDA #!HeadIcePalette
	BRA .End
+
	CPY #$02
	BCS +
	LDA $00
	AND #$08
	BEQ +
	TAY
+
	LDX $0F
	BNE .short
	LDA.w HeadTilePalette,y
	BRA .End
.short:
	LDA.w HeadTilePaletteShort,y
.End
	TSB $01
	LDA $01
	LDX $15E9|!addr
	STA !15F6,x
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL

SpriteMainRt:
	LDA !C2,x
	BEQ .NoGFX
	JSR SubGFX
.NoGFX
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BNE EndMain
	LDA !C2,x
	ASL
	TAY
	LDA StatePtrs,y
	STA $00
	LDA StatePtrs+1,y
	STA $01
	JMP (!dp)

;------------------------------------------------
; state 00 - in a pipe
;------------------------------------------------

S00_InPipe:
	LDA !1504,x
	BEQ .MaybeChange
	DEC !1504,x
	RTS
.MaybeChange
	LDA !1510,x
	AND #$08
	BNE .Change
	JSR CheckProximity
	BCC .Return
.Change
	INC !C2,x
	LDA !1510,x
	AND #$04
	LSR #2
	TAY
	LDA TimeInState01,y
	STA !1504,x
	STZ !1594,x
.Return
EndMain:
	RTS

;------------------------------------------------
; state 01 - emerging from the pipe
;------------------------------------------------

S01_MoveOut:
	JSR SharedRt
	LDA !1510,x
	AND #$03
S01_03_Shared:
	TAY
	LDA XSpeed,y
	STA !B6,x
	PHA
	LDA YSpeed,y
	STA !AA,x
	BEQ .NoUpdateY
	JSL $01801A|!bank
.NoUpdateY
	PLA
	BEQ .NoUpdateX
	JSL $018022|!bank
.NoUpdateX  
	DEC !1504,x
	BNE .Return
	INC !C2,x
	LDA #!TimeInState02
	STA !1504,x
	LDA !160E,x
	STA $00
	LDA !1510,x
	AND #$70
	LSR #2
	ORA $00
	TAY
	LDA NumberToSpit,y
	STA !1626,x
.Return
	RTS

;------------------------------------------------
; state 02 - fully out of the pipe
;------------------------------------------------

S02_OutOfPipe:
	JSR SharedRt
	LDA !1534,x
	BEQ .NoFixFrame
	LDA !1504,x
	CMP #!TimeUntilSpit-$20
	BCC .NoFixFrame
	CMP #!TimeUntilSpit+$20
	BCS .NoFixFrame
	LDA #$00
	STA !1602,x
.NoFixFrame
	LDA !1510,x
	AND #$70
	LSR #4
	STA $04
	LDA !1626,x
	BEQ .MaybeChange
	LDA !1504,x
	CMP #!TimeUntilSpit
	BNE .DecReturn
	LDA !163E,x
	BNE .Return
.Spit
	JSR SpitProjectiles
	LDY $04
	LDA TimeBetweenSpits,y
	STA !163E,x
	RTS
.DecReturn
	DEC !1504,x
	RTS
.MaybeChange
	DEC !1504,x
	BEQ .ChangeState
	RTS
.ChangeState
	INC !C2,x
	LDA !1510,x
	AND #$04
	LSR #2
	TAY
	LDA TimeInState01,y
	STA !1504,x
.Return
	RTS

;------------------------------------------------
; state 03 - going back into the pipe
;------------------------------------------------

S03_MoveBack:
	JSR SharedRt
	LDA !1510,x
	AND #$03
	TAY
	LDA XSpeed,y
	EOR #$FF : INC
	STA !B6,x
	PHA
	LDA YSpeed,y
	EOR #$FF : INC
	STA !AA,x
	BEQ .NoUpdateY
	JSL $01801A|!bank
.NoUpdateY
	PLA
	BEQ .NoUpdateX
	JSL $018022|!bank
.NoUpdateX
	DEC !1504,x
	BNE .Return
	STZ !C2,x
	LDA #!TimeInState00
	STA !1504,x
.Return
	RTS

;------------------------------------------------
; code shared between multiple states
;------------------------------------------------

SharedRt:
	LDA !1534,x
	BEQ .NoFace
	JSR FacePlayer
.NoFace
	LDA !1594,x
	BNE .NoInteraction
	JSL $01A7DC|!bank
.NoInteraction
	LDA !1534,x
	BNE .VenusAni
	INC !1570,x
	LDA !1570,x
	LSR #3
	AND #$01
	STA !1602,x
.EndAnimation
	RTS
.VenusAni:
	LDA !1510,x
	AND #$70
	BEQ .EndAnimation
	LDA #$01
	STA !1602,x
	RTS

CheckProximity:
	STZ !1594,x
	%SubHorzPos()
	LDA $0E
	CLC
	ADC #$1B
	CMP #$37
	BCS .Return
	INC !1594,x
.Return
	RTS

FacePlayer:
	LDA !1510,x
	AND #$70
	CMP #$30
	BEQ .FixedV
	%SubVertPos()
	TYA
	ASL
	STA !157C,x
	BRA .CheckHoriz
.FixedV
	LDA #$02
	STA !157C,x
.CheckHoriz
	LDA !1510,x
	AND #$02
	BNE .FixedH
	%SubHorzPos()
	TYA
	ORA !157C,x
	STA !157C,x
	RTS
.FixedH
	LDA !1510,x
	AND #$01
	EOR #$01
	ORA !157C,x
	STA !157C,x
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
	%GetDrawInfo()			; set some variables up for writing to OAM
	LDA !157C,x
	STA $02					; direction into $02
	LDA !1510,x
	STA $04					; behavior byte 1 into $04
	AND #$03
	STA $05					; direction and orientation into $05
	LSR
	STA $06					; orientation into $06
	LSR
	LDA !1602,x
	ROL
	STA $03
	LDA !1534,x
	STA $07					; plant type into $07
	LDA $05
	AND #$01
	STA $08
	STZ $09
	LDA !1FD6,x
	STA $0B
	LDA !15F6,x
	STA $0D
	LDA !C2,x
	CMP #$02				; if the sprite is all the way out of the pipe...
	BEQ .StemOnly				; then draw just the stem and head
.AlwaysCovered
	LDA $04
	AND #$01
	STA $0A					; save the direction bit for use with the cover-up routine
	LDA !D8,x
	SEC
	SBC !151C,x
	STA $0C
	LDA !E4,x
	SEC
	SBC !1528,x
	CLC
	ADC $0C
	LDX $0A
	BEQ .NoFlipCheckVal
	EOR #$FF
	INC
.NoFlipCheckVal
	CLC
	ADC #$10
	CMP #$20
	BCC .CoverUpTileOnly
.StemAndCoverUpTile
	JSR .DrawCoverUpTile
.StemOnly
	JSR .DrawStem
.EndGFX
	JSR .DrawHead				; the head tile is always drawn
	PHY
	LDA $09
	DEC
	LDY #$00
	LDX $15E9|!addr
	%FinishOAMWrite()
	PLY
	LDA $07
	BEQ +
	TYA
	LSR #2
	TAY
	LDA $0460|!addr,y
	ORA #$02
	STA $0460|!addr,y
+
	LDA !C2,x
	CMP #$02
	BEQ +
	LDA !15EA,x
	LSR #2
	TAY
	LDA $0460|!addr,y
	ORA #$02
	STA $0460|!addr,y
+
	RTS

.CoverUpTileOnly
	JSR .DrawCoverUpTile
	BRA .EndGFX

.DrawHead
	LDX $03
	LDA $07
	BEQ .NormalHead
.VenusHead
	LDA.w VenusTileList,x
	STA $0302|!addr,y
	LDA $0D
	AND #$3F
	LDX $02
	ORA.w VenusFlip,x
	ORA $64					; and the level's sprite priority
	STA $0303|!addr,y
	LDX $05
	LDA $00
	CLC
	ADC.w HeadXOffset,x		; set the X offset for the head tile
	STA $0300|!addr,y

	; yoff table index is in the following format:
	; ---ffadd
	; f: flip state
	; a: animation frame
	; d: direction
	LDA $02      ; head flip state
	ASL #3       ; shift to bits 3 and 4
	STA $02      ; safe to clobber here
	LDA $03      ; animation frame
	AND #$02     ; stored left shifted once...
	ASL          ; shift once more to 2nd bit (stays in A now)
	ORA $05      ; or in bits 3 and 4
	ORA $02      ; or in direction (bits 0 and 1)
	TAX
	LDA $01
	CLC
	ADC.w VenusHeadYOffset,x
	STA $0301|!addr,y

	INC $09
	RTS

.NormalHead
	LDA.w HeadTileList,x
	STA $0302|!addr,y
	STA $0306|!addr,y
	CLC
	ADC #$10
	STA $030A|!addr,y
	STA $030E|!addr,y
	LDX $06
	LDA $0D
	ORA $64
	STA $0303|!addr,y
	STA $030B|!addr,y
	EOR.w StemFlip,x
	STA $0307|!addr,y
	STA $030F|!addr,y
	TXA
	BEQ ..vert
	LDX $08
	LDA $01
	STA $0301|!addr,y
	STA $0309|!addr,y
	CLC
	ADC #$08
	STA $0305|!addr,y
	STA $030D|!addr,y
	LDA $00
	CLC
	ADC.w HeadOffset,x
	STA $0300|!addr,y
	STA $0304|!addr,y
	CLC
	ADC.w HeadOffset2,x
	STA $0308|!addr,y
	STA $030C|!addr,y
	BRA +
..vert
	LDX $08
	LDA $00
	STA $0300|!addr,y
	STA $0308|!addr,y
	CLC
	ADC #$08
	STA $0304|!addr,y
	STA $030C|!addr,y
	LDA $01
	CLC
	ADC.w HeadOffset,x
	STA $0301|!addr,y
	STA $0305|!addr,y
	CLC
	ADC.w HeadOffset2,x
	STA $0309|!addr,y
	STA $030D|!addr,y
+
	LDA $09
	CLC
	ADC #$04
	STA $09
	RTS

.DrawCoverUpTile
	LDX $15E9|!addr
	LDA !151C,x				; make backups of the XY init positions
	STA $0F
	LDA !1528,x
	LDX $05
	SEC
	SBC $1A
	CLC
	ADC.w CoverUpXOffset,x
	STA $0300|!addr,y
	LDA $0F
	SEC
	SBC $1C
	CLC
	ADC.w CoverUpYOffset,x
	STA $0301|!addr,y
	LDA #!CoverUpTile
	STA $0302|!addr,y
	LDA #$00
	STA $0303|!addr,y
	INY #4
	INC $09
	RTS

.DrawStem
	LDX $06
	LDA.w StemTileList,x
	STA $0302|!addr,y
	STA $0306|!addr,y
	STA $030A|!addr,y
	STA $030E|!addr,y
	LDA $0B
	ORA $64					; and the level's sprite priority
	STA $0303|!addr,y
	STA $030B|!addr,y
	EOR.w StemFlip,x
	STA $0307|!addr,y
	STA $030F|!addr,y
	LDX $05
	LDA $00
	CLC
	ADC.w StemXOffset,x		; set the X offset for the stem tile
	STA $0300|!addr,y
	CLC
	ADC.w TileXOffset,x
	STA $0304|!addr,y
	LDA $01
	CLC
	ADC.w StemYOffset,x		; set the Y offset for the stem tile
	STA $0301|!addr,y
	CLC
	ADC.w TileYOffset,x
	STA $0305|!addr,y
	LDA $04
	BIT #$04
	BNE +
	LSR #2
	LDX $08
	BCS ..horz
	LDA $0300|!addr,y
	STA $0308|!addr,y
	LDA $0304|!addr,y
	STA $030C|!addr,y
	LDA $01
	ADC.w StemOffset,x
	STA $0309|!addr,y
	STA $030D|!addr,y
	BRA ++
..horz
	LDA $0301|!addr,y
	STA $0309|!addr,y
	LDA $0305|!addr,y
	STA $030D|!addr,y
	LDA $00
	CLC
	ADC.w StemOffset,x
	STA $0308|!addr,y
	STA $030C|!addr,y
++
	LDA $09
	CLC
	ADC #$04
	STA $09
	TYA
	ADC #$10
	TAY
	RTS
+
	TYA
	CLC
	ADC #$08
	TAY
	INC $09
	INC $09
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Venus Fire Trap fireball-spit routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $00, $01, $02, $03, $04, $0B - used by the routine?
; $05 - misc. scratch
; $06-$07 - pointer to Y speeds for spreadshot
; $08 - X speed to use
; $09 - Y speed to use
; $0A - gravity flag
; $0C-$0D - X offset
; $0E-$0F - Y offset

;(+/-2,4) from the head

FireXOffsets1:
	db $06,$02,$06,$02,$06,$02,$06,$02
	db $06,$02,$06,$02,$16,$12,$16,$12
FireYOffsets1:
	db $04,$04,$04,$04,$14,$14,$14,$14
	db $04,$04,$04,$04,$04,$04,$04,$04
FireXSpeeds1:
	db $08,$F8,$08,$F8
FireYSpeeds1:
	db $06,$06,$FA,$FA

; Bit 0: Direction.  0 = up/left, 1 = right/down.
; Bit 1: Orientation.  0 = vertical, 1 = horizontal.
; Bit 2: Stem length.  0 = long, 1 = short.

FireXSpeeds1A:
	db $07,$F9,$07,$F9,$0A,$F6,$0A,$F6
FireYSpeeds1A:
	db $0A,$0A,$F6,$F6,$04,$04,$FC,$FC

!FireTotalSpeed1B = $18

FireYSpeedPtrs2:
;	dw FireYSpeeds2x2
	dw FireYSpeeds2x3
	dw FireYSpeeds2x4
	dw FireYSpeeds2x5
;	dw FireYSpeeds2x6
	dw FireYSpeeds2x7

FireYSpeeds2x2:
	dw $03,$08
FireYSpeeds2x3:
	db $02,$06,$0A
FireYSpeeds2x4:
	db $02,$05,$08,$0B
FireYSpeeds2x5:
	db $01,$03,$05,$07,$09
FireYSpeeds2x6:
	db $01,$03,$05,$07,$09,$0B
FireYSpeeds2x7:
	db $01,$03,$05,$07,$09,$0B,$0D
!FireXSpeed2 = $0A

!FireYSpeed3 = $D0

!FireTotalSpeed4 = $20

!FireXOffset5 = $0004
!FireYOffset5 = $0006
!FireXSpeed5x1 = $11
!FireXSpeed5x2 = $EF
!FireYSpeed5 = $CC

SpitProjectiles:
	LDA $04
	ASL
	TAY
	LDA SpitPtrs-2,y
	STA $00
	LDA SpitPtrs-1,y
	STA $01
	JMP (!dp)

SpitPtrs:
	dw .NormalVenus
	dw .SpreadVenus
	dw .ShowerVenus
	dw .AimingVenus
	dw .FirePiranha

.NormalVenus
	JSR .SetDefaultOffsets
	JSR .SetPositions
	REP #$20
	LDA $8A
	SEC
	SBC $94
	BPL $04
	EOR #$FFFF : INC
	STA $00
	LDA $8C
	SEC
	SBC #$0010
	SEC
	SBC $96
	BPL $04
	EOR #$FFFF : INC
	LDY #$00
	CMP $00
	BCS $02
	LDY #$04
	SEP #$20
	TYA
	CLC
	ADC !157C,x
	TAY
	LDA FireXSpeeds1A,y
	STA $08
	LDA FireYSpeeds1A,y
	STA $09
	STZ $0A
	JSR SpawnFireball
	DEC !1626,x
	RTS

.SpreadVenus
	LDA !1626,x
	DEC
	STA $05
	LDA !160E,x
	ASL
	TAY
	REP #$20
	LDA FireYSpeedPtrs2,y
	STA $06
	SEP #$20
	LDA !157C,x
	LSR
	LDA #!FireXSpeed2
	BCC $03
	EOR #$FF : INC
	STA $08
	STZ $0A
	JSR .SetDefaultOffsets
	JSR .SetPositions
	LDA !157C,x
	AND #$02
	STA $03
..Loop
	LDY $05
	LDA ($06),y
	LDY $03
	BEQ $03
	EOR #$FF : INC
	STA $09
	JSR SpawnFireball
	DEC $05
	BPL ..Loop
	STZ !1626,x
	RTS

.ShowerVenus
	JSR GetHorizDistance
	LDA $8A
	LSR
	LDY $8E
	BNE $03
	EOR #$FF : INC
	STA $08
	LDA #!FireYSpeed3
	STA $09
	LDA #$01
	STA $0A
	BRA .Shared

.AimingVenus
	LDA #!FireTotalSpeed4
.AimingVenusSub
	JSR MagikoopaAimRt
	LDA $00
	STA $09
	LDA $01
	STA $08
	STZ $0A
.Shared
	JSR .SetDefaultOffsets
	JSR .SetPositions
	JSR SpawnFireball
	DEC !1626,x
	RTS

.FirePiranha
	LDA.b #!FireXOffset5
	STA $0C
	LDA.b #!FireXOffset5>>8
	STA $0D
	LDA.b #!FireYOffset5
	STA $0E
	LDA.b #!FireYOffset5>>8
	STA $0F
	JSR .SetPositions
	LDA #!FireXSpeed5x1
	STA $08
	LDA #!FireYSpeed5
	STA $09
	LDA #$01
	STA $0A
	JSR SpawnFireball
	LDA #!FireXSpeed5x2
	STA $08
	JSR SpawnFireball
	DEC !1626,x
	DEC !1626,x
	RTS

.SetDefaultOffsets
	LDA !1510,x
	AND #$03
	ASL #2
	STA $00
	LDA !157C,x
	ORA $00
	TAY
	STZ $0D
	LDA FireXOffsets1,y
	STA $0C
	BPL $02
	DEC $0D
	STZ $0F
	LDA FireYOffsets1,y
	STA $0E
	BPL $02
	DEC $0F
	RTS

.SetPositions
	LDA !E4,x
	CLC
	ADC $0C
	STA $8A
	LDA !14E0,x
	ADC $0D
	STA $8B
	LDA !D8,x
	CLC
	ADC $0E
	STA $8C
	LDA !14D4,x
	ADC $0F
	STA $8D
	RTS

SpawnFireball:
	LDY #$13
.Loop
	LDA $1892|!addr,y
	BEQ .FoundSlot
	DEY
	BPL .Loop
	RTS
.FoundSlot
	LDA !1510,x
	ASL
	BCC .NotIce
	LDA #$02
	TSB $0A
.NotIce
	LDA #!ClusterSprite
	STA $1892|!addr,y
	LDA $8A
	STA $1E16|!addr,y
	LDA $8B
	STA $1E3E|!addr,y
	LDA $8C
	STA $1E02|!addr,y
	LDA $8D
	STA $1E2A|!addr,y
	LDA $08
	STA $1E66|!addr,y
	LDA $09
	STA $1E52|!addr,y
	LDA $0A
	STA $0F4A|!addr,y
	LDA #$FF
	STA $0F5E|!addr,y
	LDA !1510,x
	ASL
    	LDA #$06
    	STA $1DFC|!Base2    ;Sound effect	
	RTS

GetHorizDistance:
	PHY
	LDY #$00
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	SEC
	SBC $94
	BPL $05
	EOR #$FFFF
	INC
	INY
	STA $8A
	SEP #$20
	STY $8E
	PLY
	RTS

GetVertDistance:
	PHY
	LDY #$00
	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	SEC
	SBC $96
	BPL $05
	EOR #$FFFF
	INC
	INY
	STA $8C
	SEP #$20
	STY $8F
	PLY
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Magikoopa's aiming routine ($01BF6A, from yoshicookiezeus's disassembly)
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MagikoopaAimRt:
	STA $01				;
	PHX					;
	PHY					; preserve the indexes of the spawner and the spawned sprite
	JSR SubVertPos2		; $0E = vertical distance
	STY $02				; $02 = vertical direction
	LDA $0E				; $0C = vertical distance (absolute value)
	BPL $03				;
	EOR #$FF				;
	INC					;
	STA $0C				;
	%SubHorzPos()		; $0F = horizontal distance
	STY $03				; $03 = horizontal direction
	LDA $0E				; $0D = horizontal distance (absolute value)
	BPL $03				;
	EOR #$FF				;
	INC					;
	STA $0D				;
	LDY #$00				;
	LDA $0D				;
	CMP $0C				;
	BCS .NoSwitch			; if the vertical distance is less than the horizontal distance...
	INY					; increment Y
	PHA					;
	LDA $0C				;
	STA $0D				; and switch $0C and $0D
	PLA					;
	STA $0C				;
.NoSwitch				;
	STZ $00				;
	STZ $0B				; clear $00 and $0B
	LDX $01				;
.Loop					;
	LDA $0B				;
	CLC					;
	ADC $0C				;
	CMP $0D				; if $0C + $0B < $0D, branch
	BCC .Label1			; else, subtract $0D and increase $00
	SBC $0D				;
	INC $00				;
.Label1					;
	STA $0B				;
	DEX					;
	BNE .Loop			;
	TYA					;
	BEQ .NotSwitched		; if $0C and $0D were switched...
	LDA $00				; then switch $00 and $01 as well
	PHA					;
	LDA $01				;
	STA $00				;
	PLA					;
	STA $01				;
.NotSwitched				;
	LDA $00				;
	LDY $02				;
	BEQ $03				; if the horizontal distance was inverted,
	EOR #$FF				; invert $00
	INC					;
	STA $00				;
	LDA $01				;
	LDY $03				;
	BEQ $03				; if the vertical distance was inverted,
	EOR #$FF				; invert $01
	INC					;
	STA $01				;
	PLY					; retrieve sprite indexes
	PLX					;
	RTS					;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; SubVertPos2
;
; - Checks whether the sprite is above or below the player, using their lower tile
; - Also outputs the distance between them (low byte only)
; - Input: None
; - Output:
;	- Y = direction status (00 -> sprite above, 01 -> sprite below)
;	- $0F = 8-bit signed vertical distance between the player and the sprite
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubVertPos2:
	REP #$20
	LDA $96
	CLC
	ADC #$0010
	STA $0C
	SEP #$20
	LDY #$00
	LDA $0C
	SEC
	SBC !D8,x
	STA $0F
	LDA $0D
	SBC !14D4,x
	BPL $01
	INY
	RTS
