@asar 1.81

incsrc "../main.asm"

; ----------------------------------------------------------------------------------------------------------------------------------
;
; "Item Memory"
; by Ragey <i@ragey.net>
; https://github.com/xragey/smw
;
; Replaces the item memory system in Super Mario World with a different system that assigns a bit to every individual tile in a
; stage, rather than having columns within a screen share the same bit. Also implements item memory settings 3. Implements a flag
; that can be used to toggle the use of item memory. Compatible with the ExLevel system implemented by recent versions of Lunar
; Magic.
;
; Installing this patch reclaims offset $7E19F8 (384 bytes).
;
; Division and multiply routines by GreenHammerBro <https://smwc.me/u/18802>
; Additional coding by lx5 <https://github.com/TheLX5>
;
; ----------------------------------------------------------------------------------------------------------------------------------

macro spr_imem_entry()
	LDA !D8,x
	AND #$F0
	STA $98
	LDA !E4,x
	AND #$F0
	STA $9A
	LDA !14D4,x
	STA $99
	LDA !14E0,x
	STA $9B
endmacro

!ExLevelScreenSize = !exlvl_screen_size
!ItemMemory = !item_memory
!ItemMemoryMask = !item_memory_mask

assert read1($00FFD5) != $23, "This patch does not support SA-1 images."

if read1($00FFD5)&$10 == $10
	!fast = 1
else
	!fast = 0
endif

; Loading level code
org $0096F4|!bank
	jsl ClearItemMemory|!bank

; Item memory offsets, for settings 0,1,2,3 respectively.
org $00BFFF|!bank
ItemMemoryBlockOffsets:
    dw $0000, $0700<<3, $0E00<<3, $1500<<3
warnpc $00C00D|!bank

org $00C00D|!bank
autoclean \
	JSL WriteItemMemory
	RTS
ClearItemMemory:
	; Check if we're entering from the overworld.
	LDA $141A|!addr
	BNE .no_clear

	; clear item memory via rom->ram DMA
	; read the 0000 entry over and over for the whole
	; item memory table
	REP #$30
	LDA.w #!ItemMemory
	STA.w $2181
	SEP #$20
	LDA.b #!ItemMemory>>16
	STA.w $2183
	LDX #$8008
	STX $4300
	LDX #ItemMemoryBlockOffsets
	STX $4302
	LDA #ItemMemoryBlockOffsets>>16
	STA $4304
;	LDX #$1C00
	LDX #($1C00*2)
	STX $4305
	LDA #$01
	STA $420B
	SEP #$10
.no_clear:
	; Restore overwritten jump position.
	JML $05D796|!bank
warnpc $00C063|!bank

freecode
print "sprite_write_item_memory = $", pc
SpriteWriteItemMemory:
	%spr_imem_entry()
; WriteItemMemory. Marks a certain coordinate as collected.
; This can be used as a shared routine.
; On entry, $98 should be set to the X position and $9A as the Y position.
print "write_item_memory = $", pc
WriteItemMemory:
	LDA !ItemMemoryMask
	BIT #$01
	BNE .Return
.cont:
	STX $4F
	; X = Item memory index
	LDA $13BE|!addr
	ASL
	TAX

	; $45 = $13D7 * X position
	REP #$30
	LDY $13D7|!addr
	LDA $9A
	LSR #4
	PHA
	LSR #4
	CMP $13D7|!addr
	BCS +
	TAY
	LDA $13D7|!addr
+	SEP #$30
	STA $211B
	XBA
	STA $211B
	STY $211C
	REP #$20
	LDA $2134
	STA $45

	; $47 = Y positon * 16
	LDA $98
	AND #$3FF0
	STA $47

	; A = Absolute offset
	PLA
	AND #$000F
	CLC
	ADC $45
	CLC
	ADC $47
	CLC
	ADC.l ItemMemoryBlockOffsets,x

	; X = Address offset
	; A = Bit to set in address
	REP #$10
	STA $45
	LSR #3
	TAX
	PHX
	LDA $45
	AND #$0007
	TAX
	SEP #$20
	LDA.l $00C0AA|!bank,x
	PLX
	ORA.l !ItemMemory,x
	STA.l !ItemMemory,x
	SEP #$10
	LDX $4F
.Return
	RTL

load_blk_ptrs = $00BEA8|!bank

; TODO doesn't work properly
print "sprite_read_item_memory = $", pc
SpriteReadItemMemory:
	LDA !ItemMemoryMask
	BIT #$02
	BEQ .set_up_data
	LDA #$00
	RTL
.set_up_data:
	%spr_imem_entry()
	; save layer1 data ptrs
	LDA  $65
	PHA
	LDA  $66
	PHA
	LDA  $67
	PHA

	REP  #$10
	LDY  $98
	LDX  #$0000
	LDA.l load_blk_ptrs,x
	STA  $65
	LDA.l load_blk_ptrs+1,x
	STA  $66
	STZ  $67
	LDA  $1925|!addr
	ASL
	TAY
	LDA  [$65],y
	STA  $04
	INY
	LDA  [$65],y
	STA  $05
	STZ  $06
	LDA  $9B
	STA  $07
	ASL
	CLC
	ADC  $07
	TAY
	LDA  [$04],y
	STA  $6B
	INY
	LDA  [$04],y
	STA  $6C
	LDA  #$7E
	STA  $6D
	SEP  #$10

	; restore layer1 data ptrs
	PLA
	STA $67
	PLA
	STA $66
	PLA
	STA $65
	LDX  $15E9|!addr
	BRA ReadItemMemory_do_read
print "read_item_memory = $", pc
; ReadItemMemory. Checks if the current block coordinate is marked as collected.
; This can be used as a shared (object generation) routine.
; On entry, $6B+Y should be set to the current block linear index. For pretty
; much all object generation routines, this is already set correctly. Returns
; A=$00 if the flag is not set or any other value if it's set.
ReadItemMemory:
	LDA !ItemMemoryMask
	BIT #$02
	BEQ .do_read
	LDA #$00
	RTL
.do_read:
	STX $4F
	; A = $45 = Absolute offset
	LDA $13BE
	ASL
	TAX
	REP #$30
	LDA $6B
	SEC
	SBC #$C800
	CLC
	ADC.l ItemMemoryBlockOffsets,x
	STA $45
	TYA
	CLC
	ADC $45
	STA $45

	; X = Address offset
	; A = Bit to read in address
	LSR #3
	TAX
	PHX
	LDA $45
	AND #$0007
	SEP #$20
	TAX
	LDA.l $00C0AA|!bank,x
	PLX
	AND.l !ItemMemory,x
	SEP #$10
	PHP
	LDX $4F
	PLP
.Return
	RTL
