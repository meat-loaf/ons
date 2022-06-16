incsrc "../../../asm_defs/main.asm"

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:
	LDA #(~!level_constrain_top_flag)
	AND !level_constrain_flags
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

print "Disables level constraining to the top of the level."
