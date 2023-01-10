incsrc "../../main.asm"
incsrc "statusbar_defs.asm"

; skip the first 3 OAM slots so yoshi's tongue isnt above some tiles and below others
!oam_tbl_start_index  = $3D

macro get_next_oam_tile(oam_tiles_tbl, abort_func)
?loop:
	DEX
	BPL ?cont
	JMP.w <abort_func>
?cont:
	LDY <oam_tiles_tbl>,x
	LDA $0201|!addr,y
	CMP #$F0
	BNE ?loop
endmacro

macro draw_static_tile_propram(x_pos,y_pos,tile,tileflip,palette,page,size,use_propram,propram,propram_w)
	LDA.b #<x_pos>
	STA.w $0200|!addr,y
	LDA.b #<y_pos>
	STA.w $0201|!addr,y
	LDA.b #<tile>
	STA.w $0202|!addr,y
	LDA.b #pack_props(<tileflip>,!status_prio_props,<palette>,<page>)
	if <use_propram> != 0
	  ORA.<propram_w> <propram>
	endif
	STA $0203|!addr,y
	LDY.w .oam_tiles_small,x
	LDA.b #<size>
	STA.w $0420|!addr,y
endmacro

macro draw_static_tile(x_pos,y_pos,tile,tileflip,palette,page,size)
	%draw_static_tile_propram(<x_pos>,<y_pos>,<tile>,<tileflip>,<palette>,<page>,<size>,$00,$00,L)
endmacro

macro draw_digit_tile_sk_prop(x_pos,y_pos,source_addr,addr_width,tileflip,palette,page,size,do_skip,ix_skip,branch_skip,use_propram,propram,propram_w)
	LDY.<addr_width> <source_addr>
	if <do_skip> != 0
	  if <ix_skip> != 0
	    CPY #<ix_skip>
	  endif
	  BNE.b ?cont
	  LDY.w .oam_tiles,x
	  ; BRA is often out of range. This isn't empirically slower.
	  JMP.w <branch_skip>
	endif
?cont
	LDA.w .number_tilenums,y
	LDY.w .oam_tiles,x
	STA.w $0202|!addr,y
	LDA.b #<x_pos>
	STA.w $0200|!addr,y
	LDA.b #<y_pos>
	STA.w $0201|!addr,y
	LDA.b #pack_props(<tileflip>,!status_prio_props,<palette>,<page>)
	if <use_propram> != 0
	  ORA.<propram_w> <propram>
	endif
	STA $0203|!addr,y
	LDY.w .oam_tiles_small,x
	LDA.b #<size>
	STA.w $0420|!addr,y
endmacro

macro draw_digit_tile_sk(x_pos,y_pos,source_addr,addr_width,tileflip,palette,page,size,do_skip,ix_skip,branch_skip)
	%draw_digit_tile_sk_prop(<x_pos>,<y_pos>,<source_addr>,<addr_width>,<tileflip>,<palette>,<page>,<size>,<do_skip>,<ix_skip>,<branch_skip>,$00,$00,L)
endmacro

macro draw_digit_tile_propram(x_pos,y_pos,source_addr,addr_width,tileflip,palette,page,size,use_propram,propram,propram_w)
	%draw_digit_tile_sk_prop(<x_pos>,<y_pos>,<source_addr>,<addr_width>,<tileflip>,<palette>,<page>,<size>,$00,$00,L,<use_propram>,<propram>,<propram_w>)
endmacro

macro draw_digit_tile(x_pos,y_pos,source_addr,addr_width,tileflip,palette,page,size)
	%draw_digit_tile_sk_prop(<x_pos>,<y_pos>,<source_addr>,<addr_width>,<tileflip>,<palette>,<page>,<size>,$00,$00,L,$00,$00,L)
endmacro

macro draw_item_box(return)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(\
		!item_box_tl_xpos,!item_box_tl_ypos,!item_box_tile,\
		!tile_noflip,$0B,$00,$02)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(\
		!item_box_tr_xpos,!item_box_tr_ypos,!item_box_tile,\
		!tile_xflip,$0B,$00,$02)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(\
		!item_box_bl_xpos,!item_box_bl_ypos,!item_box_tile,\
		!tile_yflip,$0B,$00,$02)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(\
		!item_box_br_xpos,!item_box_br_ypos,!item_box_tile,\
		!tile_yxflip,$0B,$00,$02)
	<return>
endmacro

macro draw_timer(return)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!timer_clock_xpos,!timer_clock_ypos,!clock_tile,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!timer_100s_xpos,!timer_100s_ypos,!timer_hundreds|!ramlo,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!timer_tens_xpos,!timer_tens_ypos,!timer_tens|!ramlo,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!timer_ones_xpos,!timer_ones_ypos,!timer_ones|!ramlo,W,\
			!tile_noflip,$00,$00,$00)
	<return>
endmacro

macro draw_score(return)
?sc:
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!score_pts_t1_xpos,!score_pts_t1_ypos,!pts_t1_tile,\
		!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!score_pts_t2_xpos,!score_pts_t2_ypos,!pts_t2_tile,\
		!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!score_ones_xpos,!score_ones_ypos,!zero_digit_tile,\
		!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_tens_xpos,!score_tens_ypos,$0F2E|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_100s_xpos,!score_100s_ypos,$0F2D|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_thous_xpos,!score_thous_ypos,$0F2C|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile_sk(!score_10thous_xpos,!score_10thous_ypos,$0F2B|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00,!do_skip,!blank_digit_ix,.skip)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile_sk(!score_hunthous_xpos,!score_hunthous_ypos,$0F2A|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00,!do_skip,!blank_digit_ix,.skip)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile_sk(!score_mils_xpos,!score_mils_ypos,$0F29|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00, !do_skip,!blank_digit_ix,.skip)
.skip:
	<return>
endmacro

macro draw_starcoins(return)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!ccoin_1_x,!ccoin_ypos_base,$0EFF|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!ccoin_2_x,!ccoin_ypos_base,$0F00|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!ccoin_3_x,!ccoin_ypos_base,$0F01|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!ccoin_4_x,!ccoin_ypos_base,$0F02|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!ccoin_5_x,!ccoin_ypos_base,$0F03|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)

	; also draw the moon tile because fuck it
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!moon_xpos,!moon_ypos,!status_bar_tilemap+$03|!ramlo,W,\
			!tile_noflip,$00,$00,$00)

	<return>
endmacro

macro draw_lives(return)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!lives_xpos_1,!lives_ypos,!m_t1_tile,\
			!tile_noflip,$0C,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!lives_xpos_2,!lives_ypos,!m_t2_tile,\
			!tile_noflip,$0C,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!lives_xpos_3,!lives_ypos,$0F16|!ramlo|!addr,W,\
			!tile_noflip,$0C,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!lives_xpos_4,!lives_ypos,$0F17|!ramlo|!addr,W,\
			!tile_noflip,$0C,$00,$00)
	<return>
endmacro

macro draw_coins(return)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!coins_xpos_1,!coins_ypos,!coin_tile,\
		!tile_noflip,$08,$00,$00)
;	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
;	%draw_static_tile(!coins_xpos_2,!coins_ypos,!x_tile,\
;		!tile_noflip,$08,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!coins_xpos_3,!coins_ypos,$0F13|!ramlo|!addr,W,\
			!tile_noflip,$08,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!coins_xpos_4,!coins_ypos,$0F14|!ramlo|!addr,W,\
			!tile_noflip,$0C,$00,$00)
	<return>
endmacro

macro draw_red_coins(return)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!rcoins_xpos, !rcoins_ypos,!rcoin_tile,
		!tile_noflip,$0C,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!rcoins_xpos_1,!rcoins_ypos,$0EFA|!ramlo|!addr,W,\
			!tile_noflip,$08,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!rcoins_xpos_2,!rcoins_ypos,$0EFB|!ramlo|!addr,W,\
			!tile_noflip,$08,$00,$00)
	<return>
endmacro

org $00A2E6
	autoclean JSL status_bar

; skip layer 3 scroll fuckery
org $00A5A8
       BRA $01 : NOP

freecode
; abort
no_oam_left:
	PLA            ; \ clean the stack
	PLA            ; /
	PLB            ; get stored bank byte
.exit:
	RTL            ; return to main code (stop drawing)

status_bar:
	JSL $028AB1|!bank ; restore original code (do this first to make sure all oam alloc is done here)
	LDA $0100
	CMP #$0B
	BEQ .continue
	CMP #$0A+$01
	BCC no_oam_left_exit
.continue:
	PHB
	PHK
	PLB

if !use_midway_imem_sram_dma == !true
; ----   midway point dma stuff    ----
	LDA.w !midway_imem_dma_stage
	BEQ.b .midway_done
	DEC
	STA   !midway_imem_dma_stage
	ASL
	TAY
	REP.b #$10
	LDA.b #!item_memory>>16
	STA.w $2183
	LDX.w .midway_stages_imem_from,y
	STX.w $2181
	LDA.b #(!item_memory_mirror_s>>16)
	STA.w $4304
	LDX.w .midway_stages_imem_to,y
	STX.w $4302
	LDX.w #(!item_memory_size/!item_memory_dma_frames)
	STX.w $4305

	LDA.b #$2180
	STA.w $4301

	LDA.b #%10000000
	STA.w $4300
	LDA.b #$01
	STA.w !hw_dma_enable
	SEP.b #$10
.midway_done:
; ---- midway point dma stuff done ----
endif
	LDA !status_bar_config
	ASL
	TAX
	JMP (.configurations,x)
.configurations:
	dw .standard_config
	dw .ibox_only

if !use_midway_imem_sram_dma == !true
.midway_stages_imem_from:
	%gen_dma_stage_table(!item_memory,!item_memory_size,!item_memory_dma_frames)
.midway_stages_imem_to:
	%gen_dma_stage_table(!item_memory_mirror_s,!item_memory_size,!item_memory_dma_frames)
endif
.standard_config:
	LDX.b #!oam_tbl_start_index
	JSR.w .timer
	JSR.w .item_box
	JSR.w .coins
	;JSR.w .rcoins
	JSR.w .lives
	;JSR.w .star_coins
	;JSR.w .score

if !enable_debug_cpu_meter == !true
	JSR.w .cpu_meter
	jsr.w .ambient_inf
endif
	PLB
	RTL
.ibox_only
	LDX.b #!oam_tbl_start_index
	JSR.w .item_box
	PLB
	RTL

.item_box:
	%draw_item_box(RTS)
.timer:
	%draw_timer(RTS)
.score:
	%draw_score(RTS)
.star_coins:
	%draw_starcoins(RTS)
.lives:
	%draw_lives(RTS)
.coins:
	%draw_coins(RTS)
.rcoins:
	%draw_red_coins(RTS)


if !enable_debug_cpu_meter == !true

!star_tile      = $EF
!star_props     = $34

.cpu_meter:
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	LDA $2137       ;   Prepare H/V-count data
	LDA $213D       ;   Get V-count data
	STA $0201,y
	LDA #!star_tile
	STA $0202,y
	LDA #!star_props
	STA $0203,y
	LDA #$00
	STA $0200,y

	LDY.W .oam_tiles_small,x
	STA.w $0420|!addr,y

	STZ $045B
	RTS
endif

.ambient_inf:
	phx
	rep #$30
	stz $00
	ldx.w #(!num_ambient_sprs*2)-2
.loop
	lda !ambient_rt_ptr,x
	beq .cont
	sep #$20
	lda $00
	inc
	cmp #$0a
	bcc .lostore
	inc $01
	lda #$00
.lostore:
	sta $00
	rep #$20
.cont:
	dex : dex
	bpl .loop
	sep #$30
	plx

	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile($08,$d0,$01,B,\
			!tile_noflip,$00,$00,$00)

	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile($10,$d0,$00,B,\
			!tile_noflip,$00,$00,$00)

	rts

.number_tilenums:
	db !zero_digit_tile,!one_digit_tile,!two_digit_tile,!three_digit_tile
	db !four_digit_tile,!five_digit_tile,!six_digit_tile,!seven_digit_tile
	db !eight_digit_tile,!nine_digit_tile,!a_digit_tile,!b_digit_tile
	db !c_digit_tile,!d_digit_tile,!e_digit_tile,!f_digit_tile
	db !empty_coin_tile,!blank_digit_tile,!coin_tile,!moon_tile_empty
	db !moon_tile_full
.oam_tiles:
	db $FC,$F8,$F4,$F0
	db $EC,$E8,$E4,$E0
	db $DC,$D8,$D4,$D0
	db $CC,$C8,$C4,$C0
	db $BC,$B8,$B4,$B0
	db $AC,$A8,$A4,$A0
	db $9C,$98,$94,$90
	db $8C,$88,$84,$80
	db $7C,$78,$74,$70
	db $6C,$68,$64,$60
	db $5C,$58,$54,$50
	db $4C,$48,$44,$40
	db $3C,$38,$34,$30
	db $2C,$28,$24,$20
	db $1C,$18,$14,$10
	db $0C,$08,$04,$00
.oam_tiles_small:
	db $3F,$3E,$3D,$3C
	db $3B,$3A,$39,$38
	db $37,$36,$35,$34
	db $33,$32,$31,$30
	db $2F,$2E,$2D,$2C
	db $2B,$2A,$29,$28
	db $27,$26,$25,$24
	db $23,$22,$21,$20
	db $1F,$1E,$1D,$1C
	db $1B,$1A,$19,$18
	db $17,$16,$15,$14
	db $13,$12,$11,$10
	db $0F,$0E,$0D,$0C
	db $0B,$0A,$09,$08
	db $07,$06,$05,$04
	db $03,$02,$01,$00

incsrc "disable_irq.asm"
incsrc "sbar_tilemap_rewrite.asm"
print "status bar patch uses ", freespaceuse, " bytes"
