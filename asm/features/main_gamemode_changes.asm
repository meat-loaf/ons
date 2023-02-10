incsrc "../main.asm"

org $00A5AB|!bank
	jsl level_setup_ram_special

org $00FFD8|!bank
;if !use_midway_imem_ram_dma == !true
	db $04       ; 16kb sram
;else
;	db $01       ; 2kb sram
;endif

; yoshi wings ani stuff
org $00A6DE|!bank        ; prevent entrance type 5 from making levels slippery
BRA $00

org $00A704|!bank         ; overwrite Yoshi wings flag check in "Do Nothing" entrance types
autoclean JML EntranceType5Check

org $00C82A|!bank
autoclean JML YwingAniType

org $00C836|!bank
;	db $80
;	NOP : NOP


org $00A261|!bank
if !dbg_start_select_end_level == !true
	BRA exit_level : NOP
org $00A269|!bank
exit_level:
else
	LDY !main_level_num
endif

org $00D0E7|!bank
	db $18       ; gamemode to execute on death
;	db $0B       ; gamemode to execute on death
warnpc $00D0E8|!bank

; gm18: gamemode transition -> temp fade
%replace_pointer($009359|!bank,$009F37|!bank)
%replace_pointer($00935B|!bank,gamemode_19|!bank)
%replace_pointer($00935D|!bank,gamemode_1b|!bank)
;%replace_pointer($00935D|!bank,$009F37|!bank)
;%replace_pointer($00935F|!bank,gamemode_1b|!bank)

org $00A5EE|!bank
	jsr $919B
	jsr $8494
	jsl level_load_code
	rts
warnpc $00A5F9|!bank


org $00A2D8|!bank
	jsl level_main

org $009468|!bank
gamemode_19:
autoclean \
	JSL.l gm19
	RTS
;; todo: should be the 'death/return to level or midpoint' menu'
gamemode_1b:
	LDA.b #$10
	STA.w !gamemode
	RTS

warnpc $009557|!bank

freecode
prot gradients
die:
	rtl
level_load_code:
	sep #$30
	; restore hijacked code
	inc !gamemode
	lda #$81
	sta $4200
	; sp1 gfx file value - low
	; used as gradient id to load
	lda !level_header_sgfx3_lo
	cmp #$7f
	beq die

	phb
	rep #$30
	and.w #($3F<<2)
	sta $00
	lsr
	adc $00
	tax
	lda.l gradient_tbl_ptrs+1,x
	sta $01
	lda.l gradient_tbl_ptrs,x
	sta $00
	sep #$20
	ldx.w #!big_hdma_decomp_buff_rg
	stx $03
	ldx.w #!big_hdma_decomp_buff_b
	stx $05
	lda.b #!big_hdma_decomp_buff_rg>>16

	sta $4337
	sta $4347
	pha
	plb

	jsr decomp_gradient
	plb

; majority of below code is interpreted from mariofangamer's
; scrollable hdma uberasm code
	ldx #$3242
	stx $4330
	ldx #$3240
	stx $4340
	ldx.w #!big_hdma_ptr_rg
	stx $4332	; Red-green table
	ldx.w #!big_hdma_ptr_b
	stx $4342	; Blue table
	lda.b #!big_hdma_ptr_rg>>16
	sta $4334	; RAM bank
	sta $4344	; RAM bank

	sep #$30
	ldx #$05
.hdma_init_loop:
	lda.l init_hdma,x
	sta !big_hdma_ptr_rg,x
	sta !big_hdma_ptr_b,x
	dex
	bpl .hdma_init_loop

	lda #$18
	tsb $0D9F|!addr
	bra level_main_skip_gm14_entry

level_main:
	jsl $00e2bd|!bank
.skip_gm14_entry:
	lda !level_header_sgfx3_lo
	cmp #$7f
	beq .exit

	rep #$20
	and #$0003
	asl : asl
	tax

	LDA.w #!big_hdma_decomp_buff_rg
	STA $00
	LDA.w #!big_hdma_decomp_buff_b
	STA $02

	lda !layer_1_ypos_curr,x

	pha
	asl
	clc
	adc $00
	sta !big_hdma_ptr_rg+1
	clc
	adc #$00E0
	sta !big_hdma_ptr_rg+4
	pla
	clc
	adc $02
	sta !big_hdma_ptr_b+1
	clc
	adc #$0070
	sta !big_hdma_ptr_b+4
	sep #$20
.exit:
	rtl


gradient_tbl_ptrs:
	dl sky_hdma_table

init_hdma:
	db $F0 : dw $0000
	db $F0 : dw $0000

; decompress a scrollable hdma graident
; by mariofangamer
decomp_gradient:
	LDY #$FFFF
; failsafe
;	LDX $0E

.next_row:
	iny
	lda [$00],y
	bne .cont
.ret:
	rts

.cont:
	STA $0F
	INY
	LDA [$00],y
	STA $0C
	INY
	LDA [$00],y
	STA $0D
	INY
	LDA [$00],y
	STA $0E

..Loop
	LDA $0E
	STA ($05)
	REP #$20
	LDA $0C
	STA ($03)
	INC $03
	INC $03
	INC $05
	SEP #$20

; failsafe
;	DEX
;	BMI .Return
	DEC $0F
	BNE ..Loop
	BRA .next_row

level_setup_ram_special:
	; restore hijacked code
	jsl $05809E|!bank
	stz !ambient_playerfireballs
	lda #(!num_ambient_sprs*2)-2
	sta !ambient_spr_ring_ix
	ldx #(!num_turnblock_slots-1)*6
	stx !turnblock_run_index
	stx !turnblock_free_index
.loop:
	lda #$00
	sta turnblock_status_d.timer,x
	sta turnblock_status_d.timer+1,x
	txa
	sec : sbc #$06
	tax
	bpl .loop
	rtl

EntranceType5Check:
	LDA $192A|!addr       ; Entrance type-- sw___aaa
	AND #$07
	BEQ .Return     ; Entrance type should be 0 or 5 here, so do nothing if it's 0
	JML $00A709|!bank     ; return and set shoot-vertically-upward animation
.Return
	JML $00A715|!bank

YwingAniType:   ; check whether animation occurred from Yoshi wings or entrance type 5
	LDA $192A|!addr
	AND #$07
	CMP #$05
	REP #$20
	BNE YwingReturn ; if entrance type is not 5, then run Yoshi wings code normally
	LDA $80         ;\ Mario's on-screen Y-position
	CMP #$00A0      ;/ if entrance type is 5, then always stop at #$00A0 (can be adjusted)
	SEP #$20
	BPL +
	STZ $71         ; reset Mario's animation
	+
	JML $00CD8F|!bank     ; return, bypassing code to set Yoshi wings flag

YwingReturn:
	LDY $1B95|!addr       ; restore overwritten code
	JML $00C82F|!bank

gm19:
	;LDA.b #$10
	;STA.w !gamemode
	; setup next game mode
	INC.w !gamemode

	; don't do 'from overworld' stuff
	LDA.b #$01
	STA.w !exit_counter

	%midway_backup_restore(!true)
; setup load point
;	JSL.l oam_reset
if (read1($03BCDC|!bank)) != $FF
	; note: clobbers Y if using a new horz level mode.
	JSL.l $03BCDC|!bank
else
	LDX $95
	LDA $5B
	LSR
	BCC .not_vert
	LDX $97
.not_vert:
endif

	LDA.w !midway_flag
	BNE.b .midway
	LDA.w !main_level_num
	REP.b #$20
	AND.w #$00FF
	CMP.w #$0024+$01
	BCC.b .low_lvl_num
	CLC
	ADC.w #$00DC
.low_lvl_num:
	SEP.b #$20
	STA !exit_table,x
	XBA
	ORA #!19D8_flag_lm_modified
	STA !exit_table_new_lm,x
	RTL
.midway:
	PHX
	LDA.b #(midway_ptr_tables|!bank)>>16
	STA $8C

	LDA.w !midway_flag
	DEC
	ASL
	TAY
	LDA.w !main_level_num
	REP.b #$30
	AND.w #$00FF
	ASL
	TAX
	LDA.l midway_ptr_tables,x
	STA $8A
	LDA.b [$8A],y

	SEP.b #$30

	PLX
	STA.w !exit_table,x
	XBA
	STA.w !exit_table_new_lm,x

	RTL

midway_tables:
.level_000:
.level_001:
.level_002:
.level_003:
	%midway_table_entry($0003, !true, !false)
	%midway_table_entry($0029, !true, !false)
.level_004:
.level_005:
.level_006:
.level_007:
.level_008:
.level_009:
.level_00A:
.level_00B:
.level_00C:
.level_00D:
.level_00E:
.level_00F:
.level_010:
.level_011:
.level_012:
.level_013:
.level_014:
.level_015:
.level_016:
.level_017:
.level_018:
.level_019:
.level_01A:
.level_01B:
.level_01C:
.level_01D:
	dw $0000,$0000,$0000,$0000,$0000
.level_01E:
	%midway_table_entry($001E, !true, !false)
.level_01F:
.level_020:
.level_021:
.level_022:
.level_023:
.level_024:
	dw $0000,$0000,$0000,$0000,$0000
.level_101:
	%midway_table_entry($0101, !true, !false)
.level_102:
	%midway_table_entry($0102, !true, !false)
.level_103:
	%midway_table_entry($0103, !true, !false)
.level_104:
.level_105:
	%midway_table_entry($0105, !true, !false)
	%midway_table_entry($0142, !true, !false)
.level_106:
	%midway_table_entry($0106, !true, !false)
	%midway_table_entry($0106, !true, !false)
	%midway_table_entry($0144, !true, !false)
.level_107:
	%midway_table_entry($0107, !true, !false)
.level_108:
	%midway_table_entry($0108, !true, !false)
.level_109:
.level_10A:
.level_10B:
.level_10C:
.level_10D:
.level_10E:
.level_10F:
.level_110:
.level_111:
.level_112:
.level_113:
.level_114:
.level_115:
.level_116:
.level_117:
.level_118:
.level_119:
.level_11A:
.level_11B:
.level_11C:
.level_11D:
.level_11E:
.level_11F:
.level_120:
.level_121:
.level_122:
.level_123:
.level_124:
.level_125:
.level_126:
.level_127:
.level_128:
.level_129:
.level_12A:
.level_12B:
.level_12C:
.level_12D:
.level_12E:
.level_12F:
.level_130:
.level_131:
.level_132:
.level_133:
.level_134:
.level_135:
.level_136:
.level_137:
.level_138:
.level_139:
.level_13A:
.level_13B:
	dw $0000,$0000,$0000,$0000,$0000

midway_ptr_tables:
dw midway_tables_level_000
dw midway_tables_level_001
dw midway_tables_level_002
dw midway_tables_level_003
dw midway_tables_level_004
dw midway_tables_level_005
dw midway_tables_level_006
dw midway_tables_level_007
dw midway_tables_level_008
dw midway_tables_level_009
dw midway_tables_level_00A
dw midway_tables_level_00B
dw midway_tables_level_00C
dw midway_tables_level_00D
dw midway_tables_level_00E
dw midway_tables_level_00F
dw midway_tables_level_010
dw midway_tables_level_011
dw midway_tables_level_012
dw midway_tables_level_013
dw midway_tables_level_014
dw midway_tables_level_015
dw midway_tables_level_016
dw midway_tables_level_017
dw midway_tables_level_018
dw midway_tables_level_019
dw midway_tables_level_01A
dw midway_tables_level_01B
dw midway_tables_level_01C
dw midway_tables_level_01D
dw midway_tables_level_01E
dw midway_tables_level_01F
dw midway_tables_level_020
dw midway_tables_level_021
dw midway_tables_level_022
dw midway_tables_level_023
dw midway_tables_level_024
dw midway_tables_level_101
dw midway_tables_level_102
dw midway_tables_level_103
dw midway_tables_level_104
dw midway_tables_level_105
dw midway_tables_level_106
dw midway_tables_level_107
dw midway_tables_level_108
dw midway_tables_level_109
dw midway_tables_level_10A
dw midway_tables_level_10B
dw midway_tables_level_10C
dw midway_tables_level_10D
dw midway_tables_level_10E
dw midway_tables_level_10F
dw midway_tables_level_110
dw midway_tables_level_111
dw midway_tables_level_112
dw midway_tables_level_113
dw midway_tables_level_114
dw midway_tables_level_115
dw midway_tables_level_116
dw midway_tables_level_117
dw midway_tables_level_118
dw midway_tables_level_119
dw midway_tables_level_11A
dw midway_tables_level_11B
dw midway_tables_level_11C
dw midway_tables_level_11D
dw midway_tables_level_11E
dw midway_tables_level_11F
dw midway_tables_level_120
dw midway_tables_level_121
dw midway_tables_level_122
dw midway_tables_level_123
dw midway_tables_level_124
dw midway_tables_level_125
dw midway_tables_level_126
dw midway_tables_level_127
dw midway_tables_level_128
dw midway_tables_level_129
dw midway_tables_level_12A
dw midway_tables_level_12B
dw midway_tables_level_12C
dw midway_tables_level_12D
dw midway_tables_level_12E
dw midway_tables_level_12F
dw midway_tables_level_130
dw midway_tables_level_131
dw midway_tables_level_132
dw midway_tables_level_133
dw midway_tables_level_134
dw midway_tables_level_135
dw midway_tables_level_136
dw midway_tables_level_137
dw midway_tables_level_138
dw midway_tables_level_139
dw midway_tables_level_13A
dw midway_tables_level_13B

freedata
gradients:
;=======================================
; Scrolling Gradient
; Channels: Red, Green, Blue
; Table Size: 293
; No. of Writes: 464
;
; Generated by GradientTool
;=======================================
sky_hdma_table:
db $2D,$26,$48,$8D
db $01,$26,$49,$8D
db $06,$26,$49,$8E
db $05,$27,$4A,$8E
db $03,$27,$4A,$8F
db $07,$27,$4B,$8F
db $01,$27,$4C,$8F
db $07,$27,$4C,$90
db $05,$27,$4D,$90
db $03,$27,$4D,$91
db $07,$27,$4E,$91
db $01,$27,$4F,$91
db $07,$27,$4F,$92
db $04,$27,$50,$92
db $03,$27,$50,$93
db $08,$27,$51,$93
db $08,$27,$52,$94
db $04,$27,$53,$94
db $03,$27,$53,$95
db $04,$27,$54,$95
db $08,$28,$54,$95
db $03,$29,$54,$95
db $01,$29,$55,$95
db $04,$29,$55,$96
db $08,$2A,$55,$96
db $05,$2B,$55,$96
db $03,$2B,$56,$96
db $08,$2C,$56,$96
db $07,$2D,$56,$97
db $01,$2D,$57,$97
db $08,$2E,$57,$97
db $08,$2F,$57,$97
db $04,$30,$57,$97
db $05,$30,$58,$97
db $09,$31,$58,$97
db $09,$32,$58,$98
db $05,$33,$58,$98
db $04,$33,$59,$98
db $09,$34,$59,$98
db $0B,$35,$59,$98
db $02,$36,$59,$98
db $0B,$36,$5A,$98
db $0C,$37,$5A,$98
db $04,$38,$5B,$98
db $08,$38,$5B,$99
db $0B,$39,$5B,$99
db $01,$39,$5C,$99
db $0C,$3A,$5C,$99
db $09,$3B,$5C,$99
db $03,$3B,$5D,$99
db $0C,$3C,$5D,$99
db $08,$3D,$5D,$99
db $04,$3D,$5E,$99
db $04,$3E,$5E,$99
db $02,$3E,$5E,$9A
db $0D,$3E,$5E,$99
db $0F,$3F,$5E,$99
db $02,$3F,$5D,$98
db $04,$3E,$5D,$98
db $02,$3E,$5C,$98
db $04,$3E,$5C,$97
db $01,$3D,$5C,$97
db $02,$3D,$5B,$97
db $04,$3D,$5B,$96
db $03,$3D,$5A,$96
db $03,$3C,$5A,$95
db $04,$3C,$59,$95
db $03,$3C,$59,$94
db $05,$3B,$58,$94
db $01,$3B,$58,$93
db $05,$3B,$57,$93
db $01,$3A,$57,$93
db $25,$3A,$56,$92
db $00
