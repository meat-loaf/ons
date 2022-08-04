;Act as $0130

!bounce_num		= $09	;>The bounce block sprite number
!bounce_properties	= $06	;>The properties of bounce blocks (palette, tile number high byte)

!map16_tile             = $0312 ; The tile the block will use.


db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; enable if using db $37

MarioCape:
MarioBelow:
	LDA !on_off_cooldown
	BNE +
	JSR BOUNCE
+

MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:
Return:
-
	RTL
SpriteV:
	%check_sprite_kicked_vertical()
	BCC Return

	BRA SPRITEBOUNCE
SpriteH:
	LDA !on_off_cooldown
	BNE -
	%check_sprite_kicked_horizontal()
	BCC Return
SPRITEBOUNCE:
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
	JML $0286ED


	LDA $0C
	AND #$F0	; get real y for everything else
	STA $98
	LDA $0D
	STA $99
	JSR BOUNCE

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
MarioFireball:
	RTL
BOUNCE:			; Code for spawning a bounce block sprite is here
	LDA #!frames_for_on_off_cooldown
	STA !on_off_cooldown
	PHX
	PHY
	LDA.b #!map16_tile
	STA $03
	LDA.b #!map16_tile>>8
	STA $04
	LDA #!bounce_num
	LDX #$FF
	LDY #$00
	%spawn_bounce_sprite2()
	PLY
	PLX
	RTS
