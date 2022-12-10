@includefrom objectool.asm
includeonce

!object_position    = $57
!object_argument    = $58
!object_dimensions  = $59
!ext_obj_type       = $59
!object_number      = $5A

!scratch_obj_xpos   = $06
!scratch_obj_ypos   = $07
!scratch_obj_width  = $08
!scratch_obj_height = $09


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; code for extended objects 98-FF
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!2x2_exobjs_start = $98
!3x3_exobjs_start = $A2
!cluster_exobjs_start = $A6

CustExObj98:
CustExObj99:
CustExObj9A:
CustExObj9B:
CustExObj9C:
CustExObj9D:
CustExObj9E:
CustExObj9F:
CustExObjA0:
CustExObjA1:
	LDA !ext_obj_type
	SEC : SBC #!2x2_exobjs_start
	JMP Objects2x2
CustExObjA2:
CustExObjA3:
CustExObjA4:
CustExObjA5:
	LDA !ext_obj_type
	SEC : SBC #!3x3_exobjs_start
	JMP Objects3x3
; 'cluster' objects of arbitrary size follow.
; These can also be drawn with object 2D/A
CustExObjA6:
CustExObjA7:
CustExObjA8:
CustExObjA9:
CustExObjAA:
CustExObjAB:
CustExObjAC:
CustExObjAD:
CustExObjAE:
CustExObjAF:
CustExObjB0:
CustExObjB1:
CustExObjB2:
CustExObjB3:
	LDA !ext_obj_type
	SEC : SBC #!cluster_exobjs_start
	JMP ClusterExObjects
CustExObjB4:
CustExObjB5:
CustExObjB6:
CustExObjB7:
CustExObjB8:
CustExObjB9:
CustExObjBA:
CustExObjBB:
CustExObjBC:
CustExObjBD:
CustExObjBE:
CustExObjBF:
CustExObjC0:
CustExObjC1:
CustExObjC2:
CustExObjC3:
CustExObjC4:
CustExObjC5:
CustExObjC6:
CustExObjC7:
CustExObjC8:
CustExObjC9:
CustExObjCA:
CustExObjCB:
CustExObjCC:
CustExObjCD:
CustExObjCE:
CustExObjCF:
CustExObjD0:
CustExObjD1:
CustExObjD2:
CustExObjD3:
CustExObjD4:
CustExObjD5:
CustExObjD6:
CustExObjD7:
CustExObjD8:
CustExObjD9:
CustExObjDA:
CustExObjDB:
CustExObjDC:
CustExObjDD:
CustExObjDE:
CustExObjDF:
CustExObjE0:
CustExObjE1:
CustExObjE2:
CustExObjE3:
CustExObjE4:
CustExObjE5:
CustExObjE6:
CustExObjE7:
CustExObjE8:
CustExObjE9:
CustExObjEA:
CustExObjEB:
CustExObjEC:
CustExObjED:
CustExObjEE:
CustExObjEF:
	RTS
CustExObjF0:
	JSR BackUpPtrs
	LDY !object_load_pos
	LDX #$00
.loop
	STZ !ObjScratch
	LDA #$03
	STA [$6E],y

	LDA [$6B],y
	CMP #$25
	BNE .not_empty
	LDA #$F0
	STA !ObjScratch
.not_empty:
	LDA .pipe_square_tiles,x
	CLC
	ADC !ObjScratch
	STA [$6B],y
	JSR ShiftObjRight
	INX
	TXA
	AND #$01
	BNE .loop
	JSR RestorePtrs
	JSR ShiftObjDown
	CPX #$04
	BNE .loop
	RTS

.pipe_square_tiles:
	db $6C,$6D,$6E,$6F
; midways
CustExObjF1:
CustExObjF2:
CustExObjF3:
CustExObjF4:
CustExObjF5:
midway_bar_ext_objs:
	LDA !ext_obj_type
	SEC
	SBC #$F0
	TAX
	CMP !midway_flag
	BNE .cont
	; don't draw anything if this midway is active
	RTS
.cont:
	LDY !object_position

	LDA !sprite_memory_header
	BIT #!level_status_flag_goal_move_left
	BNE .backwards
.midway_not_active:
	LDA #$35
	STA [$6B],y
	LDA #$00
	STA [$6E],y
	JSR ShiftObjRight
	LDA .tiles_bar-1,x
	STA [$6B],y
	LDA #$00
	STA [$6E],y
	RTS
.tiles_bar:
	db $D0,$D1,$D2,$D3,$D4
.backwards:
	JSR ShiftObjRight
	LDA .tiles_bar-1,x
	STA [$6B],y
	LDA #$00
	STA [$6E],y
	JSR ShiftObjRight
	LDA #$35
	STA [$6B],y
	LDA #$03
	STA [$6E],y
	RTS
CustExObjF6:
CustExObjF7:
	RTS
; 7 square ice blocks: draw if flag unset
CustExObjF8:
	LDA !level_state_flags_curr
	AND.b #%00000001
	BEQ CustExObjF9
	LDA.b #$03
	BRA CustExObjF9_draw
; 7 square ice blocks: always draw
CustExObjF9:
	LDA #$07
.draw:
	STA.b $0A  ; loop counter

	LDY !object_position
	JSR BackUpPtrs
	LDX.b #$00
.loop:
	LDA .tbl,x
	STA.b [$6B],y
	LDA.b #$04
	STA.b [$6E],y
	JSR ShiftObjRight
	INX
	LDA .tbl,x
	STA.b [$6B],y
	LDA.b #$04
	STA.b [$6E],y
	DEC $0A
	BMI .done
	JSR RestorePtrs
	JSR ShiftObjDown
	INX
	LDA .tbl,x
	STA.b [$6B],y
	LDA.b #$04
	STA.b [$6E],y
	JSR ShiftObjRight
	INX
	LDA .tbl,x
	STA.b [$6B],y
	LDA.b #$04
	STA.b [$6E],y
	DEC $0A
	BMI .done
	JSR RestorePtrs
	JSR ShiftObjDown
	LDX #$00
	BRA .loop
.done
	RTS
.tbl:
	db $9C,$9D,$AC,$AD
; object drawn if bit 0 of !level_state_flags_curr is set:
; ice block bridge, 16 tiles (1 screen) wide
CustExObjFA:
	LDA !level_state_flags_curr
	AND.b #%00000001
	BEQ .no_draw
	LDA.b #$26
	STA !ObjScratch+0
	STZ !ObjScratch+1

	LDY !object_position
	JSR BackUpPtrs
	LDA.b #$01
	STA.b $0B
	LDA.b #$0F
	STA.b $0A
.loop:
	LDA !ObjScratch+0
	STA [$6B],y
	LDA !ObjScratch+1
	STA [$6E],y
	JSR ShiftObjRight
	DEC $0A
	BPL .loop
	JSR RestorePtrs
	DEC $0B
	BMI .no_draw
	JSR ShiftObjDown
	LDA.b #$0F
	STA.b $0A
	LDA.b #$BE
	STA !ObjScratch+0
	LDA.b #$04
	STA !ObjScratch+1
	BRA .loop
.no_draw:
	RTS
CustExObjFB:
	LDA #$0D
	JMP Objects2x2
CustExObjFC:
	LDA #$0C
	JMP Objects2x2
CustExObjFD:
	LDA #$0B
	JMP Objects2x2
CustExObjFE:
	LDA #$0A
	JMP Objects2x2
; tree platform
CustExObjFF:
	LDY !object_position

	LDA #$05
	STA [$6E],y
	LDA #$79
	STA [$6B],y
	JSR ShiftObjRight
	LDA #$05
	STA [$6E],y
	LDA #$7A
	STA [$6B],y
	JSR ShiftObjRight
	LDA #$05
	STA [$6E],y
	LDA #$7B
	STA [$6B],y
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; code for normal objects 00-FF (actually object 2D in the editor)
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mush_plat_tiles:
	dw $0200, $0201, $0202      ; left, center, right
	dw $0203                    ; stem directly below the platform
	dw $0204                    ; stem
; 00 - a mushroom platform from smb1
; the argument shifts the position of the stem from the center
CustObj00:
	LDX #$00

	REP #$30
	LDA.w mush_plat_tiles
	STA $0A
	LDA.w mush_plat_tiles+2,x
	STA $0C
	LDA.w mush_plat_tiles+4,x
	STA $0E
	SEP #$30
	JSR StoreNybbles
	JSR BackUpPtrs
	LDY !object_position

	LDA $0A
	STA [$6B],y
	LDA $0B
	STA [$6E],y
	LDX !scratch_obj_width
	BEQ .rest
	BRA .first_loop_end
.mush_top_loop
	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y
.first_loop_end
	JSR ShiftObjRight
	DEX
	BNE .mush_top_loop

	LDA $0E
	STA [$6B],y
	LDA $0F
	STA [$6E],y
.rest
	LDA !scratch_obj_height ; \ branch out if height is zero
	BEQ .done               ; /

	REP #$20
	LDA mush_plat_tiles+6,x ; \ x sure to be zero here
	STA $0A                 ; |
	LDA mush_plat_tiles+8,x ; /
	STA $0C
	SEP #$20

	JSR RestorePtrs
	JSR ShiftObjDown

	LDA !scratch_obj_width  ; \
	LSR                     ; | find halfway point
	CLC                     ; | offset to left or right
	ADC !object_argument    ; | by desired amount
	STA $0E                 ; /

	LDA $0E
.half_loop
	BEQ .half_shifts_done
	JSR ShiftObjRight
	DEC $0E
	BRA .half_loop
.half_shifts_done

	LDX !scratch_obj_height

	LDA $0A
	STA [$6B],y
	LDA $0B
	STA [$6E],y
	DEX

	BEQ .done

.expand_loop
	JSR ShiftObjDownAlt

	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y
	DEX
	BNE .expand_loop
.done
	RTS

CustObj01:
	LDA !object_argument
	JMP SquareObjects

CustObj02:
	LDA !object_argument
	JMP WideVertObjects

CustObj03:
	LDA !object_argument
	JMP TallHorzObjects

CustObj04:
	LDA !object_argument
	JMP HorzObjects
CustObj05:
	LDA !object_argument
	JMP VertObjects
CustObj06:
	LDA !object_argument
	JMP DoubleWideVertObjAlternateRows
CustObj07:
	LDA !object_argument
	JMP DoubleTallHorzObjAlternateRows
; TODO
CustObj08:
	LDA !object_argument
	JMP AlternatingBrickObjs
CustObj09:
	LDA !object_argument
	JMP Objects1x1Stretchable
; generate a section of an extended cluster object
; note: there are no size checks. if the object is too big, it will generate garbage
CustObj0A:
	LDA !object_argument
	SEC : SBC #!cluster_exobjs_start
	JMP ClusterNormObjects

CustObj0B:
CustObj0C:
CustObj0D:
CustObj0E:
CustObj0F:
CustObj10:
CustObj11:
CustObj12:
CustObj13:
CustObj14:
CustObj15:
CustObj16:
CustObj17:
CustObj18:
CustObj19:
CustObj1A:
CustObj1B:
CustObj1C:
CustObj1D:
CustObj1E:
CustObj1F:
CustObj20:
CustObj21:
CustObj22:
CustObj23:
CustObj24:
CustObj25:
CustObj26:
CustObj27:
CustObj28:
CustObj29:
CustObj2A:
CustObj2B:
CustObj2C:
CustObj2D:
CustObj2E:
CustObj2F:
CustObj30:
CustObj31:
CustObj32:
CustObj33:
CustObj34:
CustObj35:
CustObj36:
CustObj37:
CustObj38:
CustObj39:
CustObj3A:
CustObj3B:
CustObj3C:
CustObj3D:
CustObj3E:
CustObj3F:
CustObj40:
CustObj41:
CustObj42:
CustObj43:
CustObj44:
CustObj45:
CustObj46:
CustObj47:
CustObj48:
CustObj49:
CustObj4A:
CustObj4B:
CustObj4C:
CustObj4D:
CustObj4E:
CustObj4F:
CustObj50:
CustObj51:
CustObj52:
CustObj53:
CustObj54:
CustObj55:
CustObj56:
CustObj57:
CustObj58:
CustObj59:
CustObj5A:
CustObj5B:
CustObj5C:
CustObj5D:
CustObj5E:
CustObj5F:
CustObj60:
CustObj61:
CustObj62:
CustObj63:
CustObj64:
CustObj65:
CustObj66:
CustObj67:
CustObj68:
CustObj69:
CustObj6A:
CustObj6B:
CustObj6C:
CustObj6D:
CustObj6E:
CustObj6F:
CustObj70:
CustObj71:
CustObj72:
CustObj73:
CustObj74:
CustObj75:
CustObj76:
CustObj77:
CustObj78:
CustObj79:
CustObj7A:
CustObj7B:
CustObj7C:
CustObj7D:
CustObj7E:
CustObj7F:
CustObj80:
CustObj81:
CustObj82:
CustObj83:
CustObj84:
CustObj85:
CustObj86:
CustObj87:
CustObj88:
CustObj89:
CustObj8A:
CustObj8B:
CustObj8C:
CustObj8D:
CustObj8E:
CustObj8F:
CustObj90:
CustObj91:
CustObj92:
CustObj93:
CustObj94:
CustObj95:
CustObj96:
CustObj97:
CustObj98:
CustObj99:
CustObj9A:
CustObj9B:
CustObj9C:
CustObj9D:
CustObj9E:
CustObj9F:
CustObjA0:
CustObjA1:
CustObjA2:
CustObjA3:
CustObjA4:
CustObjA5:
CustObjA6:
CustObjA7:
CustObjA8:
CustObjA9:
CustObjAA:
CustObjAB:
CustObjAC:
CustObjAD:
CustObjAE:
CustObjAF:
CustObjB0:
CustObjB1:
CustObjB2:
CustObjB3:
CustObjB4:
CustObjB5:
CustObjB6:
CustObjB7:
CustObjB8:
CustObjB9:
CustObjBA:
CustObjBB:
CustObjBC:
CustObjBD:
CustObjBE:
CustObjBF:
CustObjC0:
CustObjC1:
CustObjC2:
CustObjC3:
CustObjC4:
CustObjC5:
CustObjC6:
CustObjC7:
CustObjC8:
CustObjC9:
CustObjCA:
CustObjCB:
CustObjCC:
CustObjCD:
CustObjCE:
CustObjCF:
CustObjD0:
CustObjD1:
CustObjD2:
CustObjD3:
CustObjD4:
CustObjD5:
CustObjD6:
CustObjD7:
CustObjD8:
CustObjD9:
CustObjDA:
CustObjDB:
CustObjDC:
CustObjDD:
CustObjDE:
CustObjDF:
CustObjE0:
CustObjE1:
CustObjE2:
CustObjE3:
CustObjE4:
CustObjE5:
CustObjE6:
CustObjE7:
CustObjE8:
CustObjE9:
CustObjEA:
CustObjEB:
CustObjEC:
CustObjED:
CustObjEE:
CustObjEF:
CustObjF0:
CustObjF1:
CustObjF2:
CustObjF3:
CustObjF4:
CustObjF5:
CustObjF6:
CustObjF7:
CustObjF8:
CustObjF9:
CustObjFA:
CustObjFB:
CustObjFC:
CustObjFD:
CustObjFE:
CustObjFF:
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BitTable:
	db $01,$02,$04,$08,$10,$20,$40,$80


Obj1x1TilesUnset:
	dw $02F9,$02FA,$04BE,$04AF,$04BF,$049F
Obj1x1TilesSet:
	dw $0025,$0025,$0025,$0025,$012F,$0110

Obj1x1SwitchCementOutline:
	dw $006A,$006B

Obj2x1Tiles:
	dw $0000,$0000

Obj1x2Tiles:
	dw $0000,$0000

SquareObjTiles2A:
	dw $0200,$0201,$0202,$0210,$0211,$0212,$0220,$0221,$0222 : dw $0230,$0231,$0232 : dw $0203,$0213,$0223 : dw $0233

SquareObjTiles2B:
	dw $0204,$0201,$0205,$0210,$0211,$0212,$0214,$0221,$0215 : dw $0224,$0231,$0225 : dw $0206,$0213,$0216 : dw $0226

UnidimensionalObjTiles2:
	dw $020C,$020D,$020E : dw $021F

UnidimensionalObjCheckTiles:
	dw $0000,$021B,$0000 : dw $0000

UnidimensionalObjReplaceTiles:
	dw $0000,$021E,$0000 : dw $0000

Horiz2EndTiles:
	dw $0000,$0000,$0000 : dw $0000

Vert2EndTiles:
	dw $0000,$0000,$0000 : dw $0000

;------------------------------------------------
; make an object consisting of a 3x3 square
;------------------------------------------------
Obj3x3Tiles:
	dw $0400,$0401,$0402,$0403,$0404,$0405,$0406,$0407,$0408
	dw $0410,$0411,$0412,$0413,$0414,$0415,$0416,$0417,$0418
	dw $0420,$0421,$0422,$0423,$0424,$0425,$0426,$0427,$0428
	dw $0430,$0431,$0432,$0433,$0434,$0435,$0436,$0437,$0438
.remainTiles:
	dw $0400,$0401,$0439,$0403,$0404,$0405,$040A,$0407,$0408
	dw $0439,$0411,$0412,$0413,$0414,$0415,$0416,$0417,$041B
	dw $040A,$0421,$0422,$0423,$0424,$0425,$0426,$0427,$042C
	dw $0430,$0431,$041B,$0433,$0434,$0435,$042C,$0437,$0438

macro check_tile_3x3(label)
	LDA [$6B],y
	CMP Obj3x3Tiles_remainTiles,x
	BNE ?+
	LDA [$6E],y
	CMP Obj3x3Tiles_remainTiles+1,x
	BEQ <label>
?+
endmacro

Objects3x3:
	ASL           ; \
	STA $0A       ; | ((A * 2) * 8) + (A  * 2) = our index
	ASL #3        ; |
	CLC           ; |
	ADC $0A       ; /
	TAX
	JSR BackUpPtrs

	%check_tile_3x3(+)
	LDY !object_position
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
+
	INX #2

	JSR ShiftObjRight

;	%check_tile_3x3(+)
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
;+
	INX #2

	JSR ShiftObjRight
	%check_tile_3x3(+)
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
+
	JSR RestorePtrs
	JSR ShiftObjDown

	INX #2

;	%check_tile_3x3(+)
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
;+
	INX #2
	JSR ShiftObjRight

;	%check_tile_3x3(+)
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
;+
	INX #2
	JSR ShiftObjRight

;	%check_tile_3x3(+)
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
;+
	JSR RestorePtrs
	JSR ShiftObjDown

	INX #2

	%check_tile_3x3(+)
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
+
	INX #2
	JSR ShiftObjRight

;	%check_tile_3x3(+)
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
;+
	INX #2
	%check_tile_3x3(+)
	JSR ShiftObjRight
	LDA.w Obj3x3Tiles,x
	STA [$6B],y
	LDA.w Obj3x3Tiles+1,x
	STA [$6E],y
+

	RTS
	


;------------------------------------------------
; make an object consisting of a 2x2 square
;------------------------------------------------

Obj2x2Tiles:
	dw $02B0,$02B1,$02B2,$02B3
	dw $02B4,$02B5,$02B6,$02B7
	dw $02B8,$02B9,$02BA,$02BB
	dw $02BC,$02BD,$02BE,$02BF
	dw $02E0,$02E1,$02E2,$02E3
	dw $02E4,$02E5,$02E6,$02E7
	dw $02B0,$02B1,$02B2,$02EF
	dw $02B4,$02B5,$02EE,$02B7
	dw $02E4,$02B9,$02BA,$02BB
	dw $02BC,$02E5,$02BE,$02BF
	dw $02B4,$02B5,$02F7,$0500
	dw $0500,$0500,$04F0,$0565
	dw $03B9,$03B9,$031E,$03B9
	dw $03B9,$03B9,$03B9,$031F
Objects2x2:
	ASL #3
	TAX
	JSR BackUpPtrs
	LDY $57
	LDA.w Obj2x2Tiles,x
	STA [$6B],y
	LDA.w Obj2x2Tiles+1,x
	STA [$6E],y
	INX #2
	JSR ShiftObjRight
	LDA.w Obj2x2Tiles,x
	STA [$6B],y
	LDA.w Obj2x2Tiles+1,x
	STA [$6E],y
	JSR RestorePtrs
	JSR ShiftObjDown
	INX #2
	LDA.w Obj2x2Tiles,x
	STA [$6B],y
	LDA.w Obj2x2Tiles+1,x
	STA [$6E],y
	INX #2
	JSR ShiftObjRight
	LDA.w Obj2x2Tiles,x
	STA [$6B],y
	LDA.w Obj2x2Tiles+1,x
	STA [$6E],y
	RTS

Objects1x1Stretchable:
	STA $00
	ASL
	TAX
	LDY !object_position
	JSR StoreNybbles
	JSR BackUpPtrs
	LDA $00
	CMP #$02
	BCS .std
	PHX
	TAX
	LDA $1F27|!addr,x
	PLX
	CMP #$00
	BNE .std
.switch_outline:
	LDA Obj1x1SwitchCementOutline,x
	STA !ObjScratch+0
	STA !ObjScratch+2
	LDA Obj1x1SwitchCementOutline+1,x
	STA !ObjScratch+1
	STA !ObjScratch+3
	BRA .h_loop_start
.std:
	
	LDA Obj1x1TilesUnset,x
	STA !ObjScratch+0
	LDA Obj1x1TilesUnset+1,x
	STA !ObjScratch+1
	LDA Obj1x1TilesSet,x
	STA !ObjScratch+2
	LDA Obj1x1TilesSet+1,x
	STA !ObjScratch+3
.h_loop_start:
	LDX !scratch_obj_width
.h_loop
	JSL read_item_memory
	BEQ .unset
.set:
	LDA !ObjScratch+2
	STA [$6B],y
	LDA !ObjScratch+3
	STA [$6E],y
	BRA .next
.unset:
	LDA !ObjScratch+0
	STA [$6B],y
	LDA !ObjScratch+1
	STA [$6E],y
.next:
	JSR ShiftObjRight
	DEX
	BPL .h_loop
.v_loop
	JSR RestorePtrs
	JSR ShiftObjDown
	DEC !scratch_obj_height
	BPL .h_loop_start
	RTS

;------------------------------------------------
; make an object consisting of a 2x1 rectangle
;------------------------------------------------

Objects2x1:
	ASL #2
	TAX
	LDY $57
	LDA.w Obj2x1Tiles,x
	STA [$6B],y
	LDA.w Obj2x1Tiles+1,x
	STA [$6E],y
	INX #2
	JSR ShiftObjRight
	LDA.w Obj2x1Tiles,x
	STA [$6B],y
	LDA.w Obj2x1Tiles+1,x
	STA [$6E],y
	RTS

;------------------------------------------------
; make an object consisting of a 1x2 rectangle
;------------------------------------------------

Objects1x2:
	ASL #2
	TAX
	LDY $57
	LDA.w Obj1x2Tiles,x
	STA [$6B],y
	LDA.w Obj1x2Tiles+1,x
	STA [$6E],y
	INX #2
	JSR ShiftObjDown
	LDA.w Obj1x2Tiles,x
	STA [$6B],y
	LDA.w Obj1x2Tiles+1,x
	STA [$6E],y
	RTS

;------------------------------------------------
; make an object consisting of 9 blocks that can be stretched
;------------------------------------------------
; for the "BigSquareObjects" routine, $58 is used for 8 extra size bits (yyyyxxxx)
;------------------------------------------------
; 9 tiles for MxN objects where M >= 2 and N >= 2: top-left corner, top ledge, top-right corner, left edge, middle, right edge, bottom-left corner, bottom edge, bottom right corner
; 3 tiles for Nx1 objects: left end, middle, right end
; 3 tiles for 1xN objects: top end, middle, bottom end
; 1 tile for 1x1 objects
SquareObjTiles:
	dw $0210,$0211,$0212,$0213,$0214,$0215,$0216,$0217,$0218 : dw $0219,$021A,$021B : dw $021C,$021D,$021E : dw $021F ; smb3 square: pal 0
	dw $0220,$0221,$0222,$0223,$0224,$0225,$0226,$0227,$0228 : dw $0229,$022A,$022B : dw $022C,$022D,$022E : dw $022F ; smb3 square: pal 1
	dw $0230,$0231,$0232,$0233,$0234,$0235,$0236,$0237,$0238 : dw $0239,$023A,$023B : dw $023C,$023D,$023E : dw $023F ; smb3 square: pal 2
	dw $0240,$0241,$0242,$0243,$0244,$0245,$0246,$0247,$0248 : dw $0249,$024A,$024B : dw $024C,$024D,$024E : dw $024F ; smb3 square: pal 3
	dw $0250,$0251,$0252,$0253,$0254,$0255,$0256,$0257,$0258 : dw $0259,$025A,$025B : dw $025C,$025D,$025E : dw $025F ; smb3 square: pal 4
	dw $0260,$0261,$0262,$0263,$0264,$0265,$0266,$0267,$0268 : dw $0269,$026A,$026B : dw $026C,$026D,$026E : dw $026F ; smb3 square: pal 5
	dw $0270,$0271,$0272,$0273,$0274,$0275,$0276,$0277,$0278 : dw $0279,$027A,$027B : dw $027C,$027D,$027E : dw $027F ; smb3 square: pal 6
	dw $0280,$0281,$0282,$0283,$0284,$0285,$0286,$0287,$0288 : dw $0289,$028A,$028B : dw $028C,$028D,$028E : dw $028F ; smb3 square: pal 7

BigSquareObjects:
	JSR SquareObjectsInit
	JSR StoreNybbles
	LDA $58
	ASL #4
	TSB $08
	LDA $58
	AND #$F0
	TSB $09
	BRA SquareObjectsSub
SquareObjects:
	JSR SquareObjectsInit
	JSR StoreNybbles
SquareObjectsSub:
	LDY !object_position
	LDA !scratch_obj_width
	STA $00
	LDA !scratch_obj_height
	STA $01
	JSR BackUpPtrs
	LDA !scratch_obj_height
	BEQ .NoVert
	LDA !scratch_obj_width
	BEQ .VertOnly
	JMP .StartObjLoop
.VertOnly
	REP #$30
	LDA $0C
	CLC
	ADC #$000C
	STA $0C
	SEP #$20
.LoopV
	LDX $0C
	LDA $01
	CMP $09
	BEQ .SetTileIndexV
	INX
	CMP #$00
	BNE .SetTileIndexV
	INX
.SetTileIndexV
	REP #$20
	TXA
	ASL
	TAX
	LDA.w SquareObjTiles,x
	SEP #$30
	STA [$6B],y
	XBA
	STA [$6E],y
	JSR ShiftObjDown
	DEC $01
	BPL .LoopV
	RTS
.NoVert
	LDA !scratch_obj_width
	BEQ .SingleTile
.HorizOnly
	REP #$30
	LDA $0C
	CLC
	ADC #$0009
	STA $0C
	SEP #$20
.LoopH
	LDX $0C
	LDA $00
	CMP $08
	BEQ .SetTileIndexH
	INX
	CMP #$00
	BNE .SetTileIndexH
	INX
.SetTileIndexH
	REP #$20
	TXA
	ASL
	TAX
	LDA.w SquareObjTiles,x
	SEP #$30
	STA [$6B],y
	XBA
	STA [$6E],y
	JSR ShiftObjRight
	DEC $00
	BPL .LoopH
	RTS
.SingleTile
	REP #$30
	LDA $0C
	CLC
	ADC #$000F
	ASL
	TAX
	LDA.w SquareObjTiles,x
	SEP #$30
	STA [$6B],y
	XBA
	STA [$6E],y
	RTS
.StartObjLoop
	REP #$10
	LDX $0C
	LDA $01
	CMP !scratch_obj_height
	BEQ .NoInc1
	INX #3
	CMP #$00
	BNE .NoInc1
	INX #3
.NoInc1
	LDA $00
	CMP $08
	BEQ .SetTileIndex
	INX
	CMP #$00
	BNE .SetTileIndex
	INX
.SetTileIndex
	REP #$20
	TXA
	ASL
	TAX
	LDA.w SquareObjTiles,x
	SEP #$30
	STA [$6B],y
	XBA
	STA [$6E],y
	JSR ShiftObjRight
.DecAndLoop
	DEC $00
	BPL .StartObjLoop
	JSR RestorePtrs
	JSR ShiftObjDown
	LDA $08
	STA $00
	DEC $01
	BMI .EndObjLoop
	JMP .StartObjLoop
.EndObjLoop
.Return
	RTS

SquareObjectsInit:
	REP #$20
	AND.w #$00FF
	ASL #4
	STA $0C
	SEP #$20
.Return
	RTS

AlternatingBrickTiles:
	dw $02F7,$02F9,$02FA,$02F7  ; closed on both sides
	dw $02FA,$02F9,$02FA,$02F7  ; closed on right
	dw $02FA,$02F9,$02FA,$02F9  ; closed on neither
	dw $02F7,$02F9,$02FA,$02FA  ; closed on left
AlternatingBrickObjs:
	ASL #2
	TAX

	LDA AlternatingBrickTiles,x
	STA !ObjScratch
	LDA AlternatingBrickTiles+2,x
	STA !ObjScratch+2
	LDA AlternatingBrickTiles+4,x
	STA !ObjScratch+4
	LDA AlternatingBrickTiles+6,x
	STA !ObjScratch+6

	JSR StoreNybbles
	LDY !object_position
	LDA !scratch_obj_width
	STA $00
	LDA !scratch_obj_height
	STA $01
	JSR BackUpPtrs
.vloop
	LDX $00
	LDA !ObjScratch
	STA [$6B],y
	LDA !ObjScratch
	STA [$6E],y
	DEX
	BMI .vnext
	TXA
	AND #$01
	LDA !ObjScratch,x
	
.vnext	
	DEC $01
	BPL .vloop
.done
	RTS
;SquareObjects2Tiles
;SquareObjects2:
;.Return
;	RTS

;------------------------------------------------
; make an object consisting of 3 blocks that can be stretched horizontally only
;------------------------------------------------

Horiz2EndObjects:
	LDY $57
	REP #$30
	AND.w #$00FF
	ASL #3
	TAX
	LDA $08
	AND #$00FF
	BNE .NotSingleTile
	LDA.w Horiz2EndTiles+6,x
	STA $0E
	SEP #$30
	BRA .StoreOnlyOne
.NotSingleTile
	LDA.w Horiz2EndTiles+4,x
	STA $0E
	LDA.w Horiz2EndTiles+2,x
	STA $0C
	LDA.w Horiz2EndTiles,x
	SEP #$30
	STA [$6B],y
	XBA
	STA [$6E],y
	LDX $08
	BRA .End
.Loop
	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y
.End
	JSR ShiftObjRight
	DEX
	BNE .Loop
	LDA $0E
.StoreOnlyOne
	STA [$6B],y
	LDA $0F
	STA [$6E],y
	RTS

;------------------------------------------------
; make an object consisting of 3 blocks that can be stretched vertically only
;------------------------------------------------

Vert2EndObjects:
	LDY $57
	REP #$30
	AND.w #$00FF
	ASL #3
	TAX
	LDA $09
	AND #$00FF
	BNE .NotSingleTile
	LDA.w Vert2EndTiles+6,x
	STA $0E
	SEP #$30
	BRA .StoreOnlyOne
.NotSingleTile
	LDA.w Vert2EndTiles+4,x
	STA $0E
	LDA.w Vert2EndTiles+2,x
	STA $0C
	LDA.w Vert2EndTiles,x
	SEP #$30
	STA [$6B],y
	XBA
	STA [$6E],y
	LDX $09
	BRA .End
.Loop
	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y
.End
	JSR ShiftObjDown
	DEX
	BNE .Loop
	LDA $0E
.StoreOnlyOne
	STA [$6B],y
	LDA $0F
	STA [$6E],y
	RTS

;------------------------------------------------
; make an object that can be stretched in one direction only and checks which direction that is; also checks for overlap with specific other tiles and changes the spawned tile accordingly
;------------------------------------------------
; Note: Currently, stretching it in both directions will just cause it to return without creating any tiles, because I'm not sure what those cases should do.
;------------------------------------------------

UnidimensionalObjects2:
	REP #$30
	AND #$00FF
	ASL #3
	TAX
	LDA.w UnidimensionalObjTiles2,x
	STA $0A
	LDA.w UnidimensionalObjTiles2+2,x
	STA $0C
	LDA.w UnidimensionalObjTiles2+4,x
	STA $0E
	LDA.w UnidimensionalObjCheckTiles,x
	STA $45
	LDA.w UnidimensionalObjCheckTiles+2,x
	STA $47
	LDA.w UnidimensionalObjCheckTiles+4,x
	STA $49
	LDA.w UnidimensionalObjReplaceTiles,x
	STA !ObjScratch
	LDA.w UnidimensionalObjReplaceTiles+2,x
	STA !ObjScratch+2
	LDA.w UnidimensionalObjReplaceTiles+4,x
	STA !ObjScratch+4
	LDA.w UnidimensionalObjTiles2+6,x
	STA !ObjScratch+6
	LDA.w UnidimensionalObjCheckTiles+6,x
	STA !ObjScratch+8
	LDA.w UnidimensionalObjReplaceTiles+6,x
	STA !ObjScratch+10
	SEP #$30
	JSR StoreNybbles
	LDY $57
	LDA $09
	BEQ .Horiz
	LDA $08
	BEQ .Vert
; both H and V?
	RTS
.Zero
	LDA [$6E],y
	XBA
	LDA [$6B],y
	REP #$20
	CMP !ObjScratch+8
	BEQ .ReplaceZero
	LDA !ObjScratch+6
	BRA .StoreTileZero
.ReplaceZero
	LDA !ObjScratch+10
.StoreTileZero
	SEP #$20
	STA [$6B],y
	XBA
	STA [$6E],y
	RTS
.Horiz
	LDA $08
	BEQ .Zero
	LDA [$6E],y
	XBA
	LDA [$6B],y
	REP #$20
	CMP $45
	BEQ .Replace1H
	LDA $0A
	BRA .SetTile1H
.Replace1H
	LDA !ObjScratch
.SetTile1H
	SEP #$20
	STA [$6B],y
	XBA
	STA [$6E],y
	LDX $08
	BRA .EndH
.LoopH
	LDA [$6E],y
	XBA
	LDA [$6B],y
	REP #$20
	CMP $47
	BEQ .Replace2H
	LDA $0C
	BRA .SetTile2H
.Replace2H
	LDA !ObjScratch+2
.SetTile2H
	SEP #$20
	STA [$6B],y
	XBA
	STA [$6E],y
.EndH
	JSR ShiftObjRight
	DEX
	BNE .LoopH
	LDA [$6E],y
	XBA
	LDA [$6B],y
	REP #$20
	CMP $49
	BEQ .Replace3H
	LDA $0E
	BRA .SetTile3H
.Replace3H
	LDA !ObjScratch+4
.SetTile3H
	SEP #$20
	STA [$6B],y
	XBA
	STA [$6E],y
	RTS
.Vert
	LDA $09
	BEQ .Zero
	LDA [$6E],y
	XBA
	LDA [$6B],y
	REP #$20
	CMP $45
	BEQ .Replace1V
	LDA $0A
	BRA .SetTile1V
.Replace1V
	LDA !ObjScratch
.SetTile1V
	SEP #$20
	STA [$6B],y
	XBA
	STA [$6E],y
	LDX $09
	BRA .EndV
.LoopV
	LDA [$6E],y
	XBA
	LDA [$6B],y
	REP #$20
	CMP $47
	BEQ .Replace2V
	LDA $0C
	BRA .SetTile2V
.Replace2V
	LDA !ObjScratch+2
.SetTile2V
	SEP #$20
	STA [$6B],y
	XBA
	STA [$6E],y
.EndV
	JSR ShiftObjDown
	DEX
	BNE .LoopV
	LDA [$6E],y
	XBA
	LDA [$6B],y
	REP #$20
	CMP $49
	BEQ .Replace3V
	LDA $0E
	BRA .SetTile3V
.Replace3V
	LDA !ObjScratch+4
.SetTile3V
	SEP #$20
	STA [$6B],y
	XBA
	STA [$6E],y
	RTS

;------------------------------------------------
; make an object composed of a single Map16 tile that can be set to use item memory
;------------------------------------------------
; Input:
; - $0C-$0D = tile number
; - X: 0 not to use item memory, any non-zero value to use it
;------------------------------------------------

SingleBlockObjects:
	LDY $57
	LDA $59
	AND #$0F
	STA $00
	STA $02
	LDA $59
	LSR #4
	STA $01
	JSR BackUpPtrs
.StartObjLoop0
	CPX #$00
	BEQ .SetTileNumber
	JSR GetItemMemoryBit
	BEQ .SetTileNumber
	JSR ShiftObjRight
	BRA .DecAndLoop0
.SetTileNumber
	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y
	JSR ShiftObjRight
.DecAndLoop0
	DEC $00
	BPL .StartObjLoop0
	JSR RestorePtrs
	JSR ShiftObjDown
	LDA $02
	STA $00
	DEC $01
	BMI .EndObjLoop0
	JMP .StartObjLoop0
.EndObjLoop0
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; other subroutines (many of them ripped or adapted directly from SMW)
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;------------------------------------------------
; allow an object to go across screen boundaries horizontally (adapted from $0DA95B)
;------------------------------------------------

ShiftObjRight:
	INY
	TYA
	AND #$0F
	BNE .NoScreenChange
	LDA $5B
	LSR
	BCS .VertLvl
	REP #$21
	LDA $6B
	ADC $13D7|!addr
	STA $6B
	STA $6E
	LDA #$0000
	SEP #$20
	INC $1BA1|!addr
	LDA $57
	AND #$F0
	TAY
.NoScreenChange
	RTS
.VertLvl
	INC $6C
	INC $6F
	LDA $57
	AND #$F0
	TAY
	RTS

;------------------------------------------------
; allow an object to go across subscreen boundaries vertically (adapted from $0DA97D)
;------------------------------------------------

ShiftObjDown:
	LDA $57
.Sub
	CLC
	ADC #$10
	STA $57
	TAY
	BCC .NoScreenChange
	LDA $5B
	AND #$01
	BNE .VertLvl
	LDA $6C
	ADC #$00
	STA $6C
	STA $6F
	STA $05
.NoScreenChange
	RTS
.VertLvl
	LDA $6C
	ADC #$01
	STA $6C
	STA $6F
	INC $1BA1|!addr
	RTS

;------------------------------------------------
; allow an object to go across subscreen boundaries vertically; will not reset the X position (adapted from $0DA97D)
;------------------------------------------------

ShiftObjDownAlt:
	TYA
	BRA ShiftObjDown_Sub

;------------------------------------------------
; allow an object to go across screen boundaries backward horizontally
;------------------------------------------------

ShiftObjLeft:
	DEY
	TYA
	AND #$0F
	CMP #$0F
	BNE .NoScreenChange
	LDA $5B
	LSR
	BCS .VertLvl
	REP #$20
	LDA $6B
	SEC
	SBC $13D7|!addr
	STA $6B
	STA $6E
	SEP #$20
	DEC $1BA1|!addr
	LDA $57
	AND #$F0
	ORA #$0F
	TAY
.NoScreenChange
	RTS
.VertLvl
	DEC $6C
	DEC $6F
	LDA $57
	AND #$F0
	ORA #$0F
	TAY
	RTS

;------------------------------------------------
; allow an object to go across subscreen boundaries backward vertically
;------------------------------------------------

ShiftObjUp:
	LDA $57
.Sub
	SEC
	SBC #$10
	STA $57
	TAY
	BCS .NoScreenChange
	LDA $5B
	AND #$01
	BNE .VertLvl
	LDA $6C
	SBC #$00
	STA $6C
	STA $6F
	STA $05
.NoScreenChange
	RTS
.VertLvl
	LDA $6C
	SBC #$01
	STA $6C
	STA $6F
	DEC $1BA1|!addr
	RTS

;------------------------------------------------
; allow an object to go across subscreen boundaries backward vertically; will not reset the X position
;------------------------------------------------

ShiftObjUpAlt:
	TYA
	BRA ShiftObjUp_Sub

;------------------------------------------------
; allow an object to go across screen boundaries horizontally; shifts a customizable number of tiles (input in A)
;------------------------------------------------

ShiftObjRight2:
	STA $0E
.Check
	CMP #$11
	BCC .Run
	PHA
	REP #$20
	LDA $6B
	CLC
	ADC $13D7|!addr
	STA $6B
	STA $6E
	SEP #$20
	INC $1BA1|!addr
	PLA
	SEC
	SBC #$10
	STA $0E
	BRA .Check
.Run
	LDA $57
	AND #$0F
	STA $0F
	CLC
	ADC $0E
	CMP #$10
	AND #$0F
	STA $0F
	BCC .NoScreenChange
	LDA $5B
	AND #$01
	BNE .VertLvl
	REP #$20
	LDA $6B
	ADC $13D7|!addr
	STA $6B
	STA $6E
	SEP #$20
	INC $1BA1|!addr
.NoScreenChange
	LDA $57
	AND #$F0
	ORA $0F
	STA $57
	TAY
	RTS
.VertLvl
	INC $6C
	INC $6F
	LDA $57
	AND #$F0
	ORA $0F
	TAY
	RTS

;------------------------------------------------
; allow an object to go across subscreen boundaries vertically; shifts a customizable number of tiles (input in A)
;------------------------------------------------

ShiftObjDown2:
	ASL #4
	STA $0E
	LDA $57
	CLC
	ADC $0E
	STA $57
	TAY
	BCC .NoScreenChange
	LDA $5B
	AND #$01
	BNE .VertLvl
	LDA $6C
	ADC #$00
	STA $6C
	STA $6F
	STA $05
.NoScreenChange
	RTS
.VertLvl
	LDA $6C
	CLC
	ADC #$02
	STA $6C
	STA $6F
	INC $1BA1|!addr
	RTS

;------------------------------------------------
; allow an object to go across screen boundaries backward horizontally; shifts a customizable number of tiles (input in A)
;------------------------------------------------

ShiftObjLeft2:
	STA $0E
	LDA $57
	AND #$0F
	STA $0F
	SEC
	SBC $0E
	CMP #$10
	AND #$0F
	STA $0F
	BCC .NoScreenChange
	LDA $5B
	LSR
	BCS .VertLvl
	REP #$20
	LDA $6B
	SEC
	SBC $13D7|!addr
	STA $6B
	STA $6E
	SEP #$20
	DEC $1BA1|!addr
.NoScreenChange
	LDA $57
	AND #$F0
	ORA $0F
	STA $57
	RTS
.VertLvl
	DEC $6C
	DEC $6F
	LDA $57
	AND #$F0
	ORA #$0F
	TAY
	RTS

;------------------------------------------------
; allow an object to go across subscreen boundaries backward vertically; shifts a customizable number of tiles (input in A)
;------------------------------------------------

ShiftObjUp2:
	LDA $57
.Sub
	SEC
	SBC #$10
	STA $57
	TAY
	BCS .NoScreenChange
	LDA $5B
	AND #$01
	BNE .VertLvl
	LDA $6C
	SBC #$00
	STA $6C
	STA $6F
	STA $05
.NoScreenChange
	RTS
.VertLvl
	LDA $6C
	SEC
	SBC #$02
	STA $6C
	STA $6F
	DEC $1BA1|!addr
	RTS

;------------------------------------------------
; back up the low and high byte of the Map16 pointers in scratch RAM (ripped from $0DA6B1)
;------------------------------------------------
; also includes a call point for a typical object initialization routine
;------------------------------------------------

ObjectInitStd:
	JSR StoreNybbles
	LDY $57
	LDA $08
	STA $00
	STA $02
	LDA $09
	STA $01
BackUpPtrs:
	LDA $6B
	STA $04
	LDA $6C
	STA $05
	RTS

;------------------------------------------------
; restore the low and high byte of the Map16 pointers from scratch RAM (ripped from $0DA6BA)
;------------------------------------------------

RestorePtrs:
	LDA $04
	STA $6B
	STA $6E
	LDA $05
	STA $6C
	STA $6F
	LDA $1928|!addr
	STA $1BA1|!addr
	RTS

;------------------------------------------------
; check item memory for a particular block position (ripped from $0DA8DC)
;------------------------------------------------
; Output: A will be 0 if the item memory bit is not set and nonzero if it is set.
;------------------------------------------------

GetItemMemoryBit:
	PHX
	PHY
	LDX $13BE|!addr
	LDA #$F8
	CLC
	ADC $0DA8AE|!bank,x
	STA $08
	LDA.b #$19|(!addr>>8)
	ADC $0DA8B1|!bank,x
	STA $09
	LDA $1BA1|!addr
	ASL #2
	STA $0E
	LDA $0A
	AND #$10
	BEQ .UpperSubscreen
	LDA $0E
	ORA #$02
	STA $0E
.UpperSubscreen
	TYA
	AND #$08
	BEQ .LeftHalfOfScreen
	LDA $0E
	ORA #$01
	STA $0E
.LeftHalfOfScreen
	TYA
	AND #$07
	TAX
	LDY $0E
	LDA ($08),y
	AND $0DA8A6|!bank,x
	PLY
	PLX
	CMP #$00
	RTS

;------------------------------------------------
; store object variables to scratch RAM (X position to $06, Y position to $07, width to $08, and height to $09)
;------------------------------------------------

StoreNybbles:
	LDA $57
	AND #$0F
	STA !scratch_obj_xpos
	LDA $57
	LSR #4
	STA !scratch_obj_ypos
	LDA $59
	AND #$0F
	STA !scratch_obj_width
	LDA $59
	LSR #4
	STA !scratch_obj_height
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; custom variants of some of the base subroutines
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; For this system:
; - 16-bit AXY most of the time (A can be switched to 8-bit mode, but XY should ALWAYS be left as 16-bit because Y indexes the Map16 pointers)
; - Y = index to Map16 data (is a multiple of $13D7|!addr or #$0200 plus an object's position within a screen or column of screens)
; $57: unused? (originally object position within the subscreen (yyyyxxxx))
; $58: normal object extra settings byte
; $59: normal object size/extended object number
; $5A: normal object number
; $00-$01: screen height (is the value of $13D7|!addr for horizontal levels and #$0100 for vertical ones)
; $02-$03: object initial position index
; $04-$05: object width
; $06-$07: object height
; $08-$09: counter for object width
; $0A-$0B: counter for object height
; $0C-$0F: scratch

CustObjInitStd:
	LDA $59
	AND #$0F
	STA $04
	STZ $05
	LDA $59
	LSR #4
	STA $06
	STZ $07
	LDA $0A
	AND #$10
	LSR #4
	STA $0F
	LDA $5B
	LSR
	BCS .Vertical
	LDA $8B
	ORA $0F
	STA $09
	LDA $57
	STA $08
	if !sa1
		STZ $2250
	endif
	REP #$30
	LDA $13D7|!addr
	CMP #$0FF0
	BCC .MultiplyScreen
	LDY $08
	CMP #$12A0
	BEQ .Mode1A
	CMP #$1C00
	BNE .Shared
.Mode1B
	LDA $1BA1|!addr
	AND #$00FF
	BEQ .Shared
	TYA
	CLC
	ADC #$1C00
	TAY
	BRA .Shared
.Mode1A
	LDA $1BA1|!addr
	AND #$00FF
	DEC
	BMI .Shared
	BNE .Mode1AScreen02
.Mode1AScreen01
	TYA
	CLC
	ADC #$12A0
	TAY
	BRA .Shared
.Mode1AScreen02
	TYA
	CLC
	ADC #$2540
	TAY
	BRA .Shared
.MultiplyScreen
	LSR #4
	if !sa1
		AND #$00FF
		STA $2251
		LDA $1BA1|!addr
		AND #$00FF
		STA $2253
		NOP
		LDA $2306
	else
		SEP #$20
		STA $4202
		LDA $1BA1|!addr
		STA $4203
		PHA
		PLA
		REP #$30
		LDA $4216
	endif
	ASL #4
	ADC $08
	TAY
	BRA .Shared
.Vertical
	LDA $57
	STA $0E
	LDA $1BA1|!addr
	if !sa1
		REP #$30
		AND #$00FF
		STA $2251
		LDA #$0020
		STA $2253
		NOP
		LDA $2306
	else
		STA $4202
		LDA #$20
		STA $4203
		REP #$30
		LDA #$0100
		STA $00
		LDA $4216
	endif
	ASL #4
	ADC $0E
	TAY
.Shared
	STA $02
	LDA #$C800
	STA $6B
	LDA #$0000|!map16
	STA $6D
	LDA #$00C8|((!map16|$01)<<8)
	STA $6F
	LDA $04
	STA $08
	LDA $06
	STA $0A
	LDA $13D7|!addr
	STA $00
	RTS

;------------------------------------------------
; shift the current tile position index right
;------------------------------------------------

CustObjShiftR1:
	LDA #$0001
CustObjShiftRX:
	STA $0E
.Check
	CMP #$0011
	BCC .Run
	PHA
	TYA
	CLC
	ADC $00
	TAY
	PLA
	SEC
	SBC #$0010
	STA $0E
	BRA .Check
.Run
	LDA $5B
	LSR
	BCS .Vertical
	TYA
	PHA
	CLC
	ADC $0E
	TAY
	PLA
	AND #$000F
	CLC
	ADC $0E
	CMP #$0010
	BCC .NoScreenChange
	TYA
	SEC
	SBC #$0010
	CLC
	ADC $00
	TAY
.NoScreenChange
	RTS
.Vertical
	TYA
	PHA
	CLC
	ADC $0E
	TAY
	PLA
	AND #$000F
	CLC
	ADC $0E
	CMP #$0010
	BCC .NoScreenChange
	TYA
	CLC
	ADC #$00F0
	TAY
	RTS

;------------------------------------------------
; shift the current tile position index left
;------------------------------------------------

CustObjShiftL1:
	LDA #$0001
CustObjShiftLX:
	STA $0E
.Check
	CMP #$0011
	BCC .Run
	PHA
	TYA
	SEC
	SBC $00
	TAY
	PLA
	SEC
	SBC #$0010
	STA $0E
	BRA .Check
.Run
	LDA $5B
	LSR
	BCS .Vertical
	TYA
	PHA
	SEC
	SBC $0E
	TAY
	PLA
	AND #$000F
	SEC
	SBC $0E
	BPL .NoScreenChange
	TYA
	CLC
	ADC #$0010
	SEC
	SBC $00
	TAY
.NoScreenChange
	RTS
.Vertical
	TYA
	PHA
	SEC
	SBC $0E
	TAY
	PLA
	AND #$000F
	SEC
	SBC $0E
	BPL .NoScreenChange
	TYA
	SEC
	SBC #$00F0
	TAY
	RTS

;------------------------------------------------
; shift the current tile position index down; reset the X position
;------------------------------------------------

CustObjShiftD1:
	LDA #$0001
CustObjShiftDX:
	ASL #4
	STA $0E
	LDA $5B
	LSR
	BCS .Vertical
	TYA
	CLC
	ADC $0E
	TAY
	LDA $04
	INC
	JMP CustObjShiftLX
.Vertical
	PHY
	TYA
	CLC
	ADC $0E
	TAY
	EOR $01,s
	AND #$0100
	BEQ .NoScreenChange
	TYA
	CLC
	ADC #$0100
	TAY
.NoScreenChange
	PLA
	LDA $04
	INC
	JMP CustObjShiftLX

;------------------------------------------------
; shift the current tile position index down; do not reset the X position
;------------------------------------------------

CustObjShiftD1NoReset:
	LDA #$0001
CustObjShiftDXNoReset:
	ASL #4
	STA $0E
	LDA $5B
	LSR
	BCS .Vertical
	TYA
	CLC
	ADC $0E
	TAY
	RTS
.Vertical
	PHY
	TYA
	CLC
	ADC $0E
	TAY
	EOR $01,s
	AND #$0100
	BEQ .NoScreenChange
	TYA
	CLC
	ADC #$0100
	TAY
.NoScreenChange
	PLA
	RTS

;------------------------------------------------
; shift the current tile position index up; reset the X position
;------------------------------------------------

CustObjShiftU1:
	LDA #$0001
CustObjShiftUX:
	AND #$00FF
	ASL #4
	STA $0E
	LDA $5B
	LSR
	BCS .Vertical
	TYA
	SEC
	SBC $0E
	TAY
	LDA $04
	INC
	JMP CustObjShiftLX
.Vertical
	PHY
	TYA
	SEC
	SBC $0E
	TAY
	EOR $01,s
	AND #$0100
	BEQ .NoScreenChange
	TYA
	SEC
	SBC #$0100
	TAY
.NoScreenChange
	PLA
	LDA $04
	INC
	JMP CustObjShiftLX

;------------------------------------------------
; shift the current tile position index up; do not reset the X position
;------------------------------------------------

CustObjShiftU1NoReset:
	LDA #$0001
CustObjShiftUXNoReset:
	ASL #4
	STA $0E
	LDA $5B
	LSR
	BCS .Vertical
	TYA
	SEC
	SBC $0E
	TAY
	RTS
.Vertical
	PHY
	TYA
	SEC
	SBC $0E
	TAY
	EOR $01,s
	AND #$0100
	BEQ .NoScreenChange
	TYA
	SEC
	SBC #$0100
	TAY
.NoScreenChange
	PLA
	RTS

;------------------------------------------------
; find the acts-like setting of the tile at the current position (or a specified tile number)
;------------------------------------------------

FindMap16ActsLike:
	PHP
	SEP #$20
	LDA [$6E],y
	XBA
	LDA [$6B],y
FindMap16ActsLikeEntry1:
	REP #$20
.Loop
	ASL
	ADC $06F624|!bank
	STA $0D
	SEP #$20
	LDA $06F626|!bank
	STA $0F
	REP #$20
	LDA [$0D]
	CMP #$0200
	BCS .Loop
	PLP
	RTS

; only low byte: really only need to be replacing tiles on page 1 at the moment.
SSPipeCheckReplaceTile:
	LDA $0F
	CMP #$0F          ; tree trunk
	BEQ .replace_treetrunk
	BCS .noreplace    ; normal pipes
	LDA [$6E],y
	BEQ .replacealt
	CMP #$01
	BNE .noreplace
	LDA [$6B],y
	BEQ .replace    ; tile 100 - ledge
	CMP #$25
	BEQ .noreplace
	SEC
	SBC #$45       ; \ tiles 145-14F: the ledge side/corner tiles
	CMP #$0B       ; |
	BCC .replace   ; /
	SBC #$20       ; \ tiles 165-167: the solid dirt tile, and the upside-down grass filled in corner tiles
	CMP #$03       ; /
	BCS .noreplace
.replace
	LDA #$05
	STA [$6E],y
	SEC
	RTS
.noreplace
	CLC
	RTS
; change the page 0 dirt tile as needed
.replacealt
	LDA [$6B],y
	CMP #$3F
	BNE .noreplace
	LDA #$65
	STA [$6B],y
	BRA .replace
.replace_treetrunk
	LDA [$6E],y
	BEQ .lava
	CMP #$01
	BNE .noreplace
.ledge
	LDA [$6B],y
	BNE .noreplace
	LDA $0E
	BNE .ledge_right
.ledge_left
	LDA #$75
	STA [$6B],y
	BRA .replace
.ledge_right
	LDA #$76
	STA [$6B],y
	BRA .replace
.lava
	LDA [$6B],y
	CMP #$04
	BEQ .lavacont
	CMP #$05
	BNE .noreplace
.lavacont
	LDA $0E
	BNE .lava_right
.lava_left
	LDA #$73
	STA [$6B],y
	BRA .replace
.lava_right
	LDA #$74
	STA [$6B],y
	BRA .replace
WideVertObjTiles:
	dw $0290,$0291,$0292,$0293,$0294,$0295 ; ss pipe (green), only enterable from top
	dw $029C,$029D,$0292,$0293,$029E,$029F ; ss pipe (green), only enterable from bottom
	dw $02A0,$02A1,$02A2,$02A3,$02A4,$02A5 ; ss pipe (blue), enterable from both sides
	dw $0290,$0291,$02C0,$02C1,$0294,$0295 ; ss pipe (green), only enterable from top: special turn left
	dw $0290,$0291,$02C2,$02C3,$0294,$0295 ; ss pipe (green), only enterable from top: special turn up
	dw $0290,$0291,$02C4,$02C5,$0294,$0295 ; ss pipe (green), only enterable from top: special turn right
	dw $0290,$0291,$02C6,$02C7,$0294,$0295 ; ss pipe (green), only enterable from top: special turn down
	dw $029C,$029D,$02C0,$02C1,$029E,$029F ; ss pipe (green), only enterable from bottom: special turn left
	dw $029C,$029D,$02C2,$02C3,$029E,$029F ; ss pipe (green), only enterable from bottom: special turn up
	dw $029C,$029D,$02C4,$02C5,$029E,$029F ; ss pipe (green), only enterable from bottom: special turn right
	dw $029C,$029D,$02C6,$02C7,$029E,$029F ; ss pipe (green), only enterable from bottom: special turn down
	dw $02A0,$02A1,$02C8,$02C9,$02A4,$02A5 ; ss pipe (blue), enterable from both sides, special turn left
	dw $02A0,$02A1,$02CA,$02CB,$02A4,$02A5 ; ss pipe (blue), enterable from both sides, special turn up
	dw $02A0,$02A1,$02CC,$02CD,$02A4,$02A5 ; ss pipe (blue), enterable from both sides, special turn right
	dw $02A0,$02A1,$02CE,$02CF,$02A4,$02A5 ; ss pipe (blue), enterable from both sides, special turn down
	dw $0577,$0578,$0577,$0578,$0577,$0578 ; tree trunk. replaces ledges and lava
	dw $0650,$0651,$0652,$0653,$0650,$0651 ; vertical pipe, palette 0
	dw $0660,$0661,$0662,$0663,$0660,$0661 ; vertical pipe, palette 1
	dw $0670,$0671,$0672,$0673,$0670,$0671 ; vertical pipe, palette 2, slippery
	dw $0680,$0681,$0682,$0683,$0680,$0681 ; vertical pipe, palette 3
	dw $0690,$0691,$0692,$0693,$0690,$0691 ; vertical pipe, palette 4
	dw $06A0,$06A1,$06A2,$06A3,$06A0,$06A1 ; vertical pipe, palette 5
	dw $06B0,$06B1,$06B2,$06B3,$06B0,$06B1 ; vertical pipe, palette 6
	dw $06C0,$06C1,$06C2,$06C3,$06C0,$06C1 ; vertical pipe, palette 7
	dw $0672,$0673,$0672,$0673,$0672,$0673 ; vertical pipe, palette 2, slippery, no ends
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $0654,$0655,$0652,$0653,$0654,$0655 ; vertical pipe, palette 4, exit enabled (both ends)
	dw $0664,$0665,$0662,$0663,$0664,$0665 ; vertical pipe, palette 5, exit enabled (both ends), slippery
	dw $0674,$0675,$0672,$0673,$0674,$0675 ; vertical pipe, palette 2, exit enabled (both ends)
	dw $0684,$0685,$0682,$0683,$0684,$0685 ; vertical pipe, palette 3, exit enabled (both ends)
	dw $0694,$0695,$0692,$0693,$0694,$0695 ; vertical pipe, palette 4, exit enabled (both ends)
	dw $06A4,$06A5,$06A2,$06A3,$06A4,$06A5 ; vertical pipe, palette 5, exit enabled (both ends)
	dw $06B4,$06B5,$06B2,$06B3,$06B4,$06B5 ; vertical pipe, palette 6, exit enabled (both ends)
	dw $06C4,$06C5,$06C2,$06C3,$06C4,$06C5 ; vertical pipe, palette 7, exit enabled (both ends)


; creates an object that is two tiles wide with different ends, with varying height.
; width is ignored. (TODO: look at making widths > 2 extend the object further)
WideVertObjects:
	STA $0F
	REP #$30
	AND #$00FF
	ASL
	STA $00
	ASL
	ADC $00
	ASL
	TAX
	LDA.w WideVertObjTiles,x
	STA !ObjScratch
	LDA.w WideVertObjTiles+2,x
	STA !ObjScratch+$02
	LDA.w WideVertObjTiles+4,x
	STA !ObjScratch+$04
	LDA.w WideVertObjTiles+6,x
	STA !ObjScratch+$06
	LDA.w WideVertObjTiles+8,x
	STA !ObjScratch+$08
	LDA.w WideVertObjTiles+10,x
	STA !ObjScratch+$0A
	SEP #$30
	JSR StoreNybbles
	LDY !object_position
	JSR BackUpPtrs
	LDA !scratch_obj_height
	BEQ .end
	STZ $0E
	JSR SSPipeCheckReplaceTile
	BCS .skip1
	LDA !ObjScratch
	STA [$6B],y
	LDA !ObjScratch+$01
	STA [$6E],y
.skip1
	JSR ShiftObjRight
	INC $0E
	JSR SSPipeCheckReplaceTile
	BCS .skip2
	LDA !ObjScratch+$02
	STA [$6B],y
	LDA !ObjScratch+$03
	STA [$6E],y
.skip2
	LDX !scratch_obj_height
	BRA .EndV
.LoopV
	STZ $0E
	JSR SSPipeCheckReplaceTile
	BCS .skip3
	LDA !ObjScratch+$04
	STA [$6B],y
	LDA !ObjScratch+$05
	STA [$6E],y
.skip3
	INC $0E
	JSR ShiftObjRight
	INC $0E
	JSR SSPipeCheckReplaceTile
	BCS .skip4
	LDA !ObjScratch+$06
	STA [$6B],y
	LDA !ObjScratch+$07
	STA [$6E],y
.skip4
.EndV
	JSR ShiftObjDown
	DEX
	BNE .LoopV
	STZ $0E
	JSR SSPipeCheckReplaceTile
	BCS .skip5
	LDA !ObjScratch+$08
	STA [$6B],y
	LDA !ObjScratch+$09
	STA [$6E],y
.skip5
	JSR ShiftObjRight
	INC $0E
	JSR SSPipeCheckReplaceTile
	BCS .skip6
	LDA !ObjScratch+$0A
	STA [$6B],y
	LDA !ObjScratch+$0B
	STA [$6E],y
.skip6
.end
	RTS

TallHorzObjTiles:
	dw $0296,$0297,$0298,$0299,$029A,$029B  ; green, enter left
	dw $02AC,$0297,$02AE,$02AD,$029A,$02AF  ; green, enter right
	dw $02A6,$02A7,$02A8,$02A9,$02AA,$02AB  ; blue, both sides
	dw $0296,$02D0,$0298,$0299,$02D1,$029B  ; green, enter left special turn left
	dw $0296,$02D2,$0298,$0299,$02D3,$029B  ; green, enter left special turn up
	dw $0296,$02D4,$0298,$0299,$02D5,$029B  ; green, enter left special turn right
	dw $0296,$02D6,$0298,$0299,$02D7,$029B  ; green, enter left special turn down
	dw $02AC,$02D0,$02AE,$02AD,$02D1,$02AF  ; green, enter right, special turn left
	dw $02AC,$02D2,$02AE,$02AD,$02D3,$02AF  ; green, enter right, special turn up
	dw $02AC,$02D4,$02AE,$02AD,$02D5,$02AF  ; green, enter right, special turn right
	dw $02AC,$02D6,$02AE,$02AD,$02D7,$02AF  ; green, enter right, special turn down
	dw $02A6,$02D8,$02A8,$02A9,$02D9,$02AB  ; blue, special turn left
	dw $02A6,$02DA,$02A8,$02A9,$02DB,$02AB  ; blue, special turn up
	dw $02A6,$02DC,$02A8,$02A9,$02DD,$02AB  ; blue, special turn right
	dw $02A6,$02DE,$02A8,$02A9,$02DF,$02AB  ; blue, special turn down
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $0656,$0657,$0658,$0659,$065A,$065B  ; horizontal pipe, end on left/right. palette 0
	dw $0666,$0667,$0668,$0669,$066A,$066B  ; horizontal pipe, end on left/right. palette 1
	dw $0676,$0677,$0678,$0679,$067A,$067B  ; horizontal pipe, end on left/right. palette 2, slip
	dw $0686,$0687,$0688,$0689,$068A,$068B  ; horizontal pipe, end on left/right. palette 3
	dw $0696,$0697,$0698,$0699,$069A,$069B  ; horizontal pipe, end on left/right. palette 4
	dw $06A6,$06A7,$06A8,$06A9,$06AA,$06AB  ; horizontal pipe, end on left/right. palette 5
	dw $06B6,$06B7,$06B8,$06B9,$06BA,$06BB  ; horizontal pipe, end on left/right. palette 6
	dw $06C6,$06C7,$06C8,$06C9,$06CA,$06CB  ; horizontal pipe, end on left/right. palette 7
	dw $0677,$0677,$0677,$067A,$067A,$067A  ; horizontal pipe, end on left/right. palette 2, slip, no ends
	dw $069E,$02A7,$02A8,$069C,$02AA,$069D  ; blue ss-passable pipe with exit-enabled ends
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF  ; available slot
	dw $0656,$0657,$0658,$065C,$065A,$065D  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 0
	dw $0666,$0667,$0668,$066C,$066A,$066D  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 1
	dw $0676,$0677,$0678,$067C,$067A,$067D  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 2
	dw $0686,$0687,$0688,$068C,$068A,$068D  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 3
	dw $06C6,$0697,$0698,$0699,$069A,$069D  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 4
	dw $06A6,$06A7,$06A8,$06AC,$06AA,$06AD  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 5
	dw $06D6,$06B7,$06B8,$06BC,$06BA,$06BB  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 6
	dw $06C6,$06C7,$06C8,$06CC,$06CA,$06CD  ; horizontal pipe, end on left/right, exit enabled (both ends). palette 7


TallHorzObjects:
	REP #$30
	AND #$00FF
	ASL
	STA $00
	ASL
	ADC $00
	ASL
	TAX
	LDA.w TallHorzObjTiles,x
	STA !ObjScratch
	LDA.w TallHorzObjTiles+2,x
	STA !ObjScratch+$02
	LDA.w TallHorzObjTiles+4,x
	STA !ObjScratch+$04
	LDA.w TallHorzObjTiles+6,x
	STA !ObjScratch+$06
	LDA.w TallHorzObjTiles+8,x
	STA !ObjScratch+$08
	LDA.w TallHorzObjTiles+10,x
	STA !ObjScratch+$0A
	SEP #$30
	JSR StoreNybbles

	LDY !object_position
	JSR BackUpPtrs
	LDA !scratch_obj_width
	BEQ .end
	STZ !ObjScratch+$0C
.LoopH2
	LDX !ObjScratch+$0C
	REP #$20
	LDA !ObjScratch,x
	STA $0A
	LDA !ObjScratch+$02,x
	STA $0C
	LDA !ObjScratch+$04,x
	STA $0E
	SEP #$20
	JSR SSPipeCheckReplaceTile
	BCS .skip1
	LDA $0A
	STA [$6B],y
	LDA $0B
	STA [$6E],y
.skip1
	LDX !scratch_obj_width
	BRA .EndH
.LoopH
	JSR SSPipeCheckReplaceTile
	BCS .skip2
	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y
.skip2
.EndH
	JSR ShiftObjRight
	DEX
	BNE .LoopH
	JSR SSPipeCheckReplaceTile
	BCS .skip3
	LDA $0E
	STA [$6B],y
	LDA $0F
	STA [$6E],y
.skip3
	LDA !ObjScratch+$0C
	BNE .end
	CLC
	ADC #$06
	STA !ObjScratch+$0C
	JSR RestorePtrs
	JSR ShiftObjDown
	BRA .LoopH2
.end
	RTS

; left, center, right, followed by tile to use when block is only 1 tile
HorzObjTiles:
	dw $0384,$0385,$0386,$0387
	dw $0394,$0395,$0396,$0397
	dw $03A4,$03A5,$03A6,$03A7
	dw $03B4,$03B5,$03B6,$03B7
	dw $03C4,$03C5,$03C6,$03C7
	dw $03D4,$03D5,$03D6,$03D7
	dw $03E4,$03E5,$03E6,$03E7
	dw $03F4,$03F5,$03F6,$03F7
	dw $02F0,$02F1,$02F2,$02F3
	dw $0055,$0055,$0055,$0055
	dw $004B,$004C,$004D,$0051  ; smb1 dancing bush 1; use ExGFXF0 in AN2
	dw $004E,$004F,$0050,$0051  ; smb1 dancing bush 2; use ExGFXF0 in AN2
	dw $0056,$0056,$0056,$0056
HorzObjects:
	REP #$30
	AND #$00FF
	ASL #3
	TAX
	LDA.w HorzObjTiles,x
	STA $0A
	LDA.w HorzObjTiles+2,x
	STA $0C
	LDA.w HorzObjTiles+4,x
	STA $0E
	SEP #$30
	JSR StoreNybbles

	LDY $57
	LDA !scratch_obj_width
	BNE .nonzero
	LDA.w HorzObjTiles+6,x
	STA [$6B],y
	LDA.w HorzObjTiles+7,x
	STA [$6E],y
	RTS
.nonzero
	LDX !scratch_obj_width
	LDA $0A
	STA [$6B],y
	LDA $0B
	STA [$6E],y
	BRA .EndH
.LoopH
	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y
.EndH
	JSR ShiftObjRight
	DEX
	BNE .LoopH
	LDA $0E
	STA [$6B],y
	LDA $0F
	STA [$6E],y
.done
	RTS
; top, center, bottom, then the tile to use when one block tall
VertObjTiles:
	dw $0380,$0381,$0382,$0383
	dw $0390,$0391,$0392,$0393
	dw $03A0,$03A1,$03A2,$03A3
	dw $03B0,$03B1,$03B2,$03B3
	dw $03C0,$03C1,$03C2,$03C3
	dw $03D0,$03D1,$03D2,$03D3
	dw $03E0,$03E1,$03E2,$03E3
	dw $03F0,$03F1,$03F2,$03F3
	dw $02F4,$02F5,$02F6,$02F3
	dw $055B,$056B,$056B,$055B
	dw $056A,$056A,$056A,$056A

vert_obj_replace:
	LDA [$6E],y
	BEQ .pg_z
	CMP #$01
	BEQ .pg_1
.end_norepl
	LDA #$00
	RTS
.pg_1
	LDA [$6B],y
	BEQ .ledgerepl
	CMP #$4E
	BNE .end_norepl
	LDA #$EF
	BRA .done_repl
.ledgerepl
	LDA #$F0
	BRA .done_repl
.pg_z
	LDA [$6B],y
	CMP #$04
	BEQ .done_repl_alt
	CMP #$05
	BNE .end_norepl
.done_repl_alt
	LDA #$FF
.done_repl
	RTS
	
VertObjects:
	REP #$30
	AND #$00FF
	ASL #3
	TAX
	LDA VertObjTiles,x
	STA !ObjScratch
	LDA VertObjTiles+2,x
	STA !ObjScratch+$02
	LDA VertObjTiles+4,x
	STA !ObjScratch+$04
	LDA VertObjTiles+6,x
	STA !ObjScratch+$06
	SEP #$30
	JSR StoreNybbles
	LDY !object_position
	LDX !scratch_obj_height
	BEQ .single
	LDA !ObjScratch
	STA [$6B],y
	LDA !ObjScratch+1
	STA [$6E],y
	BRA .next
.loop
	JSR vert_obj_replace
	CLC : ADC !ObjScratch+2
;	LDA !ObjScratch+2
	STA [$6B],y
	LDA !ObjScratch+3
	STA [$6E],y
.next
	JSR ShiftObjDown
	DEX
	BNE .loop
	LDA !ObjScratch+4
	STA [$6B],y
	LDA !ObjScratch+5
	STA [$6E],y
	BRA .done
.single
	LDA !ObjScratch+$06
	STA [$6B],y
	LDA !ObjScratch+$07
	STA [$6E],y
.done
	RTS

DoubleWideVAlternateObjTiles:
	dw $0409,$040A,$040B,$040C,$0419,$041A,$041B,$041C

DoubleWideVertObjAlternateRows:
	ASL #4               ; 8 pointers (shift left 3) at 2 bytes each (8*2 = 16)
	TAX
	STA $0E
	STZ $0F
	JSR StoreNybbles
	JSR BackUpPtrs

	STZ $0A

	LDA !scratch_obj_width
	CMP #$04
	BCC .store
	SEC
	SBC #$03
	ASL #4
	STA $0A
.store
	LDA !scratch_obj_height
	CLC
	ADC $0A
	STA $0A
	LDY !object_position
	STZ $0C
	STZ $0D
.loop
	LDA DoubleWideVAlternateObjTiles,x
	STA [$6B],y
	LDA DoubleWideVAlternateObjTiles+1,x
	STA [$6E],y
	INX #2
	JSR ShiftObjRight
	INC $0D
	LDA $0D
	CMP #$08
	BEQ .next
	CMP #$04
	BNE .loop
	BRA .no_next
.next
	LDX $0E
	STZ $0D
.no_next
	LDA $0C
	CMP $0A
	BEQ .done
	INC $0C
	JSR RestorePtrs
	JSR ShiftObjDown
	BRA .loop
.done
	RTS

DoubleTallHAlternateObjTiles:
;	dw $0429,$0439,$042A,$043A,$042B,$043B,$042C,$043C
	dw $0429,$042B,$0439,$043B,$042A,$042C,$043A,$043C
DoubleTallHorzObjAlternateRows:
	ASL #4               ; 8 pointers (shift left 3) at 2 bytes each (8*2 = 16)
	TAX
	JSR StoreNybbles
	JSR BackUpPtrs


	STZ $0A
	STZ $0E
	STZ $0F

	LDA !scratch_obj_height
	CMP #$04
	BCC .store
	SEC
	SBC #$03
	ASL #4
	STA $0A
.store
	LDA !scratch_obj_width
	CLC
	ADC $0A
	STA !scratch_obj_width
	LDY !object_position
.loopstart
	REP #$30
	LDA DoubleTallHAlternateObjTiles,x
	STA $0A
	LDA DoubleTallHAlternateObjTiles+2,x
	STA $0C
	SEP #$30
.loop
	LDA $0A
	STA [$6B],y
	LDA $0B
	STA [$6E],y
	LDA $0E
	INC $0E
	CMP !scratch_obj_width    ; check width before incrementing
	BEQ .next
	JSR ShiftObjRight

	LDA $0C
	STA [$6B],y
	LDA $0D
	STA [$6E],y

	LDA $0E
	INC $0E
	CMP !scratch_obj_width    ; check width before incrementing
	BEQ .next
	JSR ShiftObjRight
	BRA .loop
.next
	LDA $0F
	CMP #$03
	BEQ .done
	JSR RestorePtrs
	JSR ShiftObjDown
	INC $0F
	INX #4
	STZ $0E
	BRA .loopstart
.done
	RTS

; dimensions of extended objects consisting of a large group of tiles: low nybble is width (minus 1), high nybble is height (minus 1)
ClusterExObjSize:
	db $33,$33,$33,$34,$33,$14,$22
	db $22,$01,$01,$14,$22,$22,$11

; pointers to the tilemaps of extended objects consisting of a large group of tiles (index 00 will use a table starting at the specified scratch RAM address plus 1)
ClusterExObjPtrs:
	dw .WindowEqualDiamondP2
	dw .WindowEqualDiamondP3
	dw .WindowEqualDiamondAltTerrain
	dw .WindowOblongDiamondLTSBP2
	dw .OutsideDiamondAltTerrain
	dw .CenterPipeD
	dw .IceStaircaseLeft
	dw .IceStaircaseRight
	dw .PipeTurnWater1
	dw .PipeTurnWater2
	dw .CenterPipeU
	dw .UpsSteepNormSlopeDecorativeL
	dw .UpsSteepNormSlopeDecorativeR
	dw .SmallFloatingPlat

.WindowEqualDiamondP2
	dw $FFFF,$01ED,$01EC,$FFFF
	dw $01ED,$0457,$0456,$01EC
	dw $01E4,$0441,$0440,$01E2
	dw $FFFF,$01E4,$01E2,$FFFF
.WindowEqualDiamondP3
	dw $FFFF,$0477,$0476,$FFFF
	dw $0477,$0487,$0486,$0476
	dw $0481,$0471,$0470,$0480
	dw $FFFF,$0481,$0480,$FFFF
.WindowEqualDiamondAltTerrain
	dw $FFFF,$0497,$0496,$FFFF
	dw $0497,$04A7,$04A6,$0496
	dw $04A1,$0491,$0490,$04A0
	dw $FFFF,$04A1,$04A0,$FFFF
.WindowOblongDiamondLTSBP2
	dw $FFFF,$044A,$044B,$0446,$FFFF
	dw $0447,$045A,$045B,$0456,$0446
	dw $0451,$0441,$0442,$0443,$0450
	dw $FFFF,$0451,$0452,$0453,$FFFF
.OutsideDiamondAltTerrain
	dw $FFFF,$0490,$0491,$FFFF
	dw $0490,$04A0,$04A1,$0491
	dw $04A6,$0496,$0497,$04A7
	dw $FFFF,$04A6,$04A7,$FFFF
.CenterPipeD
	dw $04EB,$04EC,$04ED,$04EE,$04EF
	dw $04FB,$04FC,$04FD,$04FE,$04FF
.IceStaircaseLeft
	dw $FFFF,$FFFF,$049E
	dw $FFFF,$04BE,$04AE
	dw $04BC,$04BD,$04BE
.IceStaircaseRight
	dw $049E,$FFFF,$FFFF
	dw $04AE,$04BE,$FFFF
	dw $04BE,$04BC,$04BD
.PipeTurnWater1
	dw $031E,$00B9
.PipeTurnWater2
	dw $00B9,$031F
.CenterPipeU
	dw $04CB,$04CC,$04CD,$04CE,$04CF
	dw $04DB,$04DC,$04DD,$04DE,$04DF
.UpsSteepNormSlopeDecorativeL:
	dw $0496,$00EA,$00EA
	dw $04A6,$0498,$0499
	dw $FFFF,$04A8,$04A9
.UpsSteepNormSlopeDecorativeR:
	dw $00EA,$00EA,$0497
	dw $049A,$049B,$04A7
	dw $04AA,$04AB,$FFFF
.SmallFloatingPlat
	dw $0101,$0103
	dw $04A6,$04A7


;------------------------------------------------
; make a non-rectangular arrangement of blocks
;------------------------------------------------
ClusterNormObjects:
	TAY
	LDA ClusterExObjSize,y
	AND #$0F
	STA $03

	TYA
	ASL
	TAY

	LDA !object_dimensions
	AND #$0F
	STA $00
	STA $02

	CLC : SBC $03
	EOR #$FF
;	INC
	ASL
	STA $03

	LDA !object_dimensions
	LSR #4
	STA $01
	BRA ClusterObjsMain
ClusterExObjects:
	TAY
	LDA ClusterExObjSize,y
	PHA
	AND #$0F
	STA $00
	STA $02
	STZ $03
	PLA
	LSR #4
	STA $01
	TYA
	ASL
	TAY
ClusterObjsMain:
	REP #$20
	LDA ClusterExObjPtrs,y
	STA $0A
	SEP #$20
	LDY $57
	JSR BackUpPtrs
.Loop
	REP #$20
	LDA ($0A)
	CMP #$FFFF
	SEP #$20
	BEQ .SkipTile
	STA [$6B],y
	XBA
	STA [$6E],y
.SkipTile
	JSR ShiftObjRight
	REP #$20
	INC $0A                ; \ traverse to the next pointer
	INC $0A                ; /
	SEP #$20
	DEC $00
	BPL .Loop
	JSR RestorePtrs
	JSR ShiftObjDown
	LDA $02
	STA $00

	LDA $03
	BEQ .next
	CLC : ADC $0A
;	DEC : DEC
	STA $0A
.next
	DEC $01
	BPL .Loop
	RTS
