;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fast NMI
;
; This patch rewrites SMW's NMI routine, allowing for more NMI time. With this
; patch, NMI, in a normal level, will end roughly 6 scanlines earlier,
; resulting in ~1000 or so extra cycles.
;
; This patch also preserves $00-03 in NMI.
;
; Current conflicts: Everything.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

assert read1($008209) == $22, "Apply this patch only once."
assert read3($00820A) != $0087AD, "Apply this patch after saving in LM and using exanimations."
assert read1($00A390) == $22, "Apply this patch after saving in LM and using exanimations."

!exanim_hijack	= read3($00A391)
!vram_hijack	= read3($00820A)

org $008072
		JSR pre_gm			; Run pre-game mode code.
		
org $00816A
nmi:		SEI
		REP #$30
		PHA
		PHX
		PHY
		PHB
		PHK
		PLB
		PEI ($00)
		PEI ($02)
		
		LDA $4210
		LDA $41
		STA $2123
		
		LDA #$4300
		SEP #$30
		
		LDA $43
		STA $2125
		LDA $44
		STA $2130
		
		LDA $40
		AND #$FB
		STA $2131
		
		LDA #$80
		STA $2100
		STZ $420C
		LDA #$09
		STA $2105
		
		LDA $10
		BEQ .no_lag
		
		LDA $0D9B
		BMI mode_7_end
		JMP level_end
		
	.no_lag	INC $10
		
		PHD
		LDA #$00
		TCD
		
		STZ $00				; DMA bytes.
		REP #$20
		LDA #$8000
		STA $2102			; Set OAM address to $0000 with priority.
		LDA #$0004
		STA $01				; DMA to register $2104.
		LSR
		STA $03				; Set source address to $000200.
		LDA #$0220
		STA $05				; Transfer $0220 bytes.
		SEP #$20
		LDY #$01
		STY $420B
		LDA $003F
		STA $2102			; Set the highest priority OAM index.
		
		JSR dma_palette			; DMA the palette.
		
		LDA $0D9B
		BNE +
		JMP level
	+	BMI .mode_7
		DEC
		BNE +
		JMP transition
	+	JMP overworld
		
	.mode_7	BIT $0D9B
		BVC mode_7
		
		JSR dma_l1_mode_7
		
		LDA $0D9B
		LSR
		BCS mode_7_no_sb
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
mode_7:		JSR dma_status_bar
	.no_sb	JSR dma_mario_gfx
		PLD
		JSR $85D2
		
	.end	LDA $2A
		CLC
		ADC #$80
		STA $211F
		LDA $2B
		ADC #$00
		STA $211F
		LDA $2C
		CLC
		ADC #$80
		STA $2120
		LDA $2D
		ADC #$00
		STA $2120
		LDA $2E
		STA $211B
		REP #$20
		LDA $2F
		STA $211B
		LDA $31
		STA $211C
		LDA $33
		STA $211D
		SEP #$20
		LDA $35
		STA $211E
		
		JSR $8416
		
		LDA $0DAE
		STA $2100
		LDA $0D9F
		STA $420C
		
		LDA $0D9B
		LSR
		BCC .not_bowser
		
		LDA #$81
		STA $4200
		LDA #$07
		STA $2105
		LDA $3A
		STA $210D
		LDA $3B
		STA $210D
		LDA $3C
		STA $210E
		LDA $3D
		STA $210E
		REP #$30
		JMP level_pull
		
	.not_bowser
		LDX #$24
		BIT $0D9B
		BVC +
		LDA $13FC
		CMP #$02
		BCS +
		LDX #$2D
	+	JMP level_irq
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

transition:	LDA $13C6
		CMP #$08
		BNE +
		LDA $1FFE
		BEQ ++
		JSL $0C9567
	++	JSR dma_mario_gfx
		PLD
		BRA level_credits
		
	+	JSR dma_sp1
		
		LDA $143A
		BEQ level_no_sb
		JMP dma_transition

level:		JSR dma_status_bar
	.no_sb	REP #$20
		JSL !exanim_hijack+9
		REP #$20
		LDA #$4300
		TCD				; LM's hijack actually resets the DP, so we must set it again.
		SEP #$20
	.ow	JSR dma_mario_gfx
	.trans	PLD
		JSL !vram_hijack
	.credits
		JSR $85D2
		
	.end	LDA $1A
		STA $210D
		LDA $1B
		STA $210D
		LDA $1C
		CLC
		ADC $1888
		STA $210E
		LDA $1D
		ADC $1889
		STA $210E
		LDA $1E
		STA $210F
		LDA $1F
		STA $210F
		LDA $20
		STA $2110
		LDA $21
		STA $2110
		
	.trans_end
		LDA $0DAE
		STA $2100
		LDA $0D9F
		STA $420C
		
		LDA $0D9B
		BEQ .sb
		
		LDA #$81
		STA $4200
		
		LDA $13C6
		CMP #$08
		BNE +
		
		LDA $22
		STA $2111
		LDA $23
		STA $2111
		LDA $24
		STA $2112
		LDA $25
		STA $2112
		REP #$30
		BRA .pull
		
	.sb	LDX #$24
	.irq	STX $4209
		STZ $420A
		STZ $11
		
		LDA #$A1
		STA $4200
		
	+	REP #$30
		STZ $2111
		STZ $2111
		
	.pull	PLA
		STA $02
		PLA
		STA $00
		PLB
		PLY
		PLX
		PLA
		
		print "NMI RTI: ", pc
		RTI

overworld:	LDY $1DE8
		DEY
		DEY
		CPY #$04
		BCS +
		
		JMP switch_submap
	+	JMP ow_animation
		
		print "NMI end: ", pc
		
		warnpc $008374

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
org $008449
dma_oam:	STZ $00				; DMA bytes.
		REP #$20
		LDA #$8000
		STA $2102			; Set OAM address to $0000 with priority.
		
		LDA #$0004
		STA $01				; DMA to register $2104.
		LSR
		STA $03				; Set source address to $000200.
		LDA #$0220
		STA $05				; Transfer $0220 bytes.
		SEP #$20
		
		LDY #$01
		STY $420B
		
		LDA $003F
		STA $2102			; Set the highest priority OAM index.
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
org $0085FD
		REP #$20
		PHD
		LDA #$4300
		TCD
		
		STZ $2115
		LDX #$50
		STX $2117
		
		LDA #$1808
		STA $10
		LDA #fill_l3
		STA $12
		STZ $14
		LDX #$10
		STX $16
		LDY #$02
		STY $420B
		
		LDX #$80
		STX $2115
		LDX #$50
		STX $2117
		
		INC $11
		INC $12
		LDX #$10
		STX $16
		STY $420B
		SEP #$20
		STZ $003F
		
		JSL $7F8000
		JSR dma_oam
		PLD
		RTS
		
fill_l3:
		db $FC,$38

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
pre_gm:		LDA $1DFB
		BNE +
		
		LDA $2142
		CMP $1DFF
		BNE ++
		
	+	STA $2142
		STA $1DFF
		STZ $1DFB
	++	LDA $1DFC
		STA $2143
		STZ $1DFC
		
		LDA $421A			; Set high byte to $421A.
		XBA
		LDA $4218
		REP #$30
		AND #$F0F0
		STA $0DA4
		TAY
		EOR $0DAC
		AND $0DA4
		STA $0DA8
		STY $0DAC
		
		LDA $421A			; Set high byte to $421B.
		SEP #$30
		LDA $4219
		REP #$30
		STA $0DA2
		TAY
		EOR $0DAA
		AND $0DA2
		STA $0DA6
		STY $0DAA
		
		LDA $1DF9
		STA $2140
		STZ $1DF9
		SEP #$30
		
		LDX $0DB3
		LDA $0DA4,x
		STA $17
		AND #$C0
		ORA $0DA2,x
		STA $15
		
		LDA $0DA8,x
		STA $18
		AND #$40
		ORA $0DA6,x
		STA $16
		
		JMP $9322			; Run the game mode.
		
		warnpc $0086C7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
org $008DAC
dma_status_bar:	STZ $2115			; Write bytes to VRAM.
		REP #$20
		LDA #$5042
		STA $2116			; Set the VRAM address to $5042.
		
		LDA #$1800
		STA $10				; DMA bytes to $2116.
		LDA #$0EF9
		STA $12				; Source address: $000EF9.
		LDA #$1C00
		STA $14				; Transfer $1C bytes.
		SEP #$20
		LDY #$02
		STY $420B
		
		LDX #$63
		STX $2116			; Set the VRAM address to $5063.
		LDX #$1B
		STX $15				; Transfer $1B bytes.
		STY $420B
		RTS
		
		warnpc $008DF5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
org $0098A9
dma_l1_mode_7:	LDX #$7E
		STX $24
		
		LSR
		REP #$20
		BCS .bowser
		LDA $0014
		AND #$00FF
		LSR
		LSR
		AND #$0006
		TAX
		
		LDY #$80
		STY $2115
		LDA #$7800
		STA $2116
		
		LDA #$1801
		STA $20
		LDA $05BA39,x
		STA $22
		
		LDX #$80
		STX $25
		
		LDY #$04
		STY $420B
		
		LDA #$0004
		LDX #$06
		BRA +
		
	.bowser	LDA #$0008
		LDX #$16
	+	STA $0000
		
		LDA #$C680
		STA $22
		STZ $2115
		
		LDA #$1800
		STA $20
		
		LDY #$04
	-	LDA $9891,x
		STA $2116
		
		LDA $0000
		STA $25
		STY $420B
		
		DEX
		DEX
		BPL -
		SEP #$20
		RTS
		
		warnpc $009925

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
org $00A300
dma_mario_gfx:	REP #$20
		LDY #$04
		LDX $0D84
		BEQ .no_palette			; If the number of tiles isn't 0, DMA the player palette.
		
		LDX #$86
		STX $2121
		LDA #$2200
		STA $20
		LDA $0D82
		STA $22
		LDA #$1400
		STA $24
		STY $420B			; DMA the player's palette.
		
	.no_palette
		LDX #$80
		STX $2115			; Write words to VRAM.
		LDA #$67F0
		STA $2116
		
		LDA #$1801
		STA $20
		LDA $0D99
		STA $22
		LDA #$207E
		STA $24
		STY $420B			; DMA a miscellaneous tile to 7F.
		
		LDX #$60
		STX $2117
		
		LDX #$00
	-	LDA $0D85,x
		STA $22
		LDA #$0040
		STA $25
		STY $420B			; DMA the upper portion of the player and Yoshi's 16x16 tiles.
		INX
		INX
		CPX $0D84
		BCC -
		
		LDA #$6100
		STA $2116
		
		LDX #$00
	-	LDA $0D8F,x
		STA $22
		LDA #$0040
		STA $25
		STY $420B			; DMA the lower portion of the player and Yoshi's 16x16 tiles.
		INX
		INX
		CPX $0D84
		BCC -
		SEP #$20
		RTS
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
dma_anim_gfx:	JSL !exanim_hijack
		RTS
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
anim_yellow:	STZ $0000
anim_red:	STA $2121
		
		LDA $0014
		AND #$1C
		LSR
		ADC $0000
		TAY
		LDA $B60C,y
		STA $2122
		LDA $B60D,y
		STA $2122			; Update palette animation.
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
dma_sp1:	LDA $1935
		BEQ .return
		STZ $1935
		
		REP #$20
		LDX #$80
		STX $2115
		LDA #$64A0
		STA $2116
		
		LDA #$1801
		STA $20
		LDA #$0BF6
		STA $22
		LDA #$C000
		STA $24
		LDY #$04
		STY $420B
		
		LDX #$A0
		STX $2116
		STA $24
		STY $420B
		SEP #$20
		
	.return	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

cgram_ptrs:
		dl $000682,$000905,$000703
	
dma_palette:	LDY $0680
		STZ $0680
		REP #$10
		LDX cgram_ptrs,y
		LDA $0000,x			; If the number of bytes to transfer is 0, stop.
		BEQ .none
		
		LDY #$2200
		STY $20
		STX $22
		STZ $24
		
		LDY #$0004
		LDA $0000,x
	-	STA $25				; Set the number of bytes to transfer.
		LDA $0001,x
		STA $2121			; Set the CGRAM destination.
		REP #$20
		INC $22
		INC $22
		SEP #$20
		STY $420B			; DMA the palettes.
		
		LDX $22
		LDA $0000,x			; Continue transferring palettes until done.
		BNE -
		
	.none	LDA $0701
		AND #$1F
		ORA #$20
		STA $2132			; Set the red BG intensity.
		
		REP #$20
		STZ $0681
		
		LDA $0701
		LSR
		LSR
		SEP #$30
		LSR
		LSR
		LSR
		AND #$1F
		ORA #$40
		STA $2132			; Set the green BG intensity.

		LDA $0702
		LSR
		LSR
		ORA #$80
		STA $2132			; Set the blue BG intensity.
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
ow_animation:	REP #$20
		LDX #$80
		STX $2115
		LDA #$0750
		STA $2116
		
		LDA #$1801
		STA $20
		LDA #$0AF6
		STA $22
		STZ $24
		LDA #$0160
		STA $25
		LDY #$04
		STY $420B
		SEP #$20
		
		LDA $13D9
		CMP #$0A
		BEQ .return
		LDA #$6D
		JSR anim_yellow
		LDA #$10
		STA $0000
		LDA #$7D
		JSR anim_red
	.return	JMP level_ow

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
submap_vram_offsets:
		db $00,$04,$08,$0C

submap_tilemap_offsets:
		db $00,$08,$10,$18

switch_submap:	LDA #$80
		STA $2115
		STZ $2116
		LDA #$30
		ADC submap_vram_offsets,y
		STA $2117
		
		REP #$20
		LDA #$1801
		STA $10
		LDA #$4000
		STA $12
		LDX #$7F
		STX $14
		LDX #$08
		STX $16
		SEP #$20
		
		LDX $0DB3
		LDA $1F11,x
		BEQ .main_ow
		LDA #$60
		STA $13
	.main_ow
		LDA $13
		ADC submap_tilemap_offsets,y
		STA $13
		
		LDA #$20
		ADC submap_vram_offsets,y
		
		LDY #$02
		STY $420B
		
		STZ $2116
		STA $2117
		
		LDX #$E4
		STX $13
		LDX #$7E
		STX $14
		LDX #$08
		STX $16
		STY $420B
		
		PLD
		JMP level_end
		
		print pc
		
		warnpc $00A594

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
org $00A601
		JSR dma_anim_gfx		; Repoint a JSR.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
org $00A7C2
dma_transition:	REP #$20
		LDX #$80
		STX $2115			; Write words to VRAM.
		
		LDA #$6000
		STA $2116
		LDA #$1801
		STA $4320
		LDA #$977B
		STA $4322
		LDA #$C07F
		STA $4324
		LDY #$04
		STY $420B
		
		LDA #$6100
		STA $2116
		LDX #$C0
		STX $4325
		STY $420B
		
		LDA #$64A0
		STA $2116
		STX $4325
		STY $420B
		
		LDA #$65A0
		STA $2116
		STX $4325
		STY $420B
		SEP #$20
		JMP level_trans
		
		warnpc $00A82D