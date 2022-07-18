;To be used as solid block (#$130) or a 1-way up ledge (#$100)
;It will be slippery only when mario's feet is on top of the block, not inside it.

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; if using db $37


MarioAbove:
TopCorner:
;	LDA $7D			;\If player Y speed is up (negative), then return.
;	BMI done		;/
;	REP #$20		;\Detect if mario is standing on top of the block
;	LDA $98			;|(better than using $7E:0072). Note: when mario descends onto
;	AND #$FFF0		;|the top of the block, he goes slightly into the block than he
;	SEC : SBC #$001C	;|should be by a maximum of 4 pixels before being "snapped" to
;	CMP $96			;|the top of the block, thats why I choose $001C instead of $0020.
;	SEP #$20		;|
;	BCC done		;/

LDA #$01                ;Note: you can copy this entire code and paste them
STA !mario_slip         ;in other blocks to make them slippery like Icy Melting Blocks
                        ;from Ersanio. (make sure that the top offset runs the code).
done:
MarioBelow:
MarioSide:
BodyInside:
HeadInside:
;WallFeet:
;WallBody:
SpriteH:
MarioCape:
SpriteV:
	RTL
;SpriteV:
;	LDA !AA,x		;\If going upward, return
;	BMI done		;/
;	LDA #$01
;	STA !spr_sprite_slip,x
;	RTL
MarioFireball:
	LDA.b $03
	CMP.b #$AF
	BEQ .melt_coin
	CMP.b #$BF
	BEQ .melt_muncher
	CMP.b #$9F
	BEQ .melt_rev_muncher
	CMP.b #$BE
	BNE done
.melt_empty:
	REP.b #$10
	LDX.w #$0025
	BRA .finish
.melt_coin:
	REP.b #$10
	LDX.w #$002B
	BRA .finish
.melt_rev_muncher:
	REP.b #$10
	LDX.w #$0110
	BRA .finish
.melt_muncher:
	REP.b #$10
	LDX.w #$012F
.finish:
	%change_map16()
	SEP.b #$10
	%create_smoke()
	JSL write_item_memory
	LDX $15E9|!addr
	STZ $170B|!addr,x
	STZ $1729|!addr,x
	STZ $1733|!addr,x
	RTL

print "A slippery block."
