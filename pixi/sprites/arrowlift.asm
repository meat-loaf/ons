prot SPRITEGFX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Island Arrow Lift
; Programmed by SMWEdit
;
; Uses first extra bit: NO
;
; You will need to patch SMKDan's dsx.asm to your ROM with xkas
; this sprite, like all other dynamic sprites, uses the last 4 rows of sp4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!OFFSET = $1528
		!SOLIDIFYTMR = $1558
		!STANDINGLASTFRAME = $1626

		!LASTXLO = $1534
		!LASTXHI = $1570
		!LASTYLO = $1594
		!LASTYHI = $1602

		!SPRXTMP = $04		; \
		!SPRYTMP = $06		;  | scratch
		!SPRXTMP2 = $08		;  | RAM
		!SPRYTMP2 = $0A		; /

		!NUMFRAMES = $70		; number of FRAMES in a full 360
		!SOLIDIFYTIME = $08	; time (# FRAMES) to move after spat out

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		PRINT "INIT ",pc
		STORE_POS:
		LDA $E4,x		; \
		STA !LASTXLO,x		;  | store current position
		LDA $14E0,x		;  | to sprite tables for
		STA !LASTXHI,x		;  | use next time sprite
		LDA $D8,x		;  | routine is called.
		STA !LASTYLO,x		;  | It's used for moving mario
		LDA $14D4,x		;  | while he's standing on it
		STA !LASTYHI,x		; /
		RTL		

		PRINT "MAIN ",pc			
		PHB
		PHK				
		PLB				
		JSR SPRITE_ROUTINE	
		PLB
		RTL     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XSPEEDS:	db $00,$01,$02,$03,$04,$04,$05,$06,$07,$08,$09,$09,$0A,$0B,$0B,$0C
		db $0D,$0D,$0E,$0E,$0E,$0F,$0F,$0F,$10,$10,$10,$10,$10,$10,$10,$10
		db $10,$0F,$0F,$0F,$0E,$0E,$0E,$0D,$0D,$0C,$0B,$0B,$0A,$09,$09,$08
		db $07,$06,$05,$04,$04,$03,$02,$01,$00,$FF,$FE,$FD,$FC,$FC,$FB,$FA
		db $F9,$F8,$F7,$F7,$F6,$F5,$F5,$F4,$F3,$F3,$F2,$F2,$F2,$F1,$F1,$F1
		db $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F1,$F1,$F1,$F2,$F2,$F2,$F3
		db $F3,$F4,$F5,$F5,$F6,$F7,$F7,$F8,$F9,$FA,$FB,$FC,$FC,$FD,$FE,$FF

YSPEEDS:	db $F0,$F0,$F0,$F0,$F0,$F1,$F1,$F1,$F2,$F2,$F2,$F3,$F3,$F4,$F5,$F5
		db $F6,$F7,$F7,$F8,$F9,$FA,$FB,$FC,$FC,$FD,$FE,$FF,$00,$01,$02,$03
		db $04,$04,$05,$06,$07,$08,$09,$09,$0A,$0B,$0B,$0C,$0D,$0D,$0E,$0E
		db $0E,$0F,$0F,$0F,$10,$10,$10,$10,$10,$10,$10,$10,$10,$0F,$0F,$0F
		db $0E,$0E,$0E,$0D,$0D,$0C,$0B,$0B,$0A,$09,$09,$08,$07,$06,$05,$04
		db $04,$03,$02,$01,$00,$FF,$FE,$FD,$FC,$FC,$FB,$FA,$F9,$F8,$F7,$F7
		db $F6,$F5,$F5,$F4,$F3,$F3,$F2,$F2,$F2,$F1,$F1,$F1,$F0,$F0,$F0,$F0

		!STAND_YPOS = $FFDE	; Y position of platform relative to sprite
		!STAND_XMIN = $FFF0	; Left X boundary
		!STAND_XMAX = $0010	; Right X boundary


JUSTSPATOUT:	LDA #$08		; \ set normal
		STA $14C8,x		; / sprite mode
		LDA #!SOLIDIFYTIME	; \ set timer for
		STA !SOLIDIFYTMR,x	; / "solidification"
		RTS

WAITINGTOSOLIDIFY:
		LDA $1588,x		; \
		AND #%00001111		;  | automatically end solidify
		BEQ NO_FORCE_SOLID	;  | timer if touching something
		STZ !SOLIDIFYTMR,x	; /
NO_FORCE_SOLID:
		JSL $018022|!bank	; Update X position without gravity
        	JSL $01801A|!bank	; Update Y position without gravity
		JSL $019138|!bank	; interact with objects (normally called within $01802A)
		JSL $018032|!bank	; interact with sprites
		RTS

RETURN1YOSHI:	STZ $15D0,x		; zero eating flag in case mario lost yoshi during eating (prevents glitch)
RETURN1:	RTS

;;MAIN SPRITE ROUTINE STARTS BELOW

SPRITE_ROUTINE:	JSR SUB_GFX
		LDA $14C8,x		; \  if it's a "shell"
		CMP #$09		;  | that means yoshi
		BCS JUSTSPATOUT		; /  just spat it out
		CMP #$08		; \ don't execute sprite
		BNE RETURN1		; / code if not "normal"
		LDA $9D			; \ RETURN if
		BNE RETURN1		; / sprites locked
		LDA $15D0,x		; \ RETURN if
		BNE RETURN1YOSHI	; / being eaten
		%SubOffScreen()	; only process sprite while on screen

		LDA !SOLIDIFYTMR,x	; \ if recently spat out and has not
		BNE WAITINGTOSOLIDIFY	; / "solidified" yet then branch to handler
		JSR POSOFFSETSTART	; interaction improvement offset
		LDA $187A		; \ don't shift
		BEQ NOYOSHI		; / if not on Yoshi
		LDA $96			; \
		CLC			;  | offset Y
		ADC #$10		;  | by #$10
		STA $96			;  | again to
		LDA $97			;  | compensate
		ADC #$00		;  | for yoshi
		STA $97			; /
NOYOSHI:
		LDA !LASTXLO,x		; \
		STA !SPRXTMP2		;  | store sprite's old
		LDA !LASTXHI,x		;  | X and Y positions
		STA !SPRXTMP2+1		;  | into scratch
		LDA !LASTYLO,x		;  | RAM for use
		STA !SPRYTMP2		;  | in some of the
		LDA !LASTYHI,x		;  | following code
		STA !SPRYTMP2+1		; /
		LDA $E4,x		; \
		STA !SPRXTMP		;  | store sprite X
		LDA $14E0,x		;  | and Y position
		STA !SPRXTMP+1		;  | into scratch
		LDA $D8,x		;  | RAM for use
		STA !SPRYTMP		;  | in some of the
		LDA $14D4,x		;  | following code
		STA !SPRYTMP+1		; /
		LDA !STANDINGLASTFRAME,x		; \ check if mario was
		BEQ NOT_STANDING_LAST_FRAME	; / standing last frame
		LDA $77			; \  don't move mario if
		AND #%00000011		;  | he is hitting the side
		BNE NO_MOVE_MARIO	; /  of an object
		PHP			; \
		REP #%00100000		;  | move mario
		LDA !SPRXTMP		;  | with the
		SEC			;  | sprite
		SBC !SPRXTMP2		;  |
		CLC			;  |
		ADC $94			;  |
		STA $94			;  |
		LDA !SPRYTMP		;  |
		SEC			;  |
		SBC !SPRYTMP2		;  |
		CLC			;  |
		ADC $96			;  |
		STA $96			;  |
		PLP			; /
NO_MOVE_MARIO:
		STZ !STANDINGLASTFRAME,x	; zero this in case it won't be set this frame
NOT_STANDING_LAST_FRAME:
		BRA NO_NO_STAND_JMP	; \ this is used when a standard
NO_STAND_JMP:	JMP NO_STAND		; / branch is out of range
NO_NO_STAND_JMP:
		LDA $7D			; \ don't stand on if
		BMI NO_STAND_JMP	; / mario not moving down

		REP #$20
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get minimum
		ADC.w #!STAND_YPOS-1	; / Y area for standing
		CMP $96			; compare with mario's Y position
		BCS NO_STAND_1		; don't execute next command if area is under mario 
		INY		; set Y register = 1
NO_STAND_1:	
		SEP #$20
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
	
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get maximum
		ADC.w #!STAND_YPOS+5	; / Y area for standing
		CMP $96			; compare with mario's Y position
		BCC NO_STAND_2		; don't execute next command if area is over mario
		INY
		
NO_STAND_2:	
		SEP #$20
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
		REP #$20
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get minimum
		ADC.w #!STAND_XMIN	; / X area for standing
		BPL CMP1		; \ if area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP1:		CMP $94			; compare with mario's X position
		BCS NO_STAND_3		; don't execute next command if area is after mario
		INY		; set Y register = 1
NO_STAND_3:	SEP #$20
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
		REP #$20
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get maximum
		ADC.w #!STAND_XMAX	; / X area for standing
		BPL CMP2		; \ if X area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP2:		CMP $94			; compare with mario's X position
		BCC NO_STAND_4		; don't execute next command if area is before mario
		INY		; set Y register = 1
NO_STAND_4:	
		SEP #$20
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
		REP #$20
		LDA !SPRYTMP		;  | Y position so
		CLC			;  | that he is
		ADC.w #!STAND_YPOS	;  | standing at
		STA $96			;  | specified offset
		SEP #$20			; /
		
		LDA #$01		; \ set standing
		STA $1471		; / mode
		STA !STANDINGLASTFRAME,x	; / was standing during this frame
		LDA $1588,x		; \
		AND #$03
		BEQ NO_BOUNCE_1		;  | bounce off
		LDA #!NUMFRAMES		;  | the wall
		SEC			;  |
		SBC !OFFSET,x		;  |
		STA !OFFSET,x		; /
NO_BOUNCE_1:
		LDA $AA,x		; \
		BMI NO_BOUNCE_2		;  | handle a
		LDA $1588,x		;  | bounce off
		AND #$04
		BEQ NO_BOUNCE_2		;  |
		LDA #!NUMFRAMES/2	;  |
		SEC			;  |
		SBC !OFFSET,x		;  |
		BPL STOREFLIPPED	;  |
		CLC			;  |
		ADC #!NUMFRAMES		;  |
STOREFLIPPED:	STA !OFFSET,x		; /
NO_BOUNCE_2:
		LDA $AA,x		; \
		BPL NO_BOUNCE_3		;  | handle a
		LDA $77			;  | bounce off
		AND #%00001000		;  | the ceiling
		BEQ NO_BOUNCE_3		;  | (mario has
		LDA #!NUMFRAMES/2	;  | to hit it,
		SEC			;  | not the
		SBC !OFFSET,x		;  | sprite)
		BPL STOREFLIPPED2	;  |
		CLC			;  |
		ADC #!NUMFRAMES		;  |
STOREFLIPPED2:	STA !OFFSET,x		; /
NO_BOUNCE_3:
		LDY !OFFSET,x		; \	
		LDA XSPEEDS,y		;  | speeds
		STA $B6,x		;  |
		LDA YSPEEDS,y		;  |
		STA $AA,x		; /
		BRA NOT_NOT_STANDING	; don't execute "not standing" code
NO_STAND:
		STZ $B6,x		; \ prevent
		STZ $AA,x		; / movement
		LDA !OFFSET,x		; \
		CMP #!NUMFRAMES-1	;  | make the
		BCS BACKTOZERO		;  | disc spin
		INC !OFFSET,x		;  |
		BRA AFTERUPDATEOFFSET	;  |
BACKTOZERO:	STZ !OFFSET,x		; /
AFTERUPDATEOFFSET:
NOT_NOT_STANDING:
		LDA $187A		; \ don't shift
		BEQ NOYOSHI2		; / if not on Yoshi
		LDA $96			; \  reverse
		SEC			;  | offset Y
		SBC #$10		;  | by #$10
		STA $96			;  | again to
		LDA $97			;  | compensate
		SBC #$00		;  | for yoshi
		STA $97			; /
NOYOSHI2:
		JSL STORE_POS|!bank		; store sprite's current position for reference in next frame
		JSR POSOFFSETEND	; reverse interaction improvement offset
AFTER_MAIN_CODE:
		JSL $018022|!bank	; Update X position without gravity
		JSL $01801A|!bank	; Update Y position without gravity
		JSL $019138|!bank	; interact with objects (normally called within $01802A)
		JSL $018032|!bank	; interact with other sprites
RETURN:		RTS

;; This temporarily offsets mario's and the sprite's
;; Y positions so the lift doesn't have a glitch
;; when it's at the top of the level

		!PERCEPTIONOFFSET = $40

POSOFFSETSTART:	LDA $96			; \
		CLC			;  | add specified
		ADC #!PERCEPTIONOFFSET	;  | offset to
		STA $96			;  | mario
		LDA $97			;  |
		ADC #$00		;  |
		STA $97			; /
		LDA $D8,x		; \
		CLC			;  | add specified
		ADC #!PERCEPTIONOFFSET	;  | offset to
		STA $D8,x		;  | sprite
		LDA $14D4,x		;  |
		ADC #$00		;  |
		STA $14D4,x		; /
		RTS			; \
POSOFFSETEND:	LDA $96			;  | subtract
		SEC			;  | specified
		SBC #!PERCEPTIONOFFSET	;  | offset from
		STA $96			;  | mario
		LDA $97			;  |
		SBC #$00		;  |
		STA $97			; /
		LDA $D8,x		; \
		SEC			;  | subtract
		SBC #!PERCEPTIONOFFSET	;  | specified
		STA $D8,x		;  | offset from
		LDA $14D4,x		;  | sprite
		SBC #$00		;  |
		STA $14D4,x		; /
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!TILESDRAWN = $08	; \ scratch RAM
		!TEMP_FOR_TILE = $03	; / addresses

FRAMES:		db $00,$01,$02,$03,$10,$11,$12,$13,$20,$21,$22,$23,$30,$31,$32,$33
		db $40,$41,$42,$43,$50,$51,$52,$53,$60,$61,$62,$63,$70,$71,$72,$73
		db $80,$81,$82,$83,$90,$91,$92,$93,$A0,$A1,$A2,$A3,$B0,$B1,$B2,$B3
		db $C0,$C1,$C2,$C3,$D0,$D1,$D2,$D3,$00,$01,$02,$03,$10,$11,$12,$13
		db $20,$21,$22,$23,$30,$31,$32,$33,$40,$41,$42,$43,$50,$51,$52,$53
		db $60,$61,$62,$63,$70,$71,$72,$73,$80,$81,$82,$83,$90,$91,$92,$93
		db $A0,$A1,$A2,$A3,$B0,$B1,$B2,$B3,$C0,$C1,$C2,$C3,$D0,$D1,$D2,$D3

FLIPXY:		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

DISC_TILES:	db $00,$02,$20,$22
DISC_XPOS:	db $F8,$08,$F8,$08
DISC_YPOS:	db $F8,$F8,$08,$08

SUB_GFX:	
		LDY !OFFSET,x	
		LDA FLIPXY,y		;  | to offset
		STA $02			; store to scratch RAM
		STZ !TILESDRAWN		; zero tiles drawn
		
		%GetDrawInfo()
		JSR DRAW_DISC		; draw disc
		JSR SETTILES		; set tiles / don't draw offscreen
ENDSUB:		RTS

DRAW_DISC:	
PHY
LDY !OFFSET,x		; \
LDA FRAMES,y		;  |
PLY			; /
SETFRM:         REP #$10
		LDX.w #SPRITEGFX
		%GetDynSlot()
		BCC ENDSUB
		STA !TEMP_FOR_TILE	; store tile into scratch RAM
	
		LDX #$00		; load X with zero
TILELP:		CPX #$04		; end of loop?
		BNE NORETFRML		; if not, then don't end
		BRA RETFRML		; if so, end
NORETFRML:
		LDA $00			; get sprite's X position
		PHY			; \
		LDY $02			;  | offset by
		BEQ NO_FLIP_R		;  | this tile's
		SEC			;  | X position
		SBC DISC_XPOS,x		;  | (add or
		BRA END_FLIP_R		;  | subtract
NO_FLIP_R:	CLC			;  | depending on
		ADC DISC_XPOS,x		;  | direction)
END_FLIP_R:	PLY			; /
		STA $0300,y		; set tile's X position
		LDA $01			; get sprite's Y position
		PHY			; \
		LDY $02			;  | offset by
		BEQ NO_FLIP_R2		;  | this tile's
		SEC			;  | Y position
		SBC DISC_YPOS,x		;  | (add or
		BRA END_FLIP_R2		;  | subtract
NO_FLIP_R2:	CLC			;  | depending on
		ADC DISC_YPOS,x		;  | direction)
END_FLIP_R2:	PLY			; /
		STA $0301,y		; set tile's Y position
		LDA !TEMP_FOR_TILE	; load tile # from scratch RAM
		CLC			; \ shift tile right/down
		ADC DISC_TILES,x	; / according to which part
		STA $0302,y		; set tile #
		PHX			; back up X (index to tile data)
		LDX $15E9		; load X with index to sprite
		LDA $15F6,x		; load palette info
		ORA $64			; add in priority bits
		PHX			; \
		LDX $02			;  | flip the tile
		BEQ NO_FLIP_XY		;  | X and Y if
		ORA #%11000000		;  | address set
NO_FLIP_XY:	PLX			; /
		STA $0303,y		; set extra info
		PLX			; load backed up X
		INC !TILESDRAWN		; another tile was drawn
		INY #4
		INX			; next tile to draw
		JMP TILELP		; loop (BRA is out of range)
		
RETFRML:		LDX $15E9
ENDDISC:		RTS

SETTILES:	LDA !TILESDRAWN		; \ don't do it
		BEQ NODRAW		; / if no tiles
		LDY #$02		; #$02 means 16x16
		DEC A			; A = # tiles - 1
		%FinishOAMWrite()
NODRAW:		RTS

SPRITEGFX:
incbin arrowlift.bin		;included graphics file
