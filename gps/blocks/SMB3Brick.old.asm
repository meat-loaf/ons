;Acts like $25 (to prevent the coin from pushing (dropped) sprites outwards).

;options:
!CoinBrick	= 1		;>Will switch between a coin and a brick? 0 = no, 1 = yes.
!Switch		= $14AD|!addr	;>What ram address will switch this block.
!invert		= 0		;>Invert flags, 0 = if ram is clear, then brick, otherwise coin, 1 = vice versa.
!bounce_num	= $08		;>The bounce block sprite number
!map16_tile	= $03E9

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside
JMP WallRun : JMP WallFeet


BOUNCE:			; Code for spawning a bounce block sprite is here
	LDA.b #!map16_tile
	STA $03
	LDA.b #!map16_tile>>8
	STA $04

	LDX #$FF
	LDA #!bounce_num
	LDX #$FF
	LDY #$00
	%spawn_bounce_sprite2()
RETURN2:
	RTL


SHATTER1:	; shatter routine for Mario hitting block. Standard stuff from now on... 
		; and badly written stuff too
	LDA #$0F
	TRB $98
	TRB $9A

	PHY		;>don't act like 125
	PHK
	PER $0006	; hit sprites above block
	PEA $94F3
	JML $0286ED|!bank	; sprite block interact
	PLY	

	JMP SHATTER2
;------------------------------------------------------------------------------------
MarioBelow:
if !CoinBrick != 0
	if !invert = 0
		LDA !Switch	;\If switch is ON, then coin.
		BEQ +		;|
		JMP Coin	;/
		+
	else
		LDA !Switch	;\If switch is OFF, then coin.
		BNE +		;|
		JMP Coin	;/
		+
	endif
endif
	LDY #$01
	LDA #$30
	STA $1693|!addr

	LDA $19		; powerup
	BNE SHATTER1	; shatter block if not small
	JMP BOUNCE	; bounce if small
;------------------------------------------------------------------------------------
SpriteV:
if !CoinBrick != 0
	if !invert = 0
		LDA !Switch		;\If switch is ON, then coin.
		BEQ +			;|
		JMP PassableCoin	;/
		+
	else
		LDA !Switch		;\If switch is OFF, then coin.
		BNE +			;|
		JMP PassableCoin	;/
		+
	endif
endif
	LDY #$01
	LDA #$30
	STA $1693|!addr
	%check_sprite_kicked_vertical()
	BCC RETURN2

	LDA #$10	; set y speed
	STA !AA,x	;

	LDA $0F		;\Prevent sprite from being shifted sideways.
	PHA		;/
	LDA $98
	PHA
	LDA $99		; preserve these
	PHA
	LDA $9A
	PHA
	LDA $9B
	PHA
	PHY

;	LDA $0A		; $0A-D hold the x/y of sprite contact
;	AND #$F0	; have to clear the low nybble much like $98-9B
;	STA $9A
;	LDA $0B
;	STA $9B
;	LDA $0C
;	AND #$F0
;	SEC
;	SBC #$08
;	STA $98		; move y up for this (so sprites thrown below the block don't get hit)
;	LDA $0D
;	SBC #$00
;	STA $99
	%sprite_block_position()

	PHK
	PER $0006	; hit sprites above block
	PEA $94F3
	JML $0286ED|!bank


	LDA $0C
	AND #$F0	; get real y for everything else
	STA $98
	LDA $0D
	STA $99

	BRA SPRITE_SHATTER2
;------------------------------------------------------------------------------------
SpriteH:
if !CoinBrick != 0
	if !invert = 0
		LDA !Switch		;\If switch is ON, then coin.
		BEQ +			;|
		JMP PassableCoin	;/
		+
	else
		LDA !Switch		;\If switch is OFF, then coin.
		BNE +			;|
		JMP PassableCoin	;/
		+
	endif
endif
	LDY #$01
	LDA #$30
	STA $1693|!addr
	%check_sprite_kicked_horizontal()
	BCS SPRITEH_1
	RTL
SPRITEH_1:

	LDA $0F		;\Prevent sprite from being shifted sideways.
	PHA		;/
	LDA $98
	PHA
	LDA $99		; preserve these
	PHA
	LDA $9A
	PHA
	LDA $9B
	PHA


SPRITE_SHATTER:
	PHY

	%sprite_block_position()

SPRITE_SHATTER2:
;	PHB
;	LDA #$02
;	PHA
;	PLB
;	LDA #$00    	; set palette number
;	JSR $028663 	; breaking effect
;	PLB


;	LDA #$02 	; Replace block with blank tile
;	STA $9C
;	JSL $00BEB0
	%shatter_block()


	PLY
	PLA 
	STA $9B
	PLA 		;restore these
	STA $9a
	PLA 
	STA $99
	PLA 
	STA $98
	PLA
	STA $0F
	RTL
;------------------------------------------------------------------------------------
MarioCape:
if !CoinBrick != 0
	if !invert = 0
		LDA !Switch		;\If switch is ON, then don't break the coin.
		BEQ +			;|
		JMP RETURN		;/
		+
	else
		LDA !Switch		;\If switch is OFF, then don't break the coin.
		BNE +			;|
		JMP RETURN		;/
		+
	endif
endif
;	PHY

	LDA #$0F
	TRB $98
	TRB $9A

SHATTER2:
;	PHB
;	LDA #$02
;	PHA
;	PLB
;	LDA #$00    ; set palette number to default (00). Anything else = rainbow
;	JSL $028663 ; breaking effect
;	PLB

;	LDA #$02 ; Replace block with blank tile
;	STA $9C
;	JSL $00BEB0

	%shatter_block()

; set item memory
	PHK
	PEA .jsl_2_rts_return-1
	PEA $84CE
	JML $00C00D|!bank
.jsl_2_rts_return
	SEP #$10


;	PLY
	RTL
;------------------------------------------------------------------------------------
MarioFireBall:			;>fireballs should go through coins!
BodyInside:			;>fireballs should go through coins!
WallFeet:

	MarioAbove:
	TopCorner:

if !CoinBrick != 0
	if !invert = 0
		LDA !Switch		;\If switch is ON, then pass through coin.
		BEQ +			;|
		JMP PassableCoin	;/
		+
	else
		LDA !Switch		;\If switch is OFF, then pass through coin.
		BNE +			;|
		JMP PassableCoin	;/
		+
	endif
endif
JMP SolidBrick

HeadInside:
MarioSide:
WallRun:

if !CoinBrick != 0
	if !invert = 0
		LDA !Switch	;\If switch is ON, then coin.
		BEQ +		;|
		JMP Coin	;/
		+
	else
		LDA !Switch	;\If switch is OFF, then coin.
		BNE +		;|
		JMP Coin	;/
		+
	endif
endif
SolidBrick:
	LDY #$01
	LDA #$30
	STA $1693|!addr
RETURN:
	RTL


Coin:
	JSL $05B34A
	%erase_block()
	;%give_points()		;>give player points (only happens if you get coins from ? and turn blocks)
;glitter
	;PHY			;>protect tile behavor
	PHK			;\the JSL-RTS trick.
	PEA.w .jslrtsreturn-1	;|Thanks LX5 and imamelia!
	PEA.w $84CF-1		;/
	JML $00FD5A|!bank	;>glitter subroutine
.jslrtsreturn
	;PLY			;>end protect to avoid stack overflow.
PassableCoin:
	LDY #$00		;\Become passable (coins need this).
	LDA #$25		;|
	STA $1693|!addr	;/
	RTL

if !CoinBrick
	if !invert
	print "A coin which turns into a brick block if RAM ",hex(!Switch)," is set."
	else
	print "A brick block which turns into a coin if RAM ",hex(!Switch)," is set."
	endif
else
print "A simple brick block."
endif
