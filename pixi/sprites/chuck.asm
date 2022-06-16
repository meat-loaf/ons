;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
!Stomps = $03
;;
;; Change this to the amount of hits you want Chargin' Chuck to take
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; USES EXTRA BIT: YES
;;
;; If Extra bit is set, the chuck will not change into a chargin' chuck when hit
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra bytes used: 1
;;
;; Extra byte 1 determines the Chuck's initial starting state (00-0C). See the Init notes.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	InitSpriteTables = $07F7D2|!bank
	SprSprInteract = $018032|!bank
	ShatterBlock = $028663|!bank
	GenerateTile = $00BEB0|!bank
	UpdateYPosNoGrvty = $01801A|!bank
	UpdateXPosNoGrvty = $018022|!bank
	FindFreeSprSlot = $02A9E4|!bank
	GetRand = $01ACF9|!bank
	MarioSprInteract = $01A7DC|!bank
	BoostMarioSpeed = $01AA33|!bank
	GivePoints = $02ACE5|!bank
	DisplayContactGfx = $01AB99|!bank
	HurtMario = $00F5B7|!bank
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; starting states:
; 00-02: chargin' (state 2 will start walking immediately)
; 03: hurt
; 04: diggin'
; 05: preparin' to split
; 06: jumpin' (but won't give speed by default)
; 07: landing (?)
; 08: clappin'
; 09: puntin'
; 0A: pitchin'
; 0B: waiting to whistle (note: will only change to whistlin' when extra bit is set, otherwise becomes a chargin' chuck)
; 0C: whistlin'
; anything higher will crash, so don't do that
print "INIT ",pc
	PHB
	PHK
	PLB

	LDA !extra_byte_1,x
	STA !C2,x
	CMP #$04
	BNE +
	LDA.B #$30
	STA.W !1540,x
	LDA.B !sprite_x_low,X
	AND.B #$10
	LSR A
	LSR A
	LSR A
	LSR A
	STA.W !157C,X
+
	JSR FaceMario
	LDA.W ChuckInitialHeadPos,Y
	STA.W !151C,X
	PLB
	RTL

ChuckInitialHeadPos:  db $00,$04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_02C132:
	db $30,$20,$0A,$30

DATA_02C136:
	db $05,$0E,$0F,$10

Diggin:
	TYX
	LDA !1558,x
	BEQ ADDR_02C156
	CMP #$01
	BNE ADDR_02C150
	LDA #$30
	STA !1540,x
	LDA #$04
	STA !1534,x
	STZ !1570,x
ADDR_02C150:
	LDA #$02
	STA !151C,x
Return02C155:
	RTS                       ; Return

ADDR_02C156:
	LDA !1540,x
	BNE ADDR_02C181
	INC !1534,x
	LDA !1534,x
	AND #$03
	STA !1570,x
	TAY
	LDA DATA_02C132,y
	STA !1540,x
	CPY #$01
	BNE ADDR_02C181
	LDA !1534,x
	AND #$0C
	BNE ADDR_02C17E
	LDA #$40
	STA !1558,x
Return02C17D:
	RTS                       ; Return

ADDR_02C17E:
	JSR DigginChuckSpawnRock
ADDR_02C181:
	LDY !1570,x
	LDA DATA_02C136,y
	STA !1602,x
	LDY !157C,x
	LDA DATA_02C1F3,y
	STA !151C,x
Return02C193:
	RTS                       ; Return


DATA_02C194:
	db $14,$EC

DATA_02C196:
	db $00,$FF

DATA_02C198:
	db $08,$F8

DigginChuckSpawnRock:
	JSL FindFreeSprSlot     ; \ Return if no free slots
	BMI Return02C1F2          ; /
	LDA #$08                ; \ Sprite status = Normal
	STA !14C8,y             ; /
	LDA #$48
	STA !9E,y
	LDA #$09
	LDA !157C,x
	STA $02
	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	PHX
	TYX
	JSL InitSpriteTables
	LDX $02
	LDA $00
	CLC
	ADC DATA_02C194,x
	STA !E4,y
	LDA $01
	ADC DATA_02C196,x
	STA !14E0,y
	LDA DATA_02C198,x
	STA !B6,y
	PLX
	LDA !D8,x
	CLC
	ADC #$0A
	STA !D8,y
	LDA !14D4,x
	ADC #$00
	STA !14D4,y
	LDA #$C0
	STA !AA,y
	LDA #$2C
	STA !1540,y
Return02C1F2:
	RTS                       ; Return


DATA_02C1F3:
	db $01,$03


print "MAIN ",pc

ChucksMain:
	PHB
	PHK
	PLB
	LDA !187B,x
	PHA
	JSR ADDR_02C22C
	PLA
	BNE ADDR_02C211
	CMP !187B,x
	BEQ ADDR_02C211
	LDA !163E,x
	BNE ADDR_02C211
	LDA #$28
	STA !163E,x
ADDR_02C211:
	PLB
Return02C212:
	RTL                       ; Return

ChuckDeadHeadFrame:
	db $01,$02,$03,$02

ADDR_02C217:
	LDA $14
	LSR
	LSR
	AND #$03
	TAY
	LDA ChuckDeadHeadFrame,y
	STA !151C,x
	JSR ChuckGraphics
Return02C227:
	RTS                       ; Return


DATA_02C228:
	db $40,$10

DATA_02C22A:
	db $03,$01

ADDR_02C22C:
	LDA !14C8,x
	CMP #$08
	BNE ADDR_02C217
	LDA !15AC,x
	BEQ ADDR_02C23D
	LDA #$05
	STA !1602,x
ADDR_02C23D:
	LDA !1588,x             ; \ Branch if on ground
	AND #$04                ;  |
	BNE ADDR_02C253           ; /
	LDA !AA,x
	BPL ADDR_02C253
	LDA !C2,x
	CMP #$05
	BCS ADDR_02C253
	LDA #$06
	STA !1602,x
ADDR_02C253:
	JSR ChuckGraphics
	LDA $9D
	BEQ ADDR_02C25B
Return02C25A:
	RTS                       ; Return

ADDR_02C25B:
	LDA #$00
	%SubOffScreen()
	JSR ADDR_02C79D
	JSL SprSprInteract
	JSL $019138
	LDA !1588,x
	AND #$08
	BEQ ADDR_02C274
	LDA #$10
	STA !AA,x
ADDR_02C274:
	LDA !1588,x             ; \ Branch if not touching object
	AND #$03                ;  |
	BEQ ADDR_02C2F4           ; /
	LDA !15A0,x
	ORA !186C,x
	BNE ADDR_02C2E4
	LDA !187B,x
	BEQ ADDR_02C2E4
	LDA !E4,x
	SEC
	SBC $1A
	CLC
	ADC #$14
	CMP #$1C
	BCC ADDR_02C2E4
	LDA !1588,x             ; \ Branch if on ground
	AND #$40                ;  |
	BNE ADDR_02C2E4           ; /
	LDA $18A7|!Base2
	CMP #$2E
	BEQ ADDR_02C2A6
	CMP #$1E
	BNE ADDR_02C2E4
ADDR_02C2A6:
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C2F7           ; /
	LDA $9B
	PHA
	LDA $9A
	PHA
	LDA $99
	PHA
	LDA $98
	PHA
	JSL ShatterBlock
	LDA #$02                ; \ Block to generate = #$02
	STA $9C                   ; /
	JSL GenerateTile
	PLA
	SEC
	SBC #$10
	STA $98
	PLA
	SBC #$00
	STA $99
	PLA
	STA $9A
	PLA
	STA $9B
	JSL ShatterBlock
	LDA #$02                ; \ Block to generate = #$02
	STA $9C                   ; /
	JSL GenerateTile
	BRA ADDR_02C2F4

ADDR_02C2E4:
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C2F7           ; /
	LDA #$C0
	STA !AA,x
	JSL UpdateYPosNoGrvty
	BRA ADDR_02C301

ADDR_02C2F4:
	JSL UpdateXPosNoGrvty
ADDR_02C2F7:
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C301           ; /
	JSR ADDR_02C579
ADDR_02C301:
	JSL UpdateYPosNoGrvty
	LDY !164A,x
	CPY #$01
	LDY #$00
	LDA !AA,x
	BCC ADDR_02C31A
	INY
	CMP #$00
	BPL ADDR_02C31A
	CMP #$E0
	BCS ADDR_02C31A
	LDA #$E0
ADDR_02C31A:
	CLC
	ADC DATA_02C22A,y
	BMI ADDR_02C328
	CMP DATA_02C228,y
	BCC ADDR_02C328
	LDA DATA_02C228,y
ADDR_02C328:
	TAY
	BMI ADDR_02C334
	LDY !C2,x
	CPY #$07
	BNE ADDR_02C334
	CLC
	ADC #$03
ADDR_02C334:
	STA !AA,x
	LDA !C2,x
	TXY
	ASL
	TAX
	JMP (ChuckPtrs,x)

ChuckPtrs:
	dw LookSideToSide
	dw Chargin
	dw PrepCharge
	dw Hurt
	dw Diggin
	dw PrepJump
	dw Jumpin
	dw Landin
	dw Clappin
	dw Puntin
	dw Pitchin
	dw PrepWhistle
	dw Whistlin

PrepWhistle:
	TYX
	LDA #$03
	STA !1602,x
	LDA !164A,x
	BEQ ADDR_02C370
	JSR ADDR_02D4FA
	LDA $0F
	CLC
	ADC #$30
	CMP #$60
	BCS ADDR_02C370
	LDA #$0C
	STA !C2,x
ADDR_02C370:
	JMP ADDR_02C556


DATA_02C373:
	db $05,$05,$05,$02,$02,$06,$06,$06

Whistlin:
	TYX
	LDA $14
	AND #$3F
	BNE ADDR_02C386
	LDA #$1E                ; \ Play sound effect
	STA $1DFC|!Base2               ; /
ADDR_02C386:
	LDY #$03
	LDA $14
	AND #$30
	BEQ ADDR_02C390
	LDY #$06
ADDR_02C390:
	TYA
	STA !1602,x
	LDA $14
	LSR
	LSR
	AND #$07
	TAY
	LDA DATA_02C373,y
	STA !151C,x
	LDA !E4,x
	LSR
	LSR
	LSR
	LSR
	LSR
	LDA #$09
	BCC ADDR_02C3AF
	STA $18B9|!Base2
ADDR_02C3AF:
	STA $18FD|!Base2
Return02C3B2:
	RTS                       ; Return


DATA_02C3B3:
	db $7F,$BF,$FF,$DF

DATA_02C3B7:
	db $18,$19,$14,$14

DATA_02C3BB:
	db $18,$18,$18,$18,$17,$17,$17,$17
	db $17,$17,$16,$15,$15,$16,$16,$16

Pitchin:
	TYX
	LDA !1534,x
	BNE ADDR_02C43A
	JSR ADDR_02D50C
	LDA $0E
	BPL ADDR_02C3E7
	CMP #$D0
	BCS ADDR_02C3E7
	LDA #$C8
	STA !AA,x
	LDA #$3E
	STA !1540,x
	INC !1534,x
ADDR_02C3E7:
	LDA $13
	AND #$07
	BNE ADDR_02C3F5
	LDA !1540,x
	BEQ ADDR_02C3F5
	INC !1540,x
ADDR_02C3F5:
	LDA $14
	AND #$3F
	BNE ADDR_02C3FE
	JSR ADDR_02C556
ADDR_02C3FE:
	LDA !1540,x
	BNE ADDR_02C40C
	LDY !187B,x
	LDA DATA_02C3B3,y
	STA !1540,x
ADDR_02C40C:
	LDA !1540,x
	CMP #$40
	BCS ADDR_02C419
	LDA #$00
	STA !1602,x
Return02C418:
	RTS                       ; Return

ADDR_02C419:
	SEC
	SBC #$40
	LSR
	LSR
	LSR
	AND #$03
	TAY
	LDA DATA_02C3B7,y
	STA !1602,x
	LDA !1540,x
	AND #$1F
	CMP #$06
	BNE Return02C439
	JSR ADDR_02C466
	LDA #$08
	STA !1558,x
Return02C439:
	RTS                       ; Return

ADDR_02C43A:
	LDA !1540,x
	BEQ ADDR_02C45C
	PHA
	CMP #$20
	BCC ADDR_02C44A
	CMP #$30
	BCS ADDR_02C44A
	STZ !AA,x                 ; Sprite Y Speed = 0
ADDR_02C44A:
	LSR
	LSR
	TAY
	LDA DATA_02C3BB,y
	STA !1602,x
	PLA
	CMP #$26
	BNE Return02C45B
	JSR ADDR_02C466
Return02C45B:
	RTS                       ; Return

ADDR_02C45C:
	STZ !1534,x
Return02C45F:
	RTS                       ; Return


BaseballTileDispX:
	db $10,$F8

DATA_02C462:
	db $00,$FF

BaseballSpeed:
	db $18,$E8

ADDR_02C466:
	LDA !1558,x
	ORA !186C,x
	BNE Return02C439
	LDY #$07                ; \ Find a free extended sprite slot
ADDR_02C470:
	LDA $170B|!Base2,y             ;  |
	BEQ ADDR_02C479           ;  |
	DEY                       ;  |
	BPL ADDR_02C470           ;  |
Return02C478:
	RTS                       ; / Return if no free slots

ADDR_02C479:
	LDA #$0D                ; \ Extended sprite = Baseball
	STA $170B|!Base2,y             ; /
	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	LDA !D8,x
	CLC
	ADC #$00
	STA $1715|!Base2,y
	LDA !14D4,x
	ADC #$00
	STA $1729|!Base2,y
	PHX
	LDA !157C,x
	TAX
	LDA $00
	CLC
	ADC BaseballTileDispX,x
	STA $171F|!Base2,y
	LDA $01
	ADC DATA_02C462,x
	STA $1733|!Base2,y
	LDA BaseballSpeed,x
	STA $1747|!Base2,y
	PLX
Return02C4B4:
	RTS                       ; Return


DATA_02C4B5:
	db $00,$00,$11,$11,$11,$11,$00,$00

Puntin:
	TYX
	STZ !1602,x
	TXA
	ASL
	ASL
	ASL
	ADC $13
	AND #$7F
	CMP #$00
	BNE ADDR_02C4D5
	PHA
	JSR ADDR_02C556
;	LDA #$19
;	CLC
;	%SpawnSprite()
	JSL $03CBB3         ; chuck sprite generation routine (just for football...?)
	PLA
ADDR_02C4D5:
	CMP #$20
	BCS Return02C4E2
	LSR
	LSR
	TAY
	LDA DATA_02C4B5,y
	STA !1602,x
Return02C4E2:
	RTS                       ; Return

Clappin:
	TYX
	JSR ADDR_02C556
	LDA #$06
	LDY !AA,x
	CPY #$F0
	BMI ADDR_02C504
	LDY !160E,x
	BEQ ADDR_02C504
	LDA !1FE2,x
	BNE ADDR_02C502
	LDA #$19                ; \ Play sound effect
	STA $1DFC|!Base2               ; /
	LDA #$20
	STA !1FE2,x
ADDR_02C502:
	LDA #$07
ADDR_02C504:
	STA !1602,x
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ Return02C53B          ; /
	STZ !160E,x
	LDA #$04
	STA !1602,x
	LDA !1540,x
	BNE Return02C53B
	LDA #$20
	STA !1540,x
	LDA #$F0
	STA !AA,x
	JSR ADDR_02D50C
	LDA $0E
	BPL Return02C53B
	CMP #$D0
	BCS Return02C53B
	LDA #$C0
	STA !AA,x
	INC !160E,x
ADDR_02C536:
	LDA #$08                ; \ Play sound effect
	STA $1DFC|!Base2               ; /
Return02C53B:
	RTS                       ; Return

Jumpin:
	TYX
	LDA #$06
	STA !1602,x
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ Return02C555          ; /
	JSR ADDR_02C579
	JSR ADDR_02C556
	LDA #$08
	STA !1540,x
	INC !C2,x
Return02C555:
	RTS                       ; Return

ADDR_02C556:
	JSR ADDR_02D4FA
	TYA
	STA !157C,x
	LDA DATA_02C639,y
	STA !151C,x
Return02C563:
	RTS                       ; Return

Landin:
	TYX
	LDA #$03
	STA !1602,x
	LDA !1540,x
	BNE ADDR_02C579
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ Return02C57D          ; /
	LDA #$05
	STA !C2,x
ADDR_02C579:
	STZ !B6,x                 ; Sprite X Speed = 0
	STZ !AA,x                 ; Sprite Y Speed = 0
Return02C57D:
	RTS                       ; Return


DATA_02C57E:
	db $10,$F0

DATA_02C580:
	db $20,$E0

PrepJump:
	TYX
	JSR ADDR_02C556
	LDA !1540,x
	BEQ ADDR_02C602
	CMP #$01
	BNE NoSpawn
	LDA !9E,x
	CMP #$93
	BNE ADDR_02C5A7
	JSR ADDR_02D4FA
	LDA DATA_02C580,y
	STA !B6,x
	LDA #$B0
	STA !AA,x
	LDA #$06
	STA !C2,x
	JMP ADDR_02C536

ADDR_02C5A7:
	STZ !C2,x
	LDA #$50
	STA !1540,x
	LDA #$10                ; \ Play sound effect
	STA $1DF9|!Base2               ; /
	STZ $185E|!Base2        ; scratch: index into spawned chuck x-speed table
	JSR SplittinChuckSplit  ; interesting way to do this twice
	INC $185E|!Base2
SplittinChuckSplit:
	JSL FindFreeSprSlot
	BMI NoSpawn
	LDA #$08                ; \ Sprite status = Normal
	STA !14C8,y             ; /
	LDA #$91
	STA !9E,y
	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y
	LDA !D8,x
	STA !D8,y
	LDA !14D4,x
	STA !14D4,y
	PHX
	TYX
	JSL InitSpriteTables
	LDX $185E|!Base2
	LDA DATA_02C57E,x
	STA !B6,y
	PLX
	LDA #$C8
	STA !AA,y
	LDA #$50
	STA !1540,y
NoSpawn:
	LDA #$09
	STA !1602,x
Return02C601:
	RTS                       ; Return

ADDR_02C602:
	JSR ADDR_02D4FA
	TYA
	STA !157C,x
	LDA $0F
	CLC
	ADC #$50
	CMP #$A0
	BCS ADDR_02C618
	LDA #$40
	STA !1540,x
Return02C617:
	RTS                       ; Return

ADDR_02C618:
	LDA #$03
	STA !1602,x
	LDA $13
	AND #$3F
	BNE Return02C627
	LDA #$E0
	STA !AA,x
Return02C627:
	RTS                       ; Return

ADDR_02C628:
	LDA #$08
	STA !15AC,x
Return02C62D:
	RTS                       ; Return


DATA_02C62E:
	db $00,$00,$00,$00,$01,$02,$03,$04
	db $04,$04,$04

DATA_02C639:
	db $00,$04

LookSideToSide:
	TYX
	LDA #$03
	STA !1602,x
	STZ !187B,x
	LDA !1540,x
	AND #$0F
	BNE ADDR_02C668
	JSR ADDR_02D50C
	LDA $0E
	CLC
	ADC #$28
	CMP #$50
	BCS ADDR_02C668
	JSR ADDR_02C556
	INC !187B,x
ADDR_02C65C:
	LDA #$02
	STA !C2,x
	LDA #$18
	STA !1540,x
Return02C665:
	RTS                       ; Return


DATA_02C666:
	db $01,$FF

ADDR_02C668:
	LDA !1540,x
	BNE ADDR_02C677
	LDA !157C,x
	EOR #$01
	STA !157C,x
	BRA ADDR_02C65C

ADDR_02C677:
	LDA $14
	AND #$03
	BNE ADDR_02C691
	LDA !1534,x
	AND #$01
	TAY
	LDA !1594,x
	CLC
	ADC DATA_02C666,y
	CMP #$0B
	BCS ADDR_02C69B
	STA !1594,x
ADDR_02C691:
	LDY !1594,x
	LDA DATA_02C62E,y
	STA !151C,x
Return02C69A:
	RTS                       ; Return

ADDR_02C69B:
	INC !1534,x
Return02C69E:
	RTS                       ; Return


DATA_02C69F:
	db $10,$F0,$18,$E8

DATA_02C6A3:
	db $12,$13,$12,$13

Chargin:
	TYX
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C6BA           ; /
	LDA !163E,x
	CMP #$01
	BRA ADDR_02C6BA

	LDA #$24                ; \ Play sound effect
	STA $1DF9|!Base2               ; /
ADDR_02C6BA:
	JSR ADDR_02D50C
	LDA $0E
	CLC
	ADC #$30
	CMP #$60
	BCS ADDR_02C6D7
	JSR ADDR_02D4FA
	TYA
	CMP !157C,x
	BNE ADDR_02C6D7
	LDA #$20
	STA !1540,x
	STA !187B,x
ADDR_02C6D7:
	LDA !1540,x
	BNE ADDR_02C6EC
	STZ !C2,x
	JSR ADDR_02C628
	JSL GetRand
	AND #$3F
	ORA #$40
	STA !1540,x
ADDR_02C6EC:
	LDY !157C,x
	LDA DATA_02C639,y
	STA !151C,x
	LDA !1588,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C713           ; /
	LDA !187B,x
	BEQ ADDR_02C70E
	LDA $14
	AND #$07
	BNE ADDR_02C70C
	LDA #$01                ; \ Play sound effect
	STA $1DF9|!Base2               ; /
ADDR_02C70C:
	INY
	INY
ADDR_02C70E:
	LDA DATA_02C69F,y
	STA !B6,x
ADDR_02C713:
	LDA $13
	LDY !187B,x
	BNE ADDR_02C71B
	LSR
ADDR_02C71B:
	LSR
	AND #$03
	TAY
	LDA DATA_02C6A3,y
	STA !1602,x
Return02C725:
	RTS                       ; Return

PrepCharge:
	TYX
	LDA #$03
	STA !1602,x
	LDA !1540,x
	BNE Return02C73C
	JSR ADDR_02C628
	LDA #$01
	STA !C2,x
	LDA #$40
	STA !1540,x
Return02C73C:
	RTS                       ; Return


DATA_02C73D:
	db $0A,$0B,$0A,$0C,$0D,$0C

DATA_02C743:
	db $0C,$10,$10,$04,$08,$10,$18

Hurt:
	TYX
	LDY !1570,x
	LDA !1540,x
	BNE ADDR_02C760
	INC !1570,x
	INY
	CPY #$07
	BEQ HurtUpdatePhase
	LDA DATA_02C743,y
	STA !1540,x
ADDR_02C760:
	LDA DATA_02C73D,y
	STA !1602,x
	LDA #$02
	CPY #$05
	BNE ADDR_02C773
	LDA $14
	LSR
	NOP
	AND #$02
	INC A
ADDR_02C773:
	STA !151C,x
Return02C776:
	RTS                       ; Return

; this was originally a few sprite number checks;
; it also changed the sprite number to 91 to make it a chargin' chuck (..?)
HurtUpdatePhase:
	%BES(ChuckHitOrigPhase)
	LDA #$30
	STA !1540,x
	LDA #$02
	STA !C2,x
	INC !187B,x
	JMP ADDR_02C556
ChuckHitOrigPhase:
	JSR FaceMario
        LDA.W ChuckInitialHeadPos,Y
	STA.W !151C,X
	LDA !extra_byte_1,x
	CMP #$0B
	BNE +
	INC A                     ; change to 'whistling' phase
+
	STA !C2,x
Return02C798:
	RTS                       ; Return


DATA_02C799:
	db $F0,$10

DATA_02C79B:
	db $20,$E0

ADDR_02C79D:
	LDA !1564,x
	BNE Return02C80F
	JSL MarioSprInteract
	BCC Return02C80F
	LDA $1490|!Base2               ; \ Branch if Mario doesn't have star
	BEQ ADDR_02C7C4           ; /
	LDA #$D0
	STA !AA,x
ADDR_02C7B1:
	STZ !B6,x                 ; Sprite X Speed = 0
	LDA #$02                ; \ Sprite status = Killed
	STA !14C8,x             ; /
	LDA #$03                ; \ Play sound effect
	STA $1DF9|!Base2               ; /
	LDA #$03
	JSL GivePoints
Return02C7C3:
	RTS                       ; Return

ADDR_02C7C4:
	JSR ADDR_02D50C
	LDA $0E
	CMP #$EC
	BPL ADDR_02C810
	LDA #$05
	STA !1564,x
	LDA #$02                ; \ Play sound effect
	STA $1DF9|!Base2               ; /
	JSL DisplayContactGfx
	JSL BoostMarioSpeed
	STZ !163E,x
	LDA !C2,x
	CMP #$03
	BEQ Return02C80F
	INC !1528,x             ; Increase Chuck stomp count
ADDR_02C7EB:
	LDA !1528,x             ; \ Kill Chuck if stomp count >= 3
	CMP #!Stomps                ;  |
	BCC ADDR_02C7F6           ;  |
	STZ !AA,x                 ;  | Sprite Y Speed = 0
	BRA ADDR_02C7B1           ; /

ADDR_02C7F6:
	LDA #$28                ; \ Play sound effect
	STA $1DFC|!Base2               ; /
	LDA #$03
	STA !C2,x
	LDA #$03
	STA !1540,x
	STZ !1570,x
	JSR ADDR_02D4FA
	LDA DATA_02C79B,y
	STA $7B
Return02C80F:
	RTS                       ; Return

ADDR_02C810:
	LDA $187A|!Base2
	BNE Return02C819
	JSL HurtMario
Return02C819:
	RTS                       ; Return

ChuckGraphics:
	%GetDrawInfo()

	STZ.b $0F
	LDA   !extra_bits,x
	AND.b #$04
	BEQ.b .not_blue
	LDA.b #$0C
	STA.b $0F
.not_blue
	JSR ADDR_02C88C
	JSR ADDR_02CA27
	JSR ADDR_02CA9D
	JSR ADDR_02CBA1
	LDY #$FF
ADDR_02C82B:
	LDA #$04
	%FinishOAMWrite()
Return02B7AB:
	RTS

!ChuckShoulderTile = $38
!ChuckBaseballTile = $43
; !ChuckShoulderTile = $1C
; !ChuckBaseballTile = $AD

DATA_02C830:
	db $F8,$F8,$F8,$00,$00,$FE,$00,$00
	db $FA,$00,$00,$00,$00,$00,$00,$FD
	db $FD,$F9,$F6,$F6,$F8,$FE,$FC,$FA
	db $F8,$FA

DATA_02C84A:
	db $F8,$F9,$F7,$F8,$FC,$F8,$F4,$F5
	db $F5,$FC,$FD,$00,$F9,$F5,$F8,$FA
	db $F6,$F6,$F4,$F4,$F8,$F6,$F6,$F8
	db $F8,$F5

DATA_02C864:
	db $08,$08,$08,$00,$00,$00,$08,$08
	db $08,$00,$08,$08,$00,$00,$00,$00
	db $00,$08,$10,$10,$0C,$0C,$0C,$0C
	db $0C,$0C

ChuckHeadTiles:
	db $00,$02,$04,$02,$00,$2B,$2B
;ChuckHeadTiles:
;	db $06,$0A,$0E,$0A,$06,$4B,$4B

DATA_02C885:
	db $40,$40,$00,$00,$00,$00,$40


ADDR_02C88C:
	STZ $07
	LDY !1602,x
	STY $04
	CPY #$09
	CLC
	BNE ADDR_02C8AB
	LDA !1540,x
	SEC
	SBC #$20
	BCC ADDR_02C8AB
	PHA
	LSR
	LSR
	LSR
	LSR
	LSR
	STA $07
	PLA
	LSR
	LSR
ADDR_02C8AB:
	LDA $00
	ADC #$00
	STA $00
	LDA !151C,x
	STA $02
	LDA !157C,x
	STA $03
	LDA !15F6,x
	ORA $64
	STA $08
	LDA !15EA,x
	STA $05
	CLC
	ADC DATA_02C864,y
	TAY
	LDX $04
	LDA DATA_02C830,x
	LDX $03
	BNE ADDR_02C8D8
	EOR #$FF
	INC A
ADDR_02C8D8:
	CLC
	ADC $00
	STA $0300|!Base2,y
	LDX $04
	LDA $01
	CLC
	ADC DATA_02C84A,x
	SEC
	SBC $07
	STA $0301|!Base2,y
	LDX $02
	LDA DATA_02C885,x
	ORA $08
	EOR $0F
	STA $0303|!Base2,y
	LDA ChuckHeadTiles,x
	CLC : ADC !tile_off_scratch
	STA $0302|!Base2,y
	TYA
	LSR
	LSR
	TAY
	LDA #$02
	STA $0460|!Base2,y
	LDX $15E9|!Base2               ; X = Sprite index
Return02C908:
	RTS                       ; Return


DATA_02C909:
	db $F8,$F8,$F8,$FC,$FC,$FC,$FC,$F8
	db $01,$FC,$FC,$FC,$FC,$FC,$FC,$FC
	db $FC,$F8,$F8,$F8,$F8,$08,$06,$F8
	db $F8,$01,$10,$10,$10,$04,$04,$04
	db $04,$08,$07,$04,$04,$04,$04,$04
	db $04,$04,$04,$10,$08,$08,$10,$00
	db $02,$10,$10,$07

DATA_02C93D:
	db $00,$00,$00,$04,$04,$04,$04,$08
	db $00,$04,$04,$04,$04,$04,$04,$04
	db $04,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$FC,$FC,$FC
	db $FC,$F8,$00,$FC,$FC,$FC,$FC,$FC
	db $FC,$FC,$FC,$00,$00,$00,$00,$00
	db $00,$00,$00,$00

DATA_02C971:
	db $06,$06,$06,$00,$00,$00,$00,$00
	db $F8,$00,$00,$00,$00,$00,$00,$00
	db $00,$03,$00,$00,$06,$F8,$F8,$00
	db $00,$F8

ChuckBody1:
	db $29,$34,$35,$0E,$26,$2D,$20,$22
	db $2A,$26,$0C,$0C,$0C,$0C,$64,$2D
	db $67,$52,$09,$06,$29,$28,$2A,$42
	db $42,$2A

; originals:
;ChuckBody1:
;	db $0D,$34,$35,$26,$2D,$28,$40,$42
;	db $5D,$2D,$64,$64,$64,$64,$E7,$28
;	db $82,$CB,$23,$20,$0D,$0C,$5D,$BD
;	db $BD,$5D

ChuckBody2:
	db $46,$28,$22,$0E,$26,$2E,$20,$22
	db $AE,$26,$0C,$0C,$0C,$0C,$65,$2E
	db $68,$44,$0A,$07,$46,$4A,$4A,$4C
	db $4E,$48

; originals:
;ChuckBody2:
;	db $4E,$0C,$22,$26,$2D,$29,$40,$42
;	db $AE,$2D,$64,$64,$64,$64,$E8,$29
;	db $83,$CC,$24,$21,$4E,$A0,$A0,$A2
;	db $A4,$AE

DATA_02C9BF:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$40,$00,$00
	db $00,$00

DATA_02C9D9:
	db $00,$00,$00,$40,$40,$00,$40,$40
	db $00,$40,$40,$40,$40,$40,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00

DATA_02C9F3:
	db $00,$00,$00,$02,$02,$02,$02,$02
	db $00,$02,$02,$02,$02,$02,$02,$02
	db $02,$00,$02,$02,$00,$00,$00,$00
	db $00,$00

DATA_02CA0D:
	db $00,$00,$00,$04,$04,$04,$0C,$0C
	db $00,$08,$00,$00,$04,$04,$04,$04
	db $04,$00,$08,$08,$00,$00,$00,$00
	db $00,$00

ADDR_02CA27:
	STZ $06
	LDA $04
	LDY $03
	BNE ADDR_02CA36
	CLC
	ADC #$1A
	LDX #$40
	STX $06
ADDR_02CA36:
	TAX
	LDY $04
	LDA DATA_02CA0D,y
	CLC
	ADC $05
	TAY
	LDA $00
	CLC
	ADC DATA_02C909,x
	STA $0300|!Base2,y
	LDA $00
	CLC
	ADC DATA_02C93D,x
	STA $0304|!Base2,y
	LDX $04
	LDA $01
	CLC
	ADC DATA_02C971,x
	STA $0301|!Base2,y
	LDA $01
	STA $0305|!Base2,y
	LDA ChuckBody1,x
	CLC
	ADC !tile_off_scratch
	STA $0302|!Base2,y
	LDA ChuckBody2,x
	ADC !tile_off_scratch
	STA $0306|!Base2,y

	LDA $08
	ORA $06
	EOR $0F
	PHA
	EOR DATA_02C9BF,x
	STA $0303|!Base2,y
	PLA
	EOR DATA_02C9D9,x
	STA $0307|!Base2,y
	TYA
	LSR
	LSR
	TAY
	LDA DATA_02C9F3,x
	STA $0460|!Base2,y
	LDA #$02
	STA $0461|!Base2,y
	LDX $15E9|!Base2               ; X = Sprite index
Return02CA92:
	RTS                       ; Return


DATA_02CA93:
	db $FA,$00

DATA_02CA95:
	db $0E,$00

ClappinChuckTiles:
	db $28,$24
; orig
;ClappinChuckTiles:
;	db $0C,$44

DATA_02CA99:
	db $F8,$F0

DATA_02CA9B:
	db $00,$02

ADDR_02CA9D:
	LDA $04
	CMP #$14
	BCC ADDR_02CAA6
	JMP ADDR_02CB53

ADDR_02CAA6:
	CMP #$12
	BEQ ADDR_02CAFC
	CMP #$13
	BEQ ADDR_02CAFC
	SEC
	SBC #$06
	CMP #$02
	BCS Return02CAF9
	TAX
	LDY $05
	LDA $00
	CLC
	ADC DATA_02CA93,x
	STA $0300|!Base2,y
	LDA $00
	CLC
	ADC DATA_02CA95,x
	STA $0304|!Base2,y
	LDA $01
	CLC
	ADC DATA_02CA99,x
	STA $0301|!Base2,y
	STA $0305|!Base2,y
	LDA ClappinChuckTiles,x
	CLC
	ADC !tile_off_scratch
	STA $0302|!Base2,y
	STA $0306|!Base2,y
	LDA $08
	EOR $0F
	STA $0303|!Base2,y
	ORA #$40
	STA $0307|!Base2,y
	TYA
	LSR
	LSR
	TAY
	LDA DATA_02CA9B,x
	STA $0460|!Base2,y
	STA $0461|!Base2,y
	LDX $15E9|!Base2               ; X = Sprite index
Return02CAF9:
	RTS                       ; Return


ChuckShoulderGfxProp:
	db $4B,$0B

ADDR_02CAFC:
	LDY $05
	LDA !157C,x
	PHX
	TAX
	ASL
	ASL
	ASL
	PHA
	EOR #$08
	CLC
	ADC $00
	STA $0300|!Base2,y
	PLA
	CLC
	ADC $00
	STA $0304|!Base2,y
	LDA #!ChuckShoulderTile
	CLC
	ADC !tile_off_scratch
	STA $0302|!Base2,y
	INC A
	STA $0306|!Base2,y
	LDA $01
	SEC
	SBC #$08
	STA $0301|!Base2,y
	STA $0305|!Base2,y
	LDA ChuckShoulderGfxProp,x
ADDR_02CB2D:
	ORA $64
	EOR $0F
	STA $0303|!Base2,y
	STA $0307|!Base2,y
	TYA
	LSR
	LSR
	TAX
ADDR_02CB39:
	STZ $0460|!Base2,x
	STZ $0461|!Base2,x
	PLX
Return02CB40:
	RTS                       ; Return


DATA_02CB41:
	db $FA,$0A,$06,$00,$00,$01,$0E,$FE
	db $02,$00,$00,$09,$08,$F4,$F4,$00
	db $00,$F4

ADDR_02CB53:
	PHX
	STA $02
	LDY !157C,x
	BNE ADDR_02CB5E
	CLC
	ADC #$06
ADDR_02CB5E:
	TAX
	LDA $05
	CLC
	ADC #$08
	TAY
	LDA $00
	CLC
	ADC ADDR_02CB2D,x
	STA $0300|!Base2,y
	LDX $02
	LDA ADDR_02CB39,x
	BEQ ADDR_02CB8E
	CLC
	ADC $01
	STA $0301|!Base2,y

	LDA #!ChuckBaseballTile
	CLC : ADC $0F
	STA $0302|!Base2,y

	LDA #$09
	ORA $64
	STA $0303|!Base2,y
	TYA
	LSR
	LSR
	TAX
	STZ $0460|!Base2,x
ADDR_02CB8E:
	PLX
Return02CB8F:
	RTS                       ; Return


DigChuckTileDispX:
	db $FC,$04,$10,$F0,$12,$EE

DigChuckTileProp:
	db $47,$07

DigChuckTileDispY:
	db $F8,$00,$F8

DigChuckTiles:
	db $6E,$60,$62

DigChuckTileSize:
	db $00,$02,$02

ADDR_02CBA1:
	LDA !C2,x         ; \ if diggin'
	CMP #$04          ; /
	BNE Return02CBFB
	LDA !1602,x
	CMP #$05
	BNE ADDR_02CBB2
	LDA #$01
	BRA ADDR_02CBB9

ADDR_02CBB2:
	CMP #$0E
	BCC Return02CBFB
	SEC
	SBC #$0E
ADDR_02CBB9:
	STA $02
	LDA !15EA,x
	CLC
	ADC #$0C
	TAY
	PHX
	LDA $02
	ASL
	ORA !157C,x
	TAX
	LDA $00
	CLC
	ADC DigChuckTileDispX,x
	STA $0300|!Base2,y
	TXA
	AND #$01
	TAX
	LDA DigChuckTileProp,x
	ORA $64
	EOR $0F
	STA $0303|!Base2,y
	LDX $02
	LDA $01
	CLC
	ADC DigChuckTileDispY,x
	STA $0301|!Base2,y
	LDA DigChuckTiles,x

	CLC : ADC !tile_off_scratch
	STA $0302|!Base2,y

	TYA
	LSR
	LSR
	TAY
	LDA DigChuckTileSize,x
	STA $0460|!Base2,y
	PLX
Return02CBFB:
	RTS                       ; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
FaceMario:
	JSR SubHorizPos
	TYA
	STA !157C,x
Return018583:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

SubHorizPos:
	LDY #$00
	LDA $D1
	SEC
	SBC !E4,x
	STA $0F
	LDA $D2
	SBC !14E0,x
	BPL Return01AD41
	INY
Return01AD41:
	RTS                       ; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
ADDR_02D4FA:
	LDY #$00
	LDA $94
	SEC
	SBC !E4,x
	STA $0F
	LDA $95
	SBC !14E0,x
	BPL Return02D50B
	INY
Return02D50B:
	RTS
	
ADDR_02D50C:
	LDY #$00
	LDA $96
	SEC
	SBC !D8,x
	STA $0E
	LDA $97
	SBC !14D4,x
	BPL Return02D51D
	INY
Return02D51D:
	RTS
