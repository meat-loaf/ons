;Ghost Shyguy by smkdan (optimized by Blind Devil)

;USES EXTRA BIT!
;If clear, it will move left first
;If set, it will move right first

; gfx routine changed to use an 8x8 for the tail, this really
; doesn't need 3 16x16 tiles holy shit

;Extra Property Byte 1 = Range before stopping

;Tilemap defines:
!Body = $20	;body.
!Tail1 = $22	;tail, frame 1.
!Tail2 = $32	;tail, frame 2.

print "INIT ",pc
	INC !157C,x     ; move left first
	%BEC(+)
	DEC !157C,x
	LDA !extra_bits,x  ; \ i dont feel like figuring out
	EOR #$04           ; | where it does the range check shit
	STA !extra_bits,x  ; / so just hack it like a chimp
+
	STZ !C2,x	;reset index
	STZ !1570,x	;reset turning animation bits

	LDA !7FAB28,x	;load range property byte
	STA !1528,x	;reset counter to property byte
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL	;also nothing

SINE:	db $00,$03,$05,$07,$08,$07,$05,$03
	db $00,$FD,$FB,$F9,$F8,$F9,$FB,$FD

XSPEED:	db $08,$F8

ReturnI_l:			;alternate access to return with interaction + speed
	JSL $018032|!BankB	;other sprite contact
	JSL $01802A|!BankB	;speed update
	JSL $01A7DC|!BankB	;mario interact

Return_l:			;alternate access return
	RTS  

	
Run:
	JSR GFX		;draw sprite

	LDA !14C8,x
	CMP #$08            	 
	BNE Return_l           
	LDA $9D			;locked sprites?
	BNE Return_l
	LDA !15D0,x
	BNE Return_l

	%SubOffScreen()
	
	LDA !C2,x		;load YSPEED index
	LSR A			;30 updates per second
	TAY		
	LDA SINE,y		;appropriate entry in sine table for the...	
	STA !AA,x		;...y speed
	TYA			;for math
	ROL A			;shift back, would've generated carry
	INC A
	AND #$1F		;16 values, and 32 because of every odd frame
	STA !C2,x		;new index

	LDA !1570,x		;check for any turning animation bits
	AND #$60		;bits 4-6
	BNE Turning		;move as normal if all are clear
	JMP Moving

;=====

Turning:
	CMP #$20
	BEQ Stop
	CMP #$40		;turn1
	BEQ Turn1
	CMP #$60
	BEQ Turn2
	BRA ReturnI_l		;shouldn't be any other scenario...for now

Stop:
	STZ !B6,x		;stop X movement
	LDA !1570,x
	DEC A
	STA !1570,x		;store new counter
	AND #$1F		;32 frames
	BNE ReturnI_l
	
	LDA !1570,x
	AND #$80		;maintain wall bit
	ORA #$5F		;40h + 1Fh, turn 1
	STA !1570,x

	LDA !157C,x
	EOR #$01
	STA !157C,x		;flip it
	
	BRA ReturnI_l		;nothing happens with stop

Turn1:
	LDA !1570,x		;jsut decrement counter
	DEC A
	STA !1570,x
	AND #$1F		;32 frames
	BNE ReturnI_l

	LDA !1570,x
	AND #$80		;wall bit
	ORA #$7F
	STA !1570,x		;turn2

	LDA !157C,x		;flip again
	EOR #$01
	STA !157C,x

	BRA ReturnI

Turn2:
	LDA !1570,x
	DEC A
	STA !1570,x
	AND #$1F
	BNE ReturnI

	LDA !7FAB10,x		;Extra bit
	AND #$04
	BEQ No_Random		;don't roam free if bit 0 isn't set

	LDA !1570,x
	AND #$80		;bit 7 set = it's a wall / object
	BNE No_Random		;must turn back

	LDA $13			;try to increase randomness by chucking in the frame counters
	STA $148B|!Base2
	LDA $14
	STA $148C|!Base2
	JSL $01ACF9|!BankB	;get random
	AND #$01		;just bit 0 of it
	BEQ No_Random		;don't do random if clear

	STZ !1570,x		;stop the turning
	BRA ReturnI		;return without flipping

No_Random:
	LDA !157C,x
	EOR #$01
	STA !157C,x		;flip last time

	STZ !1570,x		;Stop the turning animations
	BRA ReturnI

;======

Moving:
	LDY !157C,x		;load direction
	LDA XSPEED,y	
	STA !B6,x		;change Xspeed

	LDA !1588,x		;is it against an object?
	AND #$03 
	BEQ Same_Direction
	LDA #$3F		;Turning animation, begin with a stop, 20h + 1F
	ORA #$80		;high bit set = it's a wall / object
	STA !1570,x		;bit 5 set = doing the double take animation.  The low 7 for the length
	LDA !7FAB28,x
	STA !1528,x		;also restore the range counter

Same_Direction:
	LDA $14			;frame counter...
	AND #$07
	BNE ReturnI		;only decrement range every 8th frame

	DEC !1528,x		;decrement range of Extra Property Byte 1
	BNE ReturnI
	LDA #$3F		;[same as above] Turning animation, begin with a stop, 20h + 1F
	STA !1570,x		;bit 5 set = doing the double take animation.  The low 7 for the length

	LDA !7FAB28,x
	STA !1528,x		;restore range
			
ReturnI:
	JSL $018032|!BankB	;other sprite contact
	JSL $01802A|!BankB	;speed update
	JSL $01A7DC|!BankB	;mario interact
Return:
	RTS

;================
;GRAPHICS ROUTINE
;================


TILEMAP:	db !Body,!Tail1		;Alternate between tail 1 and 2 for different frames
		db !Body,!Tail2
		db !Body,!Tail1
		db !Body,!Tail2

		db !Tail1,!Body		;another for flipped sprite
		db !Tail2,!Body
		db !Tail1,!Body
		db !Tail2,!Body

XDISP:		db $00,$0D
		db $FA,$00

TILE_SIZE:	db $02,$00
		db $00,$02


YDISP:		db $00,$07
		db $07,$00

PROP:		db $00,$00
		db $00,$00	;lol remove
		db $00,$80	;apply flip to 2/4 frames
		db $00,$80	;lol remove	

		db $00,$00
		db $00,$00
		db $80,$00
		db $80,$00



GFX:
	%GetDrawInfo()

	STY $0F         ;preserve OAM index
	STZ $03
	STZ $05		;reset X/YDISP index
	LDY #$00	;Y will be stored if check passes
	LDA !157C,x	;direction
	BNE No_Flip	;set = no flip

	LDA #$08	;8 bytes into the tilemap, accesses flipped tiles
	STA $03
	LDA #$02	;2 bytes into the DISP values, accesses flipped displacements
	STA $05
	LDY #$40	;Y has the flip bit set otherwise
	
No_Flip:
	STY $04	;flip byte
	LDY $0F         ;restore OAM index
	
	LDA $14		;frame counter that only runs during active gameplay
	LSR #2		;every fourth frame, update
	AND #$06	;clip to %XX0
	CLC
	ADC $03
	STA $03		;scratch
	
	PHX		;preserve sprite index
	LDA !15F6,x	;load proeprties
	ORA $04		;ORA with flip bit set earlier
	STA $04		;and store
	
	LDX #$00	;reset loop index

OAM_Loop:
	TXA
	CLC
	ADC $05			;add x/ydisp index
	PHX			;preserve loop index
	TAX
	LDA $00
	CLC
	ADC XDISP,x		;displacement
	STA $0300|!Base2,y	;store X pos

	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y	;Y pos

	PHY                     ; save main oam index
	TYA                     ; \
	LSR #2                  ; | index into oam extra bits table
	TAY                     ; /
	LDA TILE_SIZE,x
	STA $0460|!addr,y
	PLY                     ; restore main oam index

	PLX			;restore

	TXA			;for math
	CLC
	ADC $03
	PHX			;preserve loop index to...
	TAX			;use math'd one
	LDA TILEMAP,x
	STA $0302|!Base2,y	;store character
	PLX			;restore loop index

	TXA			;loop index into A for math
	CLC
	ADC $03
	PHX			;preserve
	TAX
	LDA PROP,x
	ORA $04			;sprite properties
	ORA $64			;level bits
	STA $0303|!Base2,y	;store properties

	PLX			;restore loop index	

	INY #4
	INX
	CPX #$02		;3 tiles
	BNE OAM_Loop

	PLX			;restore sprite index
					
	LDY #$FF                ; we set tile sizes ourselves
	LDA #$01		;2 tiles
	%FinishOAMWrite()       ;bookkeeping
	RTS
