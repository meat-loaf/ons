;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cluster Lotus Spore
;; by Sonikku
;; Description: A custom Volcano Lotus spore projectile based on the original Extended Sprite.
;; Spawn sprite with "$0F4A|!addr,x" set for the following behaviors:
;;;; x00 - Normal
;;;; x01 - Fast
;;;; x02 - Homing
;; Spawn sprite with "$0F9A|!addr,x" set to set its palette. $FF for a "random" one.
;; Spawn sprite with "$0F86|!addr,x" set to force its direction. 
;;;; x00 - upward
;;;; x01 - downward
;;;; x02 - left
;;;; x03 - right
;;;; Set highest bit (x80) on-spawn and it will maintain that orientation (so a downward-fired one will fall upward, for example).

!EnableDisco = $00	; if $01, projectiles that are "randomly colored" will cycle through palettes
    !DiscoFrame = $00	; frame to use for the a disco projectile
			;;;; (to prevent potential issues with photosensitive players, it will use a static frame as its exceptionally harsh on the eyes otherwise)

print "MAIN ",pc
Main:	PHB
	PHK
	PLB
	TYX
	JSR .Main
	JMP SubGFX
;	PLB
;	RTL

.Main;	JSR SubGFX
	LDA $9D
	BNE .Return
.Collision:
	LDA !sspipes_dir        ; \ skip collision check entirely if in sspipe...
	ORA $1497|!addr         ; | or invincibility timer...
	ORA $1490|!addr         ; | or star power timer is set
	BNE .CollisionDone      ; /
	LDA #$62
	%ClusterCollision()
	BCC .CollisionDone
	BNE .KillClus           ; interaction with cape
	LDA $187A|!addr         ; check if riding yoshi
	BNE .onyoshi
	JSL $00F5B7|!bank       ; hurt
	BRA .CollisionDone
.onyoshi
	%LoseYoshi()
	BRA .CollisionDone
.KillClus
	LDY #$03
.SmokeLoop
	LDA $17C0|!addr,y
	BEQ .SpawnSmoke
	DEY
	BPL .SmokeLoop
	STZ !cluster_num,x         ; no smoke sprites avail
	RTS
.SpawnSmoke
	LDA #$03
	STA $17C0|!addr,y
	LDA #$0C
	STA $17CC|!addr,y
	LDA !cluster_y_low,x
	STA $17C4|!addr,y
	LDA !cluster_x_low,x
	STA $17C8|!addr,y

	STZ !cluster_num,x

.CollisionDone
	LDA $0F4A|!addr,x
	ASL
	TAX
	JMP (.ptr,x)

.Return
	RTS

.ptr	dw Behavior00_Descend
	dw Behavior01_Descend2
	dw Behavior02_Homing

Behavior00_Descend:
	LDY #$00
.main	LDX $15E9|!addr
	STY $57
	JSR ManageVelocity
	LDY $57
	LDA $13
	AND .DecRate,y
	BNE +
	LDA $1E52|!addr,x
	CMP .DecMax,y
	BPL +
	CLC
	ADC .DecAccel,y
	STA $1E52|!addr,x
+	LDA $1E52|!addr,x
	BMI .Return
	LDA $0F86|!addr,x
;	AND #$80
;	BNE +
	BMI +
	STZ $0F86|!addr,x
+	TXA
	ASL #3
	ADC $13
	LDY #$08
	AND #$08
	BNE +
	LDY #$F8
+	TYA
	STA $1E66|!addr,x
.Return
	RTS
.DecRate
	db $03,$00
.DecMax
	db $18,$1C
.DecAccel
	db $01,$01

Behavior01_Descend2:
	LDY #$01
	BRA Behavior00_Descend_main

Behavior02_Homing:
	LDX $15E9|!addr
	LDA $0F5E|!addr,x
	BEQ ++
	LDY #$00
	LDA $1E52|!addr,x
	BMI Behavior00_Descend_main
+	LDA !cluster_x_high,x
	XBA
	LDA !cluster_x_low,x
	REP #$20
	SEC
	SBC $94
	CLC
	ADC #$FFFC
	STA $00
	SEP #$20

	LDA !cluster_y_high,x
	XBA
	LDA !cluster_y_low,x
	REP #$20
	SEC
	SBC $96
	CLC
	ADC #$FFF0
	STA $02
	SEP #$20

	LDA $0F5E|!addr,x
	%Aiming()
	LDA $00
	STA $1E66|!addr,x
	LDA $02
	STA $1E52|!addr,x
	LDA #$00
	STA $0F5E|!addr,x
	STA $0F86|!addr,x
++
	BRA ClusterSpeed

ManageVelocity:
	LDA $1E66|!addr,x
	STA $00
	STA $59
	LDA $1E52|!addr,x
	STA $01
	STA $5A
	LDA $0F86|!addr,x
	AND #$01
	BEQ +
	LDA $1E52|!addr,x
	EOR #$FF
	INC
	STA $1E52|!addr,x
	STA $01
+	LDA $0F86|!addr,x
	AND #$7F
	LSR
	BEQ +
	LDA $00
	STA $1E52|!addr,x
	LDA $01
	STA $1E66|!addr,x
+	JSR ClusterSpeed
	LDA $5A
	STA $1E52|!addr,x
	LDA $59
	STA $1E66|!addr,x
	RTS

ClusterSpeed:
; cluster y-speed no grav: ripped from $02FFA3
	LDA.W $1E52|!addr,x
	ASL #4
	CLC
	ADC.W $1E7A|!addr,x
	STA.W $1E7A|!addr,x
	PHP
	LDA.W $1E52|!addr,x
	LSR #4
	CMP.B #$08
	LDY.B #$00
	BCC +
	ORA.B #$F0
	DEY
+
	PLP
	ADC.W !cluster_y_low,x
	STA.W !cluster_y_low,x
	TYA
	ADC.W !cluster_y_high,x
	STA.W !cluster_y_high,x

; cluster x-speed no grav: adapted from $02FF98/$02FFA3
	LDA.W $1E66|!addr,x
	ASL #4
	CLC
	ADC.W $1E8E|!addr,x
	STA.W $1E8E|!addr,x
	PHP
	LDA.W $1E66|!addr,x
	LSR #4
	CMP.B #$08
	LDY.B #$00
	BCC +
	ORA.B #$F0
	DEY
+
	PLP
	ADC.W !cluster_x_low,x
	STA.W !cluster_x_low,x
	TYA
	ADC.W !cluster_x_high,x
	STA.W !cluster_x_high,x
	RTS
	
SubGFX:
	%ClusGetDrawInfo()

	STX $02

	LDX #$00
	LDA $14
	LSR
	EOR $02
	LSR
	LSR
	BCC +
	INX
+	STX $04
	LDX $02

if !EnableDisco
	STZ $03
endif

	LDA $00
	STA $0200|!addr,y

	LDA $05
	STA $0201|!addr,y

	LDA $0F9A|!addr,x
	CMP #$FF
	BNE +
	AND #$01
	STA $02
	TXA
if !EnableDisco
	ASL #2
	ADC $14
	LSR #2
	INC $03
endif
	AND #$03
	INC #2
	ASL
if !EnableDisco
	LDX $04
	ORA .Properties,x
	LDX $15E9|!addr
endif
	ORA $02
+	ORA $64
	STA $0203|!addr,y

	LDX $04
if !EnableDisco
	LDA $03
	BEQ +
	LDX #!DiscoFrame
endif
+	LDA .Tilemap,x
	CLC
	ADC !tile_off_scratch
	LDX $15E9|!addr
	STA $0202|!addr,y

	TYA
	LSR
	LSR
	TAY

	LDA #$00
	STA $0420|!addr,y

	%ClusFinishOAM()

	PLB
	RTL
.Tilemap
	db $09,$0A
.Properties
	db $00,$40
