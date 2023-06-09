;-----------------------------------------------------------------------;
; Cluster Sandstorm - by Ladida                                         ;
; Great for desert levels! Can also be a snowstorm, or very strong wind.;
; Edit of Roy's original Spike Hell sprite.                             ;
; pixi and sa-1 compabitility by JackTheSpades                          ;
;-----------------------------------------------------------------------;

!SandTile = $0E		;Tile # of the sand tile.
!SandSize = $00		;Size of sand tile. 8x8 by default
!SandPalPage = $31	;YXPPCCCT of tile.


SpeedTableY:
db $01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02 ; Speed table, per sprite. Amount of pixels to move down each frame. 00 = still, 80-FF = rise, 01-7F = sink.

SpeedTableX:
db $F9,$FB,$FA,$FB,$F9,$FB,$FA,$FB,$F9,$FB,$FA,$FB,$F9,$FB,$FA,$FB,$F9,$FB,$FA,$FB ; Speed table, per sprite. Amount of pixels to move down each frame. 00 = still, 80-FF = rise, 01-7F = sink.

OAMStuff:
db $40,$44,$48,$4C,$50,$54,$58,$5C,$60,$64,$68,$6C,$80,$84,$88,$8C,$B0,$B4,$B8,$BC ; These are all in $02xx

Properties:
db $00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0 ; Properties table, per sprite. YXPPCCCT.

PropertiesTwo:
db $80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40 ; Properties table, per sprite. YXPPCCCT.


IncrementByOne:
	LDA $1E02|!addr,y              ; \ Increment Y position of sprite.
	INC A                           ;  |
	STA $1E02|!addr,y              ;  |
	SEC                             ;  | Check Y position relative to screen border Y position.
	SBC $1C                         ;  | If equal to #$F0...
	CMP #$F0                        ;  |
	BNE +                           ;  |
	LDA #$01                        ;  | Appear.
	STA $1E2A|!addr,y              ; /

+
	RTL

print "MAIN ",pc
Main:                              ;The code always starts at this label in all sprites.
	LDA $1E2A|!addr,y              ; \ If meant to appear, skip sprite intro code.
	BEQ IncrementByOne              ; /

	LDA $9D                         ; \ Don't move if sprites are supposed to be frozen.
	BNE Immobile                    ; /
	LDA $14
	AND #$03
	BEQ +
	LDA $1E02|!addr,y              ; \
	CLC                             ;  |
	ADC SpeedTableY,y               ;  | Movement.
	STA $1E02|!addr,y              ; /
+

	LDA $1E16|!addr,y
	CLC
	ADC SpeedTableX,y
	STA $1E16|!addr,y

Immobile:                          ; OAM routine starts here.
	LDA !cls_spriteset_off,y
	STA !tile_off_scratch

	LDX.w OAMStuff,y                ; Get OAM index.
	LDA $1E02|!addr,y              ; \ Copy Y position relative to screen Y to OAM Y.
	SEC                             ;  |
	SBC $1C                         ;  |
	STA $0201|!addr,x              ; /
	LDA $1E16|!addr,y              ; \ Copy X position relative to screen X to OAM X.
	SEC                             ;  |
	SBC $1A                         ;  |
	STA $0200|!addr,x              ; /
	LDA #!SandTile                  ; \ Tile
	CLC : ADC !tile_off_scratch
	STA $0202|!addr,x               ; /
	LDA $14
	LSR #2
	AND #$01
	BEQ +
	LDA Properties,y
	ORA #!SandPalPage
	BRA ++
+
	LDA PropertiesTwo,y
	ORA #!SandPalPage
++
	STA $0203|!addr,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA #!SandSize
	STA $0420|!addr,x
	PLX
	LDA $18BF|!addr
	ORA $1493|!addr
	BEQ +                           ; Change BEQ to BRA if you don't want it to disappear at generator 2, sprite D2.
	LDA $0201|!addr,x
	CMP #$F0                        ; As soon as the sprite is off-screen...
	BCC +
	LDA #$00                        ; Kill it.
	STA $1892|!addr,y              ;

+	RTL
