;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Sideways Ninji, by RussianMan, requested by Anorakun, based on disassembly by imamelia.
;;
;; Extra bit determines wether it sticks to the left or right wall. Clear - attached to the right wall, set - to the left.
;;
;; Extra Byte 1 Determines jumping speed, if it's zero, the ninji will jump like vanilla sprite with variable jumping speeds (defined by JumpSpeed)
;; otherwise it'll use one and the same jumping speed from extra byte 1. valid values: 0-7F
;;
;; Extra Byte 2 determines moving speed. If zero, it'll remain stationary. valid values: 0-7F
;;
;; Extra Byte 3 determines timing at which ninji will jump, the higher value the less frequent the jumps are.
;;
;; Extra Byte 4 determines additional properties:
;; Bit 0 - jump when player jumps. should be self-explanatory.
;; Bit 1 - stay on ledges, similar to red koopas (moving only)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!NoDefaultJump = 0			;if you want to disable variable jumping when extra byte 1 = 0 and instead have no jumping at all, set this to 1

JumpSpeed:
db $D0,$C0,$B0,$D0

Tilemap:
db $04,$06

;don't edit these thank you very much
BumpSpeed:
db $10,-$10

DATA_019284:
db -$01,$01,$FF,$00

WallGravityMaxes:
db $40,-$40

WallGravityAccel:
db $02,-$02

;BlockedWall:
;db $01,$02

!GroundedFlag = !1534,x			;this is used for red koopa-like ledges check for moving ninji
!InAirCounter = !1528,x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
LDA !extra_byte_1,x
EOR #$FF
INC
STA !160E,x

LDA !extra_byte_4,x
STA !1504,x

%SubVertPos()		;
TYA			; face the player?
STA !157C,x		;

LDA !extra_bits,x
AND #$04
LSR
LSR
STA !151C,x		;which wall it's attached to, left or right.

LDA !extra_byte_2,x
BEQ Init_NoMovement
STA $00

%SubVertPos()		;face the player
LDA $00
CPY #$00
BEQ Init_StoreSpd

EOR #$FF
INC

Init_StoreSpd:
STA !AA,x

Init_NoMovement:
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
JSR NinjiMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Return:
RTS

NinjiMain:

JSR NinjiGFX			; draw the sprite

LDA !14C8,x
EOR #$08
ORA $9D				; if sprites are locked...
BNE Return			; return
INC
%SubOffScreen()

;check for moving!!!

LDA !AA,x			;only face the player when not moving (aka stationary)
BNE .NoFacing

%SubVertPos()			;
TYA				; always face the player
STA !157C,x			;

.NoFacing
JSL $01803A|!BankB		; interact with the player and with other sprites
;JSL $01802A|!BankB		; update sprite position with gravity

JSL $018022|!BankB		;*without gravity
JSL $01801A|!BankB

JSL $019138|!BankB		;interact with objects

;custom gravity, because... sideways
LDY !151C,x			;0 - interact with RIGHT, 1 - interact with LEFT
TYA
INC
AND !1588,x
BNE .TouchingWall
EOR #$03
AND !1588,x			;the opposite wall should act as a ceiling
BNE .Clear

;LDA !1588,x			;can cause a problem!!! probably, clipping into "ceiling"
;AND #$03
;BNE .TouchingWall

;gravity
LDA !1504,x			;don't care about ledge checks
AND #$02
BEQ .Gravity

LDA !GroundedFlag
BEQ .Gravity			;fall

INC !InAirCounter		;if in air for a few frames, count as not grounded (give it like 3 frames max)
LDA !InAirCounter
CMP #$04
BNE .TurningAround

STZ !GroundedFlag		;not grounded anymore
BRA .Gravity

.TurningAround
LDA !15AC,x
BNE .NoMore

LDA #$08
STA !15AC,x			;turn around thx

JSR InvertMoveSpeed		;move away

;LDY !151C,x
;LDA BlockedWall,y
;STA !1588,x			;mark as grounded for real (prevent sinking into the ground)
LDA !151C,x
INC
STA !1588,x
BRA .TouchingWall

.Gravity
STZ !InAirCounter		;only matters for ledge dwelling ninjis

LDA !B6,x
CMP WallGravityMaxes,y
BEQ .NoMore

LDA !B6,x
CLC : ADC WallGravityAccel,y
STA !B6,x
BRA .NoMore

.Clear
STZ !B6,x
BRA .NoMore

.TouchingWall
;STZ !B6,x

JSR HandleWallAsGround

STZ !InAirCounter		;only matters for ledge dwelling ninjis

LDA !1504,x
LSR
BCC .Timer

;controller check
LDA $77				; If player's not on ground
AND #$04			;
BEQ .NoMore			; no speed set

LDA $16				; If player's just (spin)jumped
ORA $18				;
BPL .NoMore			; Or not? If not return
BRA .Jump

.Timer
LDA !1540,x
BNE .NoMore

LDA !extra_byte_3,x
STA !1540,x			; if it is ready to jump, set the timer between jumps

.Jump
LDA !160E,x
if !NoDefaultJump
	BEQ .AlwaysGrounded
endif

STZ !GroundedFlag		;can move midair
STZ !InAirCounter

.AlwaysGrounded
if not(!NoDefaultJump)
	BNE .SpeedFromExtraByte

	INC !C2,x			; increment the sprite state
	LDA !C2,x			;
	AND #$03			; only the lowest 2 bits of the sprite state matter
	TAY				; these will be used to index the Y speed table
	LDA JumpSpeed,y			; and the four possible Y speeds will cycle
else
	BEQ .NoJumpsAtAll
endif

.SpeedFromExtraByte
LDY !151C,x
BEQ .RightSpeedItIs

EOR #$FF			;invert speed so it's leftward
INC

.RightSpeedItIs
STA !B6,x			;

.NoJumpsAtAll
.NoMore
LDA !1588,x
AND #$0C			;touched ground or ceiling
BEQ .NoMoveSpeedAlteration

;check for slopes??? (lazy and not smart enough)
;LDA !1588,x
;BEQ .Alter
;LDA #$18
;
;BMI .Store

;LDA #-$18

.Store
;STA !AA,x


;the gravity also should be affected!
;LDY !151C,x
;LDA BumpSpeed,y
;STA !B6,x
;BRA .NoMoveSpeedAlteration

.Alter
JSR InvertMoveSpeed

.NoMoveSpeedAlteration
STZ !1602,x			;show first frame. unless...

LDY !151C,x
BEQ .LeftSpeedCheck

;RightCheck
LDA !B6,x
BEQ .ReturnNotReally
BPL .NextFrame

.ReturnNotReally			;
JSR HandleMovingAnimation

.Return
RTS

.LeftSpeedCheck
LDA !B6,x
BPL .ReturnNotReally

.NextFrame
INC !1602,x			;next frame then
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NinjiGFX:

%GetDrawInfo()			;

LDA !157C,x
BEQ .NoAlter

LDA #$80

.NoAlter
STA $02

LDA !1602,x			;
TAX				;
LDA Tilemap,x			; set the sprite tilemap
STA $0302|!Base2,y			;

LDX $15E9|!Base2			;
LDA $00				;
STA $0300|!Base2,y		; no X displacement
LDA $01				;
STA $0301|!Base2,y		; no Y displacement

LDA !151C,x			;
LSR				; if the sprite is facing right...
LDA !15F6,x			;
BCS .NoXFlip			; X-flip it
EOR #$40			;

.NoXFlip			;
ORA $64				;
ORA $02
STA $0303|!Base2,y		;

LDY #$02
LDA #$00
%FinishOAMWrite()
RTS

HandleMovingAnimation:
LDA !AA,x
BEQ .NoAnimation

LDA !1570,x
AND #$01
STA !1602,x

LDA $14
AND #$07
BNE .NoAnimation

INC !1570,x

;INC !1602,x

.NoAnimation
RTS

InvertMoveSpeed:
LDA !AA,x
EOR #$FF
INC
STA !AA,x

LDA !157C,x
EOR #$01
STA !157C,x
RTS

HandleWallAsGround:
LDA BumpSpeed,y
STA !B6,x
STA !GroundedFlag				;regardless what value, non-zero is good

;straight from disassembly with tweaks (don't get stuck in walls doesn;t work well)
    LDA !1588,X               ;$0191C3    || Skip sprite if 
    AND #$03                  ;$0191C6    || - not set to avoid getting stuck in walls
    ;BEQ CODE_0191ED             ;$0191C8    || - not blocked on a side
    TAY                         ;$0191CA    || - being eaten by Yoshi
    LDA !15D0,X               ;$0191CB    ||
    BNE .CODE_0191ED             ;$0191CE    |/
    LDA !E4,X                   ;$0191D0    |\ 
    CLC                         ;$0191D2    ||
    ADC DATA_019284-1,Y       ;$0191D3    ||
    STA !E4,X                   ;$0191D6    || Push back from the block.
    LDA !14E0,X               ;$0191D8    ||
    ADC DATA_019284+1,Y       ;$0191DB    ||
    STA !14E0,X               ;$0191DE    |/

.CODE_0191ED:
RTS
