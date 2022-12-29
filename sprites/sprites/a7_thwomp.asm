includefrom "list.def"

%alloc_sprite($A7, thwomp_init, thwomp_main, 0, $01, $06, $33, $01, $01, $24)

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
; extra byte: direction
; 00: down
; 01: up
; 02: right
; 03: left
%set_free_start("bank1_koopakids")
thwomp_init:
	lda !extra_byte_1,x
	and #$03
	sta !extra_byte_1,x

	tay
	lda .what_blocks,y
	sta !thwomp_block_check,x

	lda !sprite_x_low,x
	clc
	adc #$08
	sta !sprite_x_low,x

	stx $00
	jsr thwomp_ptr_setup_pos_only

	lda (!thwomp_pos_lo_tbl_ptr)
	sta !thwomp_spawn_lo,x
	lda (!thwomp_pos_hi_tbl_ptr)
	sta !thwomp_spawn_hi,x

	rtl
.what_blocks:
	db $04,$08,$01,$02

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
	jsr .gfx
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne .phase_wait_ret
	jsr   thwomp_ptr_setup
	jsr.w _suboffscr0_bank1|!bank
	jsr.w _mario_spr_interact|!bank
	lda !thwomp_phase,x
	beq .phase_wait
	cmp #$01
	beq .phase_falling
	bra .phase_ground_rise
.phase_wait:
	lda !sprite_off_screen_vert,x
	bne ..offscreen_vert
	lda !sprite_off_screen_horz,x
	bne ..ret
	; TODO fix range wraparound bug
	jsr _sub_horz_pos_bank1
	stz !thwomp_face_frame,x
	lda $0F
	clc
	adc #$40
	cmp #$80
	bcs ..no_glare
	inc !thwomp_face_frame,x
..no_glare:
	lda $0F
	clc
	adc #$24
	cmp #$50
	bcs ..ret
..offscreen_vert:
	lda #$02
	sta !thwomp_face_frame,x
	inc !thwomp_phase,x
	lda #$00
	sta (!thwomp_speed_tbl_ptr)
..ret:
	rtl
.phase_falling:
	jsr.w !thwomp_speed_upd_ptr
	lda (!thwomp_speed_tbl_ptr)
	ldy !extra_byte_1,x
	cmp ..speed_max,y
	beq ..done_accel
	adc ..accels,y
	sta (!thwomp_speed_tbl_ptr)
..done_accel:
	jsr.w _spr_obj_interact|!bank
	lda !sprite_blocked_status,x
	;anD #$04
	and !thwomp_block_check,x
	beq ..not_grounded_yet
	lda.b #$18
	sta !screen_shake_timer
	lda #!thwomp_hit_ground_sfx_id
	sta !thwomp_hit_ground_sfx_port
	lda #$40
	sta !thwomp_hit_ground_wait,x
	inc !thwomp_phase,x
..not_grounded_yet
	rtl
; TODO check tables in x-dir for validity
..accels:
	db $04,~$04,$04,~$04
..speed_max:
	db $40,~$40,$40,~$40
	
.phase_ground_rise:
	lda !thwomp_hit_ground_wait,x
	bne ..ret
	stz !thwomp_face_frame,x
	lda (!thwomp_pos_lo_tbl_ptr)
	cmp !thwomp_spawn_lo,x
	bne ..keep_rising
	lda (!thwomp_pos_hi_tbl_ptr)
	cmp !thwomp_spawn_hi,x
	bne ..keep_rising
	stz !thwomp_phase,x
..ret:
	rtl
..keep_rising:
	ldy !extra_byte_1,x
	lda ..rise_speed,y
	sta (!thwomp_speed_tbl_ptr)
	jsr.w !thwomp_speed_upd_ptr
	rtl
..rise_speed:
	db $F0,$10,$F0,$10
.gfx:
	jsr.w _get_draw_info_bank1|!bank
	lda !thwomp_face_frame,x
	sta $02
	ldx #$03
	cmp #$00
	beq ..draw_loop
	inx
..draw_loop:
	lda $00
	clc
	adc ..x_disp,x
	sta $0300|!addr,y
	lda $01
	clc
	adc ..y_disp,x
	sta $0301|!addr,y
	lda ..props,x
	sta $0303|!addr,y
	lda ..tiles,x
	cpx #$04
	bne ..no_face_fix
	phx
	ldx.b $02
	cpx.b #$02
	bne +
	lda.b #!thwomp_angry_face_tile
+
	plx
..no_face_fix:
	sta $0302|!addr,y
	iny #4
	dex
	bpl ..draw_loop
	ldx $15E9|!addr
	lda.b #$04
	ldy.b #$02
	jmp _finish_oam_write
..x_disp:
	db $FC,$04,$FC,$04,$00
..y_disp:
	db $00,$00,$10,$10,$08
..tiles:
	db $00,$00,$02,$02,$04
..props:
	db $03,$43,$03,$43,$03
.done:
%set_free_finish("bank1_koopakids", thwomp_main_done)
