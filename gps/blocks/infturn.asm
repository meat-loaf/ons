db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
MarioAbove:
MarioSide:
	LDA $16
	AND #%01000000
	BEQ ret
	LDA #$53
	%spawn_sprite()
	BCS ret
	TAX
	LDA #$0B
	STA !14C8,x
	LDA $D1
	STA !E4,x
	LDA $D2
	STA !14E0,x
	LDA $D3
	STA !D8,x
	LDA $D4
	STA !14D4,x

TopCorner:
BodyInside:
HeadInside:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
ret:
	RTL

print "A turn block which never depletes."
