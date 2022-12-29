incsrc "../asm/main.asm"

incsrc "include/config.def"
incsrc "include/512kfree.def"
incsrc "include/smw_routines.def"

incsrc "macros/macros.asm"
incsrc "util/jslshims.asm"
!spriteset_offset = !spr_spriteset_off

;incsrc "spritesets/finish_oam_write.asm"
;incsrc "spritesets/spriteset_config.asm"
incsrc "spritesets/spritesets.asm"

incsrc "list.def"


; fix the game not clearing the full sprite load status table
org $02ABF3|!bank
	db $7F

org $01808C|!bank
run_sprites:
	phb
	lda !player_carrying_item
	sta !carrying_flag
	stz !player_carrying_item
	stz !player_on_solid_platform
	stz !player_in_cloud
	lda !current_yoshi_slot
	sta !yoshi_is_loose
	stz !current_yoshi_slot
	stz !dyn_slots
	ldx #!num_sprites-1
.loop
	stx !current_sprite_process
	; todo: replace with ragey's oam alloc impl directly
	jsr $80D2
	jsl handle_sprite
	dex
	bpl .loop
	lda !current_yoshi_slot
	bne .on_yoshi
	stz !player_on_yoshi
	stz !screen_shake_player_yoff
.on_yoshi:
	plb
	rtl
warnpc $0180CB|!bank
assert read1($0180CA) == !RTL_OPCODE, "RTL used for JSL2RTS by Lunar Magic overwritten."

org $018127|!bank
handle_sprite:
	lda !sprite_status,x
	bne .cont
	dec
	sta !sprite_load_index,x
	rtl
.cont:
	phk
	plb
	asl
	tay
	lda .status_ptrs-2+1,y
	pha
	lda .status_ptrs-2+0,y
	pha
	rts

; todo split tables
.status_ptrs:
	; 1
	dw spr_handle_init-1
	; 2
	dw spr_killed-1
	; 3
	dw spr_smushed-1
	; 4
	dw spr_spinkill_shim-1
	; 5
	dw spr_lavadie-1
	; 6
	dw spr_levelend-1
	; 7 - unused
	dw !bank01_jsl2rts_rtl
	; 8
	dw spr_handle_main-1
	; todo - 9 through C
spr_handle_init:
	lda #$08
	sta !sprite_status,x
	lda !sprite_num,x
	tax
	lda.l sprite_init_table_bk,x
	pha
	pha
	plb
	lda.l sprite_init_table_hi,x
	pha
	lda.l sprite_init_table_lo,x
	pha
	ldx !current_sprite_process
	rtl

spr_handle_main:
	lda !sprite_num,x
	tax
	lda.l sprite_main_table_bk,x
	pha
	pha
	plb
	lda.l sprite_main_table_hi,x
	pha
	lda.l sprite_main_table_lo,x
	pha
	ldx !current_sprite_process
	rtl
warnpc $01830F|!bank

%write_sprite_tables()


print "freespace used: ", freespaceuse, " bytes."
print "modified ", bytes, " bytes."

