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


	LDA !red_coin_total
	CLC : ADC !red_coin_counter
	STA !rcoin_count_bak

	LDA !yoshi_coins_collected
	STA !scoin_count_bak

	LDA !on_off_state
	STA !on_off_state_bak

	;LDA #$36
	;STA $1DFC|!addr

	LDA #$28
	STA $0F30|!addr

	LDA !time_huns_bak
	STA $0F31|!addr
	STZ $0F32|!addr
	STZ $0F33|!addr

if !use_midway_imem_sram_dma = !true
	; runs over several frames. see status bar code.
	LDA.b #!item_memory_dma_frames+$01
	STA.w !midway_imem_dma_stage
endif

MarioBelow:
MarioAbove:
MarioSide:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
	RTL

print "A midway point bar. Activates midway point 1-5 depending on Map16 number."
