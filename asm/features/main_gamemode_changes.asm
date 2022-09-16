incsrc "../main.asm"

org $00FFD8
if !use_midway_imem_sram_dma == !true
	db $04       ; 16kb sram
else
	db $01       ; 2kb sram
endif


; these are just missed by LM's fastrom patch i guess?
;org $00A299|!bank
;	JSL $00F6DB|!bank
;	JSL $05BC00|!bank
;	JSL $0586F1|!bank

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

org $009468|!bank
gamemode_19:
autoclean \
	JSL.l gm19
	RTS

freedata
gm19:
	; setup next game mode
	LDA.b #$10
	STA.w !gamemode

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
