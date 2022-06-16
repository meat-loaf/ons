db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead

!egg_color		= $09	; $01 for palette 8
						; $03 for palette 9
						; $05 for yellow
						; $07 for blue
						; $09 for red
						; $0B for green
						; $0D for palette E
						; $0F for palette F
						; Note: This value also affects the yoshi color!
				
!egg_sprite		= $35	; Sprite that will come from the egg
				
!egg_1up		= $75	; Sprite that will spawn if there is a yoshi. By default, 1up.
						; Note: This value WON'T be used if you aren't spawning Yoshi from an egg.

!XPlacement = $00	; Remember: $01-$7F moves the sprite to the right and $80-$FF to the left.
!YPlacement = $00	; Remember: $01-$7F moves the sprite to the bottom and $80-$FF to the top.

!SoundEffect = $02
!APUPort = $1DFC|!addr

!bounce_num			= $0A	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_direction	= $00	; Should be generally $00
!bounce_block		= $0A	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $09	; YXPPCCCT properties

; If !bounce_block is $FF.
!map16_tile = $0132		; Changes into the Map16 tile directly (also used if !bounce_num is 0x00)

!item_memory_dependent = 1	; Makes the block stay collected
!InvisibleBlock = 0			; Not solid, doesn't detect sprites, can only be hit from below
!ActivatePerSpinJump = 0	; Activatable with a spin jump (doesn't work if invisible)
; 0 for false, 1 for true

if !ActivatePerSpinJump
MarioCorner:
MarioAbove:
	LDA $140D|!addr
	BEQ Return
	LDA $7D
	BMI Return
	LDA #$D0
	STA $7D
	BRA Cape
else
MarioCorner:
MarioAbove:
endif

Return:
MarioSide:
Fireball:
MarioInside:
MarioHead:

if !InvisibleBlock
SpriteH:
SpriteV:
Cape:
RTL


MarioBelow:
	LDA $7D
	BPL Return
else
RTL

SpriteH:
	%check_sprite_kicked_horizontal()
	BCS SpriteShared
RTL

SpriteV:
	LDA !14C8,x
	CMP #$09
	BCC Return
	LDA !AA,x
	BPL Return
	LDA #$10
	STA !AA,x

SpriteShared:
	%sprite_block_position()

MarioBelow:
Cape:
endif

SpawnItem:
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
	LDA #!bounce_properties
	STA $1901|!addr,y

if !item_memory_dependent == 1
	PHK
	PEA .jsl_2_rts_return-1
	PEA $84CE
	JML $00C00D|!bank
.jsl_2_rts_return
	SEP #$10
endif

	LDA #!SoundEffect
	STA !APUPort

	LDA #$2C
	CLC
	%spawn_sprite_block()
	TAX
	if !XPlacement
		LDA #!XPlacement
		STA $00
	else
		STZ $00
	endif
	if !YPlacement
		LDA #!YPlacement
		STA $01
	else
		STZ $01
	endif
	TXA
	%move_spawn_relative()

	LDA #$09
	STA !14C8,x
	LDA #$D0
	STA !AA,x
	LDA #$2C
	STA !154C,x

	LDA !190F,x
	BPL +
	LDA #$10
	STA !15AC,x
+
; Copied and modified from LX5's egg blocks
if !egg_sprite == $2D || !egg_sprite == $35
	LDY	#$0B
.loop
	LDA	!14C8,y
	CMP	#$08
	BCC	.next_slot
	LDA	!9E,y
	CMP	#$2D
	BNE	.next_slot
	LDA	#!egg_1up
	BRA	.found_and_store
.next_slot
	DEY	
	BPL	.loop
	LDA	#!egg_sprite
	LDY	$18E2|!addr
	BEQ	.found_and_store
	LDA	#!egg_1up
.found_and_store
else
	LDA	#!egg_sprite
endif
	STA	!151C,x
	LDA	!15F6,x
	AND	#$F1
	ORA	#!egg_color
	STA	!15F6,x

	PLY
	PLX
RTL

if !egg_sprite == $2D || !egg_sprite == $35
print "Spawns a mushroom if Yoshi already exists, else a green Yoshi."
else
print "Spawns sprite $",hex(!egg_sprite)," in an egg."
endif
