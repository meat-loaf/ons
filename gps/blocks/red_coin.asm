db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:
	REP #$10
	LDX #$0025
	%change_map16()
	SEP #$10

	STZ $00
	STZ $01
	%spawn_red_coin()

SpriteV:
SpriteH:
MarioCape:
MarioFireball:
	RTL

print "A red coin."