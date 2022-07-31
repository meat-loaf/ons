;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom Volcano Lotus
;; by Sonikku
;; Description: A custom Volcano Lotus that can have a variety of different behaviors.
;;;; Extra Bit Clear:  Standard orientation.
;;;; Extra Bit Set:    Inverted orientation.
;;;; Extension Byte 1: Type of Lotus. (Valid values are 00-1F)
;;;;                       - x00 - Default SMW
;;;;                       - x01 - Fires 7 instead of 4 in a larger arc. Default behavior otherwise.
;;;;                       - x02 - Fires 4 fast-moving projectiles in the same arc as x00 in quick succession.
;;;;                       - x03 - Fires two sets of 4 back to back, going in random speeds
;;;;                       - x04 - Fires a stream of projectiles at random speeds.
;;;;                       - x05 - Fires a spread of projectiles which all home in on Mario.
;;;;                       - x06 - Continuously fires 1 at a time which home in on Mario.
;;;;                       - x07 - Fires several projectiles in a spread, alternating direction each time.
;;;;                       - x08 - Sleepy Lotus; will wait until Mario comes into range and, if he is not going under a certain speed, fires several in a spread.
;;;; 			Bit 7 (x40) - Projectiles maintain orientation (i.e. if fired downward, they fall back upward).
;;;;                    Bit 8 (x80) - Horizontal orientation. (Extra Bit Clear = left, Extra Bit Set = aim right)
!ClusterToSpawn =	$00		; Cluster sprite to spawn.
!HomingSpeed =		$20		; Speed of homing projectiles.

!behavior_ptr_lo = !1504
!behavior_ptr_hi = !1510

; 14 bytes each
BehaviorsTable:
	;;  B0  B1  B2       B3  B4       B5       B6       B7  B8  B9      B10       B11   B12-13
	db $40,$40,$80 : db $00,$38 : db $03 : db $00 : db $08,$04,$FF : db $08  : db $00 : dw DefaultPattern	; x00 - Default SMW
	db $40,$40,$80 : db $00,$38 : db $06 : db $00 : db $04,$02,$FF : db $08  : db $00 : dw LargePattern	; x01 - Fires 7 instead of 4 in a larger arc. Default behavior otherwise.
	db $08,$08,$20 : db $00,$02 : db $03 : db $01 : db $08,$04,$05 : db $04  : db $00 : dw DefaultPattern	; x02 - Fires 4 fast-moving projectiles in the same arc as x00 in quick succession.
	db $40,$48,$80 : db $18,$1F : db $03 : db $00 : db $00,$04,$FF : db $06  : db $00 : dw RandomPattern	; x03 - Fires two sets of 4 back to back, going in random speeds
	db $40,$40,$80 : db $18,$03 : db $00 : db $00 : db $06,$00,$FF : db $06  : db $00 : dw RandomPattern	; x04 - Fires a stream of projectiles at random speeds.
	db $40,$40,$80 : db $00,$38 : db $06 : db $02 : db $08,$04,$07 : db $FF  : db $00 : dw LargePattern	; x05 - Fires a spread of projectiles which all home in on Mario.
	db $0C,$0C,$08 : db $00,$0A : db $00 : db $02 : db $0A,$0A,$07 : db $FF  : db $00 : dw RandomPattern2	; x06 - Continuously fires 1 at a time which home in on Mario.
	db $08,$10,$18 : db $01,$03 : db $00 : db $01 : db $06,$00,$FF : db $0A  : db $00 : dw SpreadPattern	; x07 - Fires several projectiles in a spread, alternating direction each time.
	db $00,$12,$60 : db $01,$03 : db $00 : db $01 : db $06,$00,$FF : db $0A  : db $07 : dw SpreadPattern	; x08 - Sleepy Lotus; will wait until Mario comes into range and, if he is not going under a certain speed, fires several in a spread.
	db $40,$20,$80 : db $10,$07 : db $01 : db $02 : db $0A,$09,$FF : db $FF  : db $00 : dw DefaultPattern	; x00 - 4 homing projectiles, two at a time with short delay

;; Format:
;;      Byte 0  - Preparing-to-fire timer.
;;      Byte 1  - Firing timer.
;;      Byte 2  - Cooldown timer.
;;      Byte 3  - Continuously fire projectiles until firing timer reaches this amount
;;                if $00, it is "one-shot".
;;      Byte 4  - How frequently should projectiles be fired?
;;                (use [fast] $01, $03, $07, $0F, $1F [slow], etc.)
;;                if Byte 3 is $00, fire projectiles when firing timer reaches this amount.
;;      Byte 5  - How many projectiles should be fired each emission, minus 1. (e.g. a value of $03 fires 4 projectiles)
;;      Byte 6  - Projectile movement type. ($00 = Default, $01 = 2x speed, $02 = homes in on Mario)
;;      Byte 7  - Lotus primary palette
;;      Byte 8  - Lotus secondary (flashing) palette
;;      Byte 9  - Lotus leaf palette (if $FF; use default)
;;      Byte 10 - Spore palette (if $FF; use palettes A, B, C, or D randomly)
;;      Byte 11 - Trigger:
;;                      x00 -  Always active
;;                      x01 -  Blue POW Switch-active
;;                      x02 -  Blue POW Switch-inactive
;;                      x03 -  Silver POW Switch-active
;;                      x04 -  Silver POW Switch-inactive
;;                      x05 -  On/Off Switch On
;;                      x06 -  On/Off Switch Off
;;                      x07 -  Trigger when Mario is within range & either moving too quickly or is airborne
                               !SneakRange = $48 ; (default: $48)
                               !SneakSpeed = $13 ; (default: $13)
;;                      x08+ - Do not use/Placeholder
;;      Byte 12/13 - firing pattern

;; unused sprite tables:
;; 1626
;; 187B
;; 1FD6

print "INIT ",pc
	PHB
	PHK
	PLB

	%sprite_init_do_pos_offset(!extra_byte_2,x)

	; determine the behavior pointer
	LDA !extra_byte_1,x
	REP #$20                             ; 16-bit A
	AND #$001F
	ASL
	STA $00
	ASL #3
	STA $02
	LDA #BehaviorsTable
	CLC : ADC $02                        ; \ 16x - 2x = 14x
	SEC : SBC $00                        ; / to get offset into behaviors table
	
	SEP #$20                             ; 8-bit A
	STA !behavior_ptr_lo,x
	XBA
	STA !behavior_ptr_hi,x

; setup directions
	LDY #$00
	LDA !7FAB10,x
	AND #$04
	BEQ +
	INY
+	LDA !extra_byte_1,x
	AND #$80
	BEQ +
	INY #2
+	TYA
	STA !157C,x

; resolve sprite direction and clump it onto that surface if possible
	LDY #$00
-	JSR ResolveObj
	BCC +
	LDA #$01
	STA !1534,x
	PLB
	RTL
+	PHY
	LDY #$00
	LDA $8A
	BPL +
	DEY
+	CLC
	ADC !D8,x
	STA !D8,x
	TYA
	ADC !14D4,x
	STA !14D4,x
	LDY #$00
	LDA $8B
	BPL +
	DEY
+	CLC
	ADC !E4,x
	STA !E4,x
	TYA
	ADC !14E0,x
	STA !14E0,x
	PLY
	INY
	CPY #$04
	BCC -

	PLB
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	; initialize our behavior pointer
	LDA !behavior_ptr_lo,x
	STA $48
	LDA !behavior_ptr_hi,x
	STA $49

	JSR Main
	JSR SubGFX
	PLB
	RTL

Main:	LDA !14C8,x
	EOR #$08
	ORA $9D
	BNE .Return
	%SubOffScreen()

	STZ !151C,x

; setup gravity
	JSL $01801A|!bank
	LDA !AA,x
	CMP #$40
	BPL +
	INC !AA,x
; setup sprite/sprite and sprite/mario collision
+	JSL $01803A|!bank
	LDA !1534,x
	BEQ .NotStuckOnObj
	DEC !1534,x
	STZ !AA,x
	STZ !B6,x
; continuously force sprite onto surface of object, if not on yoshi's tongue
	BNE +
	JSR ResolveObj
	BCC +
	INC !1534,x
	BRA +
.NotStuckOnObj
	JSL $019138|!bank
; force sprite to stay onto surface (and reset direction)
	LDA !1588,x
	AND #$04
	BEQ +
	STZ !157C,x
	STZ !AA,x
+
; manage triggers
	LDY #$0B
	LDA ($48),y
	BEQ .noTrigger
	ASL
	TAX
	JSR (Triggers,x)           ; returns with sprite index back in x
.noTrigger

; get states for sprite
	LDA !C2,x
	ASL
	TAX
	JMP (.ptr,x)

.ptr	dw State00_Waiting
	dw State01_PrepareFire
	dw State02_Firing
.Return	RTS

ResolveObj:
; this basically just checks if sprite is touching a certain surface based on direction
	PHY
	LDA !B6,x
	PHA
	LDA !AA,x
	PHA
	LDA !157C,x
	AND #$03
	TAY
	LDA .InitYSpeed,y
	STA !AA,x
	STA $8A
	LDA .InitXSpeed,y
	STA !B6,x
	STA $8B
	PHY
	JSL $019138|!bank
	PLY
	PLA
	STA !AA,x
	PLA
	STA !B6,x
	LDA !1588,x
	AND .InitDir,y
	BEQ +
	PLY
	SEC
	RTS
+	PLY
	CLC
	RTS
.InitXSpeed
	db $00,$00,$01,$FF
.InitYSpeed
	db $01,$FF,$00,$00
.InitDir
	db $04,$08,$01,$02

State00_Waiting:
	LDX $15E9|!addr
; play "munching" animation while !1540,x is set
	LDA !1540,x
	BNE .Chomping
; wait to progress to next state unless !160E,x is clear
	LDA !160E,x
	BEQ .inc_state_ready
	DEC
	STA !160E,x
	LDA #$01
	STA !1602,x
	RTS
.inc_state_ready
	LDA ($48)
	STA !1540,x
	INC !C2,x
.Return	RTS
.Chomping
	LSR #3
	AND #$01
	STA !1602,x
	RTS

State01_PrepareFire:
	LDX $15E9|!addr
; play "flashing" animation while !1540,x set
	LDA !1540,x
	BNE +
; progress to next state when timer is up
	LDY #$01
	LDA ($48),y
	STA !1540,x
	INC !C2,x
	RTS
+	LSR
	AND #$01
	STA !151C,x
	RTS

State02_Firing:
	LDX $15E9|!addr
; show shooting frame
	LDA #$02
	STA !1602,x
; once timer is up, reset
	LDA !1540,x
	BNE +
	LDY #$02
	LDA ($48),y

	STA !1540,x
	STZ !C2,x
; flip "firing direction" (which is only used for the spread pattern)
	LDA !157C,x
	EOR #$40
	STA !157C,x
	RTS
; if it fires normally, branch
+
	LDY #$03
	LDA ($48),y
	BEQ .NormalFire
.RapidFire
; repeatedly shoot a projectile until timer is up
	STA $00
	LDA !1540,x
	CMP $00
	BCC .noSpawn
	SBC $00
	INY                         ; y = 4
	AND ($48),y
	BEQ SpawnProjectile
.NormalFire
; fire a projectile one time
	INY                         ; y = 4
	LDA !1540,x
	CMP ($48),y
	BEQ SpawnProjectile
.noSpawn
	RTS

SpawnProjectile:
	STY $18B8|!addr          ; run cluster sprite code: just needs to be non-zero

	INY                      ; y = 5
	LDA ($48),y
	STA $08                  ; loop counter - number of spores to spawn

	INY                      ; y = 6
	LDA ($48),y              ; projectile movement type
	ASL
	TAY

	LDA ProjSetupTbl,y
	STA $0C
	LDA ProjSetupTbl+1,y
	STA $0D

	LDY #$0C
	LDA ($48),y
	STA $45
	INY
	LDA ($48),y
	STA $46

	LDA !166E,x
	AND #$01
	STA $00
	LDY #$0A
	ORA ($48),y
	CMP #$FF
	BEQ .randProjPalette
	AND #$0F
.randProjPalette
	STA $0A                 ; projectile palette info

	LDY #$00
	LDA !extra_byte_1,x
	AND #$40
	BEQ .projNoMaintainOrient
	LDY #$80
.projNoMaintainOrient
	TYA
	ORA !157C,x
	AND #$83
	STA $0B                 ; projectile orientation info

	; setup sprite offsets
	LDA !157C,x
	AND #$03
	TAY
	LDA ProjXOffs,y
	STA $00
	LDA ProjYOffs,y
	STA $01

	LDA #$13
	STA $0F
SpawnLoop:
	LDY $08
	JMP ($0045)
PatternDone:
	; increase speed of projectiles if it fires fast projectiles
	DEC
	BNE .no_fast_proj
	ASL $02
	ASL $03
.no_fast_proj
	; set cluster to spawn
	LDA #!ClusterToSpawn+!ClusterOffset
	; slot to start from
	LDY $0F
	%SpawnCluster()
	BCC .Done              ; don't bother attempting to spawn more if no slots avail
	; set projectile direction
	LDA $0B
	STA $0F86|!addr,y
	; set projectile palette
	LDA $0A
	STA $0F9A|!addr,y
	; do misc setup of projectiles

	LDA $0C
	STA $0F4A|!addr,y
	LDA $0D
	STA $0F5E|!addr,y

	DEC $08
	STY $0F
	BPL SpawnLoop
.Done
	RTS

ProjYOffs:
	db $00,$08,$04,$04
ProjXOffs:
	db $04,$04,$00,$08

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; all patterns are stored here

DefaultPattern:
; set x/y speeds
	LDA .FireballXSpeed,y
	STA $02
	LDA .FireballYSpeed,y
	STA $03
	JMP PatternDone
.FireballXSpeed
	db $10,$F0,$06,$FA
.FireballYSpeed
	db $EC,$EC,$E8,$E8

LargePattern:
; set x/y speeds
; (this is a separate pattern just in case i felt like changing the values)
	LDA .FireballXSpeed,y
	STA $02
	LDA .FireballYSpeed,y
	STA $03
	JMP PatternDone
.FireballXSpeed
	db $10,$F0,$06,$FA
	db $0C,$F4,$00
.FireballYSpeed
	db $EC,$EC,$E8,$E8
	db $EA,$EA,$E7

RandomPattern:
; get random value and apply it to x speed
	JSL $01ACF9|!bank
	EOR $13
	SBC $94
	AND #$0F
	SEC
	SBC #$08
	STA $02
	BPL +
	EOR #$FF
	INC
+	LSR
	STA $03

; creates an arc effect (projectiles fired further left have a lower y speed)
	LDA #$E4
	CLC
	ADC $03
	STA $03
	JMP PatternDone

RandomPattern2:
; get random value and apply it to x speed (this is a wider arc)
	JSL $01ACF9|!bank
	EOR $13
	SBC $94
	AND #$1F
	SEC
	SBC #$10
	STA $02
	BPL +
	EOR #$FF
	INC
+	LSR
	CLC
	ADC #$E0
	STA $03

; creates an arc effect but more randomized
	JSL $01ACF9|!bank
	AND #$07
	CLC
	ADC $03
	STA $03
	JMP PatternDone

SpreadPattern:
; sets gets value from !1540,x based on the max value to calculate a spread
	LDY #$01
	LDA ($48),y
	LSR
	SEC
	SBC !1540,x
	STA $02
	BPL +
	EOR #$FF
	INC
+	LSR #2
	STA $03
; invert the result if the direction is set
	LDA !157C,x
	AND #$40
	BEQ +
	LDA $02
	EOR #$FF
	INC
	STA $02
+	LDA #$E8
	CLC
	ADC $03
	STA $03
	JMP PatternDone

; first is 0F4A val, second is 0F5E val
ProjSetupTbl:
	db $00,$00            ; type 0
	db $01,$01            ; type 1
	db $02,!HomingSpeed   ; type 2
	db $02,$00            ; type 3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; trigger handler; basically just sets !160E,x if the sprite should "wait"
Triggers:
	dw .Pass                ; skipped by trigger caller
	dw .Trigger_BlueP_On
	dw .Trigger_BlueP_Off
	dw .Trigger_SilvP_On
	dw .Trigger_SilvP_Off
	dw .Trigger_OnOff_On
	dw .Trigger_OnOff_Off
	dw .Trigger_Sneak

.Trigger_BlueP_On
	LDX #$00
.trig_on
	LDA $14AD|!addr,x
.trig_on2
	BNE .Pass
.Fail	LDX $15E9|!addr
	LDA #$04
	STA !160E,x
	RTS
.Pass	LDX $15E9|!addr
	RTS

.Trigger_BlueP_Off
	LDX #$00
.trig_off
	LDA $14AD|!addr,x
.trig_off2
	BEQ .Pass
	BRA .Fail

.Trigger_SilvP_Off
	LDX #$01
	BRA .trig_off
.Trigger_SilvP_On
	LDX #$01
	BRA .trig_on
.Trigger_OnOff_Off
	LDX #$02
	BRA .trig_off
.Trigger_OnOff_On
	LDX #$02
	BRA .trig_on

.Trigger_Sneak
	LDX $15E9|!addr
; fail if outside range
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC.w #!SneakRange
	CMP.w #(!SneakRange*2)+$8
	SEP #$20
	BCS ++
; pass if mario airborne
	LDA $72
	BNE .Pass
; pass if mario goes above a certain speed
	LDA $7B
	BPL +
	EOR #$FF
	INC
+	CMP #!SneakSpeed
	BCS .Pass
++	LDA !C2,x
	ORA !1540,x
	BNE .Fail
; draw the rip van fish Z's
	TXA
	ASL #3
	ADC $14
	AND #$3F
	BNE .Fail
	LDA !1528,x
	PHA
	JSL $02C0D9|!bank
	PLA
	STA !1528,x
	BRA .Fail

SubGFX:
	%GetDrawInfo()

	LDA #$FF
	STA $0F
	PHY
	LDA !157C,x
	AND #$03
	TAY
	LDA $00
	CLC
	ADC .XDisp,y
	STA $00
	LDA $01
	CLC
	ADC .YDisp,y
	STA $01
	PLY

	LDA !1602,x
	INC
	ASL
	STA $02

	LDA !151C,x
	AND #$01
	STA $03

	LDA !157C,x
	AND #$03
	STA $04
	LSR
	ASL
	STA $06
	ASL #2
	STA $05
	LDA !157C,x
	AND #$01
	STA $07

	PHY
	LDY #$07
	LDA ($48),y
	STA $0C
	INY
	LDA ($48),y
	STA $0D
	PLY

	LDX #$01
.draw_loop_1:
	TXA
	ASL #4
	CLC
	ADC #$F8
	STA $08
	CLC
	ADC $00
	STA $0300|!addr,y

	PHX
	LDA #$00
	LDX $04
	CPX #$02
	BNE +
	LDA #$08
+	PLX
	STA $09
	CLC
	ADC $01
	STA $0301|!addr,y

	PHX
	LDX $15E9|!addr
	LDA !157C,x
	AND #$03
	LSR
	BEQ +
	LDA $08
	CLC
	ADC $01
	STA $0301|!addr,y
	LDA $09
	CLC
	ADC $00
	STA $0300|!addr,y
+	PLX

	PHX
	TXA
	CLC
	ADC $05
	TAX
	LDA .Tilemap,x
	PLX
	STA $0302|!addr,y

	PHX
	TXA
	CLC
	ADC $06
	TAX
	PHX
	PHY
	LDY #$09
	LDA ($48),y
	BPL +
	LDX $15E9|!addr
	LDA !15F6,x
+	LDX $04
	PLY
	EOR .Properties2,x
+
	PLX
	EOR .Properties,x
	PLX
	ORA $64
	STA $0303|!addr,y

	LDA #$02
	JSR .SetTileSize

	INC $0F
	INY #4
	DEX
;       TODO might be able to shorten code enough to un-invert condition
;	BPL .draw_loop_1
	BMI .draw_next
	JMP .draw_loop_1
.draw_next
	LDX #$01
-
	TXA
	ASL #3
	STA $08
	CLC
	ADC $00
	STA $0300|!addr,y

	LDA #$00
	PHX
	LDX $04
	BEQ +
	LDA #$08
+	PLX
	STA $09
	CLC
	ADC $01
	STA $0301|!addr,y

	PHX
	LDX $15E9|!addr
	LDA !157C,x
	AND #$03
	LSR
	BEQ +
	LDA $08
	CLC
	ADC $01
	STA $0301|!addr,y
	LDA $09
	CLC
	ADC $00
	STA $0300|!addr,y
+	PLX

	PHX
	TXA
	CLC
	ADC $02
	ADC $05
	TAX
	LDA .Tilemap,x
	PLX
	STA $0302|!addr,y

	PHX
	LDX $15E9|!addr
	LDA !166E,x
	AND #$01
	LDX $03
	ORA $0C,x
	ORA $64
	LDX $04
	EOR .Properties2,x
+	PLX
	STA $0303|!addr,y

	LDA #$00
	JSR .SetTileSize

	INC $0F
	INY #4
	DEX
	BPL -

	LDY #$FF
	LDA $0F
	LDX $15E9|!addr
	%FinishOAMWrite()
	RTS
.SetTileSize
	XBA
	PHY
	TYA
	LSR #2
	TAY
	XBA
	STA $0460|!addr,y
	PLY
	RTS
.XDisp	db $00,$00,$F7,$02
.YDisp	db $FF,$01,$00,$00

.Properties
	db $00,$40,$80,$00
.Properties2
	db $00,$80,$00,$40
.Tilemap
; vert
	db $02,$02
	db $00,$01
	db $10,$11
	db $19,$1A
; horz
	db $07,$07
	db $04,$14
	db $05,$15
	db $06,$16
