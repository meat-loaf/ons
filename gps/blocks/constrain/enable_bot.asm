incsrc "../../../asm_defs/main.asm"

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:
	LDA #!level_constrain_bot_flag
	ORA !level_constrain_flags
	STA !level_constrain_flags

TopCorner:
BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "Re-enables level constraining to the bottom of the level."
