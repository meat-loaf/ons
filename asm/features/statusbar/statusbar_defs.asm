includefrom "status.asm"
includeonce

!status_prio_props = %00000011

!tile_noflip         = %00000000
!tile_yflip          = %00000010
!tile_xflip          = %00000001
!tile_yxflip         = !tile_yflip|!tile_xflip

!empty_coin_tile     = $1D
!x_tile              = $7F

!item_box_tile       = $60
!clock_tile          = $64
!pts_t1_tile         = $62
!pts_t2_tile         = !pts_t1_tile+$01
!zero_digit_tile     = $65
!one_digit_tile      = $66
!two_digit_tile      = $67
!three_digit_tile    = $68
!four_digit_tile     = $69
!five_digit_tile     = $75
!six_digit_tile      = $76
!seven_digit_tile    = $77
!eight_digit_tile    = $78
!nine_digit_tile     = $79
!a_digit_tile        = $20
!b_digit_tile        = $21
!c_digit_tile        = $22
!d_digit_tile        = $30
!e_digit_tile        = $31
!f_digit_tile        = $32
!blank_digit_tile    = $71
!coin_tile           = $72
!m_t1_tile           = $73
!m_t2_tile           = !m_t1_tile+$01
!rcoin_tile          = $4A

!do_skip             = $1
!empty_coin_tile_ix  = 16
!blank_digit_ix      = 17
!coin_tile_ix        = 18

!use_propram         = $1

!item_box_tl_xpos    = $70
!item_box_tl_ypos    = $07
!item_box_tr_xpos    = !item_box_tl_xpos+$10
!item_box_tr_ypos    = !item_box_tl_ypos
!item_box_bl_xpos    = !item_box_tl_xpos
!item_box_bl_ypos    = !item_box_tl_ypos+$10
!item_box_br_xpos    = !item_box_tl_xpos+$10
!item_box_br_ypos    = !item_box_tl_ypos+$10

!timer_ypos          = !item_box_tl_ypos+$08
!timer_clock_xpos    = $B8
!timer_clock_ypos    = !timer_ypos
!timer_100s_xpos     = !timer_clock_xpos+$08
!timer_100s_ypos     = !timer_ypos
!timer_tens_xpos     = !timer_100s_xpos+$08
!timer_tens_ypos     = !timer_ypos
!timer_ones_xpos     = !timer_tens_xpos+$08
!timer_ones_ypos     = !timer_ypos

!ccoin_xpos_base     = $3C
!ccoin_ypos_base     = !item_box_tl_ypos+$08
!ccoin_1_x           = !ccoin_xpos_base
!ccoin_2_x           = !ccoin_1_x+$08
!ccoin_3_x           = !ccoin_2_x+$08
!ccoin_4_x           = !ccoin_3_x+$08
!ccoin_5_x           = !ccoin_4_x+$08

!lives_xpos          = $10
!lives_ypos          = !item_box_tl_ypos+$08

!lives_xpos_1        = !lives_xpos
!lives_xpos_2        = !lives_xpos_1+$08
!lives_xpos_3        = !lives_xpos_2+$08
!lives_xpos_4        = !lives_xpos_3+$08

!coins_xpos          = !lives_xpos+$2
!coins_ypos          = !item_box_tl_ypos+$10

!coins_xpos_1        = !coins_xpos+$02
!coins_xpos_2        = !coins_xpos_1+$04
!coins_xpos_3        = !coins_xpos_2+$08
!coins_xpos_4        = !coins_xpos_3+$08

!rcoins_ypos         = !ccoin_ypos_base+$08
!rcoins_xpos         = !ccoin_xpos_base

!rcoins_xpos_1       = !rcoins_xpos+$0C
!rcoins_xpos_2       = !rcoins_xpos_1+$08


!score_ypos          = !item_box_tl_ypos+$10

!score_mils_xpos     = $A0
!score_mils_ypos     = !score_ypos
!score_hunthous_xpos = !score_mils_xpos+$08
!score_hunthous_ypos = !score_ypos
!score_10thous_xpos  = !score_hunthous_xpos+$08
!score_10thous_ypos  = !score_ypos
!score_thous_xpos    = !score_10thous_xpos+$08
!score_thous_ypos    = !score_ypos
!score_100s_xpos     = !score_thous_xpos+$08
!score_100s_ypos     = !score_ypos
!score_tens_xpos     = !score_100s_xpos+$08
!score_tens_ypos     = !score_ypos
!score_ones_xpos     = !score_tens_xpos+$08
!score_ones_ypos     = !score_ypos
!score_pts_t1_xpos   = !score_ones_xpos+$08
!score_pts_t1_ypos   = !score_ypos
!score_pts_t2_xpos   = !score_pts_t1_xpos+$08
!score_pts_t2_ypos   = !score_ypos
