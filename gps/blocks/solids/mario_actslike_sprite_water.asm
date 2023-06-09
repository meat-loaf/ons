;This block will act just like normal for Mario, but act like a different block for sprites
;This can be used to easily make blocks, slopes and ledges that are only solid for Mario
;by assigning this block to multiple map16 tiles and changing their acts like in Lunar Magic


!ActsLike	= $0000	;Acts Like number which should be used for non-Mario block interactions



db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody


; only act like water to fish, and custom sprites that act like fish
SpriteV: : SpriteH:
LDA !9E,x
CMP #$15
BCC ret
CMP #$19
BCC .cont
; rip van fish
CMP #$3D
BEQ .cont
; ...or dolphins
CMP #$41
BCC ret
CMP #$44
BCS ret
.cont:
LDY.b #!ActsLike>>8
LDA.b #!ActsLike
STA $1693|!addr
RTL

MarioBelow: : MarioAbove: : MarioSide:
TopCorner: : BodyInside: : HeadInside:
WallFeet: : WallBody:

LDA !sspipes_dir
BEQ ret
LDY #$00
LDA #$25
STA $1693|!addr

MarioCape:

MarioFireball:

ret:
RTL

print "Acts Solid for Mario and Yoshi, but acts like water for fish sprites. Object 18 with something behind it other than itself or air will turn into this, so use that instead."
