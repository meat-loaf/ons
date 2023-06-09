;~@sa1 <-- DO NOT REMOVE THIS LINE!
;Behaves $130
;This is the bottom block of the 1x2 block gate.

!SpriteNum = $80
!SpriteTyp = $3200
!sfx_open  = $10	;\Door opening sfx
!RAM_port_open = $1DF9	;/
db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside



;-------------------------------------------------
;check if player presses up or down depending on
;what side
;-------------------------------------------------
MarioBelow:
	LDA $15
	AND.b #%00001000
	BNE Unlock
	RTL
;-------------------------------------------------
;check if player unlocks it facing correctly.
;-------------------------------------------------
MarioSide:
HeadInside:
	REP #$20		;>begin 16-bit mode
	LDA $9A			;\the block position
	AND #$FFF0		;/
	CMP $94			;\if block is right of mairo (if mario is hitting the
	SEP #$20		;|left side), then branch to left side.
	BCS left_side		;/(end 16-bit mode)

;right_side:
	LDA $76			;\Player should face towards block when touching side.
	BNE Return		;|
	JMP SideDone		;|
left_side:			;|
	LDA $76			;|
	BEQ Return		;/
SideDone:
;-------------------------------------------------
;This checks what sprite number and deletes key.
;-------------------------------------------------
Unlock:

	LDA $7470		;\Return if carrying nothing.
	ORA $748F		;|
	BEQ Return		;/
	PHX
	LDX.b #$22
-
	LDA $3242,x		;\If sprite status = not carried then next slot
	CMP #$0B		;|
	BNE NextSlot		;/

	LDA !SpriteTyp,x	;\If sprite number doesn't match, then next slot
	CMP #!SpriteNum		;|
	BNE NextSlot		;/
	JMP match_sprite	;>if match, then proceed.
NextSlot:
	DEX
	BPL -
ReturnPull:
	PLX
	RTL			;>if all slots checked and still didn't find, return.
match_sprite:
	STZ $3242,x		;>erase key.
	PLX			;>done with slots.
	LDA #$40		;\Fix a bug that if you unlock the block and kick it
	TSB $15			;/at the same frame makes deleting the key not function.
;---------------------------------
;Erase block.
;---------------------------------
	LDY #$00		;\Right when it disappears, shouldn't stop the player's
	LDA #$25		;|movement.
	STA $7693		;/

	%create_smoke()			;>smoke
	%erase_block()			;>Delete self.
	LDA $5B				;\Check if vertical level = true
	AND #$01			;|
	BEQ +				;|
	PHY				;|
	LDA $99				;|Fix the $99 and $9B from glitching up if placed
	LDY $9B				;|other than top-left subscreen boundaries of vertical
	STY $99				;|levels!!!!! (barrowed from the map16 change routine of GPS).
	STA $9B				;|(this switch values $99 <-> $9B, since the subscreen boundaries are sideways).
	PLY				;|
+					;/
	REP #$20			;\Move 1 block up.
	LDA $98				;|
	SEC : SBC #$0010		;|
	STA $98				;|
	SEP #$20			;/
	%create_smoke()			;
	%erase_block()			;


	LDA #!sfx_open			;\Play sfx.
	STA !RAM_port_open		;/
TopCorner:
MarioAbove:
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
BodyInside:
Return:
	RTL

print "The bottom of the 1x2 key block."
