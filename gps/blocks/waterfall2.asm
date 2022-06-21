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
	LDA $7D
	BPL ret
;	BMI .minus
.plus:
;	CMP #$10
;	BCC ret
;	LDA #$20
;	STA $7D
;	BRA ret
.minus:
	CMP #$F0
	BCS ret
	LDA #$F0
	STA $7D
SpriteV:
SpriteH:

MarioCape:
MarioFireball:
ret:
	RTL

print "A waterfall which pushes Mario downwards."
