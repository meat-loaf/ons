;fly guy by smkdan (optimized by Blind Devil)
;flying shyguy that carries an item and releases it on kill

;USES EXTRA BIT
; if set, spawned sprite will be custom.

;EXTRA BYTE 1
; holds which sprite will be spawned.

;EXTRA BYTE 2
; graphics draw under feet

;EXTRA BYTE 3
; properties for item tile

;EXTRA BYTE 4
; the state of the spawned sprite. uses state #$08 if set to #$00

;Tilemap defines:
!Propeller1 =	$2B	;propeller frame 1
!Propeller2 =	$2C	;propeller frame 2
!Propeller3 =	$3B	;propeller frame 3
!Propeller4 =	$3C	;propeller frame 4
!Body =		$27	;body
!Feet =		$29	;feet

!FeetPal =	$03	;feet palette, CCC format ($FF to use same color as the body, the palette from CFG)

!SpawnSprite = !extra_byte_1
!SpawnTile = !extra_byte_2
!SpawnProp = !extra_byte_3
!SpawnState = !extra_byte_4

SINE:	db $00,$01,$02,$03,$04,$03,$02,$01 
	db $00,$FF,$FE,$FD,$FC,$FD,$FE,$FF

XSPDH:	db $04,$FC

!TURN_COUNT = $20

;C2: Item drop status
;1570: Turn counter
;1602: sine index

print "INIT ",pc
	%SubHorzPos()
	TYA
	STA !157C,x		;face Mario
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL


Run:
	JSR GFX			;draw sprite

	LDA !14C8,x
	EOR #$08
	ORA $9D			;locked sprites?
	ORA !15D0,x		;yoshi eating?
	ORA !C2,x
	BNE Return

	LDA #$03
	%SubOffScreen()

	JSR CheckHurt		;don't generate if there's no interaction
	BEQ DoSpeed

	JSR Generate		;generate sprite

DoSpeed:
	LDA $14			;frame counter...
	AND #$03		;every 4th frame, decrement
	BNE DontTurn

	INC !1570,x		;increment turn counter
	LDA !1570,x
	CMP #!TURN_COUNT
	BNE DontTurn

	STZ !1570,x		;reset turn counter
	LDA !157C,x		;direction...
	EOR #$01		;invert
	STA !157C,x		;new direction

DontTurn:
	JSR SineMotion

	LDY !157C,x		;xspd depending on direction
	LDA XSPDH,y
	STA !B6,x

	JSL $01802A|!BankB	;speed update
Return:
	RTS        

SineMotion:
	LDA !1602,x		;dedicated sine index
	INC A			;advance
	STA !1602,x		;and store

	LSR #3
	AND #$0F		;only 16 entries
	TAY
	LDA SINE,y		;grab entry
	STA !AA,x		;new Yspd
	RTS

;===

Generate:
	STZ $00			;spawn at same X-pos
	LDA #$19		;load Y offset
	STA $01			;store to scratch RAM.
	STZ $02 : STZ $03	;spawn sprite with zero speed

	LDA !7FAB10,x		;load extra bits
	AND #$04		;check if first extra bit is set
	BEQ .notcustom		;if not, spawn normal sprite.

	;LDA !7FAB28,x		;load extra property 1 value (holds sprite to spawn)
	LDA !extra_byte_1,x
	SEC			;clear carry - generate custom sprite
	BRA .spawn

.notcustom
	;LDA !7FAB28,x		;load extra property 1 value (holds sprite to spawn)
	LDA !SpawnSprite,x
	CLC			;clear carry - generate normal sprite
.spawn
	%SpawnSprite()
	BCS .out
	LDA #$04
	STA !spr_extra_bits,y
	LDA !SpawnState,x
	BEQ .out
	STA !14C8,y
.out:	
	LDA !SpawnProp,x
	AND #$0F
	STA !15F6,y
	INC !C2,x		;only do this once
	RTS

;damage check routine

CheckHurt:
	LDY #!SprSize-1		;loop count

CheckLoop:
	LDA !14C8,y		;sprite status
	CMP #$09
	BNE CheckKick
	BRA ClipTest		;jump to cliptest
	
CheckKick:
	CMP #$0A		;sprites never have normal status
	BNE NextSprite

	LDA !1686,y		;skip sprites that don't interact with others
	AND #$08
	BNE NextSprite

ClipTest:
	JSL $03B69F|!BankB	;clipA
	PHX
	TYX
	JSL $03B6E5|!BankB	;clipB
	PLX
	JSL $03B72B|!BankB	;check contact between A and B
	BCC NextSprite		;no contact = don't set

;contact GFX custom

	LDY #$03	;start at 3	

NewIndex:
	LDA $17C0|!Base2,y
	BEQ FoundIndex          
	DEY                       
	BPL NewIndex           
	INY

FoundIndex:
	LDA #$02                
	STA $17C0|!Base2,y
	LDA !E4,x	;sprite x         
	STA $17C8|!Base2,y

	LDA !D8,x	;sprite Y         
	STA $17C4|!Base2,y
	LDA #$08                
	STA $17CC|!Base2,y

	%Star()		;call star routine

	LDA #$01	;contact successful
	RTS

NextSprite:
        DEY
	BPL CheckLoop

;try contact by stomp

	JSL $01A7DC|!BankB	;mario interact
	BCC No_Interaction

	LDA $1490|!BankB	;star status, check first
	BEQ No_Star_Kill

	%Star()			;call star routine

	LDA #$01		;contact successful
	RTS

No_Star_Kill:
        %SubVertPos()
        LDA $0F			;must hold the vertical difference
        CMP #$F0                ;larger value means mario can jump into the side of its head
        BPL Hurt_Mario
        LDA $7D			;don't interact on rising speed
        BMI No_Interaction

;contact

        LDA $140D|!Base2	;spin jump?
        BNE Spin_Jump

	JSL $01AB99|!BankB	;contact graphic
        LDA #$13                ;sound effect
        STA $1DF9|!Base2

        JSL $01AA33|!BankB      ;set mario speed

	LDA #$02		;sprite is falling off screen
	STA !14C8,x

	LDA #$01		;contact successful
	RTS

Spin_Jump:
	JSR SUB_STOMP_PTS	;points and consecutive kills
        JSL $01AA33|!BankB	;set mario speed
        JSL $01AB99|!BankB	;display contact graphic
        LDA #$04		;being killed by spin jump
        STA !14C8,x
        LDA #$1F		;spin jump animation timer
        STA !1540,x
        JSL $07FC3B|!BankB	;show star animation
        LDA #$08		;sound effect
        STA $1DF9|!Base2

	LDA #$01		;contact successful
        RTS

Hurt_Mario:
	JSL $00F5B7|!BankB	;hurt Maio

No_Interaction:
	LDA #$00
	RTS			;last return
			
;=====

TILEMAP:	db !Propeller1,!Propeller1	;propeller
		db !Body			;body
		db !Feet			;feet

		db !Propeller2,!Propeller2
		db !Body
		db !Feet

		db !Propeller3,!Propeller3
		db !Body
		db !Feet

		db !Propeller4,!Propeller4
		db !Body
		db !Feet

XDISP:		db $00,$08
		db $00
		db $00

YDISP:		db $00,$00
		db $06
		db $14

SIZE:		db $00,$00
		db $02
		db $02

PROP:		db $00,$40
		db $00
		db $00

CPAL:		db $FF,$FF
		db $FF
		db !FeetPal

XBIAS:		db $08,$08
		db $00
		db $00

EORF:		db $40,$00


GFX:
	%GetDrawInfo()
	LDA !157C,x	;direction...
	STA $03

	LDA !15F6,x	;properties...
	STA $04

	LDA !14C8,x	;if sprite not normal, don't animate
	CMP #$08
	BEQ Norm

	STZ $08		;dead frame
	LDX #$00
	BRA OAM_Loop

Norm:
	LDA $14		;frame counter...
	AND #$03	;4
	ASL #2		;x4
	STA $08

	LDX #$00	;loop index

OAM_Loop:
	TYA
	LSR #2
	PHY
	TAY
	LDA SIZE,x
	STA $0460|!Base2,y	;size table
	PLY			;restore

	LDA $03
	BNE XLeft

	LDA $00
	SEC
	SBC XDISP,x			;pulling x here = loop index
	CLC
	ADC XBIAS,x		;add bias since it throws it on the other side
	STA $0300|!Base2,y
	BRA XNext
XLeft:
	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!Base2,y
XNext:

	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y

	TXA	
	CLC
	ADC $08
	PHX
	TAX
	LDA TILEMAP,x
	STA $0302|!Base2,y
	PLX

	LDA PROP,x
	ORA $64
	PHX
	LDX $03
	EOR EORF,x
	PLX

	STA $09		;store current value to $09
	LDA CPAL,x
	CMP #$FF
	BEQ CustomPal	;if #$FF, use user supplied palette

	ASL		;else move into palette bits
	TSB $09		;OR with current bits
	LDA $04
	AND #$01	;load only the low bit, page bit
	TSB $09		;OR with current bits
	LDA $09		;get ready to store it

	BRA StoreProp	;skip past custom palette bit
	
CustomPal:
	LDA #$00	;reset		
	LDA $04		;just OR with $04
	ORA $09		;and also $09

StoreProp:
	STA $0303|!Base2,y

	INY
	INY
	INY
	INY
	INX
	CPX #$04	;4 tiles ATM
	BEQ End_Loop
	JMP OAM_Loop

End_Loop:

;draw item
	LDX $15E9|!Base2	;load sprite index again

	LDA !C2,x		;item pending?
	BNE NoItem

;if still holding, draw it

	TYA
	LSR #2
	PHY
	TAY
	LDA #$02		;16x16 item
	STA $0460|!Base2,y	;size table
	PLY			;restore
	
	LDA $00			;same xpos
	STA $0300|!Base2,y

	LDA $01
	CLC
	ADC #$16		;on feet ypos
	STA $0301|!Base2,y

	LDA !SpawnTile,x	;tile
	STA $0302|!Base2,y

	LDA !SpawnProp,x		;properties
	ORA $64
	STA $0303|!Base2,y
	LDY #$FF		;$460 written
	LDA #$04		;5 tiles
	JSL finish_oam_write|!bank
	RTS

NoItem:
	LDY #$FF		;$460 written
	LDA #$03		;4 tiles
	JSL finish_oam_write|!bank
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; points routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STAR_SOUNDS:         db $00,$13,$14,$15,$16,$17,$18,$19

SUB_STOMP_PTS:      PHY                     ; 
                    LDA $1697|!Base2        ; \
                    CLC                     ;  | 
                    ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
                    INC $1697|!Base2	    ; increase consecutive enemies stomped
                    TAY                     ;
                    INY                     ;
                    CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
                    BCS NO_SOUND            ; /    ... don't play sound 
                    LDA STAR_SOUNDS,y       ; \ play sound effect
                    STA $1DF9|!Base2        ; /   
NO_SOUND:           TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET            ;  |
                    LDA #$08                ; /
NO_RESET:           JSL $02ACE5|!BankB      ; give mario points
                    PLY                     ;
                    RTS                     ; return
