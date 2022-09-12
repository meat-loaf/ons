includeonce

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
!player_x_spd             = $7B
; backup of $77
!sspipes_blocked_backup  = $79
!status_bar_config       = $7C

!level_slippery          = $86
; 2 bytes.
!block_ypos              = $98
; 2 bytes.
!block_xpos              = $9A
!block_to_generate       = $9C
!sprites_locked          = $9D

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
!next_oam_index          = $0D9C|!addr

!hdma_channel_enable_mirror = $0D9F|!addr

!curr_player_lives          = $0DBE|!addr
!curr_player_coins          = $0DBF|!addr

; flags set at level load, then not changed (generally)
; check consts.asm defs
!level_status_flags_1   = $0DD9|!addr

!asstd_state_flags_1    = $0DDB|!addr

!status_bar_tilemap     = $0EF9|!addr

!timer_frame            = $0F30|!addr
!timer_hundreds         = $0F31|!addr
!timer_tens             = $0F32|!addr
!timer_ones             = $0F33|!addr

!player_score           = $0F34+$00|!addr
!player_score_mid       = $0F34+$01|!addr
!player_score_hi        = $0F34+$02|!addr

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

!midway_imem_dma_stage  = $147D|!addr

; 4 bytes
!wiggler_segment_slots  = $1487|!addr

!end_level_timer        = $1493|!addr
!player_ani_timer       = $1496|!addr
!player_invuln_timer    = $1497|!addr

!player_face_screen_timer   = $1499|!addr
!player_palette_cycle_timer = $149B|!addr

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

; repurposed: low nybble used as bitfield for object generation parameters
!sprite_memory_header    = $1692|!addr

!dyn_slot_ptr  = $0660|!addr
!dyn_slot_bank = $0662|!addr
!dyn_slot_dest = $0663|!addr
!dyn_slots     = $06FE|!addr

!on_platform_ix = $1864|!addr
; 1 byte
; Toggles the use of item memory.
; ------r- : Disable reading (everything will always respawn).
; -------w : Disable writing.
!item_memory_mask = $18BB|!addr

!give_player_lives = $18E4|!addr

!level_general_purpose_1 = $1923|!addr
!level_general_purpose_2 = !level_general_purpose_1+$01

!exit_table              = $19B8|!addr
!exit_table_new_lm       = $19D8|!addr

; XXX: in SA1 add |!addr define to these, but you cant do them all!
!spr_extra_bits         = $19F8                            ; 384 bytes free due to relocating item memory (up until $1B84)
!spr_new_sprite_num     = !spr_extra_bits+!num_sprites     ; $1A04
!spr_extra_byte_1       = !spr_new_sprite_num+!num_sprites ; $1A10
!spr_extra_byte_2       = !spr_extra_byte_1+!num_sprites   ; $1A1C
!spr_extra_byte_3       = !spr_extra_byte_2+!num_sprites   ; $1A28
!spr_extra_byte_4       = !spr_extra_byte_3+!num_sprites   ; $1A34
!spr_shoot_exbyte_1     = !spr_extra_byte_4+!num_sprites   ; $1A40 currently not setup?
!spr_shoot_exbyte_2     = !spr_shoot_exbyte_1+!num_sprites ; $1A4C currently not setup?
!spr_shoot_exbyte_3     = !spr_shoot_exbyte_2+!num_sprites ; $1A58 currently not setup?
!pixi_new_code_flag     = !spr_shoot_exbyte_3+!num_sprites ; $1A64
!spr_spriteset_off      = !pixi_new_code_flag+$1           ; $1A65 (12 bytes)
!cls_spriteset_off      = !spr_spriteset_off+$0C           ; $1A71 (20 bytes)
!ext_spriteset_off      = !cls_spriteset_off+$14           ; $1A85 (x bytes)

; alt name of above
!spr_shooter_extra_byte_1 = !spr_shoot_exbyte_1
!spr_shooter_extra_byte_2 = !spr_shoot_exbyte_2
!spr_shooter_extra_byte_3 = !spr_shoot_exbyte_3

!level_load_obj_tile     = $1BA1
!time_huns_bak           = $1DEF|!addr

!spc_io_1_sfx_1DF9       = $1DF9|!addr
!spc_io_2_sfx_1DFA       = $1DFA|!addr
!spc_io_3_music_1DFB     = $1DFB|!addr
!spc_io_4_sfx_1DFC       = $1DFC|!addr

!red_coin_sfx_port       ?= !spc_io_1_sfx_1DF9

!mario_gfx               = $7E2000

; sram stuff
; todo reorganize a bit. Original free sram starts at $70035A
!item_memory_mirror_s    = $701000
!wiggler_segment_buffer  = !item_memory_mirror_s+!item_memory_size

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

; Dynamic sprite graphics upload buffer
!dynamic_buffer = $7FA000         ; 0x800 bytes long
; 7FA800 - 7FABFF free

; unused here, i'm using -d255spl
;!spr_load_status          = $7FAF00
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
