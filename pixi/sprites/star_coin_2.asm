prot StarCoinGFX

; 32x32 Star Coin, sprite version, by Blind Devil

; Extra bit: determines if it goes in front or behind layer 1.
; clear = in front
; set = behind

; Extra byte 1 (extension): Position offset
; High nybble is the Y offset, low Nybble is the X offset

; SHELL-LIKE-COLLECTIBLE
; If this is enabled, the coin can be collected via thrown sprites such as
; Koopa shells, throw blocks and others.
; 0 = disabled, 1 = enabled.

!ShellCollect = 1

!dyn_tile_scratch = $0F

!bank = !BankB
!dp = !Base1
!addr = !Base2

!animation_frame = !1602
!frame_collected = $10

print "INIT ",pc
	%BEC(.notset)
	INC !1632,x      ; make sprite go behind layer 1
.notset
	%sprite_init_do_pos_offset(!extra_byte_1,x)
	%sprite_item_memory_invoc(read_item_memory|!bank)
	LDA $0F
	BEQ .nodelete
	STZ !14C8,x
.nodelete:
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteCode
	PLB
	RTL

Return:
	RTS

SpriteCode:
	JSR Graphics

	LDA !14C8,x       ; load sprite status
	EOR #$08          ; check if default/alive
	ORA $9D           ; load sprites/animation locked flag
	BNE Return        ; if set, return.
	
	%SubOffScreen()
	
	LDA $14
	AND #$07
	BNE .no_ani_update
	LDA !animation_frame,x
	INC : AND #$03
	STA !animation_frame,x
.no_ani_update
	
	JSL $01A7DC|!BankB ; call player/sprite interaction routine
	BCC +              ; if there's no interaction, branch.
	
	LDA !1632,x        ; load sprite is behind layer 1 flag
	CMP $13F9|!Base2   ; compare with player is behind layer 1 flag
	BEQ CollectIt      ; if equal, collect coin.
	
	+
if !ShellCollect
	LDY #!SprSize-1        ;sprite slot loop count
	Loop:
	LDA !14C8,y        ; load sprite state
	CMP #$09           ; check if stunned
	BEQ Process        ; if yes, check for contact.
	CMP #$0A           ; check if kicked
	BEQ Process        ;if yes, check for contact.
	
	LoopSprSpr:
	DEY                ; decrement Y by one
	BPL Loop           ; loop while it's positive.
	RTS
	
	Process:
	LDA !1632,x           ; load sprite is behind layer 1 flag
	CMP !1632,y           ; compare with kicked sprite is behind layer 1 flag
	BNE LoopSprSpr        ; if not equal, redo the loop.
	
	TYX
	JSL $03B6E5|!BankB    ; get sprite clipping B
	LDX $15E9|!addr       ; restore sprite index
	JSL $03B69F|!BankB    ; get sprite clipping A
	JSL $03B72B|!BankB    ; check for contact
	BCC LoopSprSpr        ; if there's no contact, redo the loop.
else
	RTS
endif

CollectIt:
	LDA #$1A
	STA $1DFC|!addr

	INC !yoshi_coins_collected
	
	LDA !D8,x
	CLC
	ADC #$08
	STA $98
	LDA !14D4,x
	ADC #$00
	STA $99
	LDA !E4,x
	CLC
	ADC #$08
	STA $9A
	LDA !14E0,x
	ADC #$00
	STA $9B

	LDA.b #$08
	CLC
	ADC !yoshi_coins_collected
	%spawn_score_sprite()

	%sprite_item_memory_invoc(write_item_memory|!bank)


	; kill self
	STZ !14C8,x

	RTS

Tile_Offsets:
db $00,$02,$20,$22

XDisp:
db $00,$10
db $00,$10

YDisp:
db $00,$00
db $10,$10

OutlineProps:
db $00,$40
db $80,$C0

NoGfx:
	RTS
Graphics:
	%GetDrawInfo()        ;get sprite positions within the screen and OAM index for sprite tile slots

	REP #$10
	LDA !animation_frame,x
	LDX.w #StarCoinGFX
	%GetDynSlot()
	BCC NoGfx            ; out of slots
	STA !dyn_tile_scratch

	STZ $03
	STZ $04
	
	LDA !1632,x        ; load sprite is behind layer 1 flag
	BNE .negpri        ; if behind layer 1, don't set priority bits.
	LDA $64
	STA $03
.negpri
	LDA !15F6,x        ; load palette/properties from CFG
	ORA $03            ; OR with set up in level priority bits
	STA $02            ; store to scratch RAM.
	
	LDX #$03           ; loop count
GFXLoop:
	LDA $00            ; load sprite X-pos within the screen
	CLC
	ADC XDisp,x
	STA $0300|!Base2,y
	
	LDA $01              ;load sprite Y-pos within the screen
	CLC
	ADC YDisp,x
	STA $0301|!Base2,y
	
	LDA !dyn_tile_scratch
	CLC : ADC Tile_Offsets,x
	STA $0302|!Base2,y
	
	LDA $02              ; load final palette/properties from scratch RAM
.propsover
	STA $0303|!Base2,y
	
	INY #4            ; next oam index
	DEX
	BPL GFXLoop
	
	LDX $15E9|!addr;  ; restore sprite index
	LDY #$02          ; all tiles are 16x16
	LDA #$03          ; tiles drawn minus one
	%FinishOAMWrite()
	RTS

StarCoinGFX:
incbin star_coin.bin
