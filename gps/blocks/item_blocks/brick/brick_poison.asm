db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead

!SoundEffect = $02
!APUPort = $1DFC|!addr

!bounce_num             = $08  ; See RAM $1699 for more details.
!bounce_direction	= $00  ; Should be generally $00
!bounce_block		= $0D  ; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $00  ; YXPPCCCT properties

;!bounce_Map16 = $0132

!item_memory_dependent = 1     ; Makes the block stay collected
!InvisibleBlock = 0            ; Not solid, doesn't detect sprites, can only be hit from below
; 0 for false, 1 for true

!RAM = $19	; This determines which item it spawns whether it is to the zero or not.

; The first argument is if Mario is small, the second for big
SpriteNumber:
db $80,$80

IsCustom:
db $01,$01	; $00 (or any other even number) for normal, $01 (or any other odd number) for custom

State:
db $08,$08	; Should be either $08 or $09

RAM_1540_vals:
db $3E,$3E	; If you use powerups, this should be $3E
			; Carryable sprites uses it as the stun timer

XPlacement:
db $00,$00	; Remember: $01-$7F moves the sprite to the right and $80-$FF to the left.

YPlacement:
db $02,$02	; Remember: $01-$7F moves the sprite to the bottom and $80-$FF to the top.

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

	LDA #!bounce_num
	LDX #!bounce_block
	LDY #!bounce_direction
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

	LDA #$00

	LDY #$00
	LDA !RAM
	BEQ +
	LDY #$01
+	LDA IsCustom,y
	LSR
	LDA SpriteNumber,y
	PHY
	%spawn_sprite_block()
	TAX
	PLY
	LDA XPlacement,y
	STA $00
	LDA YPlacement,y
	STA $01
	TXA
	%move_spawn_relative()

	LDA State,y
	STA !14C8,x
	LDA RAM_1540_vals,y
	STA !1540,x
	LDA #$D0
	STA !AA,x
	LDA #$2C
	STA !154C,x

	LDA !190F,x
	BPL Return2
	LDA #$10
	STA !15AC,x

Return2:
	PLY
	PLX
RTL

print "A brick block which spawns a poison mushroom. Use extended object 1C instead."
