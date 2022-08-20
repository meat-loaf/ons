!map16_start = $A0

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

TopCorner:
BodyInside:
HeadInside:
	LDA $03
	SEC
	SBC #(!map16_start-$01)
	STA !midway_flag

	REP.b #$10
	LDX.w #$0025
	%change_map16()
	SEP.b #$10

	LDX.b #$03
.glitter_loop:
	LDA $17C0|!addr,x
	BEQ .found
	DEX
	BMI .no_slot
.found:
	LDA #$05
	STA $17C0|!addr,x
	LDA $98
	AND #$F0
	STA $17C4|!addr,x
	LDA $9A
	AND #$F0
	STA $17C8|!addr,x
	LDA #$10
	STA $17CC|!addr,x
.no_slot:
	LDA #$05
	STA $1DF9|!addr

	; TODO REPLACE WITH DMA TO SOME SRAM INSTEAD
	; THIS TAKES NEARLY 70 SCANLINES
	PHY
	LDA !item_memory_setting
	ASL
	TAX
	REP #$30
	LDA .imem_off,x
	CLC
	ADC #!item_memory_mirror
	TAY
	LDA.l .imem_off,x
	CLC
	ADC #!item_memory
	TAX
	LDA #$0700-$01
	MVN $7F,$7F
	SEP #$30
	PLY

	;LDA #$36
	;STA $1DFC|!addr

	LDA #$28
	STA $0F30|!addr

	LDA !time_huns_bak
	STA $0F31|!addr
	STZ $0F32|!addr
	STZ $0F33|!addr
	RTL
.imem_off
    dw $0000, $0700, $0E00, $1500

MarioBelow:
MarioAbove:
MarioSide:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
	RTL

print "A midway point bar. Activates midway point 1-5 depending on Map16 number."
