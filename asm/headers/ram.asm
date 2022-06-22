includeonce

!true_frame        = $13
!effective_frame   = $14
!byetudlr_hold     = $15
!byetudlr_frame    = $16

; 2 bytes
!layer_1_xpos_curr = $1A
; 2 bytes
!layer_1_ypos_curr = $1C
; 2 bytes
!layer_2_xpos_curr = $1E
; 2 bytes
!layer_2_ypos_curr = $20



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

!on_off_cooldown     = $0AF5|!addr
!next_oam_index      = $0D9C|!addr

!hdma_channel_enable_mirror = $0D9F|!addr

!curr_player_lives = $0DBE
; flags set at level load, then not changed (generally)
; check consts.asm defs
!level_status_flags_1   = $0DD9|!addr

!asstd_state_flags_1    = $0DDB|!addr

; value to use when slippery blocks can be slippery
!mario_slip             = $0DDC|!addr

!mario_on_ground        = $13EF|!addr

!flight_phase           = $1407|!addr

!horz_scroll_setting    = $1411|!addr
!vert_scroll_setting    = $1412|!addr

!yoshi_coins_collected  = $1420|!addr

!boo_tile_offset        = $1473|!addr

; 4 bytes
!wiggler_segment_slots  = $1487|!addr

!player_ani_timer       = $1496|!addr
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

!dyn_slot_dest = $1864|!addr
; 2 bytes
!dyn_slot_ptr  = $1869|!addr
!dyn_slots     = $1879|!addr
!dyn_slot_bank = $188A|!addr

; 1 byte
; Toggles the use of item memory.
; ------r- : Disable reading (everything will always respawn).
; -------w : Disable writing.
!item_memory_mask = $18BB|!addr



!level_general_purpose_1 = $1923|!addr
!level_general_purpose_2 = !level_general_purpose_1+$01

; XXX: in SA1 add |!addr define to these
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
!cls_spriteset_off      = !spr_spriteset_off+$12           ; $1A71 (20 bytes)

; alt name of above
!spr_shooter_extra_byte_1 = !spr_shoot_exbyte_1
!spr_shooter_extra_byte_2 = !spr_shoot_exbyte_2
!spr_shooter_extra_byte_3 = !spr_shoot_exbyte_3

!level_load_obj_tile   = $1BA1

!spc_io_1_sfx_1          = $1DF9|!addr
!spc_io_2_sfx_2          = $1DFA|!addr
!spc_io_3_music          = $1DFB|!addr
!spc_io_4_sfx_3          = $1DFC|!addr

; 7168 bytes
; Item memory, divided in four blocks of 1792 bytes per block.
!item_memory = $7F0000 ; last byte at 7F1BFF. free due to ow event restore
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
!dynamic_bounce_buffer = $7FA800  ; 0x80 bytes long
; 7FA880 - 7FABFF free

; 7FAC11 - 7FEFF free
!spr_load_status          = $7FAF00
; 7FB000 - 7FB408 free
!star_coins_ram           = $7FB408                           ; $7FB408: 0xC8 bytes long; ends at $7FB4CF
!bounce_blocks_map16_low  = !star_coins_ram+$C8               ; $7FB4D0: 0x4 bytes
!bounce_blocks_map16_hi   = !bounce_blocks_map16_low+$4       ; $7FB4D4: 0x4 bytes
!midway_points_ram        = !bounce_blocks_map16_hi+$4        ; $7FB4D8: 0x60 byes
!spr_extra_byte_5         = !midway_points_ram+$60            ; $7FB538: 0x12 bytes
!spr_extra_byte_6         = !spr_extra_byte_5+!num_sprites    ; $7FB54A: 0x12 bytes
!spr_extra_byte_7         = !spr_extra_byte_6+!num_sprites    ; $7FB55C: 0x12 bytes
!spr_extra_byte_8         = !spr_extra_byte_7+!num_sprites    ; $7FB56E: 0x12 bytes
!spr_extra_byte_9         = !spr_extra_byte_8+!num_sprites    ; $7FB580: 0x12 bytes
!spr_extra_byte_10        = !spr_extra_byte_9+!num_sprites    ; $7FB592: 0x12 bytes
!spr_extra_byte_11        = !spr_extra_byte_10+!num_sprites   ; $7FB5A4: 0x12 bytes
!spr_extra_byte_12        = !spr_extra_byte_11+!num_sprites   ; $7FB5B6: 0x12 bytes
!spr_extra_prop_1         = !spr_extra_byte_12+!num_sprites   ; $7FB5C8: 0x12 bytes
!spr_extra_prop_2         = !spr_extra_prop_1+!num_sprites    ; $7FB5DA: 0x12 bytes
