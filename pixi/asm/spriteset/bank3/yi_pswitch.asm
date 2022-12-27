includefrom "remaps.asm"

!yi_pswitch_sprnum = $BD

%alloc_spr(!yi_pswitch_sprnum, yi_pswitch_init, bank3_sprcaller, \
	$11, $89, $39, $A3, $19, $44)

!pswitch_squish_state = !151C
!pswitch_squish_index = !1528
!pswitch_current_slot = !1602
!pswitch_launch_speed = $50

pushpc
org !bank1_koopakids_free
yi_pswitch_init:
	lda !sprite_x_low,x
	clc
	adc #$08
	sta !sprite_x_low,x
	lda !sprite_x_high,x
	adc #$00
	sta !sprite_x_high,x
	rts
.done:
warnpc !bank1_koopakids_end
!bank1_koopakids_free = yi_pswitch_init_done
pullpc

yi_pswitch_main:
	ldy !pswitch_squish_index,x
	lda .dyn_frames,y
	sta !spr_dyn_alloc_slot_arg_frame_num
	stz !spr_dyn_alloc_slot_arg_gfx_id
	jsr spr_dyn_gfx_rt
	
	lda $9D
	ora !sprite_being_eaten,x
	bne .ret1
	jsr.w _suboffscr0_bank1
	lda !pswitch_squish_state,x
	bne .squish
;	beq .not_squished
.not_squished:
	jsl $01802A|!bank
	jsl $01A7DC|!bank
	bcc .ret1
	; load pos off (low)
	lda $0E
	cmp #$F0
	; branch if too low
	bpl .check_sides

	; abort if too far on the right
	lda $0F
	cmp #$02
	bmi .ret1
	; abort if too far to the left
	cmp #$1C
	bpl .ret1
	; abort if Mario has upwards y-speed
	lda $7D
	bmi .ret1

	lda #$01
	sta !player_on_solid_platform

	; ???
	;lda #$06
	;sta !154C,x
	
	ldy !player_on_yoshi
	lda .squish_displacement,y
	clc
	adc !sprite_y_low,x
	sta $96

	lda !sprite_y_high,x
	adc #$FF
	sta $97

	inc !pswitch_squish_state,x
.ret1
	rts
.check_sides:
;	jsr.w _sub_horz_pos_bank1
	jsr .sub_horz_pos
;	tya
	beq ..right
..left:
	lda $0E
	cmp #$f3
	bmi .ret1
	bit $7B
	bmi .ret1
	stz $7B
	rts
..right:
	bit $7B
	bpl .ret1
	stz $7B
	rts

.squish:
	lda !pswitch_squish_index,x
	asl
	tay
	rep #$20
	lda .ymario,y
	clc
	adc $96
	sta $96
	sep #$20

	stz $7D
	stz $7B
	inc !pswitch_squish_index,x
	lda !pswitch_squish_index,x
;	cmp.b #(yi_pswitch_gfx_frames_end-yi_pswitch_gfx_frames)
	cmp.b #(.dyn_frames_end-.dyn_frames)
	bne .squish_more
	; rocket lawnchair
	lda #(~!pswitch_launch_speed)+1
	sta $7D

	lda #$0B
	sta $1DF9|!addr
	; ground
	lda #$20
	sta !screen_shake_timer
	; set blue pow timer
	lda #$B0
	sta $14AD|!addr
	; todo smoke/stars
.visuals:
	lda !sprite_y_low,x
	clc
	adc #$0C
	sta !sprite_y_low,x
	lda !sprite_y_high,x
	adc #$00
	sta !sprite_y_high,x

	lda !sprite_x_low,x
	adc #$02
	sta !sprite_x_low,x
	lda !sprite_x_high,x
	adc #$00
	sta !sprite_x_high,x
	jsl $07FC3B|!bank

	stz $01
	lda #$FC
	sta $00
	lda #$10
	sta $02
	lda #$01
	jsl spr_spawn_smoke
	bcs .nosmoke

	lda #$0C
	sta $00
	lda #$01
	jsl spr_spawn_smoke
.nosmoke:

	; respawn on reload
	lda.b #$00
	ldy.w !161A,x
	sta.w !1938,y
	sta.w !sprite_status,x

	rts

.squish_more:
	cmp #$10
	bne .exit
	lda !sprite_oam_properties,x
	; mask palette
	and #$F1
	; yellow palette now
	ora #$04
	; new palette
	sta !sprite_oam_properties,x
.exit:
	rts
.dyn_frames:
	db $00,$02,$03,$04
	db $05,$06,$07,$08
	db $09,$0A,$0B,$0C
	db $0D,$0E,$0F,$0F
	db $0F,$0F,$0D,$0B
	db $09,$05,$02,$00
..end:

.ymario:
	dw $0000,$0000,$0000,$0001
	dw $0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0001
	dw $0001,$0001,$0000,$0000
	dw $0000,$FFFF,$FFFE,$FFFE
	dw $FFFD,$FFFD,$FFFC,$FFFC
; indexed by 'player on yoshi' flag (187A), which can be $02 if yoshi is turning
.squish_displacement:
	db $EE,$DE,$DE
.sub_horz_pos:
	ldy #$00
	lda $94
	sec
	sbc !E4,x
	sta $0E
	lda $95
	sbc !14E0,x
	sta $0F
	bpl .left
	iny
.left:
	rts
.done:

