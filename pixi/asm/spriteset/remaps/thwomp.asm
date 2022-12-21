includefrom "remaps.asm"

!thwomp_sprnum = $A7

; replace iggy's ball
%replace_wide_pointer($0182CB|!bank,thwomp_init)
%replace_wide_pointer($01871A|!bank,thwomp_main)

org spr_tweaker_1656_tbl+!thwomp_sprnum
	db $01
org spr_tweaker_1662_tbl+!thwomp_sprnum
	db $06
org spr_tweaker_166E_tbl+!thwomp_sprnum
	db $33
org spr_tweaker_167A_tbl+!thwomp_sprnum
	db $01
org spr_tweaker_1686_tbl+!thwomp_sprnum
	db $01
org spr_tweaker_190F_tbl+!thwomp_sprnum
	db $24

!thwomp_angry_face_tile = $06

!thwomp_hit_ground_sfx_id   = $09
!thwomp_hit_ground_sfx_port = $1DFC

!thwomp_phase               = !C2
!thwomp_spawn_lo            = !151C
!thwomp_face_frame          = !1528
!thwomp_spawn_hi            = !1534
!thwomp_hit_ground_wait     = !1540
!thwomp_block_check         = !1594

!thwomp_speed_tbl_ptr       = $45
!thwomp_speed_upd_ptr       = $47
!thwomp_pos_lo_tbl_ptr      = $4A
!thwomp_pos_hi_tbl_ptr      = $4C
org !bank1_bossfire_free
; extra byte: direction
; 00: down
; 01: up
; 02: right
; 03: left
thwomp_init:
	LDA !extra_byte_1,x
	AND #$03
	STA !extra_byte_1,x

	TAY
	LDA .what_blocks,y
	STA !thwomp_block_check,x

	LDA !sprite_x_low,x
	CLC
	ADC #$08
	STA !sprite_x_low,x

	STX $00
	JSR thwomp_ptr_setup_pos_only

	LDA (!thwomp_pos_lo_tbl_ptr)
	STA !thwomp_spawn_lo,x
	LDA (!thwomp_pos_hi_tbl_ptr)
	STA !thwomp_spawn_hi,x

	RTS
.what_blocks:
	db $04,$08,$01,$02
.done:
!bank1_bossfire_free = thwomp_init_done
warnpc !bank1_bossfire_end

org !bank1_koopakids_free

; TODO SA1
thwomp_ptr_setup:
	LDA !extra_byte_1,x
	TAY
	STX $00
	LDA .speed_lo_ptr,y
	CLC
	ADC $00
	STA !thwomp_speed_tbl_ptr
	STZ !thwomp_speed_tbl_ptr+1
	; opcode JMP
	LDA #$4C
	STA !thwomp_speed_upd_ptr
	LDA .speed_upd_ptr_lo,y
	STA !thwomp_speed_upd_ptr+1
	LDA .speed_upd_ptr_hi,y
	STA !thwomp_speed_upd_ptr+2

.pos_only:
	LDA .pos_lo_ptr,y
	CLC
	ADC $00
	STA !thwomp_pos_lo_tbl_ptr
	STZ !thwomp_pos_lo_tbl_ptr+1

	LDA .pos_hi_lo_ptr,y
	CLC
	ADC $00
	STA !thwomp_pos_hi_tbl_ptr
	LDA .pos_hi_hi_ptr,y
	ADC #$00
	STA !thwomp_pos_hi_tbl_ptr+1

	RTS
.speed_lo_ptr:
	db !sprite_speed_y,!sprite_speed_y,!sprite_speed_x,!sprite_speed_x
.pos_lo_ptr:
	db !sprite_y_low,!sprite_y_low,!sprite_x_low,!sprite_x_low
.pos_hi_lo_ptr:
	db !sprite_y_high,!sprite_y_high
	db !sprite_x_high,!sprite_x_high
.pos_hi_hi_ptr:
	db (!sprite_y_high>>8)&$FF,(!sprite_y_high>>8)&$FF
	db (!sprite_x_high>>8)&$FF,(!sprite_x_high>>8)&$FF
.speed_upd_ptr_lo
	db _spr_upd_y_no_grav
	db _spr_upd_y_no_grav
	db _spr_upd_x_no_grav
	db _spr_upd_x_no_grav
.speed_upd_ptr_hi
	db _spr_upd_y_no_grav>>8
	db _spr_upd_y_no_grav>>8
	db _spr_upd_x_no_grav>>8
	db _spr_upd_x_no_grav>>8
thwomp_main:
	JSR .gfx
	LDA !sprite_status,x
	EOR #$08
	ORA !sprites_locked
	BNE .phase_wait_ret
	JSR   thwomp_ptr_setup
	JSR.w _suboffscr0_bank1|!bank
	JSR.w _mario_spr_interact|!bank
	LDA !thwomp_phase,x
	BEQ .phase_wait
	CMP #$01
	BEQ .phase_falling
	BRA .phase_ground_rise
.phase_wait:
	LDA !sprite_off_screen_vert,x
	BNE ..offscreen_vert
	LDA !sprite_off_screen_horz,x
	BNE ..ret
	; TODO fix range wraparound bug
	JSR _sub_horz_pos_bank1
	STZ !thwomp_face_frame,x
	LDA $0F
	CLC
	ADC #$40
	CMP #$80
	BCS ..no_glare
	INC !thwomp_face_frame,x
..no_glare:
	LDA $0F
	CLC
	ADC #$24
	CMP #$50
	BCS ..ret
..offscreen_vert:
	LDA #$02
	STA !thwomp_face_frame,x
	INC !thwomp_phase,x
	LDA #$00
	STA (!thwomp_speed_tbl_ptr)
..ret:
	RTS
.phase_falling:
	JSR.w !thwomp_speed_upd_ptr
	LDA (!thwomp_speed_tbl_ptr)
	LDY !extra_byte_1,x
	CMP ..speed_max,y
	BEQ ..done_accel
	ADC ..accels,y
	STA (!thwomp_speed_tbl_ptr)
..done_accel:
	JSR.w _spr_obj_interact|!bank
	LDA !sprite_blocked_status,x
	;AND #$04
	AND !thwomp_block_check,x
	BEQ ..not_grounded_yet
	LDA.b #$18
	STA !screen_shake_timer
	LDA #!thwomp_hit_ground_sfx_id
	STA !thwomp_hit_ground_sfx_port
	LDA #$40
	STA !thwomp_hit_ground_wait,x
	INC !thwomp_phase,x
..not_grounded_yet
	RTS
; TODO check tables in x-dir for validity
..accels:
	db $04,~$04,$04,~$04
..speed_max:
	db $40,~$40,$40,~$40
	
.phase_ground_rise:
	LDA !thwomp_hit_ground_wait,x
	BNE ..ret
	STZ !thwomp_face_frame,x
	LDA (!thwomp_pos_lo_tbl_ptr)
	CMP !thwomp_spawn_lo,x
	BNE ..keep_rising
	LDA (!thwomp_pos_hi_tbl_ptr)
	CMP !thwomp_spawn_hi,x
	BNE ..keep_rising
	STZ !thwomp_phase,x
..ret:
	RTS
..keep_rising:
	LDY !extra_byte_1,x
	LDA ..rise_speed,y
	STA (!thwomp_speed_tbl_ptr)
	JMP.w !thwomp_speed_upd_ptr
..rise_speed:
	db $F0,$10,$F0,$10
.gfx:
	JSR.w _get_draw_info_bank1|!bank
	LDA !thwomp_face_frame,x
	STA $02
	LDX #$03
	CMP #$00
	BEQ ..draw_loop
	INX
..draw_loop:
	LDA $00
	CLC
	ADC ..x_disp,x
	STA $0300|!addr,y
	LDA $01
	CLC
	ADC ..y_disp,x
	STA $0301|!addr,y
	LDA ..props,x
	STA $0303|!addr,y
	LDA ..tiles,x
	CPX #$04
	BNE ..no_face_fix
	PHX
	LDX.b $02
	CPX.b #$02
	BNE +
	LDA.b #!thwomp_angry_face_tile
+
	PLX
..no_face_fix:
	STA $0302|!addr,y
	INY #4
	DEX
	BPL ..draw_loop
	LDX $15E9|!addr
	LDA.b #$04
	LDY.b #$02
	JMP _finish_oam_write
..x_disp:
	db $FC,$04,$FC,$04,$00
..y_disp:
	db $00,$00,$10,$10,$08
..tiles:
	db $00,$00,$02,$02,$04
..props:
	db $03,$43,$03,$43,$03
.done:
!bank1_koopakids_free = thwomp_main_done
warnpc !bank1_koopakids_end
