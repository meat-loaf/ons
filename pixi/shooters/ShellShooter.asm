;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shell shooter
;	by MarioFanGamer
;
; This shooter spawns kicked sprites.
; The extra bit sets $187B in the spawned sprite:
; * This turns koopas into disco shells.
; First extra byte is the sprite number.
; Second extra byte is the direction:
;  00: shoot at mario, always
;  01: shoot only right, if mario is on right
;  02: shoot only left, if mario is on left
;  03: shoot only right always
;  04: shoot only left always
;
; Third extra byte: timer.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ShellPositionLow:
db $0C,$F4

ShellPositionHigh:
db $00,$FF

ShellSpeed:
db $30,$D0

print "INIT ",pc
print "MAIN ",pc
PHB : PHK : PLB
	JSR Shooter
PLB
RTL

Return:
RTS

Shooter:
	LDA $17AB|!Base2,x
	BNE Return
	LDA !shooter_extra_byte_3,x
	STA $17AB,x

	LDA $94
	SEC : SBC $179B|!Base2,x
	ADC #$11
	CMP #$22
	BCC Return

	LDA $178B|!Base2,x
	CMP $1C
	LDA $1793|!Base2,x
	SBC $1D
	BNE Return

	LDA $17A3|!Base2,x
	XBA
	LDA $179B|!Base2,x
	REP #$20
	SEC : SBC $1A
	CMP #$00F0
	SEP #$20
	BCS Return

.no_prox_checks
	JSR SubHorzPos
	STY $57
	LDA !shooter_extra_byte_2,x
	AND #%01111111
	BEQ .side_ok
	CMP #$03
	BCS .skip_side_cmp
	DEC
	CMP $57
	BNE Return            ; don't shoot if mario isn't on the correct side
.skip_side_cmp:
	AND #$01
	STA $57
.side_ok:

	JSL $02A9DE|!BankB
	BMI Return

	LDA #$09
	STA $1DFC|!Base2

	LDA !shooter_extra_byte_1,x
	PHX
	TYX
	STA !9E,x
	JSL $07F7D2|!BankB
	PLX

	LDA $178B|!Base2,x
	SEC : SBC #$01
	STA !D8,y
	LDA $1793|!Base2,x
	SBC #$00
	STA !14D4,y

	PHY
	LDY $57
	LDA ShellPositionHigh,y
	STA $01
	LDA ShellPositionLow,y
	PLY
	CLC : ADC $179B|!Base2,x
	STA !E4,y
	LDA $17A3|!Base2,x
	ADC $01
	STA !14E0,y

	LDA #$0A
	STA !14C8,y

	LDA !shoot_num,x
	AND #$40
	BEQ .nodisco
	STA !187B,y
.nodisco

	PHY
	LDY $57
	LDA ShellSpeed,y
	PLY
	STA !B6,y

	JSR SpawnSmoke
RTS

SubHorzPos:
	LDY #$00
	LDA $94
	CMP $179B|!Base2,x
	LDA $95
	SBC $17A3|!Base2,x
	BPL +
	INY
+
RTS

SpawnSmoke:
	LDY #$03
-	LDA $17C0|!Base2,y
	BEQ +
	DEY
	BPL -
RTS

+	LDA #$01
	STA $17C0|!Base2,y
	LDA #$1B
	STA $17CC|!Base2,y

	LDA $178B|!Base2,x
	STA $17C4|!Base2,y

	PHY
	LDY $57
	LDA ShellPositionLow,y
	PLY
	CLC : ADC $179B|!Base2,x
	STA $17C8|!Base2,y
RTS
