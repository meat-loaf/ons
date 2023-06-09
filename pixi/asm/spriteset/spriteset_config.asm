includefrom "spritesets.asm"

; dump some debug info
!debug = 0

; hijack Lunar Magic's graphics upload to do the spriteset upload handling
; there, instead. As with all lunar magic hijacks, this can break between
; lunar magic versions if FuSoYa decides to change this code for any reason.
; If this hijack proves troublesome, disable this and use the provided
; uberasm gm13 hijack instead.
!hijack_lm_code           = 1

; defines for a handful of remaps for things originally on sp1/2
; moving some of them can reduce sp1/2 pressure for something like
; a sprite status bar, if desired.

!remap_koopa               = 0
; remaps growing vine and jumpin' piranha plant
!remap_jumpin_pplant_vine  = 1

; put the flapping part of the jumpin' piranha plant on SP0/SP1.
; Turns out the SMB3 sideways piranhas/venuses fit nicely in 1 file
; and there's no room for the jumpin' piranha plant's tail, so this
; define installs a small hack to keep it on page 0.
!jumpin_pirana_stem_sp0_1  = 1

; put the goal sphere on low part of sprite tiles
!goal_sphere_on_sp0_sp1    = 0

!yoshi_egg_on_sp0_sp1      = 1
!yoshi_fireball_on_sp0_sp1 = 1

; alternate behavior for sprite A5 (originally, the game
; used the sprite tilemap setting)
!wall_fuzzy_alt_behav     = 1
; if pixi is installed, use the extra bit of sprite A5
; to determine which to act like. if disabled, use the
; sprite tilemap setting as typical. note that they share
; the same tile index now, though
; unset acts like the fuzzy, set acts like the hothead
!wall_fuzzy_alt_exbit     = 1


; todo| probably won't
!remap_powerups           = 0
; todo| more likely, but maybe not
!remap_berry              = 0

!remap_goomba             = 1
!remap_message_box        = 1

; todo
!remap_coingame_stuffs    = 1

; the rotating brown platform is a funny sprite, and has some
; slightly special handling...its a lot easier to put this here.
!brown_plat_ball_tile_num = $2E

; with these settings enabled, the relevant sprite type
; will inherit the tile offset from the normal sprite that is
; spawning it, avoiding the table lookup completely. This is
; typically not an issue, and is much more performant.
!extended_sprites_inherit_parent = 1
!minorextended_sprites_inherit_parent = 1
!cluster_sprites_inherit_parent = 1

; if any of these are enabled, the spriteset tables will be generated
; despite the setting above. These can be used to load the offset for
; custom extended sprites. Note that they are expected to be called from 'normal'
; sprite code: the normal sprite slot is in X (which is loaded from $15E9 at the end)
; and the relevant sprite type slot in Y.
!use_extended_spriteset_table = 0
!use_cluster_spriteset_table = 0
!use_minorextended_spriteset_table = 0

!extram_bank = $7F0000

!pixi_installed = 0
;; pixi detection ;;
if read4($02FFE2) == $44535453          ; "STSD" in little-endian
	!pixi_installed = 1
endif

;; ------- freeram ------- ;;
; note: Put the sprite tables on wram mirrors if you can.
; note: The patch will generate more efficient code.

; Standard Sprite table (12 bytes on non-SA1, 20 bytes on SA1) used to hold sprite offset.
!spriteset_offset = !spr_spriteset_off
; Extended Sprite table (10 bytes)
!ext_spriteset_offset = !ext_spriteset_off
; Cluster Sprite table (20 bytes)
!cls_spriteset_offset = !cls_spriteset_off
; Minor extended sprite table (12 bytes)
!mex_spriteset_offset = $9D30|!extram_bank

; ram used to hold the current spriteset. Change as needed.
;!current_spriteset        = $5C
;; ----- end freeram ----- ;;

; This needs to be on direct page, it's best not to change it.
; defined in main.asm
;!tile_off_scratch         = 

!brown_plat_props_scratch = $45

; check if spriteset offset table can use y-indexing and stz
if bank(!spriteset_offset) == bank(!extram_bank)
	!spriteset_off_on_wram_mirror = 0
else
	!spriteset_off_on_wram_mirror = 1
endif

if bank(!ext_spriteset_offset) == bank(!extram_bank)
	!ext_off_on_wram_mirror = 0
else
	!ext_off_on_wram_mirror = 1
endif

if bank(!cls_spriteset_offset) == bank(!extram_bank)
	!cls_off_on_wram_mirror = 0
else
	!cls_off_on_wram_mirror = 1
endif

if bank(!mex_spriteset_offset) == bank(!extram_bank)
	!mex_off_on_wram_mirror = 0
else
	!mex_off_on_wram_mirror = 1
endif

!sprite_rt_fin_ret = RTS
!sprite_rt_fin_jmp = JMP

; LONG
generate_block       = $00BEB0|!bank
mario_spr_interact_l = $01A7DC|!bank
update_sprite_pos    = $01802A|!bank
spr_spr_interact     = $018032|!bank

; LOCAL
_spr_face_mario_rt   = $01857C|!bank
_spr_set_ani_frame   = $018E5F|!bank
_sprspr_mario_spr_rt = $018FC1|!bank
_spr_upd_pos         = $019032|!bank
_spr_obj_interact    = $019140|!bank
_get_draw_info_bank1 = $01A365|!bank
_mario_spr_interact  = $01A7E4|!bank
_spr_upd_x_no_grav   = $01ABCC|!bank
_spr_upd_y_no_grav   = $01ABD8|!bank
_sub_horz_pos_bank1  = $01AD30|!bank
_suboffscr0_bank1    = $01AC31|!bank
_suboffscr1_bank1    = $01AC2B|!bank
_suboffscr2_bank1    = $01AC27|!bank
_suboffscr3_bank1    = $01AC21|!bank
_spr_invis_solid_rt  = $01B457|!bank

_get_draw_info_bank3 = $03B760|!bank
_suboffscr0_bank3    = $03B85D|!bank
_suboffscr3_bank3    = $03B84F|!bank
_sub_vert_pos_bank3  = $03B829|!bank

spr_tweaker_1656_tbl = $07F26C|!bank
spr_tweaker_1662_tbl = $07F335|!bank
spr_tweaker_166E_tbl = $07F3FE|!bank
spr_tweaker_167A_tbl = $07F4C7|!bank
spr_tweaker_1686_tbl = $07F590|!bank
spr_tweaker_190F_tbl = $07F659|!bank

_spr_inits_start     = $01817D|!bank
_spr_mains_start     = $0185CC|!bank
