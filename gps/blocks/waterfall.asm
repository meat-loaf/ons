incsrc "../../asm/main.asm"

;Acts like 130 or 100 depending on if you want Mario to be able to jump up through it.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
HeadInside:
BodyInside:

LDA #!frames_before_waterfall_reset
STA !waterfall_reset_drop_timer|!addr

LDA !waterfall_drop_timer|!addr
EOR $14
AND #$01
BEQ +
EOR !waterfall_drop_timer|!addr         ;so it won't go double speed if Mario is on two of those
INC A
INC A
BMI nostore
STA !waterfall_drop_timer|!addr
nostore:
LDA $14
AND #$07
BNE +
JSR Splash
+

LDA !waterfall_drop_timer|!addr
CMP #$40
BCC Return

LDA $7D
BMI ++

LDA !waterfall_drop_timer|!addr
SEC
SBC #$40
LSR #2
BPL +
LDA #$00
+
STA $7D

LDA $16
BPL ++;allow jumping up while falling down
LDA #$B0
STA $7D
LDA #$01
STA $1DFA|!addr
LDA #$50
STA $149F|!addr
LDA #$0B
STA $72
++

LDA #$25
STA $1693|!addr
LDY #$00

Return:
SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL


Splash:
PHY
LDY #$0B
.Loop
LDA $17F0|!addr,y
BEQ .Found
DEY
BPL .Loop
PLY
RTS

.Found
LDA $D3
CLC
ADC #$18
STA $17FC|!addr,y
LDA $D1
STA $1808|!addr,y
LDA $D2
STA $18EA|!addr,y
LDA #$07
STA $17F0|!addr,y
LDA #$12
STA $1850|!addr,y
PLY
RTS

print "A waterfall that pushes Mario down after an amount of time. Object 19 will turn into this if there is something behind it other than air or itself, so use that instead."
