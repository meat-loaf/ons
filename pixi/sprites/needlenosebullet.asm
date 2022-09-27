;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Island Needle Nose "Bullet" (BlowHard projectile)
; Programmed by SMWEdit
;
; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!NEEDLENOSETILE = $04           ; 16x16 tile to use (on second page)

	!EXPLODESND = $1A               ; sound played when it hits something
	!EXPLODESNDPORT = $1DFC|!Base2  ; RAM adress where the explode sound will be stored to ($1DFC or $1DF9)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		PRINT "MAIN ",pc
		PHB
		PHK
		PLB
		JSR SPRITE_ROUTINE
		PLB
		RTL

		PRINT "INIT ", pc
		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_ROUTINE: JSR SUB_GFX
		LDA !14C8,x             ; \  RETURN if
		EOR #$08
		ORA $9D
		BNE RETURN              ; / sprites locked
		%SubOffScreen()         ; only process sprite while on screen
		                        ;  A is always #$00 due to the previous BNE.

NO_SMOKE:
		LDA !1588,x             ; \
		AND #%00001111          ;  | destroy sprite
		BEQ NO_HIT_SOMETHING    ;  | and do all
;               STZ !14C8,x             ;  | necessary effects
		JSL $07FC3B|!BankB      ;  | if sprite is
		LDA #!EXPLODESND        ;  | hitting an
		STA !EXPLODESNDPORT     ;  | object
		STZ !14C8,x             ; /
		BRA SUB_SMOKE
NO_HIT_SOMETHING:
		JSL $018032|!BankB      ; interact with other sprites
		JSL $018022|!BankB      ; Update X position without gravity
		JSL $01801A|!BankB      ; Update Y position without gravity
		JSL $019138|!BankB      ; interact with objects (normally called within $01802A)
		JSL $01A7DC|!BankB      ; check for mario/sprite contact

		LDA $14                 ; \
		AND #%00000111          ;  | generate
		BNE RETURN              ;  | smoke every
;               LDA #$01                ; /  8 frames

SUB_SMOKE:      LDA !D8,x               ; \
		CMP $1C                 ;  | don't generate
		LDA !14D4,x             ;  | if off screen
		SBC $1D                 ;  | vertically
		BNE RETURN              ; /
		LDA !E4,x               ; \
		CMP $1A                 ;  | don't generate
		LDA !14E0,x             ;  | if off screen
		SBC $1B                 ;  | horizontally
		BNE RETURN              ; /
		STZ $00
		STZ $01
		LDA #$10
		STA $02
		LDA #$01
		%SpawnSmoke()
RETURN:         RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:        %GetDrawInfo()
		LDA $00                 ; \ set x position
		STA $0300|!Base2,y      ; / of the tile
		LDA $01                 ; \ set y position
		STA $0301|!Base2,y      ; / of the tile
		LDA #!NEEDLENOSETILE    ; \ set tile, and
		STA $0302|!Base2,y      ; / number
		LDA !15F6,x             ; get sprite palette info
		ORA $64                 ; add in the priority bits from the level settings
		STA $0303|!Base2,y      ; set properties
		LDY #$02                ; #$02 means the tiles are 16x16
		LDA #$00                ; This means we drew one tile
		%FinishOAMWrite()
		RTS
