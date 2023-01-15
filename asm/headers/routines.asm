includeonce
kill_mario                      = $00F606|!bank
generate_tile                   = $00BEB0|!bank
; lunar magic provided routine
extract_exgfx                   = $0FF900|!bank

finish_oam_write                = $01B7B3|!bank

sub_spr_gfx_2_long              = $0190B2|!bank
sub_spr_gfx_2_long_no_push_bank = $0190B3|!bank

oam_reset                       = $7F8000

init_sprite_tables              = $07F7D2|!bank
nuke_sprite_tables              = $07F722|!bank

spawn_ambient_bounce_sprite     = $028792|!bank

if getfilestatus("routines/item_memory_rts.asm") == 0
  incsrc "routines/item_memory_rts.asm"
endif
if getfilestatus("routines/sprite_rts.asm") == 0
  incsrc "routines/sprite_rts.asm"
endif
