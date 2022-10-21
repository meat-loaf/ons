prot SPRITEGFX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Island Spike (Mace Penguin)
; Coded by SMWEdit
;
; Uses first extra bit: NO
;
; You will need to patch SMKDan's dsx.asm to your ROM with xkas
; this sprite, like all other dynamic sprites, uses the last 4 rows of sp4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!mace_sprite_num = $12           ; sprite number of mace
	!throw_time = $40                ; time (if uninterrupted) between throws
	!spit_y_range = $50              ; how close (Y) mario must be to spit

	!jump_y_speed = $E8              ; Y speed of jump

;; don't change these:
	!num_walk_frames = $2A
	!num_throw_frames = $46

	!mace_y_off = $EC
	!mace_spawn_frame = $40

	!act_status = !C2
	!tile_num = !1602
	!offset = !1528
	!throw_timer = !163E

	; two bytes
	!spr_x_scratch = $04
	; two bytes
	!spr_y_scratch = $06

	; two bytes
	!generic_scratch1 = $00
	; two bytes
	!generic_scratch2 = $02

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "INIT ",pc
	%SubHorzPos()
	TYA                             ; | face mario
	STA !157C,x                     ; /
	LDA #!throw_time                ; \ start throw
	STA !throw_timer,x              ; / timer
	RTL

	print "MAIN ", pc
	PHB
	PHK
	PLB
	JSR SPRITE_ROUTINE
	PLB
	RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPEED_TABLE:
	db $06,$FA                      ; normal movement

JUMPSPEEDTABLE:
	db $F8,$08                      ; movement backwards when jumping

MACESPEEDS:
	db $20,$E0                      ; speeds mace is thrown at

RETURN1:
	RTS

SPRITE_ROUTINE:
	JSR SUB_GFX
	LDA !14C8,x                     ; \ return if sprite
	EOR #$08                        ; | status is not 08,
	ORA $9D                         ; | sprites locked,
	ORA !15D0,x                     ; | or being eaten
	BNE RETURN1                     ; /
	%SubOffScreen()                 ; only process sprite while on screen

	LDA !1588,x                     ; \
	AND #$03                        ; | if the sprite
	BEQ DONT_CHANGE_DIR             ; | is hitting a
	LDA !157C,x                     ; | wall, then flip
	EOR #%00000001                  ; | its direction
	STA !157C,x                     ; /
DONT_CHANGE_DIR:
	LDA !act_status,x               ; get status
	BEQ WALKING                     ; 0: walking
	DEC A                             ; ...
	BEQ SPITTING                    ; 1: spitting
	JMP JUMPING                     ; else: jumping

WALKING:
	LDY !157C,x                     ; \  set X
	LDA SPEED_TABLE,y               ; | speed
	STA !B6,x                       ; /
	INC !tile_num,x                 ; next tile in animation
	LDA !tile_num,x                 ; \
	CMP #!num_walk_frames           ; | back to zero
	BCC NO_ZERO_TILENUM             ; | if too high
	STZ !tile_num,x                 ; /
NO_ZERO_TILENUM:
	LDA !throw_timer,x              ; \
	BNE NO_START_SPIT               ; | if ready
	LDA #$01                        ; | then start
	STA !act_status,x               ; | spitting
	STZ !offset,x                   ; /
NO_START_SPIT:
	LDA !14D4,x                     ; \
	CMP $97                             ; | if too
	BNE HOLD_FIRE                   ; | far away
	LDA !D8,x                       ; | vertically
	SEC                             ; | then reset
	SBC $96                             ; | timer for
	BPL CHECK_Y                     ; | spitting
	EOR #%11111111                  ; |
	INC A                             ; |
CHECK_Y:
	CMP #!spit_y_range              ; |
	BCS HOLD_FIRE                   ; /
	%SubHorzPos()
	TYA                             ; | ...otherwise if facing mario,
	CMP !157C,x                     ; | don't reset spit timer
	BEQ NO_HOLD_FIRE                ; /
HOLD_FIRE:
	LDA #!throw_time                ; \ reset
	STA !throw_timer,x              ; / timer
NO_HOLD_FIRE:
	BRA AFTERMAINCODE               ; skip code for other modes

SPITTING:
	STZ !B6,x                ; don't move horizontally
	INC !offset,x            ; next frame
	LDA !offset,x            ; \
	CLC                      ; | offset to tile numbers
	ADC #!num_walk_frames    ; | is added to frame offset
	STA !tile_num,x          ; /
	LDA !offset,x            ; \  if this isn't the last frame
	CMP #!num_throw_frames-1 ; | in spitting, then don't
	BCC NO_END_THROW         ; /  execute the following code
	LDA #$02                 ; \ jumping
	STA !act_status,x        ; / mode
	LDY !157C,x              ; \  set X
	LDA JUMPSPEEDTABLE,y     ; | speed
	STA !B6,x                ; /
	LDA #!jump_y_speed       ; \ set Y
	STA !AA,x                ; / speed
NO_END_THROW:
	JSR MACEINTERACTION      ; interact with mace as it's growing
	LDA !offset,x            ; \
	CMP #!mace_spawn_frame   ; | throw mace if it's the
	BNE AFTERMAINCODE        ; / proper frame to do so
	STZ $00                  ; x-off
	LDA #!mace_y_off
	STA $01                  ; spikeball y-off
	LDA !157C,x
	STA $0F                  ; direction backup
	TAY : LDA MACESPEEDS,y
	STA $02                  ; spikeball x speed
	STZ $03                  ; spikeball y speed
	LDA #!mace_sprite_num
	SEC
	%SpawnSprite()
	BCS AFTERMAINCODE
	LDA $0F
	STA !157C,y
NOTHROW:
	BRA AFTERMAINCODE        ; skip code for other modes

JUMPING:
	STZ !tile_num,x          ; tile number offset will be zero while jumping
	LDA !1588,x              ; \
	AND #%00000100           ; | on ground?
	BEQ NO_END_JUMP          ; /
	STZ !act_status,x        ; \  if so, then
	LDA #!throw_time         ; | reset status
	STA !throw_timer,x       ; /  and timer
NO_END_JUMP:

AFTERMAINCODE:
	JSL $01802A|!bank        ; update position based on speed values
	JSL $018032|!bank        ; interact with other sprites
	JSL $01A7DC|!bank        ; check for mario/sprite contact
RETURN:
	RTS

MACEINTERACTION:
	LDY !offset,x           ; \  don't even bother with
	LDA SHOWMACE,y          ; | the rest of this code
	BEQ RETURN              ; /  if mace isn't being shown
	LDA !E4,x               ; \
	STA !spr_x_scratch      ; | store sprite X
	LDA !14E0,x             ; | and Y position
	STA !spr_x_scratch+1    ; | into scratch
	LDA !D8,x               ; | RAM for use
	STA !spr_y_scratch      ; | in some of the
	LDA !14D4,x             ; | following code
	STA !spr_y_scratch+1    ; /
	LDA !E4,x               ; \
	PHA                     ; | back up sprite's
	LDA !14E0,x             ; | position so I
	PHA                     ; | can shift it
	LDA !D8,x               ; | around temporarily
	PHA                     ; |
	LDA !14D4,x             ; |
	PHA                     ; /
	LDY !157C,x             ; load sprite direction into Y register
	LDA !offset,x           ; load frame offset into A
	PHX                     ; back up X (index in sprite tables)
	TAX                     ; transfer A (offset) into X
	CPY #$00                ; \ decide whether to add or subtract
	BNE NOSWITCHMOFFI	; / mace offsets based on direction
SWITCHMOFFI:
	LDA !spr_x_scratch      ; \
	SEC                     ; | facing right, so subtract
	SBC MACE_X,x            ; | X coordinates (since they
	STA !generic_scratch1   ; | are negative)
	LDA !spr_x_scratch+1    ; |
	SBC MACE_X_H,x          ; |
	STA !generic_scratch1+1 ; /
	BRA ENDOFFSWITCHMI      ; banch to after following code
NOSWITCHMOFFI:
	LDA !spr_x_scratch      ; \
	CLC                     ; | add X coordinates
	ADC MACE_X,x            ; | to sprite's
	STA !generic_scratch1   ; | X position
	LDA !spr_x_scratch+1    ; | and store into
	ADC MACE_X_H,x          ; | scratch RAM
	STA !generic_scratch1+1 ; /
ENDOFFSWITCHMI:
	PLX                     ; load backed up X
	LDA !generic_scratch1   ; \
	STA !E4,x               ; | transfer shifted X
	LDA !generic_scratch1+1 ; | to sprite's X
	STA !14E0,x             ; /
	LDA !offset,x           ; load frame offset into A
	PHX                     ; back up X (index in sprite tables)
	TAX                     ; transfer A (offset) into X
	LDA !spr_y_scratch      ; \
	CLC                     ; | add Y coordinates
	ADC MACE_Y,x            ; | to sprite's
	STA !generic_scratch2   ; | Y position
	LDA !spr_y_scratch+1    ; | and store into
	ADC MACE_Y_H,x          ; | scratch RAM
	STA !generic_scratch2+1 ; /
	PLX                     ; load backed up X
	LDA !generic_scratch2   ; load shifted Y low byte
	STA !D8,x               ; store into sprite's Y low
	LDA !generic_scratch2+1 ; load shifted Y high byte
	STA !14D4,x             ; store shifted high byte
	LDA !1656,x             ; get first tweaker byte
	PHA                     ; back it up
	AND #%11101111          ; temporary "can't be jumped on"
	STA !1656,x             ; set temporary setting
	JSL $01A7DC|!bank       ; add a mario interaction field to shifted position
	PLA                     ; load backed up settings
	STA !1656,x             ; restore backup
	PLA                     ; \
	STA !14D4,x             ; | load backed up
	PLA                     ; | sprite position
	STA !D8,x               ; |
	PLA                     ; |
	STA !14E0,x             ; |
	PLA                     ; |
	STA !E4,x               ; /
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!num_tiles_drawn = $08	; \ scratch RAM
	!tile_scratch_ram = $03	; / addresses

TILES:
	db $04,$04,$04,$04,$04,$04,$04
	db $04,$04,$04,$04,$04,$04,$04
	db $02,$02,$02,$02,$02,$02,$02
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $02,$02,$02,$02,$02,$02,$02

	db $06,$06,$06,$06
	db $06,$06,$06,$06
	db $06,$06,$06,$06
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $08,$08,$08,$08
	db $0A,$0A,$0A,$0A
	db $0A,$0A,$0A,$0A
	db $0A,$0A,$0A,$0A
	db $0A,$0A,$0A,$0A
	db $0A,$0A

SHOWMACE:
	db $00,$00,$00,$00
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $01,$01,$01,$01
	db $00,$00,$00,$00
	db $00,$00

FRAMES:
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $01,$01,$01,$01
	db $02,$02,$02,$02
	db $03,$03,$03,$03
	db $10,$10,$10,$10
	db $11,$11,$11,$11
	db $12,$12,$12,$12
	db $13,$13,$13,$13
	db $20,$20,$20,$20
	db $21,$21,$21,$21
	db $22,$22,$22,$22
	db $23,$23,$23,$23
	db $30,$30,$30,$30
	db $31,$31,$31,$31
	db $32,$32,$32,$32

MACE_X:
	db $00,$00,$00,$00
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F8,$F8,$F8,$F8
	db $00,$00,$00,$00
	db $08,$08,$08,$08

MACE_X_H:
	db $00,$00,$00,$00
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $00,$00,$00,$00
	db $00,$00,$00,$00

MACE_Y:
	db $00,$00,$00,$00
	db $F6,$F6,$F6,$F6
	db $F6,$F6,$F6,$F6
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $F4,$F4,$F4,$F4
	db $EE,$EE,$EE,$EE
	db $EC,$EC,$EC,$EC
	db $EE,$EE,$EE,$EE

MACE_Y_H:
	db $00,$00,$00,$00
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF

MACE_TILES:
	db $00,$02,$20,$22
MACE_XPOS:
	db $F8,$08,$F8,$08
MACE_YPOS:
	db $F8,$F8,$08,$08
SUB_GFX:
	%GetDrawInfo()           ; get info to draw tiles

	LDA !157C,x              ; \ store direction
	STA $02                  ; / to scratch RAM
	STZ !num_tiles_drawn     ; zero tiles drawn
	PHY                      ; \
	LDY !offset,x            ; | draw mace
	LDA SHOWMACE,y           ; | if it is
	PLY                      ; | to be
	CMP #$00                 ; | shown
	BEQ NO_MACE              ; |
	JSR DRAW_MACE            ; /
NO_MACE:
	JSR DRAW_PENGUIN         ; draw actual enemy tiles
	JSR SETTILES             ; set tiles / don't draw offscreen
ENDSUB:
	RTS

DRAW_PENGUIN:
	LDA $00                  ; \ X
	STA $0300|!addr,y        ; /
	LDA $01                  ; \ Y
	STA $0301|!addr,y        ; /
	PHY                      ; \
	LDY !tile_num,x          ; | tile
	LDA TILES,y              ; | number
	PLY                      ; |
	STA $0302|!addr,y        ; /
	LDA !15F6,x              ; get props
	PHX                      ; \
	LDX $02                  ; | flip if
	BNE NO_FLIP_P            ; | sprite is
	ORA #$40                 ;  / flipped
NO_FLIP_P:
	PLX
	ORA $64                  ; > priority bytes
	STA $0303|!addr,y        ; > store props
	INY #4                   ; > next slot
	INC !num_tiles_drawn     ; another tile was drawn
	RTS

DRAW_MACE:
	LDA !offset,x           ; \
	PHY                     ; | set frame according
	TAY                     ; | to offset
	LDA FRAMES,y            ; |
	PLY                     ; /
SETFRM:
	REP #$10
	LDX.w #SPRITEGFX
	%GetDynSlot()
	BCC ENDSUB              ; if none left, end
	STA !tile_scratch_ram   ; store tile into scratch RAM

	PHX                     ; back up X
	LDX #$00                ; load X with zero
TILELP:
	CPX #$04                ; end of loop?
	BNE NORETFRML           ; if not, then don't end
	JMP RETFRML             ; if so, then JMP to end (BRA is out of range)
NORETFRML:
	LDA $00                 ; get sprite's X position
	PHY                     ; \
	LDY $02                 ; | offset by
	BNE NO_FLIP_M           ; | this tile's
	SEC                     ; | X position
	SBC MACE_XPOS,x         ; | (add or
	BRA END_FLIP_M          ; | subtract
NO_FLIP_M:
	CLC                     ; | depending on
	ADC MACE_XPOS,x         ; | direction)
END_FLIP_M:                     ; /
	PLY                     ; \
	PHX                     ; |
	LDX $15E9|!addr               ; | offset by
	PHA                     ; | mace's X
	LDA !offset,x           ; | position
	TAX                     ; | (add or
	PLA                     ; | subtract
	PHY                     ; | depending on
	LDY $02                 ; | direction)
	BNE NOSWITCHMOFF        ; |
SWITCHMOFF:
	SEC                     ; |
	SBC MACE_X,x            ; |
	BRA ENDOFFSWITCHM	; |
NOSWITCHMOFF:
	CLC                     ; |
	ADC MACE_X,x            ; |
ENDOFFSWITCHM:
	PLY                     ; |
	PLX                     ; /
	STA $0300|!addr,y             ; set tile's X position
	LDA $01                 ; get sprite's Y position
	CLC                     ; \ offset by
	ADC MACE_YPOS,x         ; / Y position
	PHX                     ; \
	LDX $15E9|!addr               ; | offset by
	PHA                     ; | mace's Y
	LDA !offset,x           ; | position
	TAX                     ; |
	PLA                     ; |
	CLC                     ; |
	ADC MACE_Y,x            ; |
	PLX                     ; /
	STA $0301|!addr,y             ; set tile's Y position
	LDA !tile_scratch_ram	; load tile # from scratch RAM
	CLC                     ; \ shift tile right/down
	ADC MACE_TILES,x	; / according to which part
	STA $0302|!addr,y             ; set tile #
	PHX                     ; back up X (index to tile data)
	LDX $15E9|!addr               ; load X with index to sprite
	LDA !15F6,x             ; load palette info
	PHX                     ; \
	LDX $02                 ; | flip the tile
	BNE NO_FLIP_MACE	; | if the sprite
	ORA #%01000000          ; | is flipped
NO_FLIP_MACE:
	PLX                     ; /
	ORA $64                 ; > add in priority bits
	STA $0303|!addr,y             ; > set extra info
	PLX                     ; > load backed up X
	INC !num_tiles_drawn    ; > another tile was drawn
	INY #4                  ; > index next slot
	INX                     ; > next tile to draw
	JMP TILELP              ; > loop (BRA is out of range)
RETFRML:
	PLX                     ; load backed up X
ENDMACE:
	RTS

SETTILES:
	LDA !num_tiles_drawn    ; \ don't reserve
	BEQ NODRAW              ; / if no tiles
	LDY #$02                ; #$02 means 16x16
	DEC A                   ; A = # tiles - 1
	%FinishOAMWrite()
NODRAW:
	RTS

SPRITEGFX:
incbin "yispike.bin"
