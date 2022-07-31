;==========================;
; Gulpit, from Paper Mario ;
; Coded by Nesquik Bunny   ;
;==========================;

!RockNumber = $BF               ; The sprite number from list.txt of rock.cfg

!TimeToStop = $28               ; For how many frames Gulpit stops when walking into a rock
!TimeInMouth = $3E              ; For how many frames Gulpit holds a rock in its mouth before spitting it out

!SwallowSFX = $21               ; Sound effect to play when swallowing a rock
!SwallowBank = $1DFC

!SpitSFX = $20                  ; Sound effect to play when spitting out a rock
!SpitBank = $1DF9

!HurtSFX = $28                  ; Sound effect to play when the sprite gets hurt
!HurtBank = $1DFC

print "INIT ", pc
	%SubHorzPos()
	TYA
	STA !157C,x
	STZ !C2,x
	LDA #$01
	STA !1504,x
	RTL

Return:
	RTS

print "MAIN ", pc
	PHB : PHK : PLB
	LDA !1594,x
	BEQ +
	DEC !1594,x
+
	JSR Run
	PLB
	RTL

Run:
	LDA #$00
	%SubOffScreen()
	JSR Graphics
	LDA !14C8,x             ; If the sprite is dead..
	CMP #$08
	BNE Return              ; ..return

	LDA !C2,x
	CMP #$03
	BEQ +
	CMP #$04                ; if swallowing, skip sprite locking
	BEQ +
	LDA $9D
	BNE Return
+
	JSL $01A7DC|!BankB
	BCC +
	JSR CheckContact
+
	LDA !C2,x
	ASL A
	PHX
	TAX
	JMP.w (Pointers,x)

Pointers:
	dw Walking      ; 00
	dw Stop         ; 01
	dw StopA        ; 02
	dw Swallow      ; 03
	dw SwallowA     ; 04
	dw Gulp         ; 05
	dw Spit         ; 06
	dw DoneSpit     ; 07
	dw Jumped       ; 08
	dw Rec          ; 09

DoneSpit:
	PLX
	STZ !C2,x
	STZ !1626,x
	STZ !1534,x
	RTS

Spit:
	PLX
	LDA !1534,x
	BEQ spitit
	INC !1626,x
	LDA !1626,x
	CMP #$10
	BCC +
	INC !C2,x
+
	RTS

spitit:
	LDA.b #!SpitSFX
	STA.w !SpitBank|!Base2
	LDA !186C,x
	BNE EndSpawn
	JSL $02A9DE|!BankB
	BMI EndSpawn
	LDA #$01                    ; Sprite state ($14C8,x).
	STA !14C8,y
	PHX
	TYX
	LDA.b #!RockNumber          ; This the sprite number to spawn.
	STA !7FAB9E,x
	PLX

	PHY
	LDY !157C,x
	LDA !E4,x
	CLC : ADC X_Offset_Low,y
	PLY
	STA.w !E4,y

	PHY
	LDY !157C,x
	LDA !14E0,x
	CLC : ADC X_Offset_High,y
	PLY
	STA !14E0,y

	LDA !D8,x
	SEC : SBC #$09
	STA.w !D8,y
	LDA !14D4,x
	SBC #$00
	STA !14D4,y
	LDA #$01
	STA !1504,y
	PHX
	TYX
	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA #$0C
	STA !7FAB10,x
	PLX
	LDA #$01
	STA !1534,x
EndSpawn:
	RTS

X_Offset_Low:   db $0C,$00
X_Offset_High:  db $00,$00

Gulp:
	PLX
	%SubHorzPos()
	TYA
	STA !157C,x
	INC !1626,x
	LDA !1626,x
	CMP.b #!TimeInMouth
	BCC +
	INC !C2,x
	STZ !1626,x
+
	RTS

SwallowA:
	PLX
	INC !1626,x
	LDA !1626,x
	CMP #$0C
	BCC +
	INC !C2,x
	STZ !1626,x
+
	RTS

Swallow:
	PLX
	LDA.b #!SwallowSFX
	STA.w !SwallowBank|!Base2
	INC !1626,x
	LDA !1626,x
	CMP #$06
	BCC +
	INC !C2,x
+
	RTS

StopA:
	PLX
	LDA !1594,x
	BNE +
	INC !C2,x
+
	RTS

Stop:
	PLX
	LDA.b #!TimeToStop
	STA !1594,x
	INC !C2,x
	RTS

WalkSp: db $0A,$FA              ; Walking speed.

Walking:
	PLX
	LDA !1588,x
	AND #$03
	BEQ +
	LDA !157C,x
	EOR #$01
	STA !157C,x             ; Flip if touching wall.
+
	LDY !157C,x
	LDA WalkSp,y
	STA !B6,x
	JSL $01802A|!BankB

	LDA !1510,x
	BNE +
	JSR FindContact         ; Check to see if it touches the rock sprite.
+
	RTS

FindContact:
	JSL $03B6E5|!BankB          ; Get clipping for self
	PHX                         ; Preserve sprite #
	LDX.b #!SprSize             ; Load # of sprites
.loop
	DEX                         ; next sprite
	BMI .abort                  ; If done, end
	LDA !14C8,x
	BEQ .loop
	TXA
	CMP $01,s
	BEQ .loop
	JSL $03B69F|!BankB          ; get clipping for client sprite
	JSL $03B72B|!BankB          ; Check for contact
	BCC .loop                   ; if no contact, continue loop
	LDA !14C8,x
	CMP #$08
	BCC .loop
	TXY                         ; client sprite index to Y
	PLX                         ; own sprite index to X
	PHX
	TYX
	LDA !7FAB9E,x
	PLX
	CMP.b #!RockNumber          ; mushroom sprite number
	BNE .end

	; LDA #$00
	; STA $14C8,y
	LDA #$FF
	STA !1626,y                 ; disp. after a while

	INC !C2,x                   ; state = pick up rock.
.end/tmp
	PHX                         ; preserve self index
	TYX                         ; client back to X
	BRA .loop                   ; continue loop

.abort
	PLX                         ; Finished. Get self sprite index back
	RTS

CheckContact:
	LDA $1490|!Base2
	BEQ +
	JMP Gone
+
	LDA $0E
	CMP #$E6
	BPL HurtHurt                ; sprite wins
	LDA #$02
	STA $1DF9|!Base2
	JSL $01AA33|!BankB
	JSL $01AB99|!BankB
	%SubHorzPos()
	TYA
	EOR #$01
	TAY
	LDA BounceMarioX,y
	STA $7B
	LDA #$BC
	STA $7D
	INC !1528,x
	LDA !1528,x
	CMP #$03
	BCS Gone
	LDA !C2,x
	CMP #$01
	BEQ .ret
	CMP #$02
	BEQ .ret
	CMP #$03
	BEQ .ret
	CMP #$04
	BEQ .ret
	LDA #$08
	STA !C2,x
.ret
	LDA.b #!HurtSFX
	STA.w !HurtBank|!Base2
	RTS

HurtHurt:
	JSL $00F5B7|!BankB
	RTS

Jumped:
	PLX
	LDA !1510,x
	INC !1510,x
	CMP #$15
	BCC +
	INC !C2,x
	; STZ !1510,x
+
	RTS

Rec:
	PLX
	INC !1510,x
	LDA !1510,x
	CMP.b #$15+$12
	BCC +
	STZ !C2,x
	STZ !1510,x
+
	RTS

Gone:
	LDA #$02
	STA !14C8,x
	LDA #$13
	STA $1DF9|!Base2
	LDA #$F0
	STA !AA,x
	JSL $01802A|!BankB
	RTS

BounceMarioX:
	db $E0,-$E0

;==================;
; GRAPHICS ROUTINE ;
;==================;

Properties:
	db $6D,$2D

Tilemap6:
	db $CC,$CE,$EC,$EE        ; Frame 1 Jumped On
	db $CC,$CE,$EC,$EE

Tilemap5:
	db $C8,$CA,$E8,$EA        ; Frame 1 Jumped On
	db $C8,$CA,$E8,$EA

Tilemap4:
	db $C4,$C6,$A0,$E6        ; Frame 1 In Mouth
	db $C4,$C6,$A0,$E6

Tilemap3:
	db $C0,$C2,$E0,$E2        ; Frame 2 Swallow
	db $C0,$C2,$E0,$E2

Tilemap2:
	db $8C,$8E,$AC,$AE        ; Frame 1 Swallow
	db $8C,$8E,$AC,$AE

X_Disp2:
	db $00,$10,$00,$10
	db $10,$00,$10,$00
Y_Disp2:
	db $F0,$F0,$00,$00
	db $F0,$F0,$00,$00

Tilemap:
	db $80,$82,$A0,$A2          ; Frame 1 Right Walking 1
	db $84,$86,$A4,$A6          ; Frame 2 Right Walking 2
	db $80,$82,$A0,$A2          ; Frame 3 Right Walking 1
	db $88,$8A,$A8,$AA          ; Frame 4 Right Walking 3

	db $80,$82,$A0,$A2          ; Frame 1
	db $84,$86,$A4,$A6          ; Frame 2
	db $80,$82,$A0,$A2          ; Frame 3
	db $88,$8A,$A8,$AA          ; Frame 4

Y_Disp:
	db $F0,$F0,$00,$00
	db $F0,$F0,$00,$00
	db $F0,$F0,$00,$00
	db $F0,$F0,$00,$00

	db $F0,$F0,$00,$00
	db $F0,$F0,$00,$00
	db $F0,$F0,$00,$00
	db $F0,$F0,$00,$00

X_Disp:
	db $00,$10,$00,$10
	db $00,$10,$00,$10
	db $00,$10,$00,$10
	db $00,$10,$00,$10

	db $10,$00,$10,$00
	db $10,$00,$10,$00
	db $10,$00,$10,$00
	db $10,$00,$10,$00

Graphics:
	%GetDrawInfo()

	LDA !C2,x
	STA $04             ; $04 = sprite state.

	LDA !14C8,x
	CMP #$02
	BEQ +
	LDA $04            ; no animation at all unless walking
	BNE +
	LDA $14
	LSR #3
	AND #$03
	ASL #2
	STA $03
+
	LDA !157C,x
	STA $02
	BNE NoAdd

	LDA $04            ; for modes 3 and above, only add 4
	CMP #$03
	BCS AddFour
	LDA $03
	CLC : ADC #$10
	BRA Store

AddFour:
	LDA $03
	CLC : ADC #$04
Store:
	STA $03
NoAdd:
	PHX
	LDX #$03
Loop:
	PHX
	TXA
	ORA $03
	TAX

	LDA $04
	CMP #$03
	BCS +
	LDA $00
	CLC : ADC X_Disp,x
	BRA ++
+
	LDA $00
	CLC : ADC X_Disp2,x
++
	STA $0300|!Base2,y

	LDA $01
	CLC : ADC Y_Disp,x
	STA $0301|!Base2,y

	LDA $04
	CMP #$03
	BEQ TilemapA
	CMP #$04
	BEQ TilemapB
	CMP #$05
	BEQ TilemapC
	CMP #$06
	BEQ TilemapD
	CMP #$08
	BEQ TilemapE

	LDA Tilemap,x
	BRA StoreToMap
TilemapA:
	LDA Tilemap2,x
	BRA StoreToMap
TilemapB:
	LDA Tilemap3,x
	BRA StoreToMap
TilemapC:
	LDA Tilemap4,x
	BRA StoreToMap
TilemapD:
	LDA Tilemap5,x
	BRA StoreToMap
TilemapE:
	LDA Tilemap6,x
StoreToMap:
	STA $0302|!Base2,y

	PHX
	LDX $02
	LDA Properties,x
	STA $0303|!Base2,y
	PLX

	INY #4

	PLX
	DEX
	BPL Loop
	PLX

	LDY #$02
	LDA #$03
	%FinishOAMWrite()
	RTS
