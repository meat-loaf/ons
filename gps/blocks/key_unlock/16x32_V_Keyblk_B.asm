;Behaves $130
;This is the bottom block of the 1x2 block gate.

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
	LDA $1470		;\Return if carrying nothing.
	ORA $148F		;|
	BEQ Return		;/
	PHX
	LDX.b #$0B
-
	LDA $14C8,x		;\If sprite status = not carried then next slot
	CMP #$0B                ;|
	BNE NextSlot            ;/

	LDA $9E,x               ;\If sprite number doesn't match, then next slot
	CMP #$80
	BNE NextSlot
	JMP match_sprite	;>if match, then proceed.
NextSlot:
	DEX
	BPL -
ReturnPull:
	PLX
	RTL			;>if all slots checked and still didn't find, return.
match_sprite:
	STZ $14C8,x		;>erase key.
	PLX			;>done with slots.
	LDA #$40		;\Fix a bug that if you unlock the block and kick it
	TSB $15			;/at the same frame makes deleting the key not function.

;---------------------------------
;Erase block.
;---------------------------------
	LDY #$00		;\Right when it disappears, shouldn't stop the player's
	LDA #$25		;|movement.
	STA $1693		;/

	%create_smoke()			;>smoke
	%erase_block()			;>Delete self.

	REP #$20			;\Move 1 block up.
	LDA $98				;|
	SEC : SBC #$0010		;|
	STA $98				;|
	SEP #$20			;/
	%create_smoke()			;
	%erase_block()			;

;	JSL write_item_memory             ; set item memory (on the top block)
; set item memory
	PHK
	PEA .jsl_2_rts_return-1
	PEA $84CE
	JML $00C00D|!bank
.jsl_2_rts_return
	SEP #$10
TopCorner:
MarioAbove:
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
BodyInside:
Return:
	RTL

print "The bottom of the 1x2 key block. Uses item memory; use extended object 41 instead."
