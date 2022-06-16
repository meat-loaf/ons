prot SPRITEGFX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mace
; for Yoshi's Island Spike (Mace Penguin)
; Coded by SMWEdit
;
; Uses first extra bit: NO
;
; You will need to patch SMKDan's dsx.asm to your ROM with xkas
; this sprite, like all other dynamic sprites, uses the last 4 rows of sp4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!offset = !1528
	!flipxy = !151C

;; other defines
	!num_spin_frames = $20

	!drawn_tiles_scr = $08	; \ scratch RAM
	!tmp_for_tile = $03	; / addresses



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SPRITE_ROUTINE
	PLB
	print "INIT ",pc
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN1:
	RTS

SPRITE_ROUTINE:
	JSR SUB_GFX
	LDA !14C8,x              ; \ return if sprite
	EOR  #$08                ; / status is not 8
	ORA $9D                  ;  | sprites
	BNE RETURN1              ; /  are locked
	%SubOffScreen()

	LDA !offset,x             ; \
	CMP #!num_spin_frames-1   ;  | update spin
	BEQ SRESET                ;  | frame offset
	INC !offset,x             ;  |
	BRA AFTERSPINUPDATE	  ;  |
SRESET:
	STZ !offset,x             ; /
	LDA !flipxy,x             ; \  rotate sprite
	EOR #%00000001            ;  | 180 degrees for
	STA !flipxy,x             ; /  next time around
AFTERSPINUPDATE:

	JSL $018022|!bank         ; Update X position without gravity
	JSL $01801A|!bank         ; Update Y position without gravity
	JSL $018032|!bank         ; interact with other sprites
	JSL $01A7DC|!bank         ; check for mario/sprite contact
RETURN:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FRAMES:
	db $00,$00,$00,$00
	db $01,$01,$01,$01
	db $02,$02,$02,$02
	db $03,$03,$03,$03
	db $10,$10,$10,$10
	db $11,$11,$11,$11
	db $12,$12,$12,$12
	db $13,$13,$13,$13

MACE_TILES:
	db $00,$02,$20,$22
MACE_XPOS:
	db $F8,$08,$F8,$08
MACE_YPOS:
	db $F8,$F8,$08,$08

SUB_GFX:
	%GetDrawInfo()
	LDA !157C,x             ; \  store direction
	EOR !flipxy,x           ;  | to scratch RAM
	STA $02                 ; /
	LDA !flipxy,x           ; \  store Y
	STA $04                 ; /  flip
	STZ !drawn_tiles_scr    ; zero tiles drawn
	JSR DRAW_MACE           ; draw mace
	JSR SETTILES            ; set tiles / don't draw offscreen
ENDSUB:
	RTS

DRAW_MACE:
	LDA !offset,x           ; \
	PHY                     ;  | set frame according
	TAY                     ;  | to offset
	LDA FRAMES,y            ;  |
	PLY                     ; /
SETFRM:
	REP #$10
	LDX.w #SPRITEGFX
	%GetDynSlot()           ; call routine to get a slot
	BCC ENDSUB              ; if none left, end
	STA !tmp_for_tile       ; store tile into scratch RAM

	PHX                     ; back up X
	LDX #$00                ; load X with zero
TILELP:
	CPX #$04                ; end of loop?
	BNE NORETFRML           ; if not, then don't end
	JMP RETFRML             ; if so, then JMP to end (BRA is out of range)
NORETFRML:
	LDA $00                 ; get sprite's X position
	PHY                     ; \
	LDY $02                 ;  | offset by
	BNE NO_FLIP_M           ;  | this tile's
	SEC                     ;  | X position
	SBC MACE_XPOS,x         ;  | (add or
	BRA END_FLIP_M          ;  | subtract
NO_FLIP_M:
	CLC                     ;  | depending on
	ADC MACE_XPOS,x         ;  | direction)
END_FLIP_M:
	PLY                     ; /
	STA $0300|!addr,y             ; set tile's X position
	LDA $01                 ; get sprite's Y position
	PHY                     ; \
	LDY $04                 ;  | offset by
	BEQ NO_FLIP_F2          ;  | this tile's
	SEC                     ;  | Y position
	SBC MACE_YPOS,x         ;  | (add or
	BRA END_FLIP_F2         ;  | subtract
NO_FLIP_F2:
	CLC                     ;  | depending on
	ADC MACE_YPOS,x         ;  | direction)
END_FLIP_F2:
	PLY                     ; /
	STA $0301|!addr,y             ; set tile's Y position
	LDA !tmp_for_tile       ; load tile # from scratch RAM
	CLC                     ; \ shift tile right/down
	ADC MACE_TILES,x        ; / according to which part
	STA $0302|!addr,y             ; set tile #
	PHX                     ; back up X (index to tile data)
	LDX $15E9|!addr               ; load X with index to sprite
	LDA !15F6,x             ; load palette info
	PHX                     ; \
	LDX $02                 ;  | flip the tile
	BNE NO_FLIP_MACE        ;  | if the sprite
	ORA #%01000000          ;  | is flipped
NO_FLIP_MACE:
	PLX                     ; /
	PHX                     ; \
	LDX $04                 ;  | flip the tile
	BEQ NO_FLIP_MACE2	;  | if the sprite
	ORA #%10000000          ;  | is flipped V
NO_FLIP_MACE2:
	PLX                     ; /
	ORA $64                 ; add in priority bits
	STA $0303|!addr,y             ; set extra info
	PLX                     ; load backed up X
	INC !drawn_tiles_scr    ; another tile was drawn
	INY #4                  ; /
	INX                     ; next tile to draw
	JMP TILELP              ; loop (BRA is out of range)
RETFRML:
	PLX                     ; load backed up X
ENDMACE:
	RTS

SETTILES:
	LDA !drawn_tiles_scr    ; \ don't reserve
	BEQ NODRAW              ; / if no tiles
	LDY #$02                ; #$02 means 16x16
	DEC A                   ; A = # tiles - 1
	%FinishOAMWrite()
NODRAW:
	RTS


SPRITEGFX:
INCBIN "spikemace.bin"
