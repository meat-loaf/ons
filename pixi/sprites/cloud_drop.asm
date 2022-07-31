;Cloud Drop by smkdan (optimized by Blind Devil)

;will swoosh back and forth between an area defined by range.
;DOESN'T USE EXTRA BIT
;EXTRA PROP 1: Range.  Keep it sane or it'll rush offscreen.

;Graphics defines:
; Horizontal
!Head1 =	$0A	;head frame 1
!Head2 =	$0C	;head frame 2
!Head3 =	$0E	;head frame 3
!Head4 =	$20	;head frame 4
!Head5 =	$22	;head frame 5
!Tail =		$34	;tail
!Tail2 =        $35     ; second tail frame

; Vertical
!VHead1 =	$00	;head frame 1
!VHead2 =	$02	;head frame 2
!VHead3 =	$04	;head frame 3
!VHead4 =	$06	;head frame 4
!VHead5 =	$08	;head frame 5
!VTail  =	$24	;tail


INCDECTBL:	db $FF,$01	;right, left.  Sub if going right, add if going left.
EORTBL:		db $00,$FF
TWOCTBL:	db $00,$01

print "INIT ",pc

;	%store_spriteset_off_long(cloud_drop_offs)

	LDA !extra_byte_1,x
	BMI .backwards
	INC !157C,x
	EOR #$FF
	STA $00
	BRA .continue
.backwards
	INC
	AND #$7F                 ; \ need positive speed in extra_byte_1, so fix it.
	DEC                      ; | original code didnt do a 'proper' inversion, so
	STA !extra_byte_1,x      ; / adust accordingly
	STA $00
	%BEC(.xposadj)
	LDA !14D4,x              ; \ For some reason, when starting 'backwards'
	XBA                      ; | the sprite is three pixels 'off'.
	LDA !D8,x                ; | Since I'm a nasty little bastard,
	REP #$20                 ; | I just adjust the sprite's position
	CLC : ADC #$0003         ; | and call it a day.
	SEP #$20                 ; |
	STA !D8,x                ; |
	XBA : STA !14D4,x        ; /
	BRA .continue
.xposadj
	LDA !14E0,x              ; \ For some reason, when starting 'backwards'
	XBA                      ; | the sprite is three pixels 'off'.
	LDA !E4,x                ; | Since I'm a nasty little bastard,
	REP #$20                 ; | I just adjust the sprite's position
	CLC : ADC #$0003         ; | and call it a day.
	SEP #$20                 ; |
	STA !E4,x                ; |
	XBA : STA !14E0,x        ; /
.continue

	LDA !7FAB10,x
	AND #$04
	BEQ +
	LDA $00
	STA !AA,x       ;into speed(y)
	STZ !1570,x	;reset turning byte
	RTL
+       LDA $00
	STA !B6,x	;into speed (x)
	STZ !1570,x	;reset turning byte
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL
Return_B:
	RTS
Run:
	JSR GFX

	LDA !14C8,x
	EOR #$08
	ORA $9D			;locked sprites?
	ORA !15D0,x		;being eaten by yoshi?
	BNE Return_B
	%SubOffScreen()

	LDA !1570,x	;turning byte..
	BEQ Keep_Moving
	INC !1570,x	;increment once each frame
	CMP #$13
	BNE Return_I	;return if it's hit the total frames

	LDA !157C,x	;change direction
	EOR #$01
	CLC
	STA !157C,x

        LDA !7FAB10,x
        AND #$04
        BEQ +
	LDA !extra_byte_1,x ; load original speed
	LDY !157C,x
	EOR EORTBL,y	;invert accordingly
	CLC
	ADC TWOCTBL,y	;two's complement adjustment
	STA !AA,x	;new xspd
        BRA ++
+	LDA !extra_byte_1,x ; load original speed
	LDY !157C,x
	EOR EORTBL,y	;invert accordingly
	CLC
	ADC TWOCTBL,y	;two's complement adjustment
	STA !B6,x	;new xspd

++	STZ !1570,x	;reset counter

	BRA Return_I	;interact

Keep_Moving:
	LDY !157C,x	;load direction..
        LDA !7FAB10,x
        AND #$04
        BEQ +
	LDA !AA,x	;load speed..
	CLC
	ADC INCDECTBL,y	;sub1 or add1 depedning on direction
	STA !AA,x	;new Xspd
	BNE Return_I	;not zero, return as normal
	LDA #$01
	STA !1570,x	;else start turning
        BRA Return_I
+	LDA !B6,x	;load speed..
	CLC
	ADC INCDECTBL,y	;sub1 or add1 depedning on direction
	STA !B6,x	;new Xspd
	BNE Return_I	;not zero, return as normal
	LDA #$01
	STA !1570,x	;else start turning
		
Return_I:
	JSL $018022|!BankB		;speed update
	JSL $01801A|!BankB		;speed update
	JSL $01A7DC|!BankB		;mario interact
	JSL $018032|!BankB		;sprites
	
Return:
	RTS

;=====

TILEMAP:
db !Head1,!Tail
db !Head2,!Tail
db !Head3,!Head3
db !Head4,!Head4
db !Head5,!Tail2
.SIZE
db $02,$00
db $02,$00
db $02,$02
db $02,$02
db $02,00

XDISP:
db $00,$10
db $00,$0E
db $00,$00
db $00,$00
db $00,$F8

db $00,$F8
db $00,$FA
db $00,$00
db $00,$00
db $00,$10

YDISP:
db $00,$05
db $00,$03
db $00,$00
db $00,$00
db $00,$04

PROP:	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$40

	db $40,$40
	db $40,$40
	db $40,$40
	db $40,$40
	db $40,$00

GFX:
	%GetDrawInfo()

;	LDA !spr_spriteset_off,x
;	STA $0E

	STZ $08		; reset
	STZ $06
	STZ $07
	STZ $05

	LDA !15F6,x	;store sprite properties
	STA $04

LDA !7FAB10,x
AND #$04
BEQ +
JMP Vert
+
	LDA !157C,x	;flip
	BNE No_Mirror

	LDA #$0A	;skip past entries with no flip
	STA $06
	STA $05

No_Mirror:
	LDA !1570,x	;frame counter for sprite frames
	LSR #2		;each 8 frames
	ASL		;drop a bit, 2 bytes per entry
	STA $09		;add frame value to indexes

	LDA $08		;chr index
	CLC
	ADC $09
	STA $08
	LDA $06		;xindex
	CLC
	ADC $09
	STA $06
	LDA $07		;yindex
	CLC
	ADC $09
	STA $07
	LDA $05		;$05
	CLC
	ADC $09
	STA $05
	
	LDX #$00	;loop index zero
	STX $0D
OAM_Loop:
	TXA
	CLC
	ADC $06
	PHX
	TAX
	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!Base2,y	;xpos
	PLX

	TXA			;loop index into A
	CLC
	ADC $07			;add index bits
	PHX			;preserve loop index
	TAX			;and we have a prepared YDISP index
	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y	;ypos
	PLX			;restore loop index

	TXA			;same process as seen above
	CLC
	ADC $08
	PHX
	TAX
	LDA TILEMAP,x
	STA $0302|!Base2,y	;CHR

	PHY
	TYA                     ; \
	LSR #2                  ; | index into oam extra bits table
	TAY                     ; /
	LDA TILEMAP_SIZE,x
	STA $0460|!addr,y
	PLY

	PLX

	TXA
	CLC
	ADC $05
	PHX
	TAX
	LDA PROP,x
	ORA $04
	ORA $64			;level bits
	STA $0303|!Base2,y
	PLX

	INY #4
	INX
	CPX #$02		;3 loops
	BNE OAM_Loop

	LDX $15E9|!addr
	LDY #$FF
	LDA #$01
	%FinishOAMWrite()
	RTS

VTILEMAP:
db !VHead1,!VTail
db !VHead2,!VTail
db !VHead3,!VHead3
db !VHead4,!VHead4
db !VHead5,!VTail
.SIZE
db $02,$00
db $02,$00
db $02,$02
db $02,$02
db $02,$00

VXDISP:	db $00,$04
	db $00,$04
	db $00,$00
	db $00,$00
	db $00,$04

VYDISP:	db $00,$10
	db $00,$0B
	db $00,$00
	db $00,$00
	db $00,$F8

	db $00,$F8
	db $00,$FE
	db $00,$00
	db $00,$00
	db $00,$10

VPROP:	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$80

	db $80,$80
	db $80,$80
	db $80,$80
	db $80,$80
	db $80,$00

Vert:
	LDA !157C,x	;flip
	BNE .No_Mirror

	LDA #$0A	;skip past entries with no flip
	STA $06
	STA $05

.No_Mirror:
	LDA !1570,x	;frame counter for sprite frames
	LSR #2		;each 8 frames
	ASL		;drop a bit, 2 bytes per entry
	STA $09		;add frame value to indexes

	LDA $08		;chr index
	CLC
	ADC $09
	STA $08
	LDA $07		;xindex
	CLC
	ADC $09
	STA $07
	LDA $06		;yindex
	CLC
	ADC $09
	STA $06
	LDA $05		;$05
	CLC
	ADC $09
	STA $05
	
	PHX		;preserve sprite index
	LDX #$00	;loop index zero
	
.OAM_Loop:
	TXA
	CLC
	ADC $07
	PHX
	TAX	
	LDA $00
	CLC
	ADC VXDISP,x
	STA $0300|!Base2,y	;xpos
	PLX

	TXA			;loop index into A
	CLC
	ADC $06			;add index bits
	PHX			;preserve loop index
	TAX			;and we have a prepared YDISP index
	LDA $01
	CLC
	ADC VYDISP,x
	STA $0301|!Base2,y	;ypos
	PLX			;restore loop index

	TXA			;same process as seen above
	CLC
	ADC $08
	PHX
	TAX
	LDA VTILEMAP,x
	STA $0302|!Base2,y	;CHR

	PHY
	TYA                     ; \
	LSR #2                  ; | index into oam extra bits table
	TAY                     ; /
	LDA VTILEMAP_SIZE,x
	STA $0460|!addr,y
	PLY

	PLX

	TXA
	CLC
	ADC $05
	PHX
	TAX
	LDA VPROP,x
	ORA $04
	ORA $64			;level bits
	STA $0303|!Base2,y
	PLX

	INY #4
	INX
	CPX #$02		;3 loops
	BNE .OAM_Loop

	PLX			;restore sprite index
					
	LDY #$FF		;16x16 tiles
	LDA #$01		;2 tiles
	%FinishOAMWrite()
	RTS
