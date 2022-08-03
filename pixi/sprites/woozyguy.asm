prot GFX

;woozy guy
;by smkdan

;this reqiores dsx.asm in the patch directory to be applied to your ROM

;GRAPHICS ARE IN WOOZYGUY.bIN
;IT MUST BE IN THE SAME DIRECTORY AS THIS ASM FILE

;a shyguy that jumps and spins in the air

!PROPRAM = $04

	!Temp = $09
	!Timers = $0B

	!SlotPointer = $0660|!Base2	;16bit pointer for source GFX
	!SlotBank = $0662|!Base2	;bank
	!SlotDestination = $0663|!Base2	;VRAM address
	!SlotsUsed = $06FE|!Base2	;how many slots have been used

	!MAXSLOTS = $04			;maximum selected slots

XSPD:	db $10,$F0
!YSPD		= $30
!JUMP_INTERVAL	= $20
	
;C2: frame index
;1570: behaviour
;1602: behaviour counter if applicable for behaviour

PRINT "INIT ",pc
	%SubHorzPos()
	TYA
	STA !157C,x

	; use x position to set pallete props
	; note: expects palette bits to be 0, or it doesn't work properly
	LDA !E4,x	;\ Load low byte of position...
	LSR #4		;| ...of 16x16 grid
	AND #$03	;| Take lower 3 bytes.
	INC : INC	;| increment twice to make range [2..5]
	CLC		;|
	ASL		;| shift into palette position in properties
	ORA !15F6,x	;| or result into properties (in A)
	STA !15F6,x	;/ store it back

	LDA !7FAB10,x	;\
	AND #$04	; |
	ASL		; |
	STA !151C,x	; | Store extra bit to a miscellaneous sprite table.
	BEQ .No32x32	; | If extra bit set...
	LDA !1662,x	; | ...make the clipping be 32x32.
	ORA #$0E	; |
	STA !1662,x	; |
	LDA !1656,x	; |
	ORA #$07	; |
	STA !1656,x	;/

.No32x32
	RTL

PRINT "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL

RETURN_L:
	RTS

Run:

	;LDA !E4,x	;
	;AND #$03	;
	;INC : INC	;
	;CLC
	;ASL		
	;STA $00
	;LDA !15F6,x
	;AND #$0E
	;EOR !15F6,x
	;ORA $00
	;STA !15F6,x	;

	LDA #$00 : %SubOffScreen()
	LDA !14C8,x
	CMP #$08
	BEQ .norm
	CMP #$03
	BEQ RETURN_L
	CMP #$02
	BNE RETURN_L
.norm
	JSR SubGFX			;draw sprite

	LDA !14C8,x
	EOR #$08
	ORA $9D			;locked sprites?
	ORA !15D0,x		;yoshi eating?
	BNE RETURN_L

	LDA !1588,x		;stop it from rising if it's touching from below
	AND #$08		;bit 3: touching cieling
	BEQ NOCIELING
	STZ !AA,x		;no yspd
NOCIELING:
	LDA !1588,x		;flip direction if touching object
	AND #$03
	BEQ NOWALL
	LDA !157C,x		;invert direction
	EOR #$01
	STA !157C,x
NOWALL:
	LDA !1570,x		;5 behaviour stages
	CMP #$05
	BNE NOCLIP
	STZ !1570,x		;reset behaviour
NOCLIP:
;determine action.  a list of JMP instructions can fake a JUMP table, for next time.  not sure how else you can get a label's address here
	LDA !1570,x		;load behaviour
	BEQ NOTHING		;00: still for A BIT
	DEC : BEQ SQUISHA	;01: squishing to JUMP
	DEC : BEQ JUMP		;02: JUMP
	DEC : BEQ ROTATING	;03: ROTATING in the air
	DEC : BEQ SQUISHA	;04: squish at end of JUMP

NOTHING:
	STZ !C2,x		;frame index = 0 (normal standing)
	LDA !1588,x		;don't advance if in air
	AND #$04
	BEQ SKIPA		;exit if in air
	INC !1602,x		;advance counter
	LDA !1602,x		;test counter...
	CMP #!JUMP_INTERVAL	;yes
	BNE SKIPA		;wait some more

	INC !1570,x		;next behaviour (squish to JUMP)
	STZ !1602,x		;reset counter
	BRA SKIPA

SQUISHA:
	INC !1602,x		;advance counter
	LDA !1602,x		;and test...
	CMP #$08		;test for 8 passed FRAMES
	BEQ ENDSQUISHA
	BIT #$04		;test unsquishing bit
	BEQ NOINV
	EOR #$07		;unsquishing has these bits inverted, also invert the unsquishing bit to zero
NOINV:
	ASL A			;YI goes twice as quick
	CLC			;add 0x10 since that's where squishing FRAMES start
	ADC #$10
	STA !C2,x		;new frame index
	BRA SKIPA		;all done

ENDSQUISHA:
	INC !1570,x		;next behaviour (JUMP)
	STZ !C2,x		;...and frame index
	STZ !1602,x		;reset counter
	BRA SKIPA

JUMP:
	LDY !157C,x		;depending on direction..
	LDA XSPD,y
	STA !B6,x		;new XSPD
	LDA #!YSPD
	EOR #$FF		;two's complement
	INC A
	STA !AA,x		;new yspd

	INC !1570,x		;next behaviour
	STZ !1602,x		;counter
	BRA SKIPA

ROTATING:
	DEC !1602,x		;-1.  used in gfx routine for this behaviour only.  decrement because i rotated them the wrong way in photoshop...

	LDY !157C,x		;update xspeed depending on direction which can change during rotation
	LDA XSPD,y
	STA !B6,x		;new XSPD

	LDA !1588,x		;ground = end
	AND #$04
	BEQ SKIPA		;don't end if in air
	
	INC !1570,x		;next behaviour
	STZ !C2,x		;zero frame
	STZ !B6,x		;halt XSPD
	STZ !1602,x		;reset counter
	BRA SKIPA	
SKIPA:
	JSL $01A7DC|!BankB	;mario interact
	JSL $01802A|!BankB	;speed
	JSL $018032|!BankB	;sprites

RETURN:
	RTS			
;=====

FRAMES:
	db $00,$01,$02,$03	;\
	db $10,$11,$12,$13	; |
	db $20,$21,$22,$23	; |
	db $30,$31,$32,$33	; | 16x16 frames.
				; |
	db $40,$41,$42,$43	; | \
	db $50,$51,$52,$53	;/  /  Squishing frames.

XDISP:	db $F8,$08,$F8,$08
YDISP:	db $F8,$F8,$08,$08
TILEMAP:
	db $00,$02,$20,$22

EORS:	db $0F,$00

RETURNGL:
	RTS

SubGFX:
	%GetDrawInfo()
	LDA !15F6,x	; properties...
	ORA #$01        ; for skooshed ani, 15F6 should have no tilemap high bit
	STA !PROPRAM

	LDA !1570,x	;test for ROTATING case
	CMP #$03	;03: ROTATING
	BNE NOTROTO

;ROTATING gfx handling
	LDA !1602,x	;load roto counter
	BIT #$10	;flip / rotate?
	BEQ NOFR
	PHA
	LDA #$C0	;set x/y bits
	TSB !PROPRAM
	PLA

NOFR:
	AND #$0F	;clip to 16 FRAMES
	STA !C2,x	;new frame index	
	
NOTROTO:
	PHA
	LDA !157C,x	;flip x on direction
	BNE NOINVG
	LDA !PROPRAM
	EOR #$40
	STA !PROPRAM
NOINVG:
	PLA

	PHY
	LDY !C2,x	;load frame index
	LDA FRAMES,y
	LDY !151C,x
	STY $0C
	BEQ .No32x32
	CLC : ADC #$60
.No32x32
	PLY
	
	REP #$10
	LDX #GFX
	%GetDynSlot()
	BCC RETURNGL
	STA !Temp	;store to scratch

	LDX #$00	;zero index

OAM_LOOP:
	LDA !PROPRAM
	AND #$40
	BEQ NOXFM
	LDA $00
	SEC : SBC XDISP,x
	CLC : ADC $0C
	STA $0300|!Base2,y
	BRA N1
NOXFM:
	LDA $00
	CLC : ADC XDISP,x
	CLC : ADC $0C
	STA $0300|!Base2,y

N1:
	LDA !PROPRAM
	AND #$80
	BEQ NOYFM
	LDA $01
	SEC : SBC YDISP,x
	CLC : ADC $0C
	STA $0301|!Base2,y
	BRA N2

NOYFM:
	LDA $01
	CLC : ADC YDISP,x
	CLC : ADC $0C
	STA $0301|!Base2,y

N2:
	LDA TILEMAP,x
	CLC
	ADC !Temp	;add calculated tile
	STA $0302|!Base2,y

	LDA !PROPRAM
	ORA $64
	STA $0303|!Base2,y

	INY #4
	INX
	CPX #$04
	BNE OAM_LOOP

	LDX $15E9|!Base2	;restore sprite index 

        LDY #$02
        LDA #$03               ;4 tiles
        JSL $01B7B3|!BankB

	RTS
RETURNG:
	LDX $15E9|!Base2	;restore sprite index 
	RTS

GFX:
incbin woozyguy.bin
