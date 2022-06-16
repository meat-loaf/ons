;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Yoshi's Island Poochy - by dtothefourth
;
; Requires dynamic sprites patch dsx.asm
; (Currently available at https://www.smwcentral.net/?p=section&a=details&id=13184 )
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



!Accel     = $02 ;How quickly Poochy accelerates to max speed
!MaxSpeed  = $30 ;Full running speed
!Decel     = $04 ;How quickly Poochy comes to a stop
!RunSound  = 1	 ;If 1, play a sound when running
!RunSFX    = $01 ;Sound effect to play
!RunBank   = $1DF9|!Base2 ;Sound bank to use
!RunFreq   = $07 ;How often to play run sound (ANDed so use 1,3,7,F,1F,3F)

!CloseDist = $0040 ;Poochy won't run up to Mario if already this close
!FarDist   = $0080 ;Poochy won't run up to Mario if further than this

!Jump	   = 1   ;If 1, will try to jump over obstacles
!JumpSpeed = $B0 ;Speed when poochy tries to jump over walls
!JumpSound = 1	 ;If 1, play a sound when jumping
!JumpSFX   = $08 ;Sound effect to play
!JumpBank  = $1DFC|!Base2 ;Sound bank to use

!Play	   = 1	 ;If 1, will swipe at nearby enemies when not running
!PlayRange = $0014 ;Range to trigger play mode

!Kill	   = 1	 ;If 1, will kill sprites when running over them
!KillSpeed = $08 ;If running at least this fast, kills enemies
!KillSound = 1	 ;If 1, play a sound when killing an enemy
!KillSFX   = $08 ;Sound effect to play
!KillBank  = $1DF9|!Base2 ;Sound bank to use

;List of sprites numbers to not kill, end with FF
DontKill:
	db $FF
;00 if the sprite not to kill is vanilla, 01 if custom, one for each dontkill entry
DontKillC:
	db $FF

PRINT "INIT ",pc
	LDA #$FF
	STA !1504,x
	RTL		

PRINT "MAIN ",pc			
	PHB
	PHK				
	PLB				
	JSR Main	
	PLB
	RTL     

!OFFSET = $1528

Main:
	JSR GFX
	LDA !14C8,x		
	CMP #$08		
	BNE +		
	LDA $9D			
	BEQ ++	
	+
	RTS
	++

	%SubOffScreen()         

	JSL $01802A|!BankB

	LDA !B6,x
	BEQ ++
	BMI +

	LDA !1588,x
	AND #$01
	BEQ ++

	LDA !C2,x
	CMP #$03
	BNE +++

	STZ !B6,x

	BRA ++
	+++

	if !Jump
	LDA #$03
	STA !C2,x
	LDA #$0C
	STA !1540,x
	else
	LDA #$09
	STA !C2,x
	endif

	BRA ++
	+
	LDA !1588,x
	AND #$02
	BEQ ++


	LDA !C2,x
	CMP #$03
	BNE +++

	STZ !B6,x

	BRA ++
	+++

	if !Jump
	LDA #$03
	STA !C2,x
	LDA #$0C
	STA !1540,x
	else
	LDA #$09
	STA !C2,x
	endif

	++

	JSL $03B664|!BankB
	JSL $03B69F|!BankB

	STZ !1534,x


	LDA !157C,x
	BEQ +

	LDA $04
	CLC
	ADC #$03
	STA $04
	LDA $0A
	ADC #$00
	STA $0A

	BRA ++
	+

	LDA $04
	SEC
	SBC #$03
	STA $04
	LDA $0A
	SBC #$00
	STA $0A

	++



	LDA $04
	SEC
	SBC #$02
	STA $04
	LDA $0A
	SBC #$00
	STA $0A

	LDA $06
	CLC
	ADC #$04
	STA $06

	LDA $05
	CLC
	ADC #$04
	STA $05
	LDA $0B
	ADC #$00
	STA $0B

	LDA $07
	SEC
	SBC #$08
	STA $07


 
	JSL $03B72B|!BankB
	BCC Below		

	%SubVertPos()		

	LDA !C2,x
	CMP #$03
	BNE +
	LDA $0F	
	CMP #$E6		
	BPL Below		
	BRA ++
	+
	LDA $0F			
	CMP #$DC		
	BPL Below		
	++

	LDA $7D		
	BMI Below		

	LDA #$01		
	STA $1471|!Base2	
	STA !1534,x

	STZ $7D	

	LDA !C2,x
	CMP #$01
	BNE +

	LDA !157C,x
	CMP $76
	BEQ +

	LDA #$05
	STA !C2,x

	+

	;LDA #$06		
	;STA !154C,x		
			

	LDA #$DA		
	LDY $187A|!Base2	
	BEQ NotOnYoshi		
	LDA #$CA		
	NotOnYoshi:		
	CLC			
	ADC !D8,x		
	STA $96			
	LDA !14D4,x		
	ADC #$FF		
	STA $97			

	LDA !157C,x
	EOR #$01
	INC
	AND $77
	BNE Below

	LDY #$00		
	LDA $1491|!addr	
	BPL RightXOffset	
	DEY			
RightXOffset:	
	CLC			
	ADC $94		
	STA $94		
	TYA			
	ADC $95		
	STA $95		


Below:


	LDA !C2,X
	ASL
	TAY
	REP #$20
	LDA States,y
	STA $00
	SEP #$20
	JMP ($0000)
RETURN1:
	RTS

States:
	dw Waiting	
	dw Chasing	     
	dw Looking    
	dw Jumping
	dw Stopping
	dw PreTurn
	dw Turning
	dw Crouching	  
	dw Playing
	dw Pause

WaitFrames:
	db $02, $01, $00, $01

Waiting:
	LDA !C2,x
	CMP !1504,x
	BEQ +
	STA !1504,x
	LDA #$00
	STA !1602,x
	+

	LDA !1588,x
	BNE +
	LDA #$01
	STA !C2,x
	RTS
	+

	LDA $14
	AND #$07
	BNE +

	LDA !1602,x
	INC
	CMP #$04
	BNE ++
	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA WaitFrames,y
	STA !OFFSET,X

	LDA !1534,x
	BNE ++

	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CLC
	ADC #$0014
	SEC
	SBC $94
	STA $00
	CLC
	ADC #!CloseDist 
	CMP #!CloseDist*2
	SEP #$20
	BCC +

	REP #$20
	LDA $00
	CLC
	ADC #!FarDist 
	CMP #!FarDist*2
	SEP #$20
	BCS +

	++
	LDA #$01
	STA !C2,x
	RTS
	+


	if !Play
	LDA !1588,x
	AND #$04
	BEQ +
	JSR PlaySprites
	+
	endif
	RTS

Pause:
	STZ !B6,x

	LDA !C2,x
	CMP !1504,x
	BEQ +
	STA !1504,x
	LDA #$00
	STA !1602,x
	STA !151C,x
	+

	LDA !1588,x
	BNE +
	LDA #$01
	STA !C2,x
	RTS
	+

	LDA $14
	AND #$07
	BNE +

	LDA !1602,x
	INC
	CMP #$04
	BNE ++


	LDA #$00
	STA !C2,x
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA WaitFrames,y
	STA !OFFSET,X

	RTS

ChaseFrames:
	db $06,$05,$04,$03

Chasing:	

	if !RunSound
	LDA $14
	AND #!RunFreq
	BNE +
	LDA #!RunSFX
	STA !RunBank
	+
	endif	

	LDA !C2,x
	CMP !1504,x
	BEQ +
	STA !1504,x
	LDA #$00
	STA !1602,x

	LDA !1588,x
	AND #$04
	BEQ +

	%SubHorzPos()
	TYA			
	EOR #$01
	STA !157C,x	
	+

	if !Kill
	LDA !B6,x
	BPL +
	EOR #$FF
	INC
	+
	CMP #!KillSpeed
	BCC +
	JSR KillSprites
	+
	endif

	LDA $14
	AND #$03
	BNE +


	LDA !1602,x
	INC
	CMP #$04
	BNE ++
	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA ChaseFrames,y
	STA !OFFSET,X

	LDA !1588,x
	AND #$04
	BNE +
	RTS
	+

	LDA !1534,x
	BNE ++

	%SubHorzPos()
	TYA			
	CMP !157C,x	
	BEQ Passed
	BRA +++

	++
	LDA !157C,x
	EOR #$01
	+++
	CMP #$00
	BEQ Right

	LDA !B6,x
	SEC
	SBC #!Accel
	CMP.B #($100-!MaxSpeed)
	BCS +
	LDA.B #($100-!MaxSpeed)
	+
	STA !B6,x


	RTS

Right:
	LDA !B6,x
	CLC
	ADC #!Accel
	CMP.B #(!MaxSpeed)
	BCC +
	LDA.B #(!MaxSpeed)
	+
	STA !B6,x

	RTS

Passed:
	LDA !1534,x
	BNE +
	LDA #$04
	STA !C2,x
	+
	RTS

Stopping:	
	if !Kill
	LDA !B6,x
	BPL +
	EOR #$FF
	INC
	+
	CMP #!KillSpeed
	BCC +
	JSR KillSprites
	+
	endif

	LDA $14
	AND #$07
	BNE +


	LDA !1602,x
	INC
	CMP #$04
	BNE ++
	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA ChaseFrames,y
	STA !OFFSET,X

Decel:
	LDA !157C,x	
	BEQ SRight

	LDA !B6,x
	SEC
	SBC #!Decel
	BPL +

	LDA #$02
	STA !C2,x

	LDA #$00
	+
	STA !B6,x
	RTS

SRight:
	LDA !B6,x
	CLC
	ADC #!Accel
	BMI +

	LDA #$02
	STA !C2,x

	LDA #$00

	+
	STA !B6,x

	RTS

LookFrames:
	db $00, $10, $10, $00

Looking:

	LDA !C2,x
	CMP !1504,x
	BEQ +
	STA !1504,x
	LDA #$00
	STA !1602,x
	STA !151C,x
	+

	LDA $14
	AND #$03
	BNE +

	LDA !1602,x
	INC
	CMP #$02
	BNE +++

	LDA !157C,x
	EOR #$01
	STA !157C,x

	LDA #$02
	+++
	CMP #$04
	BNE ++

	LDA !151C,x
	INC
	STA !151C,x
	CMP #$03
	BNE +++
	LDA #$00
	STA !C2,x
	+++
	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA LookFrames,y
	STA !OFFSET,X

	RTS	
	
Jumping:
	STZ !B6,x


	LDA !1540,x
	BEQ +

	LDA !1588,x
	AND #$04
	BNE ++
	INC !1540,x
	RTS

	++

	LDA !1540,x
	CMP #$01
	BNE ++

	LDA #!JumpSpeed
	STA !AA,x

	if !JumpSound
	LDA #!JumpSFX
	STA !JumpBank
	endif	

	LDA #$00
	STA !1602,x

	++
	LDA #$07
	STA !OFFSET,X
	RTS

	+

	LDA !157C,x
	EOR #$01
	INC
	AND !1588,x
	BNE +

	LDA !157C,x
	BEQ ++
	LDA #$20
	STA !B6,x
	BRA +
	++
	LDA #$E0
	STA !B6,x
	+


	LDA $14
	AND #$1F
	BNE +


	LDA !1602,x
	INC
	CMP #$04
	BNE ++
	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA ChaseFrames,y
	STA !OFFSET,X

	LDA !1588,x
	AND #$04
	BEQ +
	LDA #$00
	STA !C2,x
	+

	RTS

PreTurn:
	if !Kill
	LDA !B6,x
	BPL +
	EOR #$FF
	INC
	+
	CMP #!KillSpeed
	BCC +
	JSR KillSprites
	+
	endif

	LDA $14
	AND #$07
	BNE +


	LDA !1602,x
	INC
	CMP #$04
	BNE ++
	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA ChaseFrames,y
	STA !OFFSET,X

	LDA !157C,x	
	BEQ TRight

	LDA !B6,x
	SEC
	SBC #!Decel
	BPL +

	LDA #$06
	STA !C2,x

	LDA #$00
	+
	STA !B6,x
	RTS

TRight:
	LDA !B6,x
	CLC
	ADC #!Accel
	BMI +

	LDA #$06
	STA !C2,x

	LDA #$00

	+
	STA !B6,x
	RTS

Turning:

	LDA !C2,x
	CMP !1504,x
	BEQ +
	STA !1504,x
	LDA #$00
	STA !1602,x
	STA !151C,x
	+

	LDA $14
	AND #$03
	BNE +

	LDA !1602,x
	INC
	CMP #$02
	BNE +++

	LDA !157C,x
	EOR #$01
	STA !157C,x

	LDA #$02
	+++
	CMP #$04
	BNE ++

	LDA #$01
	STA !C2,x
	STA !1504,x	
	+++
	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA LookFrames,y
	STA !OFFSET,X

	RTS

KillSprites:



	JSL $03B69F|!BankB		
	LDA $04
	SEC
	SBC #$02
	STA $04
	LDA $0A
	SBC #$00
	STA $0A

	LDA $06
	CLC
	ADC #$04
	STA $06

	LDA $05
	CLC
	ADC #$04
	STA $05
	LDA $0B
	ADC #$00
	STA $0B

	LDA $07
	SEC
	SBC #$08
	STA $07

	LDY #!SprSize 		
-
	CPY #$00	
	BEQ +
	DEY			
	STX $0F			
	CPY $0F			
	BEQ -
	LDA !14C8,y
	CMP #$08
	BCC -
	CMP #$0B
	BEQ -
	LDA !167A,y
	AND #$02
	BNE -

	JSR CheckImmune
	BCS -

	PHX
	TYX
	JSL $03B6E5|!BankB
	PLX			
	JSL $03B72B|!BankB
	BCC -	

	if !KillSound
	LDA #!KillSFX
	STA !KillBank
	endif

	LDA !1656,y	
	ORA #$80
	STA !1656,y
	LDA #$02
	STA !14C8,y
	+
	RTS

CheckImmune:
	PHX

	LDX #$00
-
	LDA DontKillC,X
	CMP #$FF
	BEQ +

	CMP #$00
	BNE ++

	LDA DontKill,X
	CMP !9E,y
	BEQ Immune
	BRA NextI

	++
	PHX
	TYX
	LDA !7FAB9E,X
	PLX

	CMP DontKill,X
	BEQ Immune

NextI:
	INX
	BRA -

+
	PLX
	CLC
	RTS
Immune:
	PLX
	SEC
	RTS




CrouchFrames:
	db $07,$08,$09,$0A,$0A,$09,$08,$07

Crouching:

	LDA !C2,x
	CMP !1504,x
	BEQ +
	STA !1504,x
	LDA #$00
	STA !1602,x
	STA !151C,x
	+

	;LDA $14
	;AND #$01
	;BNE +

	LDA !1602,x
	INC
	CMP #$08
	BNE ++

	LDA !151C,x
	INC
	STA !151C,x
	CMP #$06
	BNE +++

	LDA #$08
	STA !C2,x

	+++

	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA CrouchFrames,y
	STA !OFFSET,X

	RTS


PlayFrames:
	db $0B,$0C,$0D,$0E,$0F

Playing:

	JSR FlipSprites

	LDA !C2,x
	CMP !1504,x
	BEQ +
	STA !1504,x
	LDA #$00
	STA !1602,x
	STA !151C,x
	+

	LDA $14
	AND #$03
	BNE +

	LDA !1602,x
	INC
	CMP #$01
	BNE ++

	JSR SpawnQuake


	LDA #$01
	++
	CMP #$05
	BNE ++

	LDA !151C,x
	INC
	STA !151C,x
	CMP #$03
	BNE +++

	LDA #$00
	STA !C2,x

	+++

	LDA #$00
	++
	STA !1602,x

	+

	LDA !1602,x
	TAY
	LDA PlayFrames,y
	STA !OFFSET,X

	RTS



PlaySprites:

	LDA !157C,x
	BNE +

	REP #$20
	LDA #$FFE0
	STA $00
	SEP #$20
	BRA ++
	+
	REP #$20
	LDA #$0030
	STA $00
	SEP #$20
	++

	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CLC
	ADC $00
	STA $00
	SEP #$20

	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	STA $02
	SEP #$20


	LDY #!SprSize		
-
	CPY #$00	
	BEQ +
	DEY			
	STX $0F			
	CPY $0F			
	BEQ -

	LDA !14C8,y
	CMP #$08
	BCC -
	CMP #$0B
	BEQ -
	CMP #$0A
	BEQ -

	LDA !14E0,y
	XBA
	LDA !E4,y
	REP #$20
	STA $04
	SEP #$20

	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	STA $06
	
	LDA $00
	SEC
	SBC $04
	CLC
	ADC #!PlayRange
	CMP #!PlayRange*2
	BCS ++

	LDA $02
	SEC
	SBC $06
	CLC
	ADC #$0020
	CMP #$0040
	BCS ++

	SEP #$20
	LDA #$07
	STA !C2,x
	RTS


	++
	SEP #$20
	BRA -	
	+

	RTS


print "test ",pc
FlipSprites:

	LDA !157C,x
	BNE +

	REP #$20
	LDA #$FFE0
	STA $00
	SEP #$20
	BRA ++
	+
	REP #$20
	LDA #$0030
	STA $00
	SEP #$20
	++

	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CLC
	ADC $00
	STA $00
	SEP #$20

	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	STA $02
	SEP #$20


	LDY #!SprSize		
-
	CPY #$00	
	BEQ +
	DEY			
	STX $0F			
	CPY $0F			
	BEQ -

	LDA !14C8,y
	CMP #$08
	BCC -
	CMP #$0B
	BEQ -
	CMP #$0A
	BEQ -

QuakeFlip:
	LDA !154C,y
	CMP #$07
	BNE -

	LDA !157C,x
	BEQ ++++

	LDA !B6,y
	BMI DoFlip

	BRA +++
	++++
	LDA !B6,y
	BMI +++
	
DoFlip:
	LDA !14E0,y
	XBA
	LDA !E4,y
	REP #$20
	STA $04
	SEP #$20

	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	STA $06

	REP #$20
	LDA $00
	SEC
	SBC $04
	CLC
	ADC #$0028
	CMP #$0050
	BCS +++

	LDA $02
	SEC
	SBC $06
	CLC
	ADC #$0020
	CMP #$0040
	BCS +++
	SEP #$20
	LDA !B6,y
	EOR #$FF
	INC
	STA !B6,y

	+++
	SEP #$20
	
	BRA -	
	+

	RTS




SpawnQuake:
	TXY
	PHX
	LDX #$03
-		
	LDA $16CD|!addr,x
	BEQ +
	DEX 
	BPL -
	INX 
+
	LDA !157C,y
	BEQ +

	LDA !E4,y
	CLC
	ADC #$2C	
	STA $16D1|!addr,x
	LDA !14E0,y
	ADC #$00
	STA $16D5|!addr,x
	BRA ++
	+
	LDA !E4,y
	SEC
	SBC #$10
	STA $16D1|!addr,x
	LDA !14E0,y
	SBC #$00
	STA $16D5|!addr,x
	++


	LDA !D8,y
	CLC
	ADC #$08
	STA $16D9|!addr,x
	LDA !14D4,y
	ADC #$00
	STA $16DD|!addr,x

	LDA #$01
	STA $16CD|!addr,x
	LDA #$06
	STA $18F8|!addr,x
	PLX
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILES:	db $00,$02,$03,$20,$22,$23,$00,$02,$03,$20,$22,$23
XPOS:	db $00,$10,$18,$00,$10,$18,$18,$10,$00,$18,$10,$00  
YPOS:	db $F0,$F0,$F0,$00,$00,$00,$F0,$F0,$F0,$00,$00,$00

GFX:		
		%GetDrawInfo()
		LDA !157C,x
		EOR #$01
		STA $02		

		BEQ +

		LDA $00
		SEC
		SBC #$05
		STA $00

		BRA ++
		+

		LDA $00
		CLC
		ADC #$05
		STA $00	

		++



		STZ $08	

		LDA !OFFSET,x	
		JSR GETSLOT		
		BEQ ENDSUB		
		STA $03	

		LDX #$00		
TILELP:		
		CPX #$06		
		BNE NORETFRML	
		BRA RETFRML		
NORETFRML:
						
		LDA $02			
		BEQ NO_FLIP_R	
		
		LDA #$18
		SEC				
		SBC XPOS,x		
		

		BRA END_FLIP_R	

NO_FLIP_R:
		LDA XPOS,x		

END_FLIP_R:		
		CLC
		ADC $00

		STA $0300|!addr,y		
		LDA $01			
		CLC			
		ADC YPOS,x		
		STA $0301|!addr,y	
		LDA $03				
		CLC					
		ADC TILES,x			
		STA $0302|!addr,y	
		PHX					
		LDX $15E9|!addr		
		LDA !15F6,x			
		ORA $64				
							
		LDX $02				
		BEQ NO_FLIP_XY		
		ORA #$40			
NO_FLIP_XY:					
		STA $0303|!addr,y	
		PLX					
		INC $08				
		INY #4
		INX					
		JMP TILELP			
RETFRML:
		LDX $15E9|!addr

		LDA $08		
		BEQ ENDSUB
		LDY #$02	
		DEC A		
		JSL $01B7B3|!BankB
ENDSUB:
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dynamic sprite routine
; SMKDan / SMWEdit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!TEMP = $09

!SLOTPTR = $0660		;16bit pointer for source GFX
!SLOTBANK = $0662	;bank
!SLOTDEST = $0663	;VRAM address
!SLOTSUSED = $06FE	;how many SLOTS have been used

!MAXSLOTS = $04		;maximum selected SLOTS

SLOTS: db $CC,$C8,$C4,$C0	;avaliable SLOTS.  Any more transfers and it's overflowing by a dangerous amount.

GETSLOT:
	PHY		;preserve OAM index
	PHA		;preserve frame
	LDA !SLOTSUSED	;test if slotsused == maximum allowed
	CMP #!MAXSLOTS
	BEQ NONEFREE
	CMP #!MAXSLOTS-1
	BEQ NONEFREE	

	PLA		;pop frame
	TAY
	REP #$20	;16bit A
	
	LDA #$0000
	-
	CPY #$03
	BCC +

	CLC
	ADC #$0800
	DEY #3
	BRA -
	+
	-
	DEY
	BMI +
	CLC
	ADC #$00A0
	BRA -
	+
	
	CLC
	ADC.W #SPRITEGFX


	
	;PEA SPRITEGFX	;push 16bit address, since i'm not sure how else i'm going to get the address of the label itself in TRASM
	;PLA		;pull 16bit address
	;CLC
	;ADC !TEMP	;add frame offset	
	STA !SLOTPTR	;store to pointer to be used at transfer time
	SEP #$20	;8bit store
	PHB		;push db...
	PLA		;pull to A...
	STA !SLOTBANK	;store bank to 24bit pointer

	LDY !SLOTSUSED	;calculate VRAM address + tile number
	INY
	LDA SLOTS,y	;get tile# in VRAM
	PHA		;preserve for eventual pull
	SEC
	SBC #$C0	;starts at C0h, they start at C0 in tilemap
	REP #$20	;16bit math
	AND.w #$00FF	;wipe high byte
	ASL #5
	CLC
	ADC #$0B44	;add 0B44, base address of buffer	
	STA !SLOTDEST	;destination address in the buffer

	JSR DMABUFFER	;ROM -> RAM copy

	SEP #$20	;8bit A	
	INC !SLOTSUSED	;two extra slots have been used
	INC !SLOTSUSED

	PLA		;RETURN starting tile number
	PLY
	RTS
		
NONEFREE:
	PLA
	PLY
	LDA #$00	;zero on no free SLOTS
	RTS

;;;;;;;;;;;;;;;;
;Tansfer routine
;;;;;;;;;;;;;;;;

;DMA ROM -> RAM ROUTINE

DMABUFFER:
;set destination RAM address
	REP #$20
	LDA !SLOTDEST
	STA $2181	;16bit RAM dest
	LDY #$7F
	STY $2183	;set 7F as bank

;common DMA settings
	STZ $4300	;1 reg only
	LDY #$80	;to 2180, RAM write/read
	STY $4301

;first line
	LDA !SLOTPTR
	STA $4302	;low 16bits
	LDY !SLOTBANK
	STY $4304	;bank
	LDY #$A0	;160 bytes
	STY $4305
	LDY #$01
	STY $420B	;transfer

;second line
	LDA !SLOTDEST	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SLOTDEST	;updated base
	STA $2181	;updated RAM address

	LDA !SLOTPTR	;update source address
	CLC
	ADC #$0200	;512 bytes, next row
	STA !SLOTPTR
	STA $4302	;low 16bits
	LDY !SLOTBANK
	STY $4304	;bank
	LDY #$A0
	STY $4305
	LDY #$01
	STY $420B	;transfer

;third line
	LDA !SLOTDEST	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SLOTDEST	;updated base
	STA $2181	;updated RAM address

	LDA !SLOTPTR	;update
	CLC
	ADC #$0200
	STA !SLOTPTR
	STA $4302
	LDY !SLOTBANK
	STY $4304
	LDY #$A0
	STY $4305
	LDY #$01
	STY $420B	;transfer

;fourth line
	LDA !SLOTDEST	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SLOTDEST	;updated base
	STA $2181	;updated RAM address

	LDA !SLOTPTR
	CLC
	ADC #$0200
	STA !SLOTPTR
	STA $4302
	LDY !SLOTBANK
	STY $4304
	LDY #$A0
	STY $4305
	LDY #$01
	STY $420B

	SEP #$20	;8bit A
	RTS		;all done, RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITEGFX:
INCBIN Poochy.bin		;included graphics file