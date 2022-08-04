includeonce
generate_tile = $00BEB0|!bank
; lunar magic provided routine
extract_exgfx = $0FF900|!bank

finish_oam_write = $01B7B3|!bank

if getfilestatus("routines/item_memory_rts.asm") == 0
  incsrc "routines/item_memory_rts.asm"
endif
