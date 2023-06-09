incsrc "../main.asm"
check bankcross on

!SlopeNormalRight_LowerDirtCornerTile = $C9    ; page 0
!SlopeGradualRight_LowerDirtCornerTileL = $CA  ; page 0
!SlopeGradualRight_LowerDirtCornerTileR = $CB  ; page 0

!SlopeGradualLeft_LowerDirtCornerTileL = $CC   ; page 0
!SlopeGradualLeft_LowerDirtCornerTileR = $CD   ; page 0

!SlopeNormUpsdLeft_LowerDirtCornerTile = $E7   ; page 1

!edge_tile_slope_intersect_l = $4B             ; page 3
!edge_tile_slope_intersect_r = $4C             ; page 3

Sta1To6ePointer      = $0DAA08
StzTo6ePointer       = $0DAA0D
StoreLoShiftObjRight = $0DA95B
ShiftObjRightOrig    = $0DA95D
ShiftObjDownOrig     = $0DA97D
BackupMap16Lo        = $0DA6B1
RestoreMap16Lo       = $0DA6BA

YoshiHouseLedgeObjRt = $0DF02B

%replace_pointer_long($0DA28C|!bank,pipe_square|!bank)

%replace_pointer_long($0DA497|!bank,new_cloud_rope_obj_code|!bank)

%replace_pointer_long($0DC1DC|!bank,new_cloud_rope_obj_code|!bank)

%replace_pointer_long($0DCDDC|!bank,new_cloud_rope_obj_code|!bank)

%replace_pointer_long($0DD9DC|!bank,new_cloud_rope_obj_code|!bank)

%replace_pointer_long($0DE8DC|!bank,new_cloud_rope_obj_code|!bank)

; object 1C: replace donut bridge with grassland bush objs
%replace_pointer_long($0DD9EB|!bank,$0DB5B7|!bank)

; vertpipe -> left diag ledge
%replace_pointer_long($0DD9F4|!bank,$0DB7AA|!bank)
; horiz pipe -> right diag ledge
%replace_pointer_long($0DD9F7|!bank,$0DB863|!bank)

; object 2E:
%replace_pointer_long($0DDA21|!bank,$0DF066|!bank)
; object 2F: Steep line guide slopes
%replace_pointer_long($0DDA24|!bank,$0DD070|!bank)
; object 30: extra grassy ledge
%replace_pointer_long($0DDA27,YoshiHouseLedgeObjRt|!bank)
; object 32: jellyfish (xy stretch)
%replace_pointer_long($0DDA2D|!bank,$0DBB63|!bank)
; object 33: line guide slopes
%replace_pointer_long($0DDA30|!bank,$0DCF53|!bank)

%replace_pointer_long($0DD9F1,net_edge_obj|!bank)

;replaces yoshi coins
%replace_pointer_long($0DA1D2,vert_key_lock_block|!bank)

!single_remap_counter #= $00
while !single_remap_counter < $30
  ; green star block
  if !single_remap_counter != $07
    !val #= !single_remap_counter*3
    %replace_pointer_long($0DA13F+!val,single_tile_objs|!bank)
  endif
  !single_remap_counter #= !single_remap_counter+1
endif

!single_remap_counter #= $00
while !single_remap_counter < $0E
  !val #= !single_remap_counter*3
  %replace_pointer_long($0DD99A+!val|!bank,square_objs_routine|!bank)
  !single_remap_counter #= !single_remap_counter+1
endif


; random junk to imem blocks
%replace_pointer_long($0DA220|!bank,single_tile_objs|!bank)
%replace_pointer_long($0DA223|!bank,single_tile_objs|!bank)
%replace_pointer_long($0DA226|!bank,single_tile_objs|!bank)

; ghost house square objects
; index 02 is used as jellyfish on page 1, via object 32
org $0DECC6|!bank
	db $92,$5E,$BF

; bushes, now object 1C
org $0DB5A8|!bank
bush_left:
	db $4B,$4E,$56,$55,$C3
bush_center:
	db $4C,$4F,$56,$55,$C3
bush_right:
	db $4D,$50,$56,$55,$C3
warnpc $0DB5B7|!bank

; use index 0F of 1x1 objects for red coins (new, this was added: originally went up to 0E)
; instead of the actual purple coin obj code.
org $0DB336|!bank
	LDX.b #$0F
	JMP.w square_objs_routine_no_loadx

org $0DBB65|!bank
	JMP.w square_objs_routine_no_loadx

org $0DEC66|!bank
	db $FD,$FC

org $0DE957             ; extended objects 57 through 5E: originally some random junk on page 0
; priority tree branch left, right
db $C3,$C4
; smb2 vine top, bottom
db $53,$54
; coin blocks
db $B1,$B2,$B3

org $0DB3BB             ; table of tiles on page 1 for object 17. Up to 16 entries
obj_17_tiles:
	db $05,$06,$2F,$10,$10,$53,$55,$56
	db $FF,$FF,$FF,$FF,$FF,$FF,$08,$09
warnpc $0DB3CB

warnpc $0DB3DB          ; 0x1F bytes free


org $0DABF8             ; \ change tile for slopes
	db $EA          ; | to turn into grass bg
                        ; |
org $0DABFB             ; |
	db $01          ; /


; Normal slope right lower dirt tile
org $0DAD69
	JSR StzTo6ePointer
	LDA #!SlopeNormalRight_LowerDirtCornerTile

; Gradual slope right lower dirt tile L
org $0DAE0E
	JSR StzTo6ePointer
	LDA #!SlopeGradualRight_LowerDirtCornerTileL

; Gradual slope right lower dirt tile R
org $0DAE16
	JSR StzTo6ePointer
	LDA #!SlopeGradualRight_LowerDirtCornerTileR

; Gradual slope left lower dirt tile L
org $0DACDF
	JSR StzTo6ePointer
	LDA #!SlopeGradualLeft_LowerDirtCornerTileL

; Gradual slope left lower dirt tile R
org $0DACE7
	JSR StzTo6ePointer
	LDA #!SlopeGradualLeft_LowerDirtCornerTileR

; Upside down normal slope left lower dirt tile
; page 1
org $0DAEA9
	LDA #!SlopeNormUpsdLeft_LowerDirtCornerTile

org $0DAC4F
	JSR slope_dirt_store
	NOP #2

org $0DADBE
	JSR slope_dirt_store
	NOP #2

; edge bottom corner tiles
; sadly, it's much easier to keep these on page 1.
org $0DB071
	db $0A, $0A, $0B, $0B

; 4 sided square object - left side tile
org $0DE12D
	db $4B
; 4 sided square object - center tile
; page 1
org $0DE130
	db $65

org $0DE133
	db $4C

org $0DE151
	JMP ground_square_left_tiles
	NOP
ground_square_left_tiles_done:
org $0DE16C
	JMP ground_square_right_tiles
	NOP
ground_square_right_tiles_done:

org $0DE9E9
	db $9C,$9D,$9A,$9B

org $0DB2CA
vert_key_lock_block:
	LDY !object_load_pos
	JSL read_item_memory
	BNE .no_draw
	LDA #$03
	STA [$6E],y
	LDA #$2D
	STA [$6B],y
	JSR ShiftObjDownOrig
	LDA #$03
	STA.b [$6E],y
	LDA #$2E
	STA.b [$6B],y
.no_draw
	RTS
warnpc $0DB335

org $0DDA42
dl LavaSlopesJumpTable|!bank     ; frees up 20 bytes @ 0DDAF2; moved to free space at the end of bank 0D

org $0DDCBC
lava_ledge_top:
	LDA $00
	STA $0D
	CPX #$39
	BNE draw_ledge_only_inner
draw_ledge:
	JSR GetLavaSlopeTileIndexL
	JSR LavaLedgeObjSetTile
	DEC $0D
	BPL draw_ledge
	BRA lava_ledge_finish
.only_inner:
	JSR GetLavaSlopeTileIndexL
	INX : INX
	JSR LavaLedgeObjSetTile
	DEC $0D
	BPL .only_inner
	NOP
warnpc $0DDCDD
org $0DDCDD
lava_ledge_finish:
org $0DDCE7
BPL lava_ledge_top


org $0DDC17
	JMP LavaSlopeChunkNormR_lower
org $0DDC5E
	JMP LavaSlopeChunkNormR_compare

org $0DDC3D
	JMP LavaSlopeChunkNormR_lower

org $0DDB1B
	JMP LavaSlopeChunkNormL              ; relocate the code for left lava slope to freespace at the end of bank 0d.
LavaSlopeChunkNormR:                         ; use the free'd space for hacks to the right lava slope
-
	JSR LavaRepTile
	DEX
.compare
	CPX.B #$03
	BNE -
	PHX                           ; no space left here, so we use smaller opcodes
	JSR GetLavaSlopeTileIndexN
	INX #4
	JSR StoreLavaSlopeChunkNrm
	PLX
	JMP $DC37
.lower
	JSR GetLavaSlopeTileIndexN
	STX $0F
	JSR StoreLavaSlopeChunkNrm
	JMP $DC4D
	warnpc $0DDB42
org $0DDB8B
	JMP LavaSlopeChunkNormL_lower
org $0DDB45
	JMP LavaTileFinal


org $0DDBA4
LavaSlopeChunkSteepL:
	JSR GetLavaSlopeTileIndexS
	STX $0F
	JSR StoreLavaSlopeChunkSteep
	LDX $02
.lower
	DEX
	BMI .next
	LDX $0F : INX #2
	JSR StoreLavaSlopeChunkSteep
	LDX $02
	DEx
	BRA .loop_start
.loop:
	JSR LavaRepTile_alt
.loop_start:
	DEX
	BPL .loop
	BRA +
	NOP #2
+
	warnpc $0DDBC7
org $0DDBC7
.next:
org $0DDBFE
	JMP LavaSlopeChunkSteepL_lower

org $0DDC76
	JMP LavaSlopeChunkSteepR_lower
LavaSlopeChunkSteepR:
-
	JSR LavaRepTile_alt
	DEX
.compare
	CPX #$01
	BNE -
	JSR StoreLavaSlopeChunkSteep_alt
.lower
	LDA $00
	BNE +
	RTS
+
	JSR GetLavaSlopeTileIndexS
	STX $0F
	JSR StoreLavaSlopeChunkSteep
	JMP $DC9A
	warnpc $0DDC96

org $0DDCA6
	JMP SteepLoopBegin

org $0DDD54
	JMP bottom_edge_obj_override
	NOP : NOP : NOP : NOP : NOP      ; these 5 bytes are now technically free

org $0DF300           ; this overwrites all the credits enemy names
;org $0DFCEB          ; 788 bytes free here
LavaSlopeChunkNormL:  ; $02 is used as the 'width' throughout this object code
	LDX $02
	STX $0E
	JSR GetLavaSlopeTileIndexN
	STX $0F
	JSR StoreLavaSlopeChunkNrm
	LDX $02
	DEX : DEX
	STX $0E
	BMI +
	BRA .no_reload_x
.lower:
	STX $0E
.no_reload_x:
	LDX $0F
	INX #4
	JSR StoreLavaSlopeChunkNrm
	LDX $0E
	DEX
	JMP $DB4D
+
	JMP $DB50

LavaTileFinal:
	JSR LavaRepTile
	JMP $DB4D

GetLavaSlopeTileIndexN:
	LDX #$00
	LDA !sprite_memory_header
	AND #!level_status_flag_lava_slope_toggle
	BEQ +
	LDX #$20
+
	LDA !object_dimensions
	AND #$03
	BEQ +
	TXA
	CLC
	ADC #$08
	TAX
+
	LDA [$6B],y
	CMP #$EA
	BNE +
	TXA
	CLC : ADC #$10
	TAX
+
	RTS

GetLavaSlopeTileIndexS:
	LDX #$00
	LDA !sprite_memory_header
	AND #!level_status_flag_lava_slope_toggle
	BEQ +
	LDX #$08
+
	LDA !object_dimensions
	AND #$03
	CMP #$01
	BEQ +
	TXA
	CLC
	ADC #$04
	TAX
+
	RTS

GetLavaSlopeTileIndexL:
	LDX #$00
	LDA !sprite_memory_header
	AND #!level_status_flag_lava_slope_toggle
	BEQ +
	INX #4
+
	RTS

StoreLavaSlopeChunkNrm:
	LDA .norm_lava_slope_tiles_data,x
	STA [$6B],y
	LDA .norm_lava_slope_tiles_data+1,x
	STA [$6E],y
	JSR ShiftObjRightOrig
	LDA .norm_lava_slope_tiles_data+2,x
	STA [$6B],y
	LDA .norm_lava_slope_tiles_data+3,x
	STA [$6E],y
	JSR ShiftObjRightOrig
	RTS
.norm_lava_slope_tiles_data:
	dw $02E8, $02E9, $02F8, $00EA     ; alternate slope left
	dw $02EA, $02EB, $00EA, $02FB     ; alternate slope right
	dw $020A, $020B, $02F8, $00EA     ; alternate slope left - grass bg
	dw $020C, $020D, $00EA, $02FB     ; alternate slope right - grass bg
	dw $01D2, $01D3, $01FB, $01FF     ; lava slope left
	dw $01D4, $01D5, $01FF, $01FC     ; lava slope right

StoreLavaSlopeChunkSteep:
	LDA .steep_lava_slope_tiles_data,x
	STA [$6B],y
	LDA .steep_lava_slope_tiles_data+1,x
	STA [$6E],y
	JSR ShiftObjRightOrig
	RTS
.alt
	LDX $0F
	INX #2
	BRA StoreLavaSlopeChunkSteep
.steep_lava_slope_tiles_data:
	dw $02EC, $02FC
	dw $02ED, $02FD
	dw $01D6, $01FD
	dw $01D7, $01FE
LavaRepTile:
	STX $0D
	LDA $0F
	LSR
	BRA +
.alt
	STX $0D
	LDA $0F
+
	LSR
	TAX
	LDA .tiles,x
	STA [$6B],y
	LDA .tiles+1,x
	STA [$6E],y
	JSR ShiftObjRightOrig
	LDX $0D
	RTS
.tiles:
	dw $00EA,$00EA,$01FF,$01FF
SteepLoopBegin:
	BPL .next
	RTS
.next:  JMP LavaSlopeChunkSteepR_compare

LavaSlopesJumpTable:
	LDA $59
	AND #$03
	ASL
	TAX
	PHB : PHK : PLB               ; the data bank pointer isnt 0D here, so patch that up
	JSR (.slope_ptrs,x)     ; as the hijacks use tables
	PLB : RTS
.slope_ptrs
	dw $DB06  ; normal left
	dw $DB8F  ; steep left
	dw $DC02  ; normal right
	dw $DC61  ; steep right

LavaLedgeObjSetTile:
	LDA.l .tiles,x
	STA [$6B],y
	LDA.l .tiles+1,x
	STA [$6E],y
	JSR ShiftObjRightOrig
	RTS
.tiles:
dw $0107,$00EA
dw $0159,$01FF

ground_square_left_tiles:
	LDA [$6B],y
	CMP #$25
	BNE +
	LDA.L $0DE12C,x
	JMP ground_square_left_tiles_done
+
	LDA.L .tile_behind_left_table,x
	JMP ground_square_left_tiles_done
.tile_behind_left_table
	db $46,$50,$66

ground_square_right_tiles:
	LDA [$6B],y
	CMP #$25
	BNE +
	LDA.L $0DE132,x
	JMP ground_square_right_tiles_done
+
	LDA.L .tile_behind_right_table,x
	JMP ground_square_right_tiles_done
.tile_behind_right_table
	db $49,$51,$67

bottom_edge_obj_override:
	LDA [$6B],y
	CMP #$25
	BNE +
	LDA.l $0DDD2A,x
	JMP $A95B
+
	LDA.l .tiles,x
	JMP $A95B
.tiles
	db $66,$50,$67,$51

new_cloud_rope_obj_code:
	LDY !object_load_pos
	LDA !object_dimensions
	AND #$0F
	STA $00
	LDA !object_dimensions
	LSR #4
	TAX
.draw_more
	LDA #$01
	CPX #$0E                    ; \ Handle type E and F specially
	BCS .handle_lineguides      ; /
;	CPX #$05                    ; \ 5 through D go on page 3
;	BCC .cont                   ; |
;	LDA #$03                    ; /
.cont
	STA [$6E],y
	LDA.l obj_17_tiles,x
.finish_tile
	JSR StoreLoShiftObjRight
	DEC $00
	BPL .draw_more
	RTS
.handle_lineguides
	LDA #$00
	STA [$6E],y
	LDA.l .line_guide_real_tiles-$0E,x
	BRA .finish_tile
.line_guide_real_tiles
	db $92, $93

obj_setup_sizes:
	LDA $59
	AND #$0F
	STA $00
	LDA $59
	LSR #4
	STA $01
	RTS
pushpc
org $0DA8B4
square_objs_low_bytes:
	db $DE,$21,$CF,$2A,$2B,$DD,$FF,$13
	db $1E,$24,$2E,$54,$30,$32,$2C,$2C
square_objs_routine:
	LDX $5A
	DEX
.no_loadx
	LDY $57
	JSR obj_setup_sizes
	LDA $00
	STA $02
	JSR BackupMap16Lo
.loop:
	LDA.l .uses_item_mem,x
	BEQ .no_item_mem
	JSL read_item_memory|!bank
	BEQ .no_item_mem
	LDA.l .uses_item_mem,x
	BPL .dont_draw
	LDA #$01
	STA.B [$6E],y
	LDA #$32
	BRA .draw_low_finish
.no_item_mem:
	LDA.l .square_objs_high_bytes,x
	STA   [$6E],y
	LDA.l square_objs_low_bytes,x
.draw_low_finish:
	STA  [$6B],y
.dont_draw:
	JSR ShiftObjRightOrig
	DEC $02
	BPL .loop
	JSR RestoreMap16Lo
	JSR ShiftObjDownOrig
	LDA $00
	STA $02
	DEC $01
	BPL .loop
	RTS

warnpc $0DA95B|!bank
pullpc
; a negative value spawns a brown block, a positive one doesn't draw anything.
; zero doesn't use item memory
; TODO throw block doesnt seem to set item memory, perhaps remedy this
.uses_item_mem:
	db $00,$80,$01,$00,$01,$00,$01,$00
	db $01,$80,$01,$00,$01,$01,$00,$01
; note: lunar magic will use 0 as the map16 page for indices 0-6
; and 1 for the others regardless of what is here
.square_objs_high_bytes:
	db $00,$00,$03,$00,$00,$00,$00,$01
	db $01,$01,$01,$03,$01,$01,$01,$00

pushpc
org $0DA548
SingleTileExtTiles:
	db $B4,$22,$24,$42,$43,$B5,$29,$25  ; extended objs 10-17 (object 17 actually uses index 32?)
	db $6E,$B6,$B7,$B8,$B9,$Ba,$Bb,$Bc  ; extended objs 18-1F
	db $Bd,$Be,$Bf,$11,$12,$14,$15,$16  ; extended objs 20-27
	db $17,$18,$19,$1A,$1B,$1C,$29,$1D  ; extended objs 28-2F
	db $1F,$20,$21,$22,$23,$25,$26,$27  ; extended objs 30-37
	db $28,$2A,$DE,$E0,$E2,$E4,$EC,$ED  ; extended objs 38-3F
	db $2C,$25,$2D                      ; extended objs 40, 41 (unused here), and the green star block
	skip $14
	db $FF,$FF,$FF,$FF,$B1,$B2,$B3,$FF  ; extended obj 57-5E
single_tile_objs:
	TXA
	SEC : SBC #$10
.green_star_entry:
	STA $00
	LDY !object_load_pos
	LDX $00
	LDA.l .tiles_high_byte,x
	STA [$6E],y
	LDA.l SingleTileExtTiles,x
	STA [$6B],y
	LDA.l .use_item_memory,x
	STX $0E
	BEQ .finish
	CPX #$1B
	BNE .do_item_mem
	TYA : AND #$0F
	CMP #$01 : BEQ .do_item_mem
	CMP #$04 : BEQ .do_item_mem
	CMP #$07 : BEQ .do_item_mem
	CMP #$0A : BEQ .do_item_mem
	CMP #$0D : BNE .finish
.do_item_mem
	JSL read_item_memory
	BEQ .finish
	CPX.B #$07
	BEQ .finish
	LDX $0E
	LDA.l .filled_tiles_high_byte,x
	STA [$6E],y
	LDA.l .filled_tiles_low_byte,x
	STA [$6B],y
.finish:
	RTS
warnpc $0DA64D

org $0DA64D
	LDA #$32
	JMP single_tile_objs_green_star_entry
pullpc
	
.tiles_high_byte:      ; extended objects 10 through 22 will use page 0, the rest will use page 1 (in LM)
db $00,$00,$00,$00,$00,$00,$00,$00     ; extended objs 10-17 (object 17 actually uses index 32?)
db $00,$00,$00,$00,$00,$00,$00,$00     ; extended objs 18-1F
db $00,$00,$00,$01,$03,$01,$01,$01     ; extended objs 20-27
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 28-2F
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 30-37
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 38-3F
db $01,$01,$01                         ; extended objs 40, 41 (unused here), and the green star block.
skip $14
db $00,$00,$00,$00,$00,$00,$00,$00     ; extended obj 57-5E

.use_item_memory:
db $01,$01,$00,$00,$00,$01,$00,$00     ; extended objs 10-17 (object 17 actually uses index 32?)
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 18-1F
db $01,$01,$00,$01,$00,$01,$00,$00     ; extended objs 20-27
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 28-2F
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 30-37
db $01,$01,$00,$00,$00,$00,$00,$00     ; extended objs 38-3F
db $00,$00,$01                         ; extended objs 40,41 (unused here), and the green star block.
skip $14
db $00,$00,$00,$00,$01,$01,$01,$00     ; extended obj 57-5E


.filled_tiles_high_byte
db $01,$01,$01,$00,$00,$01,$00,$01     ; extended objs 10-17 (object 17 actually uses index 32?)
db $00,$01,$01,$01,$01,$01,$01,$01     ; extended objs 18-1F
db $01,$01,$00,$01,$03,$01,$00,$00     ; extended objs 20-27
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 28-2F
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 30-37
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended objs 38-3F
db $01,$01,$01                         ; extended objs 40, 41 (unused here), and the green star block.
skip $14
db $01,$01,$01,$01,$01,$01,$01,$01     ; extended obj 57-5E

.filled_tiles_low_byte
db $32,$32,$13,$00,$00,$32,$00,$32     ; extended objs 10-17 (object 17 actually uses index 32?)
db $25,$32,$32,$32,$32,$32,$32,$32     ; extended objs 18-1F
db $32,$32,$00,$13,$00,$32,$00,$00     ; extended objs 20-27
db $32,$32,$32,$32,$32,$32,$32,$32     ; extended objs 28-2F
db $32,$32,$32,$32,$32,$32,$32,$32     ; extended objs 30-37
db $32,$32,$00,$00,$00,$00,$00,$00     ; extended objs 38-3F
db $00,$00,$32                         ; extended objs 40, 41 (unused here), and the green star block.
skip $14
db $32,$32,$32,$32,$32,$32,$32,$32     ; extended obj 57-5E

; objs 18-1B override
pushpc
org $0DB3DB
top_18_to_1b_top_tile:
	db $E6,$E2,$04,$08
top_18_to_1b_fill_tile:
	db $E4,$E0,$05,$0B
;org $0DB3FD
;	JSR set_18_to_1b_high_byte
org $0DB404
	JSR check_18_to_1b_add
;org $0DB40E
;	JSR set_18_to_1b_high_byte
org $0DB415
	JSR check_18_to_1b_add
pullpc

;set_18_to_1b_high_byte:
;	LDA.l .hi_tiles,x
;	STA [$6E],y
;	RTS
;.hi_tiles
;	db $03,$03,$00,$00
check_18_to_1b_add:
	STA $0F
	CLC : ADC #$02
	STA $0E
	LDA [$6B],y
	CMP #$25
	BEQ .noadd
	CMP $0E
	BEQ .noadd
	CMP $0F
	BEQ .noadd
	LDA.l .offsets,x
	CLC : ADC $0F
	BRA .done
.noadd
	LDA $0F
.done
	JSR StoreLoShiftObjRight
	RTS
.offsets
	db $01,$01,$00,$00

pushpc
org $0DDA9E
pipe_square_tiles:
	db $0C,$0D,$0E,$58
warnpc $0DDAC4
pullpc
pipe_square:
	LDY !object_load_pos
	LDX #$00
	JSR BackupMap16Lo
.loop
	LDA [$6B],y
	CMP #$25
	BEQ +
	LDA #$01
	BRA ++
+
	LDA #$03
++
	STA [$6E],y
	LDA.l pipe_square_tiles,x
	JSR StoreLoShiftObjRight
	INX
	TXA
	AND #$01
	BNE .loop
	JSR RestoreMap16Lo
	JSR ShiftObjDownOrig
	CPX #$04
	BNE .loop
	RTS

pushpc
org $0DB112
	db #!edge_tile_slope_intersect_l
	db #!edge_tile_slope_intersect_r
org $0DB155
JMP edge_obj_corner_override
pullpc
edge_obj_corner_override:
	CPX #$10
	BEQ .put_page_3
	CPX #$11
	BNE .norm
.put_page_3
	LDA #$03
	STA [$6E],y
.norm
	LDA.L $0DB102,x
	JMP $B159

pushpc
org $0DB49C
net_obj_tiles:
	db $0A,$0C
	db $90,$91
	db $9F,$D0
pullpc
net_edge_obj:
	LDY !object_load_pos
	LDA !object_dimensions
	LSR #4
	STA $00
	LDA !object_dimensions
	AND #$0F
	TAX
	JSR tile_get
	JSR $B4D9
	JMP $B4C0
pushpc
org $0DB4BA
	JSR tile_get : NOP
org $0DB4CE
	JSR tile_get : NOP
pullpc
tile_get:
	CPX #$04
	BCC .no_imem
	JSL read_item_memory
	BEQ .no_imem
	LDA.L net_obj_tiles,x
	CLC : ADC.l net_imem_set_off,x
	BRA .tile_done
.no_imem
	LDA.L net_obj_tiles,x
.tile_done
	RTS

net_imem_set_off:
	db $00,  $00
	db $00,  $00
	db $0-$99

slope_dirt_store:
	LDA !sprite_memory_header
	AND #!level_status_flag_slope_no_dirt
	BNE +
	LDA #$3F
	JMP StoreLoShiftObjRight
+
	JMP ShiftObjRightOrig

pushpc
; midway/goal stuff
org $0DB24B|!bank
	JSR.w midway_goal_obj_flip_on_header|!bank
org $0DB275|!bank
	JSR.w midway_goal_obj_flip_on_header|!bank
org $0DB29F|!bank
	JSR.w midway_goal_obj_flip_on_header|!bank
pullpc
midway_goal_obj_flip_on_header:
	LDA !sprite_memory_header
	AND #!level_status_flag_goal_move_left
	BNE .backwards
	STA [$6E],y
	RTS
.backwards:
	LDA.b #$03
	STA [$6E],y
	RTS

pushpc
; left diag plat - bg grass (page 0; sloped portion)
org $0DB7ED|!bank
lda #$ea
; left diag plat - bg grass (page 0; remaining portion)
org $0DB831|!bank
lda #$ea

; left diag plat - top slope tile
org $0DB7C3|!bank
	lda #$02
	sta [$6E],y
	lda #$EC
	sta [$6B],y
	jsr.w StoreLoShiftObjRight

org $0DB7D6|!bank
	jsr.w sta2to6eptr
	lda #$ec
org $0DB7DF|!bank
	jsr.w sta2to6eptr
	lda #$fc

; right diag plat - top slope tile
org $0DB884|!bank
	jsr.w sta2to6eptr
	lda #$ed

; right diag plat - slope dirt
org $0DB89D|!bank
	lda #$ea

; right diag plat - slope assist tiles
org $0DB8A7|!bank
	jsr.w sta2to6eptr
	lda #$fd

; right diag plat - remaining dirt (1?)
org $0DB8D8|!bank
	lda #$ea

; right diag plat - remaining dirt (2?)
org $0DB8F9|!bank
	lda #$ea

; right diag plat - remaining slope
org $0DB8AF|!bank
	jsr.w sta2to6eptr
	lda #$ed

pullpc
sta2to6eptr:
	lda #$02
	sta [$6E],y
	rts
;grassslopebacktilechk:

print "bank 0D end location: $",pc
