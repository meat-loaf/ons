incsrc "../main.asm"

org $00A5AB|!bank
	jsl level_setup_ram_special

;; camera hijacks ;;
; replace original calls to camera subroutine to camera script invoc
org $009712|!bank
	jsl exec_camera_script
org $009A58|!bank
	jsl exec_camera_script
org $00A299|!bank
	jsl exec_camera_script

; replaces camera scroll constants from original

; fuckin cursed alert
!lm_camera_hijack #= read3($00F6E4+1|!bank)

org !lm_camera_hijack+$0
	sbc.w !camera_bound_left_delta
!lm_camera_hijack_2 #= read3(!lm_camera_hijack+$20+$1)
org !lm_camera_hijack_2+$1
	adc.w !camera_bound_right_delta

; replace load of player's next x position in camera calcs
org $00F71A|!bank
	lda.b !camera_target_x_pos

; same with y position here
org $00F7FE|!bank
	lda.b !camera_target_y_pos
; TODO port other vert code from lx5's camera code (142A behavior for vert positioning), if needed

org $00FF30|!bank
; don't clear rng ram during level to overworld transitions
clearram_norng:
	cpx.w #(!rng_calc-!game_paused)
	bcc .clear
	cpx.w #((!random_number_output+2)-!game_paused)
	bcc .noclear
.clear
	stz !game_paused,x
.noclear:
	rts

; todo the code that copies from the save data buffer to
;      the overworld ram is right above this. when sram
;      saving is fixed, probably relocate this a bit to
;      not need the jsr hijack

org $00A1B5|!bank
	jsr clearram_norng

org $00FFD8|!bank
;if !use_midway_imem_ram_dma == !true
	db $04       ; 16kb sram
;else
;	db $01       ; 2kb sram
;endif

; don't initialize ow sprites here
org $009AA4|!bank
	nop #4

; yoshi wings ani stuff
org $00A6DE|!bank        ; prevent entrance type 5 from making levels slippery
BRA $00

org $00A704|!bank         ; overwrite Yoshi wings flag check in "Do Nothing" entrance types
autoclean JML EntranceType5Check

org $00C82A|!bank
autoclean JML YwingAniType

org $00A08A|!bank
	jml overworld_load

org $00A261|!bank
if !dbg_start_select_end_level == !true
	BRA exit_level : NOP
org $00A269|!bank
exit_level:
else
	LDY !main_level_num
endif

org $00D0E7|!bank
	db $18       ; gamemode to execute on death
;	db $0B       ; gamemode to execute on death
warnpc $00D0E8|!bank

; gm18: gamemode transition -> temp fade
%replace_pointer($009359|!bank,$009F37|!bank)
%replace_pointer($00935B|!bank,gamemode_19|!bank)
%replace_pointer($00935D|!bank,gamemode_1b|!bank)
;%replace_pointer($00935D|!bank,$009F37|!bank)
;%replace_pointer($00935F|!bank,gamemode_1b|!bank)

org $00A5EE|!bank
	jsr $919B
	jsr $8494
	jsl level_load_code
	rts
warnpc $00A5F9|!bank


org $00A2D8|!bank
	jsl level_main

org $009468|!bank
gamemode_19:
	stz !hdma_channel_enable_mirror
autoclean \
	JSL.l gm19
	RTS
;; todo: should be the 'death/return to level or midpoint' menu'
gamemode_1b:
	LDA.b #$10
	STA.w !gamemode
	RTS

warnpc $009557|!bank

freecode
prot gradients
die:
	rtl
level_load_code:
	sep #$30
	; restore hijacked code
	inc !gamemode
	lda #$81
	sta $4200
	; sp1 gfx file value - low
	; used as gradient id to load
	lda !level_header_sgfx3_lo
	cmp #$7f
	beq die

	phb
	rep #$30
	and.w #($3F<<2)
	lsr #2
	sta $00
	asl
	adc $00
	tax
	lda.l gradient_tbl_ptrs+1,x
	sta $01
	lda.l gradient_tbl_ptrs,x
	sta $00
	sep #$20
	ldx.w #!big_hdma_decomp_buff_rg
	stx $03
	ldx.w #!big_hdma_decomp_buff_b
	stx $05
	lda.b #!big_hdma_decomp_buff_rg>>16

	sta $4337
	sta $4347
	pha
	plb

	jsr decomp_gradient
	plb

; majority of below code is interpreted from mariofangamer's
; scrollable hdma uberasm code
	ldx #$3242
	stx $4330
	ldx #$3240
	stx $4340
	ldx.w #!big_hdma_ptr_rg
	stx $4332	; Red-green table
	ldx.w #!big_hdma_ptr_b
	stx $4342	; Blue table
	lda.b #!big_hdma_ptr_rg>>16
	sta $4334	; RAM bank
	sta $4344	; RAM bank

	sep #$30
	ldx #$05
.hdma_init_loop:
	lda.l init_hdma,x
	sta !big_hdma_ptr_rg,x
	sta !big_hdma_ptr_b,x
	dex
	bpl .hdma_init_loop

	lda #$18
	tsb !hdma_channel_enable_mirror
	bra level_main_skip_gm14_entry

level_main:
	jsl $00e2bd|!bank
	jsr SSPMaincode
.skip_gm14_entry:
	lda !level_header_sgfx3_lo
	cmp #$7f
	beq .exit

	rep #$20
	and #$0003
	asl : asl
	tax

	LDA.w #!big_hdma_decomp_buff_rg
	STA $00
	LDA.w #!big_hdma_decomp_buff_b
	STA $02

	lda !layer_1_ypos_curr,x

	pha
	asl
	clc
	adc $00
	sta !big_hdma_ptr_rg+1
	clc
	adc #$00E0
	sta !big_hdma_ptr_rg+4
	pla
	clc
	adc $02
	sta !big_hdma_ptr_b+1
	clc
	adc #$0070
	sta !big_hdma_ptr_b+4
	sep #$20
.exit:
	rtl


gradient_tbl_ptrs:
	dl sky_hdma_table
	dl rainbow_hdma_table

init_hdma:
	db $F0 : dw $0000
	db $F0 : dw $0000

; decompress a scrollable hdma graident
; by mariofangamer
decomp_gradient:
	LDY #$FFFF
; failsafe
;	LDX $0E

.next_row:
	iny
	lda [$00],y
	bne .cont
.ret:
	rts

.cont:
	STA $0F
	INY
	LDA [$00],y
	STA $0C
	INY
	LDA [$00],y
	STA $0D
	INY
	LDA [$00],y
	STA $0E

..Loop
	LDA $0E
	STA ($05)
	REP #$20
	LDA $0C
	STA ($03)
	INC $03
	INC $03
	INC $05
	SEP #$20

; failsafe
;	DEX
;	BMI .Return
	DEC $0F
	BNE ..Loop
	BRA .next_row

level_setup_ram_special:
	; restore hijacked code
	jsl $05809E|!bank
	stz !ambient_playerfireballs
	stz !ambient_playerfireballs+1
	stz !camera_control_resident
	stz !camera_control_resident+1

	lda #(!num_ambient_sprs*2)-2
	sta !ambient_spr_ring_ix
	ldx #(!num_turnblock_slots-1)*6
	stx !turnblock_run_index
	stx !turnblock_free_index
.loop:
	lda #$00
	sta turnblock_status_d.timer,x
	sta turnblock_status_d.timer+1,x
	txa
	sec : sbc #$06
	tax
	bpl .loop
	rtl

; reload all overworld sprites on actual ow load
; instead of just in gm04
overworld_load:
	jsl $04F675|!bank
	lda !ow_entering_star_warp
	beq .cont
	jsl $04853B|!bank
.cont:
	jml $00A093|!bank

EntranceType5Check:
	LDA $192A|!addr       ; Entrance type-- sw___aaa
	AND #$07
	BEQ .Return     ; Entrance type should be 0 or 5 here, so do nothing if it's 0
	JML $00A709|!bank     ; return and set shoot-vertically-upward animation
.Return
	JML $00A715|!bank

YwingAniType:   ; check whether animation occurred from Yoshi wings or entrance type 5
	LDA $192A|!addr
	AND #$07
	CMP #$05
	REP #$20
	BNE YwingReturn ; if entrance type is not 5, then run Yoshi wings code normally
	LDA $80         ;\ Mario's on-screen Y-position
	CMP #$00A0      ;/ if entrance type is 5, then always stop at #$00A0 (can be adjusted)
	SEP #$20
	BPL +
	STZ $71         ; reset Mario's animation
	+
	JML $00CD8F|!bank     ; return, bypassing code to set Yoshi wings flag

YwingReturn:
	LDY $1B95|!addr       ; restore overwritten code
	JML $00C82F|!bank


; ssp code, by greenhammerbro
SSPMaincode:
;.DeathAnimationCheck
;	LDA $71					;\Prevent potential glitch that the player enters pipe and dies
;	CMP #$09				;|during travel (if freezing enabled, at the same frame the players interacts a pipe cap).
;	BNE .PipeStateCheck			;|
;	rts

	.PipeStateCheck
	LDA !Freeram_SSP_PipeDir		;\don't do anything while outside the pipe.
	AND.b #%00001111			;|
	ORA !Freeram_SSP_PipeTmr		;|
	BNE .FreezeCheck			;/
	rts

	.FreezeCheck
	PHB					;\Setup banks
	PHK					;|
	PLB					;/
	LDA $13D4|!addr				;>$13D4 - pause flag.
	if !Setting_SSP_FreezeTime == 0
		ORA $9D				;>Prevent glitches in which !Freeram_SSP_PipeTmr still decrements during freezes like baby yoshi growing when the user disable pipe freezing.
	endif
	ORA $1426|!addr				;>Don't lock controls on message boxes.
	;ORA <address>				;>Other RAM to disable running pipe code.
	BEQ .HandleCarryingSprites
	JMP .pose				;>While the pipe-related code should stop running during a freeze, the pose should still be running (during freeze, he reverts to his normal pose).

	.HandleCarryingSprites
	if !Setting_SSP_CarryAllowed != 0
		..KeyGlitchFailsafe			;>A glitch that forces the player to drop the key upon exiting should the player enter and pick up the key the same frame.
		LDA $1470|!addr
		ORA $148F|!addr
		BEQ ...NoCarry
		LDA #$01
		STA !Freeram_SSP_CarrySpr

		...NoCarry
		LDY #$00			;>Default Y as #$00 (later on, will remain #$00 if not carrying sprites)
		LDA !Freeram_SSP_CarrySpr	;\fix automatic drop item when carrying (when freeze disabled, he shouldn't automatically
		BEQ ..NotCarrying		;/pick up sprites when the player didn't intend to do so.)

		..CarryingSprite
		INY

		..NotCarrying
	endif
	.ForceControlsSetAndClear
	LDA $15					;\
	ORA SSP_CarryControlsForceSet,y		;|>Force X and Y on controller to be set when carrying sprites.
	AND SSP_CarryControlsForceClear,y	;|>Clear out other than XY and START.
	STA $15					;|
	LDA $16					;|\Prevent fireballs and cape action.
	AND.b #%00010000			;||While enabling only the pause button.
	STA $16					;//

	.ResetControlsPBalloonStompCountAndFire
	STZ $17			;\Lock other controls.
	STZ $18			;/
	STZ $13F3|!addr		;\remove p-balloon
	STZ $1891|!addr		;/
	STZ $1697|!addr		;>remove consecutive stomps.
	STZ $140D|!addr		;>so fire mario cannot shoot fireballs in pipe

	.HidePlayer
	LDA !Freeram_SSP_EntrExtFlg	;\hide player if timer hits zero when entering.
	CMP #$02			;|
	BEQ ..NoHide			;|
	LDA !Freeram_SSP_PipeTmr	;|
	BNE ..NoHide			;|
	if !Setting_SSP_PipeDebug == 0
		LDA #$FF		;|
		STA $78			;/
	endif

	..NoHide
	.YoshiImage
	LDA $187A|!addr		;\if on yoshi, then use yoshi poses
	BNE ..OnYoshi		;/

	..OffYoshi
	STZ $73			;>so mario cannot remain ducking (unless on yoshi) as he exits.

	..OnYoshi
	..YoshiPipePose
	LDA !Freeram_SSP_PipeDir
	AND.b #%00000001		;
	BNE ...YoshiFaceScreen		;>Bit 0 clear = horizontal movement, set = vertical movement.

	...YoshiDuck			;>horizontal pipe
	LDA $187A|!addr			;\Do not duck if not riding yoshi.
	BEQ ....NoDuck			;/
	LDA #$04			;\crouch on yoshi
	STA $73				;/

	....NoDuck
	LDA #$01			;\(this should make mario face left or right carrying sprites to the side)
	BRA ...SetYoshiPipePose		;/

	...YoshiFaceScreen		;\yoshi face the screen (vertical pipe, Nintendo did this so that yoshi's head
	LDA #$02			;/doesn't display a glitch graphic).

	...SetYoshiPipePose
	STA $1419|!addr			;>Even if you are not mounted on yoshi, you still have to write a value here, or carrying sprites don't work.

	.InPipeMode
	if !Setting_SSP_PipeDebug == 0
		LDA #$02		;\go behind layers
		STA $13F9|!addr		;/
	endif
	if !Setting_SSP_FreezeTime != 0
		LDA #$0B		;\freeze player (blame $00cde8 for that), note that this also renders the plater invulnerable.
		STA $71			;/
		STA $9D			;>Freeze time
	endif
	LDA #$01			;\allow vertical scroll up.
	STA $1404|!addr			;/
	STZ $14A6|!addr			;>no spinning.
	STZ $1407|!addr			;>so mario cannot fly out of the cap
	STZ $72				;>zero air flag.
	STZ $14A3|!addr			;>no yoshi tongue
	if !Setting_SSP_CarryAllowed != 0
		LDA !Freeram_SSP_CarrySpr	;\if mario not carrying anything, then skip
		BEQ ..NotCarry			;/
		LDA #$01			;\force keep carrying
		STA $1470|!addr			;|
		STA $148F|!addr			;/

		..NotCarry
	endif
	.DirectionalSpeed
	LDA !Freeram_SSP_PipeDir	;\set player speed within pipe (use transfer commands
	AND.b #%00001111		;|>Only read the low 4 bits (nibble)
	TAY				;|so you can use long freeram address)
	LDA.w SSP_PipeXSpeed-1,y	;|
	STA $7B				;|
	LDA.w SSP_PipeYSpeed-1,y	;|
	STA $7D				;/

	.EnterExitTransition
	LDA !Freeram_SSP_EntrExtFlg	;\If mario is already entered the pipe, return.
	BNE ..InPipe			;/
	JMP .PipeCodeReturn

	..InPipe
	CMP #$01		;\If entering a pipe...
	BEQ ...entering_pipe	;/
	CMP #$02		;\If exiting a pipe...
	BEQ ...ExitingPipe	;/
	JMP .PipeCodeReturn

	...entering_pipe		;
	LDA !Freeram_SSP_PipeTmr	;\If timer is 0, set pose
	BNE +
	JMP .pose			;/
	+
	DEC A				;\Otherwise decrement it
	STA !Freeram_SSP_PipeTmr	;/
	BEQ ...StemSpeed		;>If decremented from 1 to 0, accelerate for stem speed
	JMP .pose			;>Otherwise still set pose (cap speed).

	...StemSpeed
	LDA !Freeram_SSP_PipeDir	;\Switch to stem speed keeping the same direction.
	AND.b #%00001111		;|>Check only bits 0-3 (normal direction bits)
	CMP #$05			;|\If already at stem speed, don't subtract again.
	BCC ....StemSpeedDone		;|/(It shouldn't land on #$00 or underflow, stay within #$01-#$08)
	LDA !Freeram_SSP_PipeDir	;|>Reload because we want to retain bits 4-7 (planned direction bits).
	SEC				;|
	SBC #$04			;/
	STA !Freeram_SSP_PipeDir	;>And set pipe direction from cap to stem speed with the same direction.

	....StemSpeedDone
	BRA .pose

	...ExitingPipe			;
	LDA !Freeram_SSP_PipeTmr	;\if timer already = 0, then skip the reset (so it does it once).
	BEQ .pose			;/
	DEC A				;\otherwise decrement timer.
	STA !Freeram_SSP_PipeTmr	;/
	BEQ .ResetStatus		;>Reset status if timer hits zero (happens once after -1 to 0).

	LDA !Freeram_SSP_PipeDir	;\Switch to cap speed keeping the same direction.
	AND.b #%00001111		;|>Check only bits 0-3 (normal direction bits)
	CMP #$05			;|\If already at pipe cap speed, don't add again.
	BCS .pose			;|/
	LDA !Freeram_SSP_PipeDir	;|>Reload because we want to retain bits 4-7 (planned direction bits).
	CLC				;|
	ADC #$04			;/
	STA !Freeram_SSP_PipeDir	;>Set direction
	BRA .pose			;>and skip the reset routine
;---------------------------------
;This resets mario's status.
;It must be exceuted for one frame
;the player exits a pipe.
;---------------------------------
	.ResetStatus
	..HandleCarryingSprites
	if !Setting_SSP_CarryAllowed != 0
		LDA !Freeram_SSP_CarrySpr	;\Holding sprites routine
		BEQ ...NotCarrySprite		;|

		...CarrySprite
		LDA #$40			;|
		BRA ...WriteXYBitController	;|
	endif
	...NotCarrySprite		;|
	LDA #$00			;|

	...WriteXYBitController		;|
	STA $15				;/
	..RevertPipeStatus
	if !Setting_SSP_FreezeTime != 0
		STZ $9D			;>back in motion
	endif
	STZ $13F9|!addr			;>go in front
	STZ $71				;>mario can move
	STZ $73				;>stop crouching (when going exiting down on yoshi)
	STZ $140D|!addr			;>no spinjump out the pipe (possable if both enter and exit caps are bottoms)
	STZ $7B				;\cancel speed
	STZ $7D				;/
	STZ $1419|!addr			;>revert yoshi
	STZ $149F|!addr			;>zero cape "rise up timer"
	LDA $16				;\Prevent fireballs and cape action.
	AND.b #%00010000		;|While enabling only the pause button.
	STA $16				;/
	LDA #$00			;\reset freeram flags
	STA !Freeram_SSP_PipeTmr	;|
	if !Setting_SSP_CarryAllowed != 0
		STA !Freeram_SSP_CarrySpr	;|
	endif
	STA !Freeram_SSP_EntrExtFlg	;/>Make code assume mario is out of the pipe.
	LDA !Freeram_SSP_PipeDir	;\Clear direction bits.
	AND.b #%11110000		;|
	STA !Freeram_SSP_PipeDir	;/
	JMP .PipeCodeReturn
;-----------------------------------------
;code that controls mario's pose
;-----------------------------------------
	.pose
	LDA !Freeram_SSP_PipeDir
	AND #$01
	BEQ ..Horiz		;>If even number (bit 0 is clear), branch to Horizontal

	..Vert
	LDA $187A|!addr		;\if mario is riding yoshi, then
	BNE ...YoshiFaceScrn	;/use face screen instead
	LDA #$0F		;>vertical pipe pose (without regard to powerup status)
	BRA ..SetPose

	...YoshiFaceScrn
	LDA #$21		;>pose that mario turns around partically face the screen
	BRA ..SetPose

	..Horiz
	LDA $187A|!addr		;\if mario is riding yoshi, then
	BNE ...YoshiFaceHoriz	;/use "ride yoshi" pose
	LDA #$00
	BRA ..SetPose

	...YoshiFaceHoriz
	LDA #$1D		;>crouch as entering a horizontal pipe on yoshi.

	..SetPose
	STA $13E0|!addr		;>set player pose

	.PipeCodeReturn
	PLB
	rts
;-------------------------------------------------------
;tables.
;-------------------------------------------------------

SSP_PipeXSpeed:
;X speed table
db $00                            ;>#$01 Stem upwards
db !SSP_HorizontalSpd             ;>#$02 Stem rightwards
db $00                            ;>#$03 Stem downwards
db $100-!SSP_HorizontalSpd        ;>#$04 Sten leftwards
db $00                            ;>#$05 Pipe cap upwards
db !SSP_HorizontalSpdPipeCap      ;>#$06 Pipe cap rightwards
db $00                            ;>#$07 Pipe cap downwards
db $100-!SSP_HorizontalSpdPipeCap ;>#$08 Pipe cap leftwards


SSP_PipeYSpeed:
;Y speed table
db $100-!SSP_VerticalSpd          ;>#$01 Stem upwards
db $00                            ;>#$02 Stem rightwards
db !SSP_VerticalSpd               ;>#$03 Stem downwards
db $00                            ;>#$04 Stem leftwards
db $100-!SSP_VerticalSpdPipeCap   ;>#$05 Pipe cap upwards
db $00                            ;>#$06 Pipe cap rightwards
db !SSP_VerticalSpdPipeCap        ;>#$07 Pipe cap downwards
db $00                            ;>#$08 Pipe cap leftwards

SSP_CarryControlsForceSet:
; first number = force button held when not carrying sprites, second is when carrying.
; a set bit here means a bit is forced to be enabled (button will be held down)
db %00000000, %01000000
SSP_CarryControlsForceClear:
; Same format as above, but fores a button to not be pressed.
; a bit clear here means the button will be forced to be cleared.
db %00010000, %01010000

;; camera scripts ;;

macro camera_script_rt_done()
	sep #$30
	jml $00F6DB|!bank
endmacro

; TODO likely need a means to back up horz/vert scroll lock values from header
; TODO think about how to handle l/r scrolling
exec_camera_script:
	rep #$30
	lda !camera_control_resident
	asl
	tax
	; this opcode actually uses the current program bank,
	; not the data bank!
	jmp (camera_script_rts,x)

camera_script_rts:
	dw .normal
	dw .self_centered_x

; default smw pretty much
.normal:
	lda #$000C
	sta !camera_bound_left_delta
	lda #$0018
	sta !camera_bound_right_delta

	lda !player_x_next
	sta !camera_target_x_pos
	lda !player_y_next
	sta !camera_target_y_pos
	%camera_script_rt_done()

.self_centered_x:
	lda !player_x_next
	sec
	sbc !camera_control_x_pos
	bpl ..not_neg
	eor #$FFFF
	inc
..not_neg:
	cmp #$0020
	; act normal if we're not within 40px on either side
	bcs ..do_normal
	lda !camera_state
	bne ..no_set_bounds

	lda !camera_control_x_pos
	sec
	sbc !player_x_next
	sta !camera_target_x_center

	lda #$0020
	sta !camera_bound_left_delta
	lda #$0040
	sta !camera_bound_right_delta
	lda !camera_control_x_pos
	sta !camera_target_x_pos
	inc !camera_state
	

;	lda #$000C
;	sta !camera_bound_left_delta
;	lda #$0018
;	sta !camera_bound_right_delta
..no_set_bounds:

	lda !camera_control_x_pos
	sta !camera_target_x_pos

	lda !player_y_next
	sta !camera_target_y_pos
	%camera_script_rt_done()
..do_normal:
	stz !camera_state
	bra .normal

;; camera scripts done ;;


;;; new on death code ;;;
;; TODO yi-style restart screen
;; TODO fix sprite facing direction, marios position
;;      is updated after sprites run init code
gm19:
	;LDA.b #$10
	;STA.w !gamemode
	; setup next game mode
	INC.w !gamemode

	; don't do 'from overworld' stuff
	LDA.b #$01
	STA.w !exit_counter

	%midway_backup_restore(!true)
; setup load point
;	JSL.l oam_reset
if (read1($03BCDC|!bank)) != $FF
	; note: clobbers Y if using a new horz level mode.
	JSL.l $03BCDC|!bank
else
	LDX $95
	LDA $5B
	LSR
	BCC .not_vert
	LDX $97
.not_vert:
endif

	LDA.w !midway_flag
	BNE.b .midway
	LDA.w !main_level_num
	REP.b #$20
	AND.w #$00FF
	CMP.w #$0024+$01
	BCC.b .low_lvl_num
	CLC
	ADC.w #$00DC
.low_lvl_num:
	SEP.b #$20
	STA !exit_table,x
	XBA
	ORA #!19D8_flag_lm_modified
	STA !exit_table_new_lm,x
	RTL
.midway:
	PHX
	LDA.b #(midway_ptr_tables|!bank)>>16
	STA $8C

	LDA.w !midway_flag
	DEC
	ASL
	TAY
	LDA.w !main_level_num
	REP.b #$30
	AND.w #$00FF
	ASL
	TAX
	LDA.l midway_ptr_tables,x
	STA $8A
	LDA.b [$8A],y

	SEP.b #$30

	PLX
	STA.w !exit_table,x
	XBA
	STA.w !exit_table_new_lm,x

	RTL

midway_tables:
.level_000:
.level_001:
	%midway_table_entry($0001, !true, !false)
.level_002:
.level_003:
	%midway_table_entry($0003, !true, !false)
	%midway_table_entry($0029, !true, !false)
.level_004:
.level_005:
.level_006:
.level_007:
.level_008:
.level_009:
.level_00A:
.level_00B:
.level_00C:
.level_00D:
.level_00E:
.level_00F:
.level_010:
.level_011:
.level_012:
.level_013:
.level_014:
.level_015:
.level_016:
.level_017:
.level_018:
.level_019:
.level_01A:
.level_01B:
.level_01C:
.level_01D:
	dw $0000,$0000,$0000,$0000,$0000
.level_01E:
	%midway_table_entry($001E, !true, !false)
.level_01F:
.level_020:
.level_021:
.level_022:
.level_023:
.level_024:
	dw $0000,$0000,$0000,$0000,$0000
.level_101:
	%midway_table_entry($0101, !true, !false)
.level_102:
	%midway_table_entry($0102, !true, !false)
.level_103:
	%midway_table_entry($0103, !true, !false)
.level_104:
.level_105:
	%midway_table_entry($0105, !true, !false)
	%midway_table_entry($0142, !true, !false)
.level_106:
	%midway_table_entry($0106, !true, !false)
	%midway_table_entry($0106, !true, !false)
	%midway_table_entry($0144, !true, !false)
.level_107:
	%midway_table_entry($0107, !true, !false)
.level_108:
	%midway_table_entry($0108, !true, !false)
.level_109:
.level_10A:
.level_10B:
.level_10C:
.level_10D:
.level_10E:
.level_10F:
.level_110:
.level_111:
.level_112:
.level_113:
.level_114:
.level_115:
.level_116:
.level_117:
.level_118:
.level_119:
.level_11A:
.level_11B:
.level_11C:
.level_11D:
.level_11E:
.level_11F:
.level_120:
.level_121:
.level_122:
.level_123:
.level_124:
.level_125:
.level_126:
.level_127:
.level_128:
.level_129:
.level_12A:
.level_12B:
.level_12C:
.level_12D:
.level_12E:
.level_12F:
.level_130:
.level_131:
.level_132:
.level_133:
.level_134:
.level_135:
.level_136:
.level_137:
.level_138:
.level_139:
.level_13A:
.level_13B:
	dw $0000,$0000,$0000,$0000,$0000

midway_ptr_tables:
dw midway_tables_level_000
dw midway_tables_level_001
dw midway_tables_level_002
dw midway_tables_level_003
dw midway_tables_level_004
dw midway_tables_level_005
dw midway_tables_level_006
dw midway_tables_level_007
dw midway_tables_level_008
dw midway_tables_level_009
dw midway_tables_level_00A
dw midway_tables_level_00B
dw midway_tables_level_00C
dw midway_tables_level_00D
dw midway_tables_level_00E
dw midway_tables_level_00F
dw midway_tables_level_010
dw midway_tables_level_011
dw midway_tables_level_012
dw midway_tables_level_013
dw midway_tables_level_014
dw midway_tables_level_015
dw midway_tables_level_016
dw midway_tables_level_017
dw midway_tables_level_018
dw midway_tables_level_019
dw midway_tables_level_01A
dw midway_tables_level_01B
dw midway_tables_level_01C
dw midway_tables_level_01D
dw midway_tables_level_01E
dw midway_tables_level_01F
dw midway_tables_level_020
dw midway_tables_level_021
dw midway_tables_level_022
dw midway_tables_level_023
dw midway_tables_level_024
dw midway_tables_level_101
dw midway_tables_level_102
dw midway_tables_level_103
dw midway_tables_level_104
dw midway_tables_level_105
dw midway_tables_level_106
dw midway_tables_level_107
dw midway_tables_level_108
dw midway_tables_level_109
dw midway_tables_level_10A
dw midway_tables_level_10B
dw midway_tables_level_10C
dw midway_tables_level_10D
dw midway_tables_level_10E
dw midway_tables_level_10F
dw midway_tables_level_110
dw midway_tables_level_111
dw midway_tables_level_112
dw midway_tables_level_113
dw midway_tables_level_114
dw midway_tables_level_115
dw midway_tables_level_116
dw midway_tables_level_117
dw midway_tables_level_118
dw midway_tables_level_119
dw midway_tables_level_11A
dw midway_tables_level_11B
dw midway_tables_level_11C
dw midway_tables_level_11D
dw midway_tables_level_11E
dw midway_tables_level_11F
dw midway_tables_level_120
dw midway_tables_level_121
dw midway_tables_level_122
dw midway_tables_level_123
dw midway_tables_level_124
dw midway_tables_level_125
dw midway_tables_level_126
dw midway_tables_level_127
dw midway_tables_level_128
dw midway_tables_level_129
dw midway_tables_level_12A
dw midway_tables_level_12B
dw midway_tables_level_12C
dw midway_tables_level_12D
dw midway_tables_level_12E
dw midway_tables_level_12F
dw midway_tables_level_130
dw midway_tables_level_131
dw midway_tables_level_132
dw midway_tables_level_133
dw midway_tables_level_134
dw midway_tables_level_135
dw midway_tables_level_136
dw midway_tables_level_137
dw midway_tables_level_138
dw midway_tables_level_139
dw midway_tables_level_13A
dw midway_tables_level_13B

freedata
gradients:
sky_hdma_table:
db $2D,$26,$48,$8D
db $01,$26,$49,$8D
db $06,$26,$49,$8E
db $05,$27,$4A,$8E
db $03,$27,$4A,$8F
db $07,$27,$4B,$8F
db $01,$27,$4C,$8F
db $07,$27,$4C,$90
db $05,$27,$4D,$90
db $03,$27,$4D,$91
db $07,$27,$4E,$91
db $01,$27,$4F,$91
db $07,$27,$4F,$92
db $04,$27,$50,$92
db $03,$27,$50,$93
db $08,$27,$51,$93
db $08,$27,$52,$94
db $04,$27,$53,$94
db $03,$27,$53,$95
db $04,$27,$54,$95
db $08,$28,$54,$95
db $03,$29,$54,$95
db $01,$29,$55,$95
db $04,$29,$55,$96
db $08,$2A,$55,$96
db $05,$2B,$55,$96
db $03,$2B,$56,$96
db $08,$2C,$56,$96
db $07,$2D,$56,$97
db $01,$2D,$57,$97
db $08,$2E,$57,$97
db $08,$2F,$57,$97
db $04,$30,$57,$97
db $05,$30,$58,$97
db $09,$31,$58,$97
db $09,$32,$58,$98
db $05,$33,$58,$98
db $04,$33,$59,$98
db $09,$34,$59,$98
db $0B,$35,$59,$98
db $02,$36,$59,$98
db $0B,$36,$5A,$98
db $0C,$37,$5A,$98
db $04,$38,$5B,$98
db $08,$38,$5B,$99
db $0B,$39,$5B,$99
db $01,$39,$5C,$99
db $0C,$3A,$5C,$99
db $09,$3B,$5C,$99
db $03,$3B,$5D,$99
db $0C,$3C,$5D,$99
db $08,$3D,$5D,$99
db $04,$3D,$5E,$99
db $04,$3E,$5E,$99
db $02,$3E,$5E,$9A
db $0D,$3E,$5E,$99
db $0F,$3F,$5E,$99
db $02,$3F,$5D,$98
db $04,$3E,$5D,$98
db $02,$3E,$5C,$98
db $04,$3E,$5C,$97
db $01,$3D,$5C,$97
db $02,$3D,$5B,$97
db $04,$3D,$5B,$96
db $03,$3D,$5A,$96
db $03,$3C,$5A,$95
db $04,$3C,$59,$95
db $03,$3C,$59,$94
db $05,$3B,$58,$94
db $01,$3B,$58,$93
db $05,$3B,$57,$93
db $01,$3A,$57,$93
db $25,$3A,$56,$92
db $00

rainbow_hdma_table:
db $38,$28,$46,$91
db $0D,$29,$46,$91
db $0C,$29,$47,$91
db $07,$29,$47,$92
db $09,$2A,$47,$92
db $05,$29,$47,$92
db $04,$29,$48,$92
db $09,$29,$48,$93
db $06,$29,$49,$93
db $06,$29,$49,$94
db $01,$28,$49,$94
db $09,$28,$4A,$94
db $05,$28,$4A,$95
db $03,$28,$4B,$95
db $03,$28,$4C,$95
db $03,$28,$4D,$95
db $01,$29,$4E,$95
db $02,$29,$4E,$96
db $03,$29,$4F,$96
db $03,$29,$50,$96
db $03,$29,$51,$96
db $02,$29,$52,$96
db $03,$29,$53,$96
db $01,$29,$54,$97
db $02,$2A,$54,$97
db $03,$2A,$55,$97
db $02,$2A,$56,$97
db $05,$2A,$57,$97
db $02,$2A,$57,$96
db $03,$2A,$58,$96
db $03,$29,$58,$95
db $02,$2A,$58,$95
db $05,$2A,$58,$94
db $05,$2B,$58,$93
db $01,$2B,$58,$92
db $05,$2C,$58,$92
db $02,$2C,$58,$91
db $03,$2D,$58,$91
db $03,$2D,$58,$90
db $03,$2E,$58,$90
db $03,$2E,$58,$8F
db $02,$2F,$58,$8F
db $05,$2F,$58,$8E
db $07,$30,$58,$8D
db $04,$31,$58,$8D
db $06,$31,$58,$8E
db $09,$32,$58,$8E
db $03,$33,$58,$8E
db $03,$33,$59,$8E
db $03,$33,$59,$8F
db $09,$34,$59,$8F
db $09,$35,$59,$8F
db $01,$35,$59,$90
db $09,$36,$59,$90
db $09,$37,$59,$90
db $02,$38,$59,$90
db $05,$38,$59,$91
db $06,$39,$59,$91
db $02,$3A,$59,$91
db $06,$3A,$58,$91
db $03,$3A,$57,$91
db $02,$3A,$57,$90
db $05,$3A,$56,$90
db $05,$3A,$55,$90
db $06,$3A,$54,$90
db $02,$3A,$53,$90
db $03,$3B,$53,$8F
db $06,$3B,$52,$8F
db $02,$3B,$51,$8F
db $05,$3B,$51,$8E
db $06,$3B,$50,$8D
db $01,$3B,$50,$8C
db $04,$3B,$4F,$8C
db $04,$3B,$4F,$8B
db $02,$3B,$4E,$8B
db $05,$3B,$4E,$8A
db $06,$3B,$4D,$89
db $01,$3B,$4D,$88
db $04,$3B,$4C,$88
db $03,$3B,$4C,$87
db $03,$3B,$4B,$87
db $04,$3B,$4B,$86
db $01,$3B,$4A,$86
db $3C,$3B,$4A,$85
db $00
