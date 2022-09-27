prot SPRITEGFX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Island Chomp Rock
; Programmed by SMWEdit
;
; Uses first extra bit: NO
;
; You will need to patch SMKDan's dsx.asm to your ROM with xkas
; this sprite, like all other dynamic sprites, uses the last 4 rows of sp4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!SPRITEKILLSND = $37

		!ACTSTATUS = $C2		; 0=normal,1=crushing
		!OFFSET = $1528
		!STARTOFFSET = $1504
		!FLIPXY = $151C

		!STANDINGLASTFRAME = $1626

		!LASTXLO = $1534
		!LASTXHI = $1570
		!LASTYLO = $1594
		!LASTYHI = $1602

		!SPRXTMP = $04
		!SPRYTMP = $06

		!SPRXTMP2 = $08
		!SPRYTMP2 = $0A

		!GENERICTMP = $0C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		PRINT "INIT ",pc
init:
		LDA !extra_bits,x
		AND #$04
		BEQ .no_alt_pal
		LDA #$0D
		STA !sprite_oam_properties,x
.no_alt_pal:
		LDA $E4,x
		STA !STARTOFFSET,x
		JSR STORE_POS
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

		!STAND_YPOS = $FFD6	; Y position of platform relative to sprite
		!STAND_XMIN = $FFF3	; Left X boundary
		!STAND_XMAX = $000C	; Right X boundary

		!LPUSH_YMIN = $FFD8	; Y position of top of left push area
		!LPUSH_YMAX = $0000	; Y position of bottom of left push area
		!LPUSH_XMIN = $FFF0	; X position for pushing
		!LPUSH_XMAX = $0000	; extent (forward) of interaction field

		!RPUSH_YMIN = $FFD8	; Y position of top of left push area
		!RPUSH_YMAX = $0000	; Y position of bottom of left push area
		!RPUSH_XMIN = $0010	; X position for pushing
		!RPUSH_XMAX = $0001	; extent (backward) of interaction field

		!LROLL_XMAX = $FFFA	; max for standing and making rock roll left
		!RROLL_XMAX = $0006	; max for standing and making rock roll right

STORE_POS:	LDA $E4,x		; \
		STA !LASTXLO,x		;  | store current position
		LDA $14E0,x		;  | to sprite tables for
		STA !LASTXHI,x		;  | use next time sprite
		LDA $D8,x		;  | routine is called.
		STA !LASTYLO,x		;  | It's used for moving mario
		LDA $14D4,x		;  | while he's standing on it
		STA !LASTYHI,x		; /
RETURN1:		RTS

SPRITE_ROUTINE:	JSR SUB_GFX
		LDA $14C8,x		; \  RETURN if
		EOR #$08		;  | sprite status
		ORA $9D			;  | is not 8 (normal) or if
		BNE RETURN1		; / sprites locked
		LDA #$03                ; 'far' suboffscreen val
		%SubOffScreen()

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
		LDA $E4,x		; \
		SEC			;  | set offsets
		SBC !STARTOFFSET,x	;  | for rotation
		PHA			;  |
		AND #%00001111		;  |
		STA !OFFSET,x		;  |
		PLA			;  |
		AND #%00010000		;  |
		STA !FLIPXY,x		; /
		LDA !STANDINGLASTFRAME,x		; \ check if mario was
		BEQ NOT_STANDING_LAST_FRAME	; / standing last frame
		LDA $77			; \  don't move mario if
		AND #%00000011		;  | he is hitting the side
		BNE NO_MOVE_MARIO	; /  of an object
		PHP			; \
		REP #%00100000		;  | move mario
		LDA !SPRXTMP		;  | 2 pixels for
		SEC			;  | every pixel
		SBC !SPRXTMP2		;  | the sprite
		ASL A			;  | moves
		CLC			;  |
		ADC $94			;  |
		STA $94			;  |
		PLP			; /
NO_MOVE_MARIO:
		STZ !STANDINGLASTFRAME,x	; zero this in case it won't be set this frame
NOT_STANDING_LAST_FRAME:
		BRA NO_NO_STAND_JMP	; \ this is used when a standard
NO_STAND_JMP:	JMP NO_STAND		; / branch is out of range
NO_NO_STAND_JMP:
		LDA $7D			; \ don't stand on if
		BMI NO_STAND_JMP	; / mario not moving down
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get minimum
		ADC.w #!STAND_YPOS-1	; / Y area for standing
		CMP $96			; compare with mario's Y position
		BCS NO_STAND_1		; don't execute next command if area is under mario 
		LDY #$01		; set Y register = 1
NO_STAND_1:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get maximum
		ADC.w #!STAND_YPOS+5	; / Y area for standing
		CMP $96			; compare with mario's Y position
		BCC NO_STAND_2		; don't execute next command if area is over mario
		LDY #$01		; set Y register = 1
NO_STAND_2:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
		PHP			; back up processor bits
		REP #%00100000		; 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get minimum
		ADC.w #!STAND_XMIN	; / X area for standing
		BPL CMP1		; \ if area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP1:		CMP $94			; compare with mario's X position
		BCS NO_STAND_3		; don't execute next command if area is after mario
		LDY #$01		; set Y register = 1
NO_STAND_3:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get maximum
		ADC.w #!STAND_XMAX	; / X area for standing
		BPL CMP2		; \ if X area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP2:		CMP $94			; compare with mario's X position
		BCC NO_STAND_4		; don't execute next command if area is before mario
		LDY #$01		; set Y register = 1
NO_STAND_4:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_STAND_JMP	; / then don't stand
		PHP			; \
		REP #%00100000		;  | offset mario's
		LDA !SPRYTMP		;  | Y position so
		CLC			;  | that he is
		ADC.w #!STAND_YPOS	;  | standing at
		STA $96			;  | specified offset
		PLP			; /
		LDA #$01		; \ set standing
		STA $1471		; / mode
		PHP			; back up processor bits
		REP #%00100000		; 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get maximum X
		ADC.w #!LROLL_XMAX	; / area for left stand-rolling
		BPL CMP7		; \ if area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP7:		CMP $94			; compare with mario's X position
		BCC NO_LROLL_1		; don't execute next command if area is after mario
		LDY #$01		; set Y register = 1
NO_LROLL_1:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_LROLL		; / then don't stand
		LDA $14			; \
		AND #%00000011		;  | "slowly" increase
		BNE NO_LROLL		;  | speed of rock
		DEC $B6,x		;  |
NO_LROLL:				; /
		PHP			; back up processor bits
		REP #%00100000		; 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get maximum X
		ADC.w #!RROLL_XMAX+1	; / area for left stand-rolling
		BPL CMP8		; \ if area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP8:		CMP $94			; compare with mario's X position
		BCS NO_RROLL_1		; don't execute next command if area is after mario
		LDY #$01		; set Y register = 1
NO_RROLL_1:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_RROLL		; / then don't stand
		LDA $14			; \
		AND #%00000011		;  | "slowly" increase
		BNE NO_RROLL		;  | speed of rock
		INC $B6,x		;  |
NO_RROLL:				; /
		LDA #$01		; \ for the next frame, indicate mario
		STA !STANDINGLASTFRAME,x	; / was standing during this frame
NO_STAND:
		BRA NO_NO_LPUSH_JMP	; \ this is used when a standard
NO_LPUSH_JMP:	JMP NO_LPUSH		; / branch is out of range
NO_NO_LPUSH_JMP:
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get top
		ADC.w #!LPUSH_YMIN-1	; / boundary for pushing
		CMP $96			; compare with mario's Y position
		BCS NO_LPUSH_1		; don't execute next command if area is under mario
		LDY #$01		; set Y register = 1
NO_LPUSH_1:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set
		BEQ NO_LPUSH_JMP	; / then don't stand
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get bottom
		ADC.w #!LPUSH_YMAX	; / boundary for pushing
		PHY			; back up Y
		LDY $187A		; \
		BEQ NOT_YOSHI1		;  | boundary is lower
		CLC			;  | if mario is on Yoshi
		ADC.w #$0010		; /
NOT_YOSHI1:	LDY $73			; \
		BNE NOT_BIG1		;  | boundary is lower
		LDY $19			;  | if mario is ducking
		BEQ NOT_BIG1		;  | or if he is not big
		CLC			;  |
		ADC.w #$0008		; /
NOT_BIG1:	PLY			; load backed up Y
		CMP $96			; compare low boundary with mario's Y position
		BCC NO_LPUSH_2		; don't execute next command if area is above mario
		LDY #$01		; set Y register = 1
NO_LPUSH_2:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set then
		BEQ NO_LPUSH		; / don't push from left
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get left
		ADC.w #!LPUSH_XMIN-1	; / boundary for pushing
		BPL CMP3		; \ if area goes backwards past
		LDA.w #$0000		; / level start then assume zero
CMP3:		CMP $94			; compare with mario's X position
		BCS NO_LPUSH_3		; don't execute next command if area is after mario
		LDY #$01		; set Y register = 1
NO_LPUSH_3:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set then
		BEQ NO_LPUSH		; / don't push from left
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get right
		ADC.w #!LPUSH_XMAX	; / boundary for pushing
		BPL CMP4		; \ if area goes backwards past
		LDA.w #$0000		; / level start then assume zero
CMP4:		CMP $94			; compare with mario's X position
		BCC NO_LPUSH_4		; don't execute next command if area is before mario
		LDY #$01		; set Y register = 1
NO_LPUSH_4:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set then
		BEQ NO_LPUSH		; / don't push from left
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDA !SPRXTMP		; \ 
		CLC			;  | keep mario at
		ADC.w #!LPUSH_XMIN	;  | push offset position
		STA $94			; /
		PLP			; load backed up processor bits
		LDA $14			; \
		AND #%00000001		;  | "slowly" increase
		BNE NO_INC_SPD_L	;  | speed of rock
		INC $B6,x		;  | 
NO_INC_SPD_L:				; /
		LDA $B6,x		; \
		CMP $7B			;  | prevent mario's speed from
		BCS OKX1		;  | exceeding that of the rock
		STA $7B			; /
OKX1:
		LDA $B6,x		; \
		BPL NOT_HITTING_WALL_L	;  | if mario is wedged
		LDA $77			;  | in between the rock
		AND #%00000010		;  | and the wall, then
		BEQ NOT_HITTING_WALL_L	;  | bounce off of him
		JSR HIT_WALL		;  | (so not to kill him)
NOT_HITTING_WALL_L:			; /
NO_LPUSH:
		BRA NO_NO_RPUSH_JMP	; \ this is used when a standard
NO_RPUSH_JMP:	JMP NO_RPUSH		; / branch is out of range
NO_NO_RPUSH_JMP:
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get top
		ADC.w #!RPUSH_YMIN-1	; / boundary for pushing
		CMP $96			; compare with mario's Y position
		BCS NO_RPUSH_1		; don't execute next command if area is below mario
		LDY #$01		; set Y register = 1
NO_RPUSH_1:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set then
		BEQ NO_RPUSH_JMP	; / don't push from right
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRYTMP		; get sprite's Y position
		CLC			; \ offset to get bottom
		ADC.w #!RPUSH_YMAX	; / boundary for pushing
		PHY			; back up Y
		LDY $187A		; \
		BEQ NOT_YOSHI2		;  | boundary is lower
		CLC			;  | if mario is on Yoshi
		ADC.w #$0010		; /
NOT_YOSHI2:	LDY $73			; \
		BNE NOT_BIG2		;  | boundary is lower
		LDY $19			;  | if mario is ducking
		BEQ NOT_BIG2		;  | or if he is not big
		CLC			;  |
		ADC.w #$0008		; /
NOT_BIG2:	PLY			; load backed up Y
		CMP $96			; compare with mario's Y position
		BCC NO_RPUSH_2		; don't execute next command if area is above mario
		LDY #$01		; set Y register = 1
NO_RPUSH_2:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set then
		BEQ NO_RPUSH		; / don't push from right
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get right
		ADC.w #!RPUSH_XMIN	; / boundary for pushing
		BPL CMP5		; \ if area goes backward past
		LDA.w #$0000		; / level start then assume zero
CMP5:		CMP $94			; compare with sprite's X position
		BCC NO_RPUSH_3		; don't execute next command if area is before mario
		LDY #$01		; set Y register = 1
NO_RPUSH_3:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set then
		BEQ NO_RPUSH		; / don't push from right
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDY #$00		; Y register = 0
		LDA !SPRXTMP		; get sprite's X position
		CLC			; \ offset to get left
		ADC.w #!RPUSH_XMAX	; / boundary for pushing
		BPL CMP6		; \ if area goes backward past
		LDA.w #$0000		; / level start the assume zero
CMP6:		CMP $94			; compare with sprite's X position
		BCS NO_RPUSH_4		; don't execute next command if area is before mario
		LDY #$01		; set Y register = 1
NO_RPUSH_4:	PLP			; load backed up processor bits
		CPY #$00		; \ if Y is not set then
		BEQ NO_RPUSH		; / don't push from right
		PHP			; back up processor bits
		REP #%00100000		; set 16 bit A/math
		LDA !SPRXTMP		; \  
		CLC			;  | keep mario at
		ADC.w #!RPUSH_XMIN	;  | push offset position
		STA $94			; /
		PLP			; load backed up processor bits
		LDA $14			; \
		AND #%00000001		;  | "slowly" increase
		BNE NO_INC_SPD_R	;  | speed of rock
		DEC $B6,x		;  | 
NO_INC_SPD_R:				; /
		LDA $B6,x		; \
		CMP $7B			;  | prevent mario's speed from
		BCC OKX2		;  | exceeding that of the rock
		STA $7B			; /
OKX2:
		LDA $B6,x		; \
		BMI NOT_HITTING_WALL_R	;  | if mario is wedged
		LDA $77			;  | in between the rock
		AND #%00000001		;  | and the wall then
		BEQ NOT_HITTING_WALL_R	;  | bounce off of him
		JSR HIT_WALL		;  | (so not to kill him)
NOT_HITTING_WALL_R:			; /
NO_RPUSH:
		LDA $B6,x		; \ don't execute following
		BEQ NOT_ROLLING		; / code if rock is not rolling
		JSR POSOFFSETEND	; reverse interaction improvement offset
		JSR KILLSPRITES		; kill sprites
		JSR POSOFFSETSTART	; re-do interaction improvement offset
		LDA $14			; \
		AND #%00000111		;  | make the rock
		BNE END_SLOWDOWN	;  | slow down
		LDA $B6,x		;  |
		BPL MINUS		;  |
PLUS:		INC $B6,x		;  |
		BRA END_SLOWDOWN	;  |
MINUS:		DEC $B6,x		; /
END_SLOWDOWN:
NOT_ROLLING:
		LDA $1588,x		; \
		AND #%00000011		;  | bounce off of
		BEQ NOT_HITTING_WALL	;  | walls
		JSR HIT_WALL		; /
NOT_HITTING_WALL:
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
		JSR STORE_POS		; store sprite's current position for reference in next frame
		JSR POSOFFSETEND	; reverse interaction improvement offset

		JSL $01802A|!bank	; update position based on speed values
		JSL $018032|!bank	; interact with other sprites      
RETURN:		RTS

;; This temporarily offsets mario's and the sprite's
;; Y positions so rock doesn't have a push glitch
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

;; SPRITE KILLER - kills enemies
;; - important note: the reason I only check for "interact with stars/cape/fire/bricks"
;;   is because some sprites with specially programmed shell interaction have this
;;   as the only way to tell if they should be killed.

KILLSPRITES:
		LDY #$0C		; load number of times to go through loop
KILL_LOOP:	CPY #$00		; \ zero? if so,
		BEQ END_KILL_LOOP	; / end loop
		DEY			; decrease # of times left+get index
		STX $06			; \  if sprite is
		CPY $06			;  | this sprite
		BEQ KILL_LOOP		; /  then ignore it
		LDA $14C8,y		; \  if sprite is not
		CMP #$08		;  | in a "tangible"
		BCC KILL_LOOP		; /  mode, don't kill
		LDA $167A,y		; \  if sprite doesn't
		AND #%00000010		;  | interact with stars/cape/fire/bricks
		BNE KILL_LOOP		; /  don't continue
		JSL $03B69F|!bank		; \
		PHX			;  | if sprite is
		TYX			;  | not touching
		JSL $03B6E5|!bank		;  | this sprite
		PLX			;  | don't continue
		JSL $03B72B|!bank		;  |
		BCC KILL_LOOP		; /
		LDA #!SPRITEKILLSND	; \ play kill
		STA $1DFC		; / sound
		LDA $1656,y		; \  force sprite
		ORA #%10000000		;  | to disappear
		STA $1656,y		; /  in smoke
		LDA #$02		; \ set sprite into
		STA $14C8,y		; / death mode (status=2)
END_KILL_LOOP:	RTS

;; subroutine for bouncing
;; I put the code in a subroutine
;; because it is used more than once
;; throughout the main code

HIT_WALL:	LDA $B6,x		; \ decide which way rock is going to
		BPL HIT_POS		; / determine which handler code to use
HIT_NEG:		LDA #$00		; \
		SEC			;  | if speed is negative
		SBC $B6,x		;  | (which means left movement)
		LSR A			;  | then handle it properly
		STA $B6,x		;  |
		INC !STARTOFFSET,x	;  | .. also alter base position for rock
		BRA END_HIT		; /
HIT_POS:		LDA $B6,x		; \
		LSR A			;  | if speed is positive
		STA $B6,x		;  | (which means right movement)
		LDA #$00		;  | then handle it properly
		SEC			;  |
		SBC $B6,x		;  |
		STA $B6,x		;  | .. also alter base position for rock
		DEC !STARTOFFSET,x	; /
END_HIT:		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!ROCK_YOFF = $F8		; shift for whole rock

		!TILESDRAWN = $08	; \ scratch RAM
		!TEMP_FOR_TILE = $03	; / addresses

		!UPFRAMES = $08
		!DOWNFRAMES = $03

FRAMES:	db $00,$01,$02,$03
		db $10,$11,$12,$13
		db $20,$21,$22,$23
		db $30,$31,$32,$33

ROCK_TILES:	db $00,$02,$20,$22
ROCK_XPOS:	db $F8,$08,$F8,$08
ROCK_YPOS:	db $F8,$F8,$08,$08

SUB_GFX:		%GetDrawInfo()
		LDA !FLIPXY,x		; \ store flip
		STA $02			; / to scratch RAM
		STZ !TILESDRAWN		; zero tiles drawn
		JSR DRAW_ROCK		; draw rock
		JSR SETTILES		; set tiles / don't draw offscreen
ENDSUB:		RTS

DRAW_ROCK:	LDA !OFFSET,x		; \
		PHY			;  | set frame according
		TAY			;  | to offset
		LDA FRAMES,y		;  |
		PLY			; /
SETFRM:		REP #$10
		LDX #SPRITEGFX
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
		SBC ROCK_XPOS,x		;  | (add or
		BRA END_FLIP_R		;  | subtract
NO_FLIP_R:	CLC			;  | depending on
		ADC ROCK_XPOS,x		;  | direction)
END_FLIP_R:	PLY			; /
		STA $0300,y		; set tile's X position
		LDA $01			; get sprite's Y position
		PHY			; \
		LDY $02			;  | offset by
		BEQ NO_FLIP_R2		;  | this tile's
		SEC			;  | Y position
		SBC ROCK_YPOS,x		;  | (add or
		BRA END_FLIP_R2		;  | subtract
NO_FLIP_R2:	CLC			;  | depending on
		ADC ROCK_YPOS,x		;  | direction)
END_FLIP_R2:	PLY			; /
		CLC			; \ rock Y
		ADC #!ROCK_YOFF		; / offset
		STA $0301,y		; set tile's Y position
		LDA !TEMP_FOR_TILE	; load tile # from scratch RAM
		CLC			; \ shift tile right/down
		ADC ROCK_TILES,x	; / according to which part
		STA $0302,y		; set tile #
		PHX			; back up X (index to tile data)
		LDX $15E9		; load X with index to sprite
		LDA $15F6,x		; load palette info
		ORA $64			; add in priority bits
					; \
		LDX $02			;  | flip the tile
		BEQ NO_FLIP_XY		;  | X and Y if
		ORA #%11000000		;  | address set
NO_FLIP_XY:				; /
		STA $0303,y		; set extra info
		PLX			; load backed up X
		INC !TILESDRAWN		; another tile was drawn
		INY #4
		INX			; next tile to draw
		JMP TILELP		; loop (BRA is out of range)
RETFRML:		LDX $15E9
ENDROCK:		RTS

SETTILES:	LDA !TILESDRAWN		; \ don't do it
		BEQ NODRAW		; / if no tiles
		LDY #$02		; #$02 means 16x16
		DEC A			; A = # tiles - 1
		JSL finish_oam_write|!bank
NODRAW:		RTS

SPRITEGFX:
INCBIN chomprock.bin		;included graphics file
