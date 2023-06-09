prot SPRITEGFX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Island Floating Slippery Rock Platform
; Programmed by SMWEdit
;
; Uses first extra bit: NO
;
; You will need to patch SMKDan's dsx.asm to your ROM with xkas
; this sprite, like all other dynamic sprites, uses the last 4 rows of sp4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; there's nothing customizable here

		!OFFSET = $1528

		!PLAT_THK = $07		; pixels below stand position to assume standing, higher for steeper slopes
		!PLAT_STICKY = $02	; pixels above stand position to assume standing, higher for steeper slopes
		!PLAT_X1 = $00		; \
		!PLAT_X2 = $02		;  | scratch RAM addresses set before processing
		!PLAT_Y1 = $04		;  | slope. !PLAT_X1 must be less than !PLAT_X2
		!PLAT_Y2 = $06		; /
		!YPOSTMP = $08		; scratch RAM used in slope processing for Y position of standing
		!TMP1 = $0A		; general use scratch RAM

		!PLAT_H = !PLAT_THK+!PLAT_STICKY	; total height of vertical interaction in any given point

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		PRINT "INIT ",pc
		LDA #$0F
		STA !OFFSET,x
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

X1DATA:		dw $FFF0,$FFF0,$FFF0,$FFF0
		dw $FFF0,$FFF1,$FFF1,$FFF1
		dw $FFF1,$FFF2,$FFF2,$FFF3
		dw $FFF3,$FFF4,$FFF4,$FFF5
		dw $FFF5,$FFF6,$FFF7,$FFF7
		dw $FFF8,$FFF9,$FFF9,$FFFA
		dw $FFFB,$FFFC,$FFFD,$FFFD
		dw $FFFE,$FFFF,$0000

Y1DATA:		dw $FFF0,$FFEF,$FFEE,$FFED
		dw $FFED,$FFEC,$FFEB,$FFEA
		dw $FFE9,$FFE9,$FFE8,$FFE7
		dw $FFE7,$FFE6,$FFE5,$FFE5
		dw $FFE4,$FFE4,$FFE3,$FFE3
		dw $FFE2,$FFE2,$FFE1,$FFE1
		dw $FFE1,$FFE1,$FFE0,$FFE0
		dw $FFE0,$FFE0,$FFE0

X2DATA:		dw $0000,$0001,$0002,$0003
		dw $0003,$0004,$0005,$0006
		dw $0007,$0007,$0008,$0009
		dw $0009,$000A,$000B,$000B
		dw $000C,$000C,$000D,$000D
		dw $000E,$000E,$000F,$000F
		dw $000F,$000F,$0010,$0010
		dw $0010,$0010,$0010

Y2DATA:		dw $FFE0,$FFE0,$FFE0,$FFE0
		dw $FFE0,$FFE1,$FFE1,$FFE1
		dw $FFE1,$FFE2,$FFE2,$FFE3
		dw $FFE3,$FFE4,$FFE4,$FFE5
		dw $FFE5,$FFE6,$FFE7,$FFE7
		dw $FFE8,$FFE9,$FFE9,$FFEA
		dw $FFEB,$FFEC,$FFED,$FFED
		dw $FFEE,$FFEF,$FFF0

RETURN1:		RTS
NO_STAND1:	JMP NO_STAND

SPRITE_ROUTINE:	JSR SUB_GFX
		LDA !14C8,x
		EOR #$08
		ORA $9D
		BNE RETURN1
		%SubOffScreen()

		LDA !OFFSET,x		; \  get index to
		ASL A			;  | platform endpoint
		TAY			; /  coords tables
		REP #%00100000		; 16 bit A/math
		LDA X1DATA,y		; \
		STA !PLAT_X1		;  | set ledge
		LDA X2DATA,y		;  | endpoint
		STA !PLAT_X2		;  | coordinates
		LDA Y1DATA,y		;  |
		STA !PLAT_Y1		;  |
		LDA Y2DATA,y		;  |
		STA !PLAT_Y2		; /
		SEP #%00100000		; 8 bit A/math

		LDA $187A		; \
		BEQ NOYOSHI1		;  | temporarily
		LDA $96			;  | offset Mario's
		CLC			;  | Y position if
		ADC #$10		;  | on Yoshi
		STA $96			;  |
		LDA $97			;  |
		ADC #$00		;  |
		STA $97			; /
NOYOSHI1:

		LDA $7D			; \ no standing if
		BMI NO_STAND1		; / Mario is going up
		LDA $E4,x		; \
		CLC			;  | if Mario
		ADC !PLAT_X1		;  | is before
		STA !TMP1		;  | X1, then
		LDA $14E0,x		;  | don't
		ADC !PLAT_X1+1		;  | stand 
		STA !TMP1+1		;  |
		LDA !TMP1		;  |
		CMP $94			;  |
		LDA !TMP1+1		;  |
		SBC $95			;  |
		BPL NO_STAND1		; /
		LDA $E4,x		; \
		CLC			;  | if Mario
		ADC !PLAT_X2		;  | is after
		STA !TMP1		;  | X2, then
		LDA $14E0,x		;  | don't
		ADC !PLAT_X2+1		;  | stand
		STA !TMP1+1		;  |
		LDA !TMP1		;  |
		CMP $94			;  |
		LDA !TMP1+1		;  |
		SBC $95			;  |
		BMI NO_STAND1		; /
		LDA !PLAT_Y1		; \
		SEC			;  | offset Y
		SBC #!PLAT_STICKY	;  | coordinates
		STA !PLAT_Y1		;  | by number
		LDA !PLAT_Y1+1		;  | of pixels
		SBC #$00		;  | to extend
		STA !PLAT_Y1+1		;  | platform
		LDA !PLAT_Y2		;  | interaction
		SEC			;  | upwards
		SBC #!PLAT_STICKY	;  |
		STA !PLAT_Y2		;  |
		LDA !PLAT_Y2+1		;  |
		SBC #$00		;  |
		STA !PLAT_Y2+1		; /
		LDA $E4,x		; \
		CLC			;  | get Mario's
		ADC !PLAT_X1		;  | X position
		STA !TMP1		;  | relative to
		LDA $94			;  | platform start
		SEC			;  |
		SBC !TMP1		; /
		STA $4202		; set as multiplicand
		LDA !PLAT_Y2		; \
		CMP !PLAT_Y1		;  | negative slope
		LDA !PLAT_Y2+1		;  | or positive
		SBC !PLAT_Y1+1		;  | slope?
		BMI NEG_SLP		; /
		LDA !PLAT_Y2		; \  POSITIVE:
		SEC			;  | Y2-Y1 is "rise"
		SBC !PLAT_Y1		; /  in slope
		STA $4203		; set as multiplier
		LDY #$00		; Y=0 means slope is positive
		BRA STARTDIV		; skip over to division
NEG_SLP:		LDA !PLAT_Y1		; \  NEGATIVE:
		SEC			;  | Y1-Y2 is "rise" in
		SBC !PLAT_Y2		; /  slope (going other way)
		STA $4203		; set as multiplier
		LDY #$01		; Y=1 means slope is negative
STARTDIV:	
		NOP #3
		LDA $4216		; \
		STA $4204		;  | put product
		LDA $4217		;  | into dividend
		STA $4205		; /
		LDA !PLAT_X2		; \  get "run" (X)
		SEC			;  | in slope
		SBC !PLAT_X1		; /
		STA $4206		; set as divisor
		NOP #8
		LDA $4214		; \ quotient goes
		STA !TMP1		; / into scratch RAM
		STZ !TMP1+1		; and zero high byte
		REP #%00100000		; 16 bit A/math
		LDA $4216		; \  
		ASL A			;  | round up if
		CMP $4204		;  | remainder >=
		BCC CHKNEG		;  | 1/2 dividend
		INC !TMP1		; /
CHKNEG:		CPY #$00		; \ if Y=0 (not negative)
		BEQ ADDYINT		; / then don't make negative
		LDA !TMP1		; \  inverse plus
		EOR.w #$FFFF		;  | 1 is equivalent
		INC A			;  | to subtracting
		STA !TMP1		; /  from zero
ADDYINT:		LDA !TMP1		; \  since X1 is considered
		CLC			;  | to be the "zero", then
		ADC !PLAT_Y1		; /  Y1 is the Y intercept
		STA !YPOSTMP		; set sum to standing Y position
		SEP #%00100000		; 16 bit A/math
		LDA $D8,x		; \
		CLC			;  | actual Y
		ADC !YPOSTMP		;  | position
		STA !TMP1		;  | is offset
		LDA $14D4,x		;  | by sprite's
		ADC !YPOSTMP+1		;  | Y position
		STA !TMP1+1		; /
		LDA !TMP1		; \
		CMP $96			;  | if Mario is higher
		LDA !TMP1+1		;  | than this, then
		SBC $97			;  | there's no standing
		BPL NO_STAND		; /
		LDA !TMP1		; \
		CLC			;  | get lower
		ADC #!PLAT_H		;  | standing
		STA !TMP1		;  | boundary
		LDA !TMP1+1		;  |
		ADC #$00		;  |
		STA !TMP1+1		; /
		LDA !TMP1		; \
		CMP $96			;  | if Mario is lower
		LDA !TMP1+1		;  | than this, then
		SBC $97			;  | there's no standing
		BMI NO_STAND		; /
		LDA #$01		; \ set standing
		STA $1471		; / mode
		LDA #$06                ; \ set riding
		STA $154C,x             ; / sprite mode
		LDA $D8,x		; \
		CLC			;  | set Mario
		ADC !YPOSTMP		;  | in standing
		STA $96			;  | Y position
		LDA $14D4,x		;  |
		ADC !YPOSTMP+1		;  |
		STA $97			; /
		LDA $96			; \
		CLC			;  | offset
		ADC #!PLAT_STICKY	;  | resulting
		STA $96			;  | position by
		LDA $97			;  | interaction
		ADC #$00		;  | upper extent
		STA $97			; /
		%SubHorzPos()	; \  decide which
		CPY #$00		;  | way to tilt
		BNE DECROT		; /  
INCROT:		LDA !OFFSET,x		; \  when it's
		CMP #$1E		;  | clockwise, don't
		BCS ENDINC		; /  go past 1E
		INC !OFFSET,x		; if not 1E, increment rotation offset
ENDINC:		INC $94			; \  make mario
		BNE ENDINC2		;  | slip off
		INC $95			; /  of slope
ENDINC2:		BRA ENDROT		; and skip CCW rotation
DECROT:		LDA !OFFSET,x		; \ when it's CCW, don't go
		BEQ ENDDEC		; / backwards past zero
		DEC !OFFSET,x		; if not zero, decrement rotation offset
ENDDEC:		DEC $94			; \  make mario
		BNE ENDROT		;  | slip off
		DEC $95			; /  of slope
ENDROT:
		BRA ENDFLATROT		; skip over code to rotate back to a flat platform 
NO_STAND:
		LDA !OFFSET,x		; \  don't turn
		CMP #$0F		;  | back if
		BEQ ENDFLATROT		; /  already there
		BCS DECFLAT		; if current offset > flat offset, go to rotate CCW
		INC !OFFSET,x		; rotate CW
		BRA ENDFLATROT		; and skip CCW
DECFLAT:		DEC !OFFSET,x		; rotate CCW
ENDFLATROT:

		LDA $187A		; \
		BEQ NOYOSHI2		;  | reverse
		LDA $96			;  | temporary
		SEC			;  | Mario offset
		SBC #$10		;  | if on Yoshi
		STA $96			;  |
		LDA $97			;  |
		SBC #$00		;  |
		STA $97			; /
NOYOSHI2:
		JSL $019138|!bank		; interact with objects

		LDA $164A,x		; \ in water
		BNE INWATER		; / or not?
INAIR:		INC $AA,x		; increase Y speed for gravity
		LDA $AA,x		; \ skip speed reducer
		BPL ENDFLOAT		; / if Y is positive
		CMP #$FA		; \ > FA (-6) means
		BCS ENDFLOAT		; / skip speed reducer
		LDA #$FA		; \ keep
		STA $AA,x		; / at FA
		BRA ENDFLOAT		; skip in-water code
INWATER:		LDA $14			; \
		AND #%00000001		;  | float up half the speed
		BNE WATERCHKSPD		;  | it would be falling down
		DEC $AA,x		; /
WATERCHKSPD:	LDA $AA,x		; \ skip speed reducer
		BMI ENDFLOAT		; / if Y is negative
		CMP #$06		; \ < 06 means
		BCC ENDFLOAT		; / skip speed reducer
		LDA #$06		; \ keep
		STA $AA,x		; / at 06
ENDFLOAT:

        	JSL $01801A|!bank             ; Update Y position without gravity
RETURN:		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!TILESDRAWN = $08	; \ scratch RAM
		!TEMP_FOR_TILE = $03	; / addresses

ROCK_TILES:	db $00,$02,$20,$22
ROCK_XPOS:	db $F8,$08,$F8,$08
ROCK_YPOS:	db $F8,$F8,$08,$08

SUB_GFX:		%GetDrawInfo()
		STZ !TILESDRAWN		; zero tiles drawn
		JSR DRAW_ROCK		; draw rock
		JSR SETTILES		; set tiles / don't draw offscreen
ENDSUB:		RTS

DRAW_ROCK:	LDA !OFFSET,x		; get frame number
		JSR OFF2FRM		; convert to dynamic pointer
		REP #$10
		LDX #SPRITEGFX
		%GetDynSlot()
		BCC ENDSUB
		STA !TEMP_FOR_TILE	; store tile into scratch RAM
		PHX			; back up X
		LDX #$00		; load X with zero
TILELP:		CPX #$04		; end of loop?
		BEQ  RETFRML		; if so, then end
		LDA $00			; get sprite's X position
		CLC			; \ offset by
		ADC ROCK_XPOS,x		; / tile's X
		STA $0300,y		; set tile's X position
		LDA $01			; get sprite's Y position
		CLC			; \ offset by
		ADC ROCK_YPOS,x		; / tile's Y
		STA $0301,y		; set tile's Y position
		LDA !TEMP_FOR_TILE	; load tile # from scratch RAM
		CLC			; \ shift tile right/down
		ADC ROCK_TILES,x	; / according to which part
		STA $0302,y		; set tile #
		PHX			; back up X (index to tile data)
		LDX $15E9		; load X with index to sprite
		LDA $15F6,x		; load palette info
		ORA $64			; add in priority bits
		STA $0303,y		; set extra info
		PLX			; load backed up X
		INC !TILESDRAWN		; another tile was drawn
		INY #4
		INX			; next tile to draw
		BRA TILELP		; loop
RETFRML:		PLX			; load backed up X
ENDROCK:		RTS

SETTILES:	LDA !TILESDRAWN		; \ don't call sub
		BEQ NODRAW		; / if no tiles
		LDY #$02		; #$02 means 16x16
		DEC A			; A = # tiles - 1
		JSL finish_oam_write
NODRAW:		RTS

!OFF2FRM_TEMP = $04

OFF2FRM:		PHY
		STA !OFF2FRM_TEMP
		AND #%00000011
		TAY
		LDA !OFF2FRM_TEMP
		ASL A
		ASL A
		AND #%11110000
		STY !OFF2FRM_TEMP
		ORA !OFF2FRM_TEMP
		PLY
		RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITEGFX:
incbin floatingrock.bin		;included graphics file
