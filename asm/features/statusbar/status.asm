incsrc "../../main.asm"
incsrc "statusbar_defs.asm"

!star_tile      = $EF
!star_props     = $34

!cpu_meter      = 1

function pack_props(flip, priority, palette, page) = (flip)|(priority|((palette&$07)<<1)|(page&$01))

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

macro draw_static_tile(x_pos,y_pos,tile,tileflip,palette,page,size)
	LDA.B #<x_pos>
	STA.W $0200|!addr,y
	LDA.B #<y_pos>
	STA.W $0201|!addr,y
	LDA.B #<tile>
	STA $0202|!addr,y
	LDA.B #pack_props(<tileflip>,!status_prio_props,<palette>,<page>)
	STA $0203|!addr,y
	LDY.W .oam_tiles_small,x
	LDA.B #<size>
	STA.W $0420|!addr,y
endmacro

macro draw_digit_tile(x_pos,y_pos,source_addr,addr_width,tileflip,palette,page,size)
	LDA.B #<x_pos>
	STA.W $0200|!addr,y
	LDA.B #<y_pos>
	STA.W $0201|!addr,y
	LDY.<addr_width> <source_addr>
	LDA.W .number_tilenums,y
	LDY.W .oam_tiles,x
	STA.W $0202|!addr,y
	LDA.B #pack_props(<tileflip>,!status_prio_props,<palette>,<page>)
	STA $0203|!addr,y
	LDY.W .oam_tiles_small,x
	LDA.B #<size>
	STA.w $0420|!addr,y
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
	%draw_digit_tile(!timer_100s_xpos,!timer_100s_ypos,$0F25|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!timer_tens_xpos,!timer_tens_ypos,$0F26|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!timer_ones_xpos,!timer_ones_ypos,$0F27|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	<return>
endmacro

macro draw_score(return)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_mils_xpos,!score_mils_ypos,$0F29|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_hunthous_xpos,!score_hunthous_ypos,$0F2A|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_10thous_xpos,!score_10thous_ypos,$0F2B|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_thous_xpos,!score_thous_ypos,$0F2C|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_100s_xpos,!score_100s_ypos,$0F2D|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!score_tens_xpos,!score_tens_ypos,$0F2E|!ramlo|!addr,W,\
			!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!score_ones_xpos,!score_ones_ypos,!zero_digit_tile,\
		!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!score_pts_t1_xpos,!score_pts_t1_ypos,!pts_t1_tile,\
		!tile_noflip,$00,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!score_pts_t2_xpos,!score_pts_t2_ypos,!pts_t2_tile,\
		!tile_noflip,$00,$00,$00)
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
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_static_tile(!coins_xpos_2,!coins_ypos,!x_tile,\
		!tile_noflip,$08,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!coins_xpos_3,!coins_ypos,$0F13|!ramlo|!addr,W,\
			!tile_noflip,$08,$00,$00)
	%get_next_oam_tile(status_bar_oam_tiles, no_oam_left)
	%draw_digit_tile(!coins_xpos_4,!coins_ypos,$0F14|!ramlo|!addr,W,\
			!tile_noflip,$0C,$00,$00)
	<return>
endmacro

org $00A2E6
	autoclean JSL status_bar

; skip layer 3 scroll fuckery
org $00A5A8
       BRA $01 : NOP

org $008EE6
	db $11 ; replace the index to the 'empty' character used for score (for mario)

org $008F14
	db $11 ; replace the index to the 'empty' character used for score (for luigi)

org $008E8B
	db $00 ; replace the index to the 'empty' character used for time (use leading zeros)

org $008F54
	db $11 ; replace the index to the 'empty' character used for lives

org $008F7D
	db $11 ; replace the index to the 'empty' character used for coins

; draw all 5 coins
org $008FD8
	LDA.w $1420|!addr
	BRA +
	NOP #4
+
; blank yoshi coin tile
org $008FE7
	db $10
; collected yoshi coin tile
org $008FED
	db $12
org $008FF6
	db $05

freecode
; abort
no_oam_left:
	PLA            ; \ clean the stack
	PLA            ; /
	PLB            ; get stored bank byte
exit:
	RTL            ; return to main code (stop drawing)

status_bar:
	JSL $028AB1|!bank ; restore original code (do this first to make sure all oam alloc is done here)
	LDA $0100
	CMP #$0A+$01
	BCC exit
.continue:
	PHB
	PHK
	PLB

	LDA !status_bar_config
	ASL
	TAX
	JMP (.configurations,x)
.configurations:
	dw .standard_config
	dw .ibox_only
.standard_config:
	LDX.B #$3D        ; skip the first 3 OAM slots so yoshi's tongue isnt above some tiles and below others
	JSR .item_box
	JSR .timer
	JSR .coins
	JSR .lives
	JSR .star_coins
	JSR .score

	JSR .cpu_meter
	PLB
	RTL
.ibox_only
	LDX.B #$3D        ; skip the first 3 OAM slots so yoshi's tongue isnt above some tiles and below others
	JSR .item_box
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

	STZ $045B
	RTS

.number_tilenums:
	db !zero_digit_tile,!one_digit_tile,!two_digit_tile,!three_digit_tile
	db !four_digit_tile,!five_digit_tile,!six_digit_tile,!seven_digit_tile
	db !eight_digit_tile,!nine_digit_tile,!a_digit_tile,!b_digit_tile
	db !c_digit_tile,!d_digit_tile,!e_digit_tile,!f_digit_tile
	db !empty_coin_tile,!blank_digit_tile,!coin_tile
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
print "status bar patch uses ", freespaceuse, " bytes"
