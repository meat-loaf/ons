;This block will act just like normal for sprites, but act like a different block for Mario
;(by default it's the blank tile 0025)
;This can be used to easily make blocks, slopes and ledges that are only solid for sprites
;by assigning this block to multiple map16 tiles and changing their acts like in Lunar Magic

!ActsLike	= $0025	;Acts Like number which should be used for Mario block interactions



db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody


SpriteV: : SpriteH:
LDA !9E,x
CMP #$2D
BEQ MarioBelow
CMP #$35
BNE +

MarioBelow: : MarioAbove: : MarioSide:
TopCorner: : BodyInside: : HeadInside:
WallFeet: : WallBody:
MarioCape:
MarioFireball:

LDY.b #!ActsLike>>8
LDA.b #!ActsLike
STA $1693|!addr

+
RTL
