;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 32x32 Boo Block, by imamelia
;;
;; This is...exactly what it says on the tin.  It's a Boo Block that is 32x32 instead of the normal 16x16.
;;
;; Uses first extra bit: NO
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpeedMax:
db $08,$F8

IncTable:
db $01,$FF

Frame:
db $01,$02,$02,$01

Tilemap:
db $C0,$C2,$E0,$E2
db $8A,$AC,$E8,$EA
db $CC,$CE,$EC,$EE

XDisp:
db $00,$10,$00,$10
db $10,$00,$10,$00

YDisp:
db $00,$00,$10,$10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR BooMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BooMain:
%SubOffScreen()

LDA #$10		;
STA $18B6|!Base2	; unknown RAM address?

LDA !14C8,x	;
CMP #$08		; if the sprite is not in normal status...
BNE SkipToGFX	;
LDA $9D		; or sprites are locked...
BEQ ContinueMain	; skip most of the main routine and just run the GFX routine
SkipToGFX:	;
JMP InteractGFX	;

ContinueMain:	;

%SubHorzPos()

LDA !1540,x	; if the timer is set...
BNE NoChangeState	;

LDA #$20			;
STA !1540,x		;
LDA !C2,x		; if the sprite state is zero...
BEQ NoCheckProximity	;
LDA $0E			;
CLC			;
ADC #$0A		;
CMP #$14			;
BCC Skip1		; skip the next part of code if the Boo is within a certain distance
NoCheckProximity:		;
LDA !7FAB10,x		;
AND #$04		; if the extra bit is set...
BNE NoChangeState		; make the Boo always follow the player
STZ !C2,x		;
CPY $76			; if the Boo is facing the player...
BNE NoChangeState		; don't make it follow him/her
INC !C2,x		;
NoChangeState:		;

LDA $0E			;
CLC			;
ADC #$0A		;
CMP #$14			;
BCC Skip1		;

LDA !15AC,x		; if the sprite is turning...
BNE Skip2			; skip the check and set
TYA			;
CMP !157C,x		;
BEQ Skip1			;
LDA #$1F			;
STA !15AC,x		; set the turn timer
BRA Skip2			;

Skip1:

STZ !1602,x		;
LDA !C2,x		;
BEQ Skip3			;
LDA #$03			;
STA !1602,x		;
INC !1570,x		;
LDA !1570,x		;
BNE NoSetTimer2		;
LDA #$20			;
STA !1558,x		;
NoSetTimer2:		;
LDA !B6,x		; increment or decrement the sprite X speed
BEQ XSpdZero		; depending on whether it is positive, negative, or zero
BPL XSpdPlus		;
INC			;
INC			;
XSpdPlus:			;
DEC			;
XSpdZero:			;
STA !B6,x			;
LDA !AA,x		; same for the Y speed
BEQ YSpdZero		;
BPL YSpdPlus		;
INC			;
INC			;
YSpdPlus:			;
DEC			;
YSpdZero:			;
STA !AA,x		;

Skip4:
JMP UpdatePosition

Skip2:

CMP #$10		;
BNE NoFlipDir	;
PHA		;
LDA !157C,x	;
EOR #$01		; flip sprite direction
STA !157C,x	;
PLA		;
NoFlipDir:	;
LSR #3		;
TAY		;
LDA Frame,y	;
STA !1602,x	;

Skip3:

STZ !1570,x	;
LDA $13		;
AND #$07	; skip this every 8 frames
BNE UpdatePosition	;

%SubHorzPos()

LDA !B6,x	;
CMP SpeedMax,y	;
BEQ NoIncXSpeed	;
CLC		;
ADC IncTable,y	;
STA !B6,x		;
NoIncXSpeed:	;

LDA $D3		;
PHA		;
SEC		;
SBC $18B6|!Base2	;
STA $D3		;
LDA $D4		;
PHA		;
SBC #$00		;
STA $D4		;

LDY #$00
LDA $D3
SEC
SBC $D8,x
STA $0E
LDA $D4
SBC $14D4,x
BPL +
INY
+

PLA		;
STA $D4		;
PLA		;
STA $D3		;

LDA !AA,x	;
CMP SpeedMax,y	;
BEQ UpdatePosition	;
CLC		;
ADC IncTable,y	;
STA !AA,x	;

UpdatePosition:

JSL $018022	;
JSL $01801A	;

InteractGFX:	;

; removed sprite number check
LDA !B6,x	;
BPL NoFlipSpeedVal	;
EOR #$FF		;
INC		;
NoFlipSpeedVal:	;
LDY #$00		;
CMP #$08		; if the sprite's speed is 08 or greater, then it is not solid
BCS NotSolid	;

PHA		;
LDA !1662,x	; preserve the sprite clipping
PHA		;
LDA !167A,x	;
PHA		; and the fourth Tweaker byte
ORA #$80		;
STA !167A,x	; set the non-default interaction bit
LDA #$2E		;
STA !1662,x	; sprite clipping = 2E

JSL $01B44F	; make the sprite solid

PLA		;
STA !167A,x	;
PLA		;
STA !1662,x	;
PLA		;
LDY #$01		;
CMP #$04		; if the sprite speed is 01-03...
BCS SetFrame	; then the frame is 01
INY		; if the sprite is completely stationary, the frame is 02
BRA SetFrame	;     

NotSolid:		;

LDA !14C8,x	;
CMP #$08		; don't interact if the sprite is not in normal status
BNE SetFrame	;
PHY		;
JSL $01A7DC	; interact with the player
PLY		;            

SetFrame:
TYA		;
STA !1602,x	;
JSR BooBlockGFX	;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BooBlockGFX:	;

%GetDrawInfo()

LDA !157C,x	;
EOR #$01		;
ASL #2		;
STA $05		;
ASL #4		;
ORA !15F6,x	;
STA $02		;

LDA !1602,x	;
ASL #2		;
STA $04		;

LDA #$03		;
STA $03		; $03 = current tile of the 4
TSB $05		;
TSB $04		; $04 = current tile of the 12

GFXLoop:		;

LDX $04		;
LDA Tilemap,x	; set the sprite tilemap
STA $0302|!Base2,y	;

LDX $05		;
LDA $00		;
CLC		;
ADC XDisp,x	;
STA $0300|!Base2,y	; set X displacement
LDX $03		;
LDA $01		;
CLC		;
ADC YDisp,x	;
STA $0301|!Base2,y	; set Y displacement

LDA $02		;
ORA $64		;
STA $0303|!Base2,y	;

INY #4		;
DEC $05		;
DEC $04		;
DEC $03		;
BPL GFXLoop	;

LDX $15E9|!Base2	;
LDY #$02		;
LDA #$03		;
JSL $01B7B3	;
RTS

