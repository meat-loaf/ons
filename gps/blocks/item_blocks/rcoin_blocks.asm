db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead

!bounce_num             = $03  ; See RAM $1699 for more details.
!bounce_direction	= $00  ; Should be generally $00
!bounce_block		= $0D  ; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $00  ; YXPPCCCT properties

!item_memory_dependent = 1     ; Makes the block stay collected
!InvisibleBlock = 0            ; Not solid, doesn't detect sprites, can only be hit from below
; 0 for false, 1 for true

!map16_base = $E0
bounce_number:
	db $03,$01,$08

MarioCorner:
MarioAbove:

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

	;LDA #!bounce_num
	LDX $03
	LDA bounce_number-!map16_base,x
	LDX #!bounce_block
	LDY #!bounce_direction
	%spawn_bounce_sprite2()

if !item_memory_dependent == 1
	JSL write_item_memory
endif

	STZ $00
	LDA #$F0
	STA $01
	%spawn_red_coin()
; spawn block
Return2:
	PLY
	PLX
RTL

print "One of a set of blocks that spawn a red coin collectible. Use extended object 5B, 5C, or 5D instead."
