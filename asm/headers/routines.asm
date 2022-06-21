includeonce
; lunar magic provided routine
extract_exgfx = $0FF900|!bank

if getfilestatus("routines/item_memory_rts.asm") == 0
  incsrc "routines/item_memory_rts.asm"
endif
