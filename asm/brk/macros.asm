macro clear_screen()
	SEP #$20
	LDA #$80  ; Force VBlank by turning off the screen.
	STA $2100
	STZ $420B
	STZ $420C
	LDA #$FF
	-
		NOP #4
		DEC
	BNE -
	STA $2115
	LDX #$0000
	STX $2116
	LDX #$FFFF
	-
		STZ $2118
		STZ $2119
		DEX
	BNE -
	SEP #$10

	LDA #$02
	STA $212C


	STZ $2101   ; 8x8/16x16 sprites using 0000 for base tile data

	LDA #$01
	STA $210B   ;layer 1 tile data at 1000, layer 2 at 0000
	STZ $210C

	LDA #$01
	STA $2105   ;background mode 1

	LDA #$40
	STA $2108   ;layer 2 tilemap at 4000 no mirroring

	;REset layer positions

	STZ $210D
	STZ $210D
	LDA #$FE
	STA $210E
	LDA #$FF
	STA $210E

	STZ $210F
	STZ $210F
	LDA #$FE
	STA $2110
	LDA #$80
	STA $2110


	LDA #$41
	STA $4360
	LDA #$18
	STA $4361


	LDA #$80
	STA $2115

	STZ $2116		;\ Set VRAM address
	STZ $2117		;/ #$0000

	;UPload font tiles
	;TRansfer source
	print pc
	LDA.b #font_tiles
	STA $4362
	LDA.b #font_tiles>>8
	STA $4363
	LDA.b #font_tiles>>16
	STA $4364

	;TRansfer size
	LDA.b #font_tiles-font_tilemap
	STA $4365
	LDA.b #(font_tiles-font_tilemap)>>8
	STA $4366

	LDA #$40
	STA $420B

	%DMA_to_CGRAM(#font_palette>>16, #font_palette, #$00, #$00A0)

	SEP #$30
	STZ $2121
	STZ $2121
	LDA #$73
	STA $2122
	LDA #$4E
	STA $2122
	lda #$E0
 	sta $2132
	REP #$30
endmacro


macro write_title()
	LDY #$0080
	STY $2115
	LDA #$4000
	STA $2116
	LDY #exception_title
	JSR write_text
endmacro

macro write_brk_message()
	SEP #$10
	LDY #$80
	STY $2115
	LDA #$4020
	STA $2116
	REP #$10

	LDX !brk_old_stack
	LDA $0002,x
	DEC
	STA $F0
	LDA $0003,x
	STA $F1
	LDA [$F0]
	AND #$00FF

	ASL
	TAX
	LDA string_table,x
	TAY
	JSR write_text
endmacro

macro write_program_counter()
	SEP #$10
	LDY #$80
	STY $2115
	LDA #$4080
	STA $2116
	REP #$10

	LDY #PC
	JSR write_text

	INC !brk_old_stack
	INC !brk_old_stack

	LDX !brk_old_stack
	SEP #$20
	LDA $FFFF,x
	STA $62
	REP #$20
	LDA $0002,x
	JSR write_byte


	LDX !brk_old_stack
	INC !brk_old_stack
	INC !brk_old_stack
	INC !brk_old_stack
	LDA $0000,x
	DEC #2
	%write_word()
endmacro

macro write_registers()
	%write_space()
	%write_space()
	LDY #B
	JSR write_text

	LDA !preserved_B
	JSR write_byte
	%write_space()
	%write_space()
	%write_space()
	%write_space()

	LDY #D
	JSR write_text
	LDA !preserved_D
	%write_word()
	%write_space()
	%write_space()


	LDY #A
	JSR write_text
	LDA !preserved_A
	%write_word()
	%write_space()
	%write_space()
	%write_space()
	%write_space()

	LDY #X
	JSR write_text
	LDA !preserved_X
	%write_word()
	%write_space()
	%write_space()

	LDY #Y
	JSR write_text
	LDA !preserved_Y
	%write_word()
	%write_space()
	%write_space()

	LDY #P
	JSR write_text
	LDA $62
	JSR write_byte
	%write_space()
	%write_space()
	%write_space()
	%write_space()
	%write_space()
	%write_space()

	LDY #S
	JSR write_text
	LDA !brk_old_stack
	%write_word()
	%write_space()
	%write_space()
	%write_space()

endmacro

macro write_layer_mirrors()
	SEP #$10
	LDY #$80
	STY $2115
	LDA #$40E0
	STA $2116
	REP #$10


	LDY #layer_1
	JSR write_text
	LDA $1A
	%write_word()
	%write_space()

	LDY #hex_prefix
	JSR write_text
	LDA $1C
	%write_word()

	LDA #$4100
	STA $2116

	LDY #layer_2
	JSR write_text
	LDA $1E
	%write_word()
	%write_space()

	LDY #hex_prefix
	JSR write_text
	LDA $20
	%write_word()

	LDA #$4120
	STA $2116

	LDY #layer_3
	JSR write_text
	LDA $22
	%write_word()
	%write_space()

	LDY #hex_prefix
	JSR write_text
	LDA $24
	%write_word()
endmacro

macro write_misc()
	SEP #$10
	LDY #$80
	STY $2115
	LDA #$4140
	STA $2116
	REP #$10


	LDY #powerup
	JSR write_text
	LDA $19
	JSR write_byte
	%write_space()
endmacro

macro write_stack()
	SEP #$10
	LDY #$80
	STY $2115
	LDA #$4220
	STA $2116
	REP #$10


	LDY #stack_title
	JSR write_text

	SEP #$10
	LDY #$80
	STY $2115
	LDA #$4240
	STA $2116
	REP #$10

	LDA !brk_old_stack
	TAX
	CMP #$01C0
	BCC ?stack_overflow
		CMP #$01FF
		BCC ?stack_normal
			LDY #stack_underflow
			JSR write_text
			LDX #$01C0
			STX !brk_old_stack
		BRA ?stack_normal
	?stack_overflow:
		LDY #stack_overflow
		JSR write_text
		LDX #$01C0
		STX !brk_old_stack
	?stack_normal:
		LDY #hex_prefix
		JSR write_text

		LDX !brk_old_stack
		SEP #$20
		LDA $0000,x
		JSR write_byte

		%write_space()

		INC !brk_old_stack
		LDX !brk_old_stack
		CPX #$0200
		BCC ?stack_normal
endmacro

macro write_space()
	STZ $2119
endmacro

macro write_word()
	XBA
	JSR write_byte
	XBA
	JSR write_byte
endmacro

macro DMA_to_CGRAM(srcbank, srcaddr, destaddr, datasize)
	REP #$20		; 16-bit A
	SEP #$10		; 8-bit XY
	LDY <destaddr>		;
	STY $2121		;
	LDA #$2200		;
	STA $4320		; 1 reg
	LDA <srcaddr>		;
	STA $4322		; set the lower two bytes of the destination address
	LDY.b <srcbank>		;
	STY $4324		;
	LDA <datasize>		; number of bytes to transfer
	STA $4325		;
	LDY #$04		; DMA channel 2
	STY $420B		;
	REP #$30		;
endmacro

macro DMA_to_VRAM(srcbank, srcaddr, destaddr, datasize)
	REP #$20		; 16-bit A
	SEP #$10		; 8-bit XY
	LDY #$80		;
	STY $2115		; increment after reading the high byte of the VRAM data write ($2119)
	LDA <destaddr>		;
	STA $2116		; VRAM address
	LDA #$1801		;
	STA $4320		; 2 regs write once, $2118
	LDA <srcaddr>		;
	STA $4322		; set the lower two bytes of the source address
	LDY.b <srcbank>		;
	STY $4324		;
	LDA <datasize>		; number of bytes to transfer
	STA $4325		;
	LDY #$04		; DMA channel 2
	STY $420B		;
	REP #$30		;
endmacro
