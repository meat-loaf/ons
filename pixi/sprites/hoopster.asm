;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hoopster, from SMB2 (or USA) by Romi (optimized by Blind Devil)
;
;Extra Bit: No
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Extra Property 1
;bit 0 - can be killed by spin jump
;bit 1 - can be carried
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TileMap:		db $09,$0B

Yspeed:			db $08,$FA,$16,$F0	;slow up, slow down, fast up, fast down

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc

			LDA $96
			CMP !D8,x
			LDA $97
			SBC !14D4,x
			BPL InitReturn
			INC !157C,x
InitReturn:		RTL

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SpriteMain
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteMain:		JSR SpriteGraphic

			LDA !14C8,x
			EOR #$08
			ORA $9D
			BNE Return
			%SubOffScreen()
			INC !1570,x

			LDY !157C,x
			LDA $94
			SEC
			SBC !E4,x
			CLC
			ADC #$18
			CMP #$50
			BCS NotNearMario
			LDA #$01
			STA !1504,x
			INY
			INY
NotNearMario:		LDA Yspeed,y
			STA !AA,x
			JSL $01801A|!BankB
			JSL $019138|!BankB
			LDA $185F|!Base2
			CMP #$25
			BNE CheckGroundStatus
			LDA $18D7|!Base2
			BEQ ChangeDir
CheckGroundStatus:	LDA !1588,x
			BEQ Interact
ChangeDir:		JSR ChangeDirection
Interact:		;LDY #$B9
			;LDA $1490|!Base2
			;BNE DefaultInteraction
			;LDA !7FAB28,x
			;AND #$01
			;AND $140D|!Base2
			;BEQ StoreTo167A
DefaultInteraction:	;LDY #$39
StoreTo167A:		;TYA	
			;STA !167A,x
			JSL $01803A|!BankB
			BCC Return
			LDA !14C8,x
			CMP #$08
			BNE Return
			;PHK
			;PER.w $0007
			;PEA $8020
			;JML $01B45C|!BankB
Return:			RTS
			BCC SpriteWins
			LDA !7FAB28,x
			AND #$02
			BEQ MarioWins
			BIT $16
			BVC MarioWins
			LDA #$0B
			STA !14C8,x
			STZ !1540,x
			LDA #$99
			STA !167A,x
			LDA #$80
			STA !1686,x
			RTS
MarioWins:		LDA #$08
			STA !154C,x
			RTS

SpriteWins:		LDA !154C,x
			BNE MarioGndStatus

			JSL $00F5B7|!BankB
			RTS

MarioGndStatus:		LDA $77
			AND #$08
			BEQ Return
			LDA !1540,x
			BNE Return
			LDA #$04
			STA !1540,x
ChangeDirection:	LDA !157C,x
			EOR #$01
			STA !157C,x
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite's Graphic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Property:		db $00,$80

SpriteGraphic:		%GetDrawInfo()

;			LDA !spr_spriteset_off,x
;			STA $04

			LDA !1504,x
			PHP
			LDA !1570,x
			LSR #2
			PLP
			BNE Graphic000
			LSR
Graphic000:		AND #$01
			STA $03
			LDA !157C,x
			STA $02

			PHX
			REP #$20
			LDA $00
			STA $0300|!Base2,y
			SEP #$20
			LDX $03
			LDA TileMap,x
			STA $0302|!Base2,y
			LDX $02
			LDA Property,x
			LDX $15E9|!Base2
			ORA !15F6,x
			ORA $64
			STA $0303|!Base2,y
			PLX
			LDY #$02
			LDA #$00
			%FinishOAMWrite()
			RTS
