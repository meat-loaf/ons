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
	JSL write_item_memory|!bank
	; restore Y
	LDY #$00

	LDX #$25
	REP #$10
	%change_map16()
	SEP #$10

	lda !block_xpos
	and #$F0
	sta !block_xpos

	lda !block_ypos
	and #$F0
	sta !block_ypos
	; the ambient spawner does not preserve Y
	PHY
	%spawn_red_coin()
	PLY

SpriteV:
SpriteH:
MarioCape:
MarioFireball:
	RTL

print "A red coin."
