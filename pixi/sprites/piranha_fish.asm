;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Island Piranha Fish / Hootie the Bluefish
; Programmed by SMWEdit
;
; based off dissasembly of the wall-follow Urchin
; X position determines if it goes clockwise or counter-clockwise.
;
; You will need to patch SMKDan's dsx.asm to your ROM with xkas
; this sprite, like all other dynamic sprites, uses the last 4 rows of sp4
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

prot HootieGFX

		!KNOCKOUTSND = $37

		!STUNTIMER = !163E
		!OFFSET = !1534
		!COUNTER = !1570

		!BANKTEMP = $08
		!TMP = $00

	!Temp = $09
	!Timers = $0B

	!SlotPointer = $0660|!Base2			;16bit pointer for source GFX
	!SlotBank = $0662|!Base2			;bank
	!SlotDestination = $0663|!Base2			;VRAM address
	!SlotsUsed = $06FE|!Base2			;how many slots have been used

	!MAXSLOTS = $04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL03:		db $08
LABEL04:		db $00,$08

PRINT "INIT ",pc
		LDA #$40		; \ default is
		STA !OFFSET,x		; / facing right
		INC !D8,X
		BNE LABEL01
		INC !14D4,X
LABEL01:	LDA !E4,X
		LDY #$00
		AND #%00010000
		STA !151C,X
		BNE LABEL02
		STZ !OFFSET,x		; face left if going left
		INY
LABEL02:	LDA LABEL03,Y
		STA !B6,X
		LDA LABEL04,Y
		STA !AA,X
		INC.w !164A,X
		LDA !151C,X
		EOR #%00010000
		STA !151C,X
		LSR A
		LSR A
		STA !C2,X
		RTL

LABEL18:		db $08,$00,$F8,$00,$F8,$00,$08,$00
LABEL17:		db $00,$08,$00,$F8,$00,$08,$00,$F8
LABEL10:		db $01,$FF,$FF,$01,$FF,$01,$01,$FF
LABEL09:		db $01,$01,$FF,$FF,$01,$01,$FF,$FF
LABEL13:		db $01,$04,$02,$08,$02,$04,$01,$08
LABEL20:		db $00,$01,$02,$01

FRAMETO:		db $40,$60,$00,$20,$00,$60,$40,$20

		PRINT "MAIN ",pc
		PHB
		PHK
		PLB
		JSR SPRITE_CODE_START
		PLB
		RTL

SPRITE_CODE_START:
		JSL $018032|!BankB
		JSL $01ACF9|!BankB
		AND #%11111111
		ORA $9D
		BNE LABEL05
		LDA #$0C
		STA !1558,X
LABEL05:	JSR SUB_GFX
		LDA !14C8,X
		CMP #$08
		BEQ LABEL06
		STZ !1528,X
		LDA #$FF
		STA !1558,X
LABEL07:	RTS

LABEL06:	LDA $9D
		BNE LABEL07
;		JSR SUB_OFF_SCREEN_X0
		INC : %SubOffScreen()	;>  A is always #$00 due to the previous BNE.
		LDA !167A,x		; \  don't disable common
		AND #%11111101		;  | methods of killing,
		STA !167A,x		; /  allow losing Yoshi
		LDA !STUNTIMER,x		; \
		BEQ NOTSTUNNED		;  | if stunned, then "fight"
		INC !1540,X		;  | the two timers used in
		INC !1558,x		;  | the original urchin code
		LDA !167A,x		;  | and also disable common
		ORA #%00000010		;  | methods of killing and
		STA !167A,x		;  | don't allow losing Yoshi
		BRA LABEL07		; /
NOTSTUNNED:
		INC !COUNTER,x		; increment counter for mouth opening/closing
		JSL $01A7DC|!BankB
		LDA !1540,X
		BNE LABEL08
		LDY !C2,X
		LDA LABEL09,Y
		STA !AA,X
		LDA LABEL10,Y
		STA !B6,X
		JSL $019138|!BankB
		LDA !1588,X
		AND #%00001111
		BNE LABEL08
		LDA #$08
		STA !1564,X
		LDA #$38
		STA !1540,X
LABEL08:	LDA #$20
		CMP !1540,X
		BNE LABEL11
		INC !C2,X
		LDA !C2,X
		CMP #$04
		BNE LABEL12
		STZ !C2,X
LABEL12:	CMP #$08
		BNE LABEL11
		LDA #$04
		STA !C2,X
LABEL11:	LDY !C2,X
		LDA !1588,X  
		AND LABEL13,Y
		BEQ LABEL14
		LDA #$08
		STA !1564,X
		DEC !C2,X
		LDA !C2,X
		BPL LABEL15
		LDA #$03
		BRA LABEL16
LABEL15:	CMP #$03
		BNE LABEL14
		LDA #$07
LABEL16:	STA !C2,X
LABEL14:	LDY !C2,X
		LDA LABEL17,Y
		STA !AA,X
		LDA LABEL18,Y
		STA !B6,X
		LDA FRAMETO,y		; \  get goal offset
		SEC			;  | minus current
		SBC !OFFSET,x		; /  frame offset
		BEQ ENDROTATE		; if it's zero (they're equal) then don't rotate
		AND #%01111111		; wrap at #$7F
		CMP #$40		; \ CW rotation if diff
		BCC INCROT		; / is less than #$40
		DEC !OFFSET,x		; else CCW rotation
		BRA FINISHROTATE	; and skip CW rotation
INCROT:		INC !OFFSET,x		; CW rotation
FINISHROTATE:	LDA !OFFSET,x		; \  keep offset
		AND #%01111111		;  | within 00-7F
		STA !OFFSET,x		; /  range
ENDROTATE:
		JSR KNOCKOUT		; start spinning if hit with a shell

		JSL $018022|!BankB
        	JSL $01801A|!BankB
		RTS

KNOCKOUT:	LDY #$0C		; load number of times to go through loop
KO_LOOP:	CPY #$00		; \ zero? if so,
		BEQ END_KO_LOOP		; / end loop
		DEY			; decrease # of times left+get index
		STX !TMP		; \  if sprite is
		CPY !TMP		;  | this sprite
		BEQ KO_LOOP		; /  then ignore it
		LDA !14C8,y		; \  if sprite's status
		CMP #$09		;  | is less than 9 (9,A,B = shell modes)
		BCC KO_LOOP		; /  ignore sprite
		LDA !1686,y		; \  if sprite doesn't
		AND #%00001000		;  | interact with others
		BNE KO_LOOP		; /  don't continue
		JSL $03B69F|!BankB	; \
		PHX			;  | if sprite is
		TYX			;  | not touching
		JSL $03B6E5|!BankB	;  | this sprite
		PLX			;  |
		JSL $03B72B|!BankB	;  |
		BCC KO_LOOP		; /
		LDA !14C8,y		; \  speed doesn't matter
		CMP #$0B		;  | if mario is holding
		BEQ MOVING		; /  the shell (status=B)
		LDA.w !AA,y		; \ continue if sprite
		BNE MOVING		; / has Y speed
		LDA.w !B6,y		; \ continue if sprite
		BNE MOVING		; / has X speed
		BRA KO_LOOP		; no speed / not holding -> don't kill
MOVING:
		LDA #$04		; \ give mario
		JSL $02ACE5|!BankB	; / 1000 points
		LDA #!KNOCKOUTSND	; \ play KNOCKOUT
		STA $1DFC|!Base2	; / sound
		LDA !1656,y		; \  force shell
		ORA #%10000000		;  | to disappear
		STA !1656,y		; /  in smoke
		LDA #$02		; \ set shell into
		STA !14C8,y		; / death mode (status=2)
		LDA #$40		; \ start stun
		STA !STUNTIMER,x		; / timer
		BRA KO_LOOP		; repeat loop
END_KO_LOOP:	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!TEMP_FOR_TILE = $03

FISH_TILES:	db $00,$02,$20,$22
FISH_XPOS:	db $F8,$08,$F8,$08
FISH_YPOS:	db $F8,$F8,$08,$08

SUB_GFX:	%GetDrawInfo()		; get info to draw tiles
		STZ !BANKTEMP		; \
		LDA !COUNTER,x		;  | decide whether
		AND #%01000000		;  | or not to have
		BEQ NO_OPEN_MOUTH	;  | open mouth
		LDA !COUNTER,x		;  | depending on
		AND #%00001000		;  | frame counter,
		BEQ NO_OPEN_MOUTH	;  | bank 0 is closed
		LDA #$01		;  | bank 1 is open
		STA !BANKTEMP		; /
NO_OPEN_MOUTH:
		LDA !STUNTIMER,x		; \
		ASL A			;  | frame number = direction
		CLC			;  | offset + stun timer*2
		ADC !OFFSET,x		; /
		AND #%01000000		; rotate 180 at frame #$40-#$7F
		STA $02			; store to scratch RAM
		LDA !STUNTIMER,x		; \
		ASL A			;  | frame number = direction
		CLC			;  | offset + stun timer*2
		ADC !OFFSET,x		; /
		JSR OFF2FRM		; convert frame number to dynamic frame pointer
		JSR GETSLOT		; call routine to get a slot
		BEQ ENDGFX		; if none left, end
		STA !TEMP_FOR_TILE	; store tile into scratch RAM
		PHX			; back up X
		LDX #$00		; load X with zero
TILELP:		CPX #$04		; end of loop?
		BEQ RETFRML		; if so, end
		LDA $00			; get sprite's X position
		PHY			; \
		LDY $02			;  | offset by
		BEQ NO_FLIP_R		;  | this tile's
		SEC			;  | X position
		SBC FISH_XPOS,x		;  | (add or
		BRA END_FLIP_R		;  | subtract
NO_FLIP_R:	CLC			;  | depending on
		ADC FISH_XPOS,x		;  | direction)
END_FLIP_R:	PLY			; /
		CLC			; \ add 8
		ADC #$08		; / to X
		STA $0300|!Base2,y	; set tile's X position
		LDA $01			; get sprite's Y position
		PHY			; \
		LDY $02			;  | offset by
		BEQ NO_FLIP_R2		;  | this tile's
		SEC			;  | Y position
		SBC FISH_YPOS,x		;  | (add or
		BRA END_FLIP_R2		;  | subtract
NO_FLIP_R2:	CLC			;  | depending on
		ADC FISH_YPOS,x		;  | direction)
END_FLIP_R2:	PLY			; /
		CLC			; \ add 7
		ADC #$07		; / to Y
		STA $0301|!Base2,y	; set tile's Y position
		LDA !TEMP_FOR_TILE	; load tile # from scratch RAM
		CLC			; \ shift tile right/down
		ADC FISH_TILES,x	; / according to which part
		STA $0302|!Base2,y	; set tile #
		PHX			; back up X (index to tile data)
		LDX $15E9|!Base2	; load X with index to sprite
		LDA !15F6,x		; load palette info
		ORA $64			; add in priority bits
		PHX			; \
		LDX $02			;  | flip the tile
		BEQ NO_FLIP_XY		;  | X and Y if
		ORA #%11000000		;  | address set
NO_FLIP_XY:	PLX			; /
		STA $0303|!Base2,y	; set extra info
		PLX			; load backed up X
		INY			; \
		INY			;  | index to next slot
		INY			;  |
		INY			; /
		INX			; next tile to draw
		BRA TILELP		; loop
RETFRML:	PLX			; load backed up X
		LDA #$03		; 4 tiles drawn
		LDY #$02		; 16x16
		JSL $01B7B3|!BankB	; don't draw if offscreen
ENDGFX:		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dynamic sprite routine
; Programmed mainly by SMKDan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GETSLOT:
	PHY		;preserve OAM index
	PHA		;preserve frame
	LDA !SlotsUsed	;test if slotsused == maximum allowed
	CMP #!MAXSLOTS
	BNE +
		
	PLA
	PLY
	LDA #$00	;zero on no free slots
	RTS

+	PLA		;pop frame
	REP #$20	;16bit A
	AND.w #$00FF	;wipe high
	XBA		;<< 8
	LSR A		;>> 1 = << 7
	STA !Temp	;back to scratch
	LDA.w #HootieGFX ;Get 16bit address
	CLC
	ADC !Temp	;add frame offset	
	STA !SlotPointer	;store to pointer to be used at transfer time
	SEP #$20	;8bit store
	LDA #HootieGFX/$10000
	CLC
	ADC !BANKTEMP
	STA !SlotBank	;store bank to 24bit pointer

	PHX		;This is how I made your boi a routine
	LDX !SlotsUsed		;calculate VRAM address + tile number
	LDA.L SlotsTable,X	;get tile# in VRAM
	PLX
	PHA		;preserve for eventual pull
	SEC
	SBC #$C0	;starts at C0h, they start at C0 in tilemap
	REP #$20	;16bit math
	AND.w #$00FF	;wipe high byte
	ASL A		;multiply by 32, since 32 bytes/16 words equates to 1 32bytes tile
	ASL A
	ASL A
	ASL A
	ASL A
if !SA1 == 1
	CLC : ADC #$8000	;add 8000, base address of buffer
else
	CLC : ADC #$0B44	;add 0B44, base address of buffer	
endif
	STA !SlotDestination	;destination address in the buffer
	SEP #$20
	STZ !Timers
	
;;;;;;;;;;;;;;;;
;Tansfer routine
;;;;;;;;;;;;;;;;

;DMA ROM -> RAM ROUTINE

if !SA1 == 1
;set destination RAM address
	REP #$20
	LDY #$C4
	STY $2230
	LDA.w !SlotDestination
	STA $2235	;16bit RAM dest
	        
	         	;set 7F as bank

;common DMA settings
	         	;1 reg only
	        	;to 2180, RAM write/read
	         

;first line
	LDA !SlotPointer
	STA $2232	;low 16bits
	LDY !SlotBank
	STY $2234	;bank
	LDY #$80	;128 bytes
	STZ $2238
	STY $2238
	LDY #$41
	STY $2237
	
	LDY $318C
	BEQ $FB
	LDY #$00
	STY $318C
	STY $2230	;transfer

;lines afterwards
-	LDY #$C4
	STY $2230
	LDA.w !SlotDestination	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SlotDestination	;updated base
	STA $2235	;updated RAM address

	LDA !SlotPointer	;update source address
	CLC
	ADC #$0200	;512 bytes, next row
	STA !SlotPointer
	STA $2232	;low 16bits
	LDY !SlotBank
	STY $2234	;bank
	LDY #$80
	STZ $2238
	STY $2238
	LDY #$41
	STY $2237
	
	LDY $318C
	BEQ $FB
	LDY #$00
	STY $318C
	STY $2230	;transfer
	LDY !Timers
	CPY #$02
	BEQ +
	INC !Timers
	BRA -
+
else
;common DMA settings
	REP #$20
	STZ $4300	;1 reg only
	LDY #$80	;to 2180, RAM write/read
	STY $4301
	
;set destination RAM address
	LDA !SlotDestination
	STA $2181	;16bit RAM dest
	LDY #$7F
	STY $2183	;set 7F as bank

	LDA !SlotPointer
	STA $4302	;low 16bits
	LDY !SlotBank
	STY $4304	;bank
	LDY #$80	;128 bytes
	STY $4305
	LDY #$01
	STY $420B	;transfer

;second line
-	LDA !SlotDestination	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SlotDestination	;updated base
	STA $2181	;updated RAM address

	LDA !SlotPointer	;update source address
	CLC
	ADC #$0200	;512 bytes, next row
	STA !SlotPointer
	STA $4302	;low 16bits
	LDY !SlotBank
	STY $4304	;bank
	LDY #$80
	STY $4305
	LDY #$01
	STY $420B	;transfer
	LDY !Timers
	CPY #$02
	BEQ +
	INC !Timers
	BRA -
+
endif
	
	SEP #$20	;8bit A	
	INC !SlotsUsed	;one extra slot has been used

	PLA		;return starting tile number
	PLY
	RTS

SlotsTable:			;avaliable slots.  Any more transfers and it's overflowing by a dangerous amount.
	db $CC,$C8,$C4,$C0	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This will convert a frame offset
;; into a pointer for a dynamic frame
;;   OFFSETS:
;;   00 01 02 03
;;   04 05 06 07
;;   08 09 0A 0B
;;   0C 0D 0E 0F
;;
;;   FRAMES:
;;   00 01 02 03
;;   10 11 12 13
;;   20 21 22 23
;;   30 31 32 33
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

incbin piranha_fish.bin -> HootieGFX
