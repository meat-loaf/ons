;Acts like $25 (to prevent the coin from pushing (dropped) sprites outwards).

;options:
!CoinBrick			= 0				;>Will switch between a coin and a brick? 0 = no, 1 = yes.
!Switch				= $14AD|!addr	;>What ram address will switch this block.
!invert				= 0				;>Invert flags, 0 = if ram is clear, then brick, otherwise coin, 1 = vice versa.
!SpinShatter		= 0				;>Breakable from above? 0 = no, 1 = yes.
!bounce_num			= $08			;>The bounce block sprite number
!map16_tile	= $03E9

!chomprock_sprite_num = $14
!brick_map16_hi = $03
!brick_map16_lo = $70

!chomp_hv_ram    = $59
!chomp_check_ram = $5A

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside
JMP WallRun : JMP WallFeet


BOUNCE:			; Code for spawning a bounce block sprite is here
	LDA.b #!map16_tile
	STA $03
	LDA.b #!map16_tile>>8
	STA $04

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
	BNE SHATTER1
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
	STZ !chomp_check_ram
	STZ !chomp_hv_ram
	LDY #$01
	LDA #$30
	STA $1693|!addr
	%check_sprite_kicked_vertical()
;	BCC RETURN2
	BCS .vKicked
	JSR SPRITE_CHECK_CUSTOM_CHOMPROCK
	BCC RETURN2
	LDA !1540,x   ; \ timer unused by the chomp rock...
	BNE RETURN2   ; / dont break block if set
	LDA #$04
	STA !1540,x
	LDA.b !B6,x
	CMP #$10
	BCS .cont
	RTL
.cont
	LDA #$01
	STA !chomp_hv_ram
	BRA .blorp
.vKicked
	LDA #$10	; set y speed
	STA !AA,x	;
.blorp
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
	STZ !chomp_hv_ram
	STZ !chomp_check_ram
	LDY #$01
	LDA #$30
	STA $1693|!addr
	%check_sprite_kicked_horizontal()
	BCS SPRITEH_1
	JSR SPRITE_CHECK_CUSTOM_CHOMPROCK
	BCS CHOMP_SPDCHK
	RTL
;	BCS SPRITEH_1_ALT
CHOMP_SPDCHK:
	LDA.b !B6,x
	CMP #$04
	BCS SPRITEH_1_ALT
	RTL
SPRITEH_1_ALT:
	LDY #$00        ;\ act like tile 25 if interacting with the chomprock
	LDA #$25        ;/ so it doesn't bounce away
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
	%shatter_block()
	JSL write_item_memory

	LDA !chomp_check_ram
	BEQ .nochompshatter
	LDA !chomp_hv_ram
	BNE .nochompshatter
	DEC $98
	BNE .nohiadj
	DEC $99
.nohiadj
	%GetMap16_pixi()
	CMP.b #!map16_tile
	BNE .nochompshatter
	CPY.b #!map16_tile>>8
	BNE .nochompshatter
	%shatter_block()
	JSL write_item_memory
.nochompshatter
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

SPRITE_CHECK_CUSTOM_CHOMPROCK:
	LDA !14C8,x
	CMP #$08
	BCC .ret_bad
	LDA !extra_bits,x
	AND #$08
	BEQ .ret_bad
	LDA !new_sprite_num,x
	CMP #!chomprock_sprite_num
	BNE .ret_bad
	SEC
	LDA #$01
	STA !chomp_check_ram
	BRA .ret_ok
.ret_bad
	CLC
.ret_ok
	RTS

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
	JSL write_item_memory

;	PLY
	RTL
;------------------------------------------------------------------------------------
MarioFireBall:			;>fireballs should go through coins!
BodyInside:			;>fireballs should go through coins!
WallFeet:

if !SpinShatter == 0
	MarioAbove:
	TopCorner:
endif

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

;------------------------------------------------------------------------------------
if !SpinShatter != 0
	MarioAbove:
	TopCorner:
	if !CoinBrick != 0
		if !invert = 0
			LDA !Switch	;\If switch is ON, then coin.
			BEQ +		;|
			JMP PassableCoin	;/
			+
		else
			LDA !Switch	;\If switch is OFF, then coin.
			BNE +		;|
			JMP PassableCoin	;/
			+
		endif
	endif

	LDY #$01
	LDA #$30
	STA $1693|!addr

	LDA $7D		;\If Y speed is negative (#$80~#$FF, going up)
	BMI RETURN	;/then return
	LDA $19		;\If powerup status is small mario, then return.
	BEQ RETURN	;/
	LDA $140D|!addr	;\If not spinjumping, return.
	BEQ RETURN	;/

	LDA #$D0	;\Bounce up like a turn block
	STA $7D		;/
	JMP SHATTER1	;>shatter the block.
endif
;------------------------------------------------------------------------------------
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
