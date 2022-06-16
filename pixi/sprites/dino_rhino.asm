prot DinoRhinoGFX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fire Breathing Dino Rhino, by mikeyk
;;
;; Description: This Dino Rhino is similar to the original, but he spits fire like the
;; Dino Torch.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!ExtraBits = !7FAB10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite initialization JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "INIT ",pc
	%SubHorzPos()
	TYA
	STA !157C,x
	LDA #$02                ;A:9D00 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdiZcHC:0890 VC:068 00 FL:5641
	STA !C2,x
	RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	print "MAIN ",pc
	PHB                     ; \
	PHK                     ;  | main sprite function, just calls local subroutine
	PLB                     ;  |
	JSR START_SPRITE_CODE   ;  |
	PLB                     ;  |
	RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!TorchSpriteNum = $6F
	
START_SPRITE_CODE:
	JSR SUB_RHINO_GFX       ;A:876E X:0007 Y:0000 D:0000 DB:03 S:01EF P:envMXdizCHC:1104 VC:086 00 FL:2316
	LDA !9E,x
	CMP #!TorchSpriteNum
	BNE NO_TORCH
	LDA !ExtraBits,x
	AND #$F7
	STA !ExtraBits,x
NO_TORCH:
	LDA $9D                 ;A:00F0 X:0007 Y:00FC D:0000 DB:03 S:01EF P:envMXdizcHC:0220 VC:096 00 FL:2316
	BNE RETURN_8            ;A:0000 X:0007 Y:00FC D:0000 DB:03 S:01EF P:envMXdiZcHC:0244 VC:096 00 FL:2316
	LDA !14C8,x             ;A:0000 X:0007 Y:00FC D:0000 DB:03 S:01EF P:envMXdiZcHC:0260 VC:096 00 FL:2316
	CMP #$08                ;A:0008 X:0007 Y:00FC D:0000 DB:03 S:01EF P:envMXdizcHC:0292 VC:096 00 FL:2316
	BNE RETURN_8            ;A:0008 X:0007 Y:00FC D:0000 DB:03 S:01EF P:envMXdiZCHC:0308 VC:096 00 FL:2316
	LDY #$06                ; change to LDA #$03 if using Jack's SubOffScreen macro
	%SubOffScreen()         ; decide whether to process offscreen
	JSL $01A7DC             ; contact with mario?
	JSL $01802A             ; update position based on speed values?
	LDA !C2,x               ;A:3000 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0606 VC:101 00 FL:2316
	BEQ SUB9CA8
	CMP #$03
	BEQ SUB9C74
	JMP SUB9D41

X_OFFSET_LOW:
	db $00,$FE,$02
X_OFFSET_HIGH:
	db $00,$FF,$00
	
SUB9C74:
	LDA !AA,x
	BMI LABEL29
	STZ !C2,x
	LDA !1588,x
	AND #$03
	BEQ LABEL29
	LDA !157C,x
	EOR #$01
	STA !157C,x

LABEL29:
	STZ !1602,x             ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZcHC:0012 VC:075 00 FL:2544
	LDA !1588,x             ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZcHC:0044 VC:075 00 FL:2544
	AND #$03                ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZcHC:0076 VC:075 00 FL:2544
	TAY                     ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZcHC:0092 VC:075 00 FL:2544
	LDA !E4,x               ;A:9C00 X:0007 Y:0000 D:0000 DB:03 S:01EF P:envMXdiZcHC:0106 VC:075 00 FL:2544
	CLC                     ;A:9C97 X:0007 Y:0000 D:0000 DB:03 S:01EF P:eNvMXdizcHC:0136 VC:075 00 FL:2544
	ADC X_OFFSET_LOW,y      ;A:9C97 X:0007 Y:0000 D:0000 DB:03 S:01EF P:eNvMXdizcHC:0150 VC:075 00 FL:2544
	STA !E4,x               ;sprite x low ;A:9C97 X:0007 Y:0000 D:0000 DB:03 S:01EF P:eNvMXdizcHC:0182 VC:075 00 FL:2544
	LDA !14E0,x             ;A:9C97 X:0007 Y:0000 D:0000 DB:03 S:01EF P:eNvMXdizcHC:0212 VC:075 00 FL:2544
	ADC X_OFFSET_HIGH,y     ;A:9C00 X:0007 Y:0000 D:0000 DB:03 S:01EF P:envMXdiZcHC:0244 VC:075 00 FL:2544
	STA !14E0,x             ;sprite x high ;A:9C00 X:0007 Y:0000 D:0000 DB:03 S:01EF P:envMXdiZcHC:0276 VC:075 00 FL:2544
RETURN_8:
	RTS                     ;A:9C00 X:0007 Y:0000 D:0000 DB:03 S:01EF P:envMXdiZcHC:0308 VC:075 00 FL:2544

RHINO_SPEED:
	db $08,$F8,$10,$F0

SUB9CA8:
	LDA !1588,x             ;A:9CA8 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:1238 VC:101 00 FL:2317
	AND #$04                ;A:9C04 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:1270 VC:101 00 FL:2317
	BEQ LABEL29             ;A:9C04 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:1286 VC:101 00 FL:2317
	LDA !1540,x             ;A:9C04 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:1302 VC:101 00 FL:2317
	BNE NO_FLAME            ;A:9CFE X:0007 Y:0002 D:0000 DB:03 S:01EF P:eNvMXdizcHC:1334 VC:101 00 FL:2317
	LDA #$FF                ; \ set fire breathing timer
	STA !1540,x             ; / 
	JSL $01ACF9             ;A;:9CFF X:0007 Y:0001 D:0000 DB:03 S:01EF P:eNvMXdizCHC:0092 VC:082 00 FL:1597
	AND #$01                ;A:9C05 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:0056 VC:083 00 FL:1597
	INC                     ;A:9C01 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:0072 VC:083 00 FL:1597
	STA !C2,x               ;A:9C02 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:0086 VC:083 00 FL:1597
NO_FLAME:
	TXA                     ;A:9CFE X:0007 Y:0002 D:0000 DB:03 S:01EF P:eNvMXdizcHC:1356 VC:101 00 FL:2317
	ASL #4                  ;A:9C38 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0044 VC:102 00 FL:2317
	ADC $14                 ;A:9C70 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0058 VC:102 00 FL:2317
	AND #$3F                ;A:9C78 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0082 VC:102 00 FL:2317
	BNE LABEL30             ;A:9C38 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0098 VC:102 00 FL:2317
	%SubHorzPos()           ; \ if not facing mario, change directions
	TYA                     ; |
	STA !157C,x             ; /
LABEL30:
	LDA #$10                ;A:9C38 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0120 VC:102 00 FL:2317
	STA !AA,x               ;A:9C10 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0136 VC:102 00 FL:2317
	LDY !157C,x             ; \ set x speed for rhino based on direction and sprite number
	LDA RHINO_SPEED,y       ; | 
	STA !B6,x               ; / 
	JSR SUB_SET_FRAME       ;A:9CF8 X:0007 Y:0001 D:0000 DB:03 S:01EF P:eNvMXdizCHC:0328 VC:102 00 FL:2317
	LDA !1588,x             ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZcHC:0584 VC:102 00 FL:2317
	AND #$03                ;A:9C04 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:0616 VC:102 00 FL:2317
	BEQ LABEL32             ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZcHC:0632 VC:102 00 FL:2317
	LDA #$C0                ;A:9C02 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:1240 VC:078 00 FL:2864
	STA !AA,x               ;A:9CC0 X:0007 Y:0001 D:0000 DB:03 S:01EF P:eNvMXdizcHC:1256 VC:078 00 FL:2864
	LDA #$03                ;A:9CC0 X:0007 Y:0001 D:0000 DB:03 S:01EF P:eNvMXdizcHC:1286 VC:078 00 FL:2864
	STA !C2,x               ;A:9C03 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:1302 VC:078 00 FL:2864
LABEL32:
	RTS                     ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdiZcHC:0654 VC:102 00 FL:2317


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fire breathing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
FLAME_TABLE:
	db $41,$42,$42,$32,$22,$12,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$12,$22,$32,$42,$42,$42,$42,$41,$41
	
	db $41,$43,$43,$33,$23,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
	db $03,$03,$03,$03,$03,$03,$03,$13,$23,$33,$43,$43,$43,$43,$41,$41                    
	
SUB9D41:
	STZ !B6,x               ; no x speed while breating fire
	LDA !1540,x             ;A:9D41 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:1082 VC:085 00 FL:4601
	BNE TIMER_SET           ;A:9DFF X:0007 Y:0001 D:0000 DB:03 S:01EF P:eNvMXdizcHC:1114 VC:085 00 FL:4601
	STZ !C2,x               ;A:9D00 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdiZcHC:0860 VC:068 00 FL:5641
	LDA #$40                ;A:9D00 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdiZcHC:0890 VC:068 00 FL:5641
	STA !1540,x             ;A:9D40 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0906 VC:068 00 FL:5641
	LDA #$00                ;A:9D40 X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:0938 VC:068 00 FL:5641
TIMER_SET:
	CMP #$C0                ;A:9DFF X:0007 Y:0001 D:0000 DB:03 S:01EF P:eNvMXdizcHC:1136 VC:085 00 FL:4601
	BNE LABEL46             ;A:9DFF X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizCHC:1152 VC:085 00 FL:4601
	LDY #$17                ; \ play fire breathing sound
	STY $1DFC|!Base2        ; /
LABEL46:
	LSR #3                  ;A:9D3F X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizCHC:1202 VC:085 00 FL:4601
	LDY !C2,x               ;A:9D1F X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizCHC:1216 VC:085 00 FL:4601
	CPY #$02                ;A:9D1F X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizCHC:1246 VC:085 00 FL:4601
	BNE LABEL47             ;A:9D1F X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdiZCHC:1262 VC:085 00 FL:4601
	CLC                     ;A:9D1F X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdiZCHC:1278 VC:085 00 FL:4601
	ADC #$20                ;A:9D1F X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdiZcHC:1292 VC:085 00 FL:4601
LABEL47:
	TAY                     ;A:9D3F X:0007 Y:0002 D:0000 DB:03 S:01EF P:envMXdizcHC:1308 VC:085 00 FL:4601
	LDA FLAME_TABLE,y       ;A:9D3F X:0007 Y:003F D:0000 DB:03 S:01EF P:envMXdizcHC:1322 VC:085 00 FL:4601
	PHA                     ;A:9D41 X:0007 Y:003F D:0000 DB:03 S:01EF P:envMXdizcHC:1354 VC:085 00 FL:4601
	AND #$0F                ;A:9D41 X:0007 Y:003F D:0000 DB:03 S:01EE P:envMXdizcHC:0008 VC:086 00 FL:4601
	STA !1602,x             ;A:9D01 X:0007 Y:003F D:0000 DB:03 S:01EE P:envMXdizcHC:0024 VC:086 00 FL:4601
	PLA                     ;A:9D01 X:0007 Y:003F D:0000 DB:03 S:01EE P:envMXdizcHC:0056 VC:086 00 FL:4601
	LSR #4                  ;A:9D08 X:0007 Y:003F D:0000 DB:03 S:01EF P:envMXdizcHC:0126 VC:086 00 FL:4601
	STA !151C,x             ;A:9D04 X:0007 Y:003F D:0000 DB:03 S:01EF P:envMXdizcHC:0140 VC:086 00 FL:4601
	BNE RETURN_10           ;A:9D04 X:0007 Y:003F D:0000 DB:03 S:01EF P:envMXdizcHC:0172 VC:086 00 FL:4601
	TXA                     ;A:9D6F X:0007 Y:0036 D:0000 DB:03 S:01EF P:envMXdizCHC:0406 VC:076 00 FL:4909
	EOR $13                 ;A:9D07 X:0007 Y:0036 D:0000 DB:03 S:01EF P:envMXdizCHC:0420 VC:076 00 FL:4909
	AND #$03                ;A:9DEE X:0007 Y:0036 D:0000 DB:03 S:01EF P:eNvMXdizCHC:0444 VC:076 00 FL:4909
	BNE RETURN_10           ;A:9D02 X:0007 Y:0036 D:0000 DB:03 S:01EF P:envMXdizCHC:0460 VC:076 00 FL:4909
	JSR SUB_FLAME_CLIP      ;A:9D00 X:0007 Y:0036 D:0000 DB:03 S:01EF P:envMXdiZCHC:0398 VC:077 00 FL:4917
	JSL $03B664             ;A:9D24 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizCHC:1104 VC:077 00 FL:4917
	JSL $03B72B             ;A:9D01 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:0694 VC:078 00 FL:4917
	BCC RETURN_10           ;A:9D30 X:0007 Y:0001 D:0000 DB:03 S:01EF P:envMXdizcHC:0272 VC:079 00 FL:4917
	LDA $1490|!Base2        ; \ flame doesn't hurt mario if has star
	BNE RETURN_10           ; /
	JSL $00F5B7             ; hurt mario
RETURN_10:
	RTS                     ;A:9D04 X:0007 Y:003F D:0000 DB:03 S:01EF P:envMXdizcHC:0194 VC:086 00 FL:4601


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $9DB6 - make flames deadly!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;facing left sideways, facing left up, facing right sideways, facing right up
FLAME1:
	db $DC,$FB,$10,$FB     ;x displacement, low
FLAME2:
	db $FF,$FF,$00,$FF     ;x displacement, high
FLAME3:
	db $24,$0C,$24,$0C
FLAME4:
	db $02,$D2,$02,$D2     ;y displacement, low
FLAME5:
	db $00,$FF,$00,$FF     ;y displacement, high
FLAME6:
	db $0C,$24,$0C,$24

SUB_FLAME_CLIP:
	LDA !1602,x             ;A:9D00 X:0007 Y:0036 D:0000 DB:03 S:01ED P:envMXdiZCHC:0444 VC:077 00 FL:4918
	SEC                     ;A:9D03 X:0007 Y:0036 D:0000 DB:03 S:01ED P:envMXdizCHC:0476 VC:077 00 FL:4918
	SBC #$02                ;A:9D03 X:0007 Y:0036 D:0000 DB:03 S:01ED P:envMXdizCHC:0490 VC:077 00 FL:4918
	TAY                     ;A:9D01 X:0007 Y:0036 D:0000 DB:03 S:01ED P:envMXdizCHC:0506 VC:077 00 FL:4918
	LDA !157C,x             ;A:9D01 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0520 VC:077 00 FL:4918
	BNE LABEL49             ;A:9D01 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0552 VC:077 00 FL:4918
	INY #2                  ;
LABEL49:
	LDA !E4,x               ;A:9D01 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0574 VC:077 00 FL:4918
	CLC                     ;A:9D71 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0604 VC:077 00 FL:4918
	ADC FLAME1,y            ;A:9D71 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0618 VC:077 00 FL:4918
	STA $04                 ;A:9D73 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0650 VC:077 00 FL:4918
	LDA !14E0,x             ;A:9D73 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0674 VC:077 00 FL:4918
	ADC FLAME2,y            ;A:9D00 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0706 VC:077 00 FL:4918
	STA $0A                 ;A:9D00 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0738 VC:077 00 FL:4918
	LDA FLAME3,y            ;A:9D00 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0762 VC:077 00 FL:4918
	STA $06                 ;A:9D0C X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0794 VC:077 00 FL:4918
	LDA !D8,x               ;A:9D0C X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0818 VC:077 00 FL:4918
	CLC                     ;A:9D70 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0848 VC:077 00 FL:4918
	ADC FLAME4,y            ;A:9D70 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:0862 VC:077 00 FL:4918
	STA $05                 ;A:9D4C X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0894 VC:077 00 FL:4918
	LDA !14D4,x             ;A:9D4C X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0918 VC:077 00 FL:4918
	ADC FLAME5,y            ;A:9D01 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0950 VC:077 00 FL:4918
	STA $0B                 ;A:9D01 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0982 VC:077 00 FL:4918
	LDA FLAME6,y            ;A:9D01 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:1006 VC:077 00 FL:4918
	STA $07                 ;A:9D24 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:1038 VC:077 00 FL:4918
	RTS                     ;A:9D24 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:1062 VC:077 00 FL:4918


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unknown routine - specific
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;org $039DEF

SUB_SET_FRAME:
	INC !1570,x             ;A:9CF8 X:0007 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:0374 VC:102 00 FL:2318
	LDA !1570,x             ;A:9CF8 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0420 VC:102 00 FL:2318
	AND #$08                ;A:9C01 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdizCHC:0452 VC:102 00 FL:2318
	LSR #3                  ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0496 VC:102 00 FL:2318
	STA !1602,x             ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0510 VC:102 00 FL:2318
	RTS                     ;A:9C00 X:0007 Y:0001 D:0000 DB:03 S:01ED P:envMXdiZcHC:0542 VC:102 00 FL:2318


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dino rhino and dino torch graphics - specific
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DT_X_OFFSET:        db $D6,$DE,$EA,$F6,$00,$FB,$FB,$FB,$FB,$00 
DT_Y_OFFSET:        db $FC,$FC,$FC,$FC,$00,$CC,$D4,$E0,$EC,$00
DT_FIRE_TILEMAP:    db $80,$82,$84,$86,$00,$88,$8A,$8C,$8E,$00 
DT_PROP:            db $09,$05,$05,$05,$0F 

DR_X_OFFSET:        db $F8,$08,$F8,$08,$08,$F8,$08,$F8 
DR_PROP:            db $0F,$0F,$0F,$0F,$4F,$4F,$4F,$4F             ;dino rhino properties, xyppccct
DR_Y_OFFSET:        db $F0,$F0,$00,$00
;DR_TILEMAP:         db $C0,$C2,$E4,$E6,$C0,$C2,$E0,$E2,$C8,$CA,$E8,$E2,$CC,$CE,$EC,$EE
;DR_TILEMAP:
;	db $C0,$C2,$E4,$E6,$C0,$C2,$E0,$E2,$C8,$CA,$E8,$E2,$CC,$CE,$EC,$EE
tile_offsets:
db $00,$02,$20,$22


FRAMES_WRITTEN:     db $07,$06,$05,$04,$03
NOGFX:
	RTS
	
SUB_RHINO_GFX:
	%GetDrawInfo()          ;A:876E X:0007 Y:0000 D:0000 DB:03 S:01ED P:envMXdizCHC:0806 VC:079 00 FL:524
	LDA !157C,x             ;A:0040 X:0007 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0686 VC:080 00 FL:524
	STA $02                 ;A:0001 X:0007 Y:00EC D:0000 DB:03 S:01ED P:envMXdizcHC:0718 VC:080 00 FL:524

	REP #$10
	LDA !1602,x
	STA $04
	LDX.w #DinoRhinoGFX
	%GetDynSlot()
	BCC NOGFX
	STA $0E

	LDA !151C,x             ; now draw the flame
	STA $03                 ;A:0004 X:0007 Y:00EC D:0000 DB:03 S:01ED P:enVMXdizCHC:0842 VC:058 00 FL:4606
	LDA !1602,x             ;A:0004 X:0007 Y:00EC D:0000 DB:03 S:01ED P:enVMXdizCHC:0866 VC:058 00 FL:4606
	STA $04                 ;A:0001 X:0007 Y:00EC D:0000 DB:03 S:01ED P:enVMXdizCHC:0898 VC:058 00 FL:4606
	PHX                     ;A:0001 X:0007 Y:00EC D:0000 DB:03 S:01ED P:enVMXdizCHC:0922 VC:058 00 FL:4606
	LDA $14                 ;A:0001 X:0007 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizCHC:0944 VC:058 00 FL:4606
	AND #$02                ;A:0097 X:0007 Y:00EC D:0000 DB:03 S:01EC P:eNVMXdizCHC:0968 VC:058 00 FL:4606
	ASL #5                  ;A:0020 X:0007 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:1040 VC:058 00 FL:4606
	LDX $04                 ;A:0040 X:0007 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:1054 VC:058 00 FL:4606
	CPX #$03                ;A:0040 X:0001 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:1078 VC:058 00 FL:4606
	BEQ LABEL35             ;A:0040 X:0001 Y:00EC D:0000 DB:03 S:01EC P:eNVMXdizcHC:1094 VC:058 00 FL:4606
	ASL                     ;A:0040 X:0001 Y:00EC D:0000 DB:03 S:01EC P:eNVMXdizcHC:1110 VC:058 00 FL:4606
LABEL35:
	STA $05                 ;A:0080 X:0001 Y:00EC D:0000 DB:03 S:01EC P:eNVMXdizcHC:1124 VC:058 00 FL:4606

	LDX #$03                ;A:0080 X:0001 Y:00EC D:0000 DB:03 S:01EC P:eNVMXdizcHC:1148 VC:058 00 FL:4606
LABEL40:
	CPX $03                 ;A:002F X:0003 Y:00F0 D:0000 DB:03 S:01EC P:envMXdizCHC:0630 VC:059 00 FL:4606
	BMI DRAW_RHINO
	STX $06                 ;A:0080 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:1164 VC:058 00 FL:4606
	LDA $04                 ;A:0080 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:1188 VC:058 00 FL:4606
	CMP #$03                ;A:0001 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:1212 VC:058 00 FL:4606
	BNE LABEL36             ;A:0001 X:0004 Y:00EC D:0000 DB:03 S:01EC P:eNVMXdizcHC:1228 VC:058 00 FL:4606
	TXA                     ;A:0003 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdiZCHC:0814 VC:059 00 FL:4680
	CLC                     ;A:0004 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizCHC:0828 VC:059 00 FL:4680
	ADC #$05                ;A:0004 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:0842 VC:059 00 FL:4680
	TAX                     ;A:0009 X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:0858 VC:059 00 FL:4680
LABEL36:
	PHX                     ;A:0001 X:0004 Y:00EC D:0000 DB:03 S:01EC P:eNVMXdizcHC:1250 VC:058 00 FL:4606
	LDA DT_X_OFFSET,x       ;A:0001 X:0004 Y:00EC D:0000 DB:03 S:01EB P:eNVMXdizcHC:1272 VC:058 00 FL:4606
	LDX $02                 ;A:0000 X:0004 Y:00EC D:0000 DB:03 S:01EB P:enVMXdiZcHC:1304 VC:058 00 FL:4606
	BNE LABEL37             ;A:0000 X:0001 Y:00EC D:0000 DB:03 S:01EB P:enVMXdizcHC:1328 VC:058 00 FL:4606
	EOR #$FF                ;
	INC                     ;
LABEL37:
	PLX                     ;A:0000 X:0001 Y:00EC D:0000 DB:03 S:01EB P:enVMXdizcHC:1350 VC:058 00 FL:4606
	CLC                     ;A:0000 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:0010 VC:059 00 FL:4606
	ADC $00                 ;A:0000 X:0004 Y:00EC D:0000 DB:03 S:01EC P:enVMXdizcHC:0024 VC:059 00 FL:4606
	STA $0300|!Base2,y      ;A:0071 X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:0048 VC:059 00 FL:4606
	LDA DT_Y_OFFSET,x       ;A:0071 X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:0080 VC:059 00 FL:4606
	CLC                     ;A:0000 X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZcHC:0112 VC:059 00 FL:4606
	ADC $01                 ;A:0000 X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZcHC:0126 VC:059 00 FL:4606
	STA $0301|!Base2,y      ;A:00B0 X:0004 Y:00EC D:0000 DB:03 S:01EC P:eNvMXdizcHC:0150 VC:059 00 FL:4606
LABEL38:
	LDA DT_FIRE_TILEMAP,x   ;A:0003 X:0008 Y:00F0 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0972 VC:059 00 FL:4817
	STA $0302|!Base2,y      ;A:00AA X:0001 Y:00EC D:0000 DB:03 S:01EC P:eNvMXdizCHC:0316 VC:059 00 FL:4606
	LDA #$00                ;A:00AA X:0001 Y:00EC D:0000 DB:03 S:01EC P:eNvMXdizCHC:0348 VC:059 00 FL:4606
	LDX $02                 ;A:0000 X:0001 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZCHC:0364 VC:059 00 FL:4606
	BNE LABEL41             ;A:0000 X:0001 Y:00EC D:0000 DB:03 S:01EC P:envMXdizCHC:0388 VC:059 00 FL:4606
	ORA #$40                ;
LABEL41:
	LDX $06                 ;A:0000 X:0001 Y:00EC D:0000 DB:03 S:01EC P:envMXdizCHC:0410 VC:059 00 FL:4606
	EOR $05                 ;A:0000 X:0003 Y:00F0 D:0000 DB:03 S:01EC P:eNvMXdizcHC:1210 VC:059 00 FL:4817
	ORA DT_PROP,x           ;A:0000 X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZCHC:0472 VC:059 00 FL:4606
	ORA $64                 ;A:000F X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdizCHC:0504 VC:059 00 FL:4606
	STA $0303|!Base2,y      ;A:002F X:0004 Y:00EC D:0000 DB:03 S:01EC P:envMXdizCHC:0528 VC:059 00 FL:4606
	INY #4                  ;A:002F X:0004 Y:00EF D:0000 DB:03 S:01EC P:eNvMXdizCHC:0602 VC:059 00 FL:4606
	DEX                     ;A:002F X:0004 Y:00F0 D:0000 DB:03 S:01EC P:eNvMXdizCHC:0616 VC:059 00 FL:4606
	CPX $03                 ;A:002F X:0003 Y:00F0 D:0000 DB:03 S:01EC P:envMXdizCHC:0630 VC:059 00 FL:4606
	BPL LABEL40             ;A:002F X:0003 Y:00F0 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0654 VC:059 00 FL:4606

DRAW_RHINO:
	PHX                     ;A:006E X:0007 Y:00EC D:0000 DB:03 S:01ED P:eNvMXdizcHC:0860 VC:080 00 FL:524
	LDX #$03                ;draw dino rhino first
LABEL33:
	STX $0F                 ;A:006E X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:0898 VC:080 00 FL:524
	LDA $02                 ;A:006E X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:0922 VC:080 00 FL:524
	CMP #$01                ;A:0001 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:0946 VC:080 00 FL:524
	BCS LABEL34             ;A:0001 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZCHC:0962 VC:080 00 FL:524
	TXA                     ;A:0002 X:0004 Y:0000 D:0000 DB:00 S:01F5 P:envMXdizcHC:0626 VC:049 00 FL:6024
	CLC                     ;A:0004 X:0004 Y:0000 D:0000 DB:00 S:01F5 P:envMXdizcHC:0640 VC:049 00 FL:6024
	ADC #$04                ;A:0004 X:0004 Y:0000 D:0000 DB:00 S:01F5 P:envMXdizcHC:0654 VC:049 00 FL:6024
	TAX                     ;A:0094 X:0004 Y:0000 D:0000 DB:00 S:01F5 P:eNvMXdizcHC:0670 VC:049 00 FL:6024
LABEL34:
	LDA DR_PROP,x           ;A:0001 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZCHC:0984 VC:080 00 FL:524
	ORA $64
	STA $0303|!Base2,y      ;A:002F X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizCHC:1016 VC:080 00 FL:524
	LDA DR_X_OFFSET,x       ;A:002F X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizCHC:1048 VC:080 00 FL:524
	CLC                     ;A:0008 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizCHC:1080 VC:080 00 FL:524
	ADC $00                 ;A:0008 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:1094 VC:080 00 FL:524
	STA $0300|!Base2,y      ;A:00B8 X:0003 Y:00EC D:0000 DB:03 S:01EC P:eNvMXdizcHC:1118 VC:080 00 FL:524
	LDA $04                 ;A:00B8 X:0003 Y:00EC D:0000 DB:03 S:01EC P:eNvMXdizcHC:1150 VC:080 00 FL:524
	CMP #$01                ;A:0000 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZcHC:1174 VC:080 00 FL:524
	LDX $0F                 ;A:0000 X:0003 Y:00EC D:0000 DB:03 S:01EC P:eNvMXdizcHC:1190 VC:080 00 FL:524
	LDA DR_Y_OFFSET,x       ;A:0000 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:1214 VC:080 00 FL:524
	ADC $01                 ;A:0000 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdiZcHC:1246 VC:080 00 FL:524
	STA $0301|!Base2,y      ;A:0040 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:1270 VC:080 00 FL:524
	LDA $0E                 ;A:0040 X:0003 Y:00EC D:0000 DB:03 S:01EC P:envMXdizcHC:1302 VC:080 00 FL:524
	LDX $0F
	CLC : ADC tile_offsets,x
	STA $0302|!Base2,y      ;A:00E6 X:0003 Y:00EC D:0000 DB:03 S:01EC P:eNvMXdizcHC:0056 VC:081 00 FL:524
	INY #4                  ;A:00E6 X:0003 Y:00EF D:0000 DB:03 S:01EC P:eNvMXdizcHC:0130 VC:081 00 FL:524
	LDX $0F                 ;A:00E6 X:0003 Y:00F0 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0144 VC:081 00 FL:524
	DEX                     ;A:00E6 X:0003 Y:00F0 D:0000 DB:03 S:01EC P:envMXdizcHC:0168 VC:081 00 FL:524
	BPL LABEL33             ;A:00E6 X:0002 Y:00F0 D:0000 DB:03 S:01EC P:envMXdizcHC:0182 VC:081 00 FL:524
	PLX                     ;A:00C0 X:00FF Y:00FC D:0000 DB:03 S:01EC P:eNvMXdizcHC:0204 VC:083 00 FL:524

DONE:

	PLX                     ;A:002F X:0003 Y:00F0 D:0000 DB:03 S:01EC P:eNvMXdizcHC:0670 VC:059 00 FL:4606
	LDY !151C,x             ;A:002F X:0007 Y:00F0 D:0000 DB:03 S:01ED P:envMXdizcHC:0698 VC:059 00 FL:4606
	LDA FRAMES_WRITTEN,y    ;A:002F X:0007 Y:0004 D:0000 DB:03 S:01ED P:envMXdizcHC:0730 VC:059 00 FL:4606
	LDY #$02                ;A:0000 X:0007 Y:0004 D:0000 DB:03 S:01ED P:envMXdiZcHC:0762 VC:059 00 FL:4606
	%FinishOAMWrite()
	RTS                     ;A:0170 X:0007 Y:00F0 D:0000 DB:03 S:01ED P:envMXdizcHC:0846 VC:061 00 FL:4606
DinoRhinoGFX:
incbin "dino_rhino.bin"
