includeonce

; not actually ram...
!ambient_tblsz     = !num_ambient_sprs+!num_ambient_sprs

!lag_flag          = $10
!irq_kind          = $11
!stripe_image_ix   = $12  ; should be divisible by 3
!true_frame        = $13
!effective_frame   = $14
!byetudlr_hold     = $15
!byetudlr_frame    = $16
!axlr0000_hold     = $17
!axlr0000_frame    = $18
!powerup           = $19

; 2 bytes
!layer_1_xpos_curr = $1A
; 2 bytes
!layer_1_ypos_curr = $1C
; 2 bytes
!layer_2_xpos_curr = $1E
; 2 bytes
!layer_2_ypos_curr = $20
; 2 bytes
!layer_3_xpos_curr = $22
; 2 bytes
!layer_3_ypos_curr = $24
; 2 bytes
!layer_2_3_xrel_pos = $26
; 2 bytes
!layer_2_3_yrel_pos = $28
; 2 bytes
!mode_7_center_x    = $2A
; 2 bytes
!mode_7_center_y    = $2C
; 2 bytes
!mode_7_matrix_param_a = $2E
; 2 bytes
!mode_7_matrix_param_b = $30
; 2 bytes
!mode_7_matrix_param_c = $32
; 2 bytes
!mode_7_matrix_param_d = $34

!BGMODE_2105_mirror         = $3E
!OAMADDL_2103_mirror        = $3F
!CGADSUB_2131_mirror        = $40
!W12SEL_2123_mirror         = $41
!W34SEL_2124_mirror         = $42
!WOBJSEL_2125_mirror        = $43
!CGSWSEL_2130_mirror        = $44

; this is actually part of ram used by the camera
; scrolling code, but is fine to use as temporary
; scratch
!sprset_tbl_scr    = $52


!object_load_pos   = $57      ; \ note: free outside object code. good scratch ram
!object_dimensions = $59      ; | > High nybble is height, low is width. Sometimes one of these nybbles will be used as an arg instead
!object_load_num   = $5A      ; /
!tile_off_scratch  = $5A      ; used in sprites only
; CD----Vv
; C - Toggle collision with Layer 2 (0: no, 1: yes)
; D = Toggle collision with Layer 1 (0: yes, 1: no)
; V - Vertical layer 2
; v - vertical layer 1
!screen_mode       = $5B
!current_spriteset = $5C
!num_screens       = $5D
!screens_stop_horz = $5E
!screens_stop_vert = $5F      ; free if not using vertical levels

; direction of screen scrolling pipe
; Bit format: PPPPDDDD
; DDDD bits (The stem and pipe cap directions):
;  #$00 = out of pipe (normal mode).
;  #$01-#$04 = travel up, right, down and left (in that order) for stem sections.
;  #$05-#$08 = same as above, but for cap speeds.
;
; PPPP bits (the planned direction for "special turning corners"):
;  #$00 = Keep going straight, don't change direction.
;  #$01-#$04 = travel up, right, down and left (in that order).
!sspipes_dir = $60

; sspipe timer for enter/exit animations
!sspipes_timer = $61

; Used to determine if mario is entering/exiting a pipe.
;  #$00 - outside pipe
;  #$01 - entering pipe
;  #$02 - exiting pipe
!sspipes_enter_exit_flag = $62

; flag set if you carried a sprite through a pipe
; TODO move this to the asstd_lvl_flags_1 bitmask
!sspipes_carry_spr        = $63

!sprite_level_props       = $64
; 3 bytes
!layer_1_bank_byte_ptr    = $65
; 3 bytes
!layer_2_bank_byte_ptr    = $68
; 3 bytes - free in levels after gm11
!map16_data_lo            = $6B
; 3 bytes - free in levels after gm11
!map16_data_hi            = $6E
!player_ani_trigger_state = $71
!player_dir               = $76
!player_x_spd_spx         = $7A
!player_x_spd             = $7B
!player_y_spd_spx         = $7C
!player_y_speed           = $7D
; 2 bytes
!player_x_scr_rel         = $7E
; 2 bytes
!player_y_scr_rel         = $80

; backup of $77
!sspipes_blocked_backup  = $79
!status_bar_config       = $7C

!level_slippery          = $86

; 2 bytes.
!player_x_next           = $94
; 2 bytes.
!player_y_next           = $96
; 2 bytes.
!block_ypos              = $98
; 2 bytes.
!block_xpos              = $9A
!block_to_generate       = $9C
!sprites_locked          = $9D
!level_sprite_data_ptr   = $CE
!wiggler_segment_ptr     = $D5

!gamemode                = $0100|!addr

!savefile_num            = $010A|!addr
!level_number            = $010B|!addr

!oam_mirror_xpos_lo      = $0200|!addr
!oam_mirror_ypos_lo      = $0201|!addr
!oam_mirror_tile_lo      = $0202|!addr
!oam_mirror_prop_lo      = $0203|!addr

!oam_mirror_xpos_lo      = $0300|!addr
!oam_mirror_ypos_lo      = $0301|!addr
!oam_mirror_tile_lo      = $0302|!addr
!oam_mirror_prop_lo      = $0303|!addr

!oam_tilesize_lo         = $0420|!addr
!oam_tilesize_lo         = $0460|!addr

!on_off_cooldown         = $0AF5|!addr

; 2 bytes; lm exlevel impl-defined
!scr_min_y_off_sprspawn  = $0BF0|!addr
; 2 bytes; lm exlevel impl-defined
!scr_max_y_off_sprspawn  = $0BF2|!addr

!hdma_channel_enable_mirror = $0D9F|!addr
!asstd_state_flags_1        = $0DA1|!addr

!curr_player_lives          = $0DBE|!addr
!curr_player_coins          = $0DBF|!addr

; flags set at level load, then not changed (generally)
; check consts.asm defs
!level_status_flags_1   = $0DD9|!addr

; from sp4
!level_header_sgfx1_lo  = $0DC3|!addr
; from sp2
!level_header_sgfx2_lo  = $0DC4|!addr
; from sp1
!level_header_sgfx3_lo  = $0DC5|!addr
; $ODC6 gets written with the high byte of sp1 graphics
; file due to 16 bit write. it is free after this, however

!status_bar_tilemap     = $0EF9|!addr

!timer_frame            = $0F30|!addr
!timer_hundreds         = $0F31|!addr
!timer_tens             = $0F32|!addr
!timer_ones             = $0F33|!addr

!player_score           = $0F34+$00|!addr
!player_score_mid       = $0F34+$01|!addr
!player_score_hi        = $0F34+$02|!addr

!ambient_gen_timer      = $0F4A|!addr

!main_level_num         = $13BF|!addr

!moon_counter           = $13C5|!addr
!coin_adder             = $13CC|!addr
!midway_flag            = $13CE|!addr
!ow_run_event_flag      = $13CE|!addr
; value to use when slippery blocks can be slippery
!mario_slip             = $140A|!addr
!mario_on_ground        = $13EF|!addr

!flight_phase           = $1407|!addr

!horz_scroll_setting    = $1411|!addr
!vert_scroll_setting    = $1412|!addr

!level_state_flags_curr = $1415|!addr      ; current live set
!level_state_flags_midp = $1416|!addr      ; midpoint backup set

!exit_counter           = $141A|!addr

!yoshi_coins_collected  = $1420|!addr

!red_coin_total         = $1473|!addr

!red_coin_adder         = $1475|!addr

!carrying_flag          = $1470|!addr

!midway_imem_dma_stage  = $147D|!addr

; 4 bytes
!wiggler_segment_slots  = $1487|!addr
; 2 bytes
!rng_calc               = $148B|!addr
; 2 bytes
!random_number_output   = $148D|!addr
!player_carrying_item   = $148F|!addr
!invincibility_timer    = $1490|!addr
!sprite_x_movement      = $1491|!addr
; for end of level
!player_peace_timer     = $1492|!addr
!end_level_timer        = $1493|!addr
!player_ani_timer       = $1496|!addr
!player_invuln_timer    = $1497|!addr

!player_face_screen_timer   = $1499|!addr
!player_palette_cycle_timer = $149B|!addr

!blue_pswitch_timer     = $14AD|!addr
!silver_pswitch_timer   = $14AE|!addr
!on_off_state           = $14AF|!addr

!item_memory_setting    = $13BE|!addr

!pause_timer = $13D3|!addr
!game_paused = $13D4|!addr

; 2 bytes
; Screen size as defined by ExLevel specification.
!exlvl_screen_size = $13D7|!addr

; used as the timer in the 'waterfall drop' blocks.
!waterfall_drop_timer = $13E6|!addr

; timer to set the `waterfall_drop_timer' above to 0.
; set by the waterfall block, turned into a proper timer with GM14 uberasm.
!waterfall_reset_drop_timer = $13E7|!addr

; A byte reserved for use in per-level asm
!levelasm_scratch_byte = $140B|!addr

; 2 bytes
!layer_1_xpos_next = $1462|!addr
; 2 bytes
!layer_1_ypos_next = $1464|!addr
; 2 bytes
!layer_2_xpos_next = $1466|!addr
; 2 bytes
!layer_2_ypos_next = $1468|!addr

; $01 - everything not listed below (uses players next frame for position)
; $02 - Springboards/pea bouncers (next frame)
; $03 - spinning brown platforms, grey falling platforms (current frame)
!player_on_solid_platform = $1471|!addr

; Settings for level constrain block interaction.
; Format: ----TBLR (Top, Bottom, Left, Right)
!level_constrain_flags  = $15E8|!addr

!current_sprite_process = $15E9|!addr

!sprite_stomp_counter    = $1697|!addr
; repurposed: low nybble used as bitfield for object generation parameters
!sprite_memory_header    = $1692|!addr

!ambient_rt_ptr    = $1699|!addr
!ambient_x_pos     = !ambient_rt_ptr+!ambient_tblsz
!ambient_y_pos     = !ambient_x_pos+!ambient_tblsz

; high byte: decimal low byte: frac
!ambient_x_speed   = !ambient_y_pos+!ambient_tblsz
; high byte: decimal low byte: frac
!ambient_y_speed   = !ambient_x_speed+!ambient_tblsz

assert !ambient_y_speed+(!num_ambient_sprs*2) <= $185C, "ambient sprite ram exceeded bounds"

!dyn_slot_ptr  = $0660|!addr
!dyn_slot_bank = $0662|!addr
!dyn_slot_dest = $0663|!addr
!dyn_slots     = $06FE|!addr

!spr_touch_tile_low = $185F|!bank
!on_platform_ix     = $1864|!addr

!powerup_ix_slot_overwrite = $1861|!addr
; two bytes: ambient sprites access in 16-bit mode
!next_oam_index     = $1869|!addr

!player_on_yoshi    = $187A|!addr
!screen_shake_timer = $1887|!addr
!screen_shake_player_yoff = $188B|!addr
; 1 byte
; Toggles the use of item memory.
; ------r- : Disable reading (everything will always respawn).
; -------w : Disable writing.
!item_memory_mask    = $18BB|!addr
!player_in_cloud     = $18C2|!addr
!starkill_counter    = $18D2|!addr
!spr_touch_tile_high = $18D7|!addr
!current_yoshi_slot  = $18DF|!addr
!yoshi_is_loose      = $18E2|!addr
!give_player_lives   = $18E4|!addr

!sprite_buoyancy         = $190E|!addr
!level_general_purpose_1 = $1923|!addr
!level_general_purpose_2 = !level_general_purpose_1+$01
; 2 bytes
!current_ambient_process = $1926|!addr

!exit_table              = $19B8|!addr
!exit_table_new_lm       = $19D8|!addr

; XXX: in SA1 add |!addr define to these, but you cant do them all!
!spr_extra_bits           = $19F8                                ; 384 bytes free due to relocating item memory (up until $1B84)
!spr_extra_byte_1         = !spr_extra_bits+!num_sprites         ; $1A04
!spr_extra_byte_2         = !spr_extra_byte_1+!num_sprites       ; $1A10
!spr_extra_byte_3         = !spr_extra_byte_1+!num_sprites       ; $1A1C
!spr_extra_byte_4         = !spr_extra_byte_2+!num_sprites       ; $1A28
!spr_spriteset_off        = !spr_extra_byte_3+!num_sprites       ; $1A34
!ambient_twk_tilesz       = !spr_spriteset_off+!num_sprites      ; $1A40
!ambient_grav_setting     = !ambient_twk_tilesz+!ambient_tblsz   ; $1A90
; two bytes! used as a mirror of $9D to not cause trouble loading
; in 16 bit mode
!ambient_sprlocked_mirror = !ambient_grav_setting+!ambient_tblsz ; $1A90
; alt name of above

; TODO implement - needs to be set to (!ambient_spr_sz*2)-2 on level load
!ambient_spr_ring_ix     = $1B97|!addr

!level_load_obj_tile     = $1BA1|!addr
!time_huns_bak           = $1DEF|!addr

!spc_io_1_sfx_1DF9       = $1DF9|!addr
!spc_io_2_sfx_1DFA       = $1DFA|!addr
!spc_io_3_music_1DFB     = $1DFB|!addr
!spc_io_4_sfx_1DFC       = $1DFC|!addr

!ambient_props           = $1E02|!addr
!ambient_misc_1          = !ambient_props+!ambient_tblsz

assert !ambient_misc_1+(!num_ambient_sprs*2) <= $1EA2, "ambient sprite ram exceeded bounds"

!red_coin_sfx_port       ?= !spc_io_1_sfx_1DF9

; sprite tables
!sprite_num               = $9E
!sprite_speed_y           = $AA
!sprite_speed_x           = $B6
!sprite_misc_c2           = $C2
!sprite_y_low             = $D8
!sprite_x_low             = $E4
!sprite_status            = $14C8
!sprite_y_high            = $14D4
!sprite_x_high            = $14E0
!sprite_speed_y_frac      = $14EC
!sprite_speed_x_frac      = $14F8
!sprite_misc_1504         = $1504
!sprite_misc_1510         = $1510
!sprite_misc_151c         = $151C
!sprite_misc_1528         = $1528
!sprite_misc_1534         = $1534
!sprite_misc_1540         = $1540
!sprite_misc_154c         = $154C
!sprite_misc_1558         = $1558
!sprite_misc_1564         = $1564
!sprite_misc_1570         = $1570
!sprite_misc_157c         = $157C
!sprite_blocked_status    = $1588
!sprite_misc_1594         = $1594
!sprite_off_screen_horz   = $15A0
!sprite_misc_15ac         = $15AC
!sprite_slope             = $15B8
!sprite_off_screen        = $15C4
!sprite_being_eaten       = $15D0
!sprite_obj_interact      = $15DC
!sprite_oam_index         = $15EA
!sprite_oam_properties    = $15F6
!sprite_misc_1602         = $1602
!sprite_misc_160e         = $160E
!sprite_load_index        = $161A
!sprite_misc_1626         = $1626
!sprite_behind_scenery    = $1632
!sprite_misc_163e         = $163E
!sprite_in_water          = $164A
!sprite_tweaker_1656      = $1656
!sprite_tweaker_1662      = $1662
!sprite_tweaker_166e      = $166E
!sprite_tweaker_167a      = $167A
!sprite_tweaker_1686      = $1686
!sprite_off_screen_vert   = $186C
!sprite_misc_187b         = $187B
!sprite_tweaker_190f      = $190F

!sprite_load_table        = $1938

!sprite_misc_1fd6         = $1FD6
!sprite_cape_disable_time = $1FE2



!mario_gfx               = $7E2000

; sram stuff
; todo reorganize a bit. Original free sram starts at $70035A
!item_memory_mirror_s    = $701000
!wiggler_segment_buffer_srm = !item_memory_mirror_s+!item_memory_size
!big_hdma_decomp_buff_rg = !wiggler_segment_buffer_srm+$200
!big_hdma_decomp_buff_b   = !big_hdma_decomp_buff_rg+$1000

; 7168 bytes
; Item memory, divided in four blocks of 1792 bytes per block.
!item_memory        = $7F0000
!rcoin_count_bak    = !item_memory+$1C00
!scoin_count_bak    = !rcoin_count_bak+$01
!on_off_state_bak   = !scoin_count_bak+$01
!got_moon_bak       = !on_off_state_bak+$01
; 3 bytes
!score_bak          = !got_moon_bak+$01
!player_power_bak   = !score_bak+$03

; 7F2000-7F3FFF free
; todo put mfg's scrollable hdma gradient buffer here
; todo how big does it need to be?


; currently unused, pasue menu setup was removed
; !pause_menu_oam_ypos_buf      = $7FA000                      ; 0x80 bytes
; !pause_menu_l3_xpos_orig      = !pause_menu_oam_ypos_buf+$80 ; 0x02 bytes
; !pause_menu_l3_ypos_orig      = !pause_menu_l3_xpos_orig+$02 ; 0x02 bytes
; !pause_menu_tilemap_orig      = !pause_menu_l3_ypos_orig+$02 ; 0x02 bytes


!wiggler_segment_buffer = $7F9A7B
; Dynamic sprite graphics upload buffer
!dynamic_buffer = !wiggler_segment_buffer+$200
; 7FA800 - 7FABFF free

; todo remove these, deprecated
; 7FB000 - 7FB408 free
!bounce_blocks_map16_low  = $7FB408
!bounce_blocks_map16_hi   = !bounce_blocks_map16_low+$4
!spr_extra_byte_5         = !bounce_blocks_map16_hi+$4
!spr_extra_byte_6         = !spr_extra_byte_5+!num_sprites
!spr_extra_byte_7         = !spr_extra_byte_6+!num_sprites
!spr_extra_byte_8         = !spr_extra_byte_7+!num_sprites
!spr_extra_byte_9         = !spr_extra_byte_8+!num_sprites
!spr_extra_byte_10        = !spr_extra_byte_9+!num_sprites
!spr_extra_byte_11        = !spr_extra_byte_10+!num_sprites
!spr_extra_byte_12        = !spr_extra_byte_11+!num_sprites
!spr_extra_prop_1         = !spr_extra_byte_12+!num_sprites
!spr_extra_prop_2         = !spr_extra_prop_1+!num_sprites

; ram defs ;
!Freeram_SSP_PipeDir    ?= !sspipes_dir
!Freeram_SSP_PipeTmr    ?= !sspipes_timer
!Freeram_SSP_EntrExtFlg ?= !sspipes_enter_exit_flag
!Freeram_SSP_CarrySpr   ?= !sspipes_carry_spr
!Freeram_BlockedStatBkp ?= !sspipes_blocked_backup
; ram defs done ;



!hw_dma_enable = $420B
