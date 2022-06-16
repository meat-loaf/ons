lorom
assert read1($00FFD5) != $23,	"This patch isn't compatible with SA-1."

;Free RAM addresses -- change as needed
!brk_triggered = $58		;1 byte
!brk_old_stack = $60		;2 bytes
!preserved_A = $0F3A		;2 bytes
!preserved_X = $0F3C		;2 bytes
!preserved_Y = $0F3E		;2 bytes
!preserved_D = $0F42		;2 bytes
!preserved_B = $0F44		;2 bytes
;end RAM

;config options
!snes9x = !true			;uses a infinite loop instead of STP so snes9x doesn't complain
;end config

;constants -- do not touch
!true = 1
!false = 0
;end constants
ORG $00FFE6
	dw brk_entry
	
ORG $00FFF0
	brk_entry:
		autoclean JML brk_handle
		
freecode
	macro exception(id, name, text)
		!<name> = #<id>
		<name>:
			db "<text>", $00
		pushpc
			org string_table+(<id>*2)
				dw <name>
		pullpc
	endmacro

	string_table:
		rep 256 : dw unknown_exception
	string_table_end:

	%exception($00, "unknown_exception", "An unknown exception has occurred")
	%exception($01, "vitor_exception", "Help! A vitor exception has     occurred")

	incsrc macros.asm

	brk_handle:
		SEI
		REP #$30		;Don't use the stack to avoid false debug info
		STA !preserved_A
		LDA #$0001
		STA $004200
		STX !preserved_X
		STY !preserved_Y
		TDC
		STA !preserved_D
		TSC
		STA !brk_old_stack
		LDA #$4306
		TCS
		PHB
		PHB
		PLA
		STA !preserved_B
		PEA ((brk_handle>>16)<<8)|(brk_handle>>16)
		PLB
		
		
		LDA !brk_triggered
		AND #$00FF
		CMP #$0001
		BNE +
			SEP #$30
			-
				LDA $4210
			BPL -
			LDA #$1F
			STZ $2121
			STA $2122
			STZ $2122
			JMP brk_brked
		+
		LDA #$0001
		STA !brk_triggered
		
		%clear_screen()
		%write_title()
		%write_brk_message()
		%write_program_counter()
		%write_registers()
		%write_layer_mirrors()
		%write_misc()
		%write_stack()

		SEP #$30
	brk_brked:
		LDA #$0F  ; End VBlank, setting brightness to 15 (100%).
		STA $2100
		if !snes9x
			BRA $FE
		else
			STP
		endif

write_text:
	-
		LDA $0000,y
		AND #$00FF
		BEQ .done
			CMP #$0028
			BCS +
				ADC.w #$0021-6
				SEC
			+
			SBC #$0030
			TAX
			LDA ascii,x
			AND #$00FF
			ORA #$0C00
			STA $2118
			INY
	BNE -
.done
	RTS
		
write_byte:
	SEP #$30
	
	TAY
	LSR #4
	TAX
	LDA numbers,x
	STA $2118
	LDA #$0C
	STA $2119
	
	TYA
	AND #$0F
	TAX
	LDA numbers,x
	STA $2118
	LDA #$0C
	STA $2119
	
	REP #$30
	RTS

font_palette:
	incbin font_palette.bin

font_tilemap:
	incbin font_tilemap.bin

font_tiles:
	incbin font_tiles.bin
	
numbers:
	db $2F, $30, $31, $32
	db $33, $34, $35, $36
	db $37, $38, $3D, $3E
	db $3F, $40, $41, $42
	
ascii:
	db $2F, $30, $31, $32, $33, $34, $35, $36
	db $37, $38
	
	db $1E, $00, $1D, $00, $00, $22, $00

	db $3D, $3E, $3F, $40, $41, $42, $43, $44
	db $45, $46, $47, $48, $49, $4A, $4B, $4C
	db $4D, $4E, $4F, $50, $51, $52, $53, $54
	db $55, $56

	db $00, $00, $00, $00, $00, $00

	db $01, $02, $03, $04, $05, $06, $07, $08
	db $09, $0A, $0B, $0C, $0D, $0E, $0F, $10
	db $11, $12, $13, $14, $15, $16, $17, $18
	db $19, $1A
	
exception_title:
	db "      EXCEPTION TRIGGERED", $00

macro prefix(text)
	<text>:
		db "<text>: $", $00
endmacro

%prefix("PC")
%prefix("D")
%prefix("B")
%prefix("A")
%prefix("X")
%prefix("Y")
%prefix("P")
%prefix("S")

macro string(name, text)
	<name>:
		db "<text>", $00
endmacro

%string(stack_overflow, "        STACK  OVERFLOW:        ")
%string(stack_underflow, "        STACK UNDERFLOW:        ")
%string(stack_title, "Dumping stack: ")
%string(hex_prefix, "$")


%string(layer_1, "Layer 1: $")
%string(layer_2, "Layer 2: $")
%string(layer_3, "Layer 3: $")

%string(powerup, "Powerup: $")
