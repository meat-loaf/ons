includefrom "list.def"

%alloc_sprite($00, shelless_koopa_init, shelless_koopa_main, 2, 0, $70, $00, $0A, $00, $00, $00)
%alloc_sprite($01, shelless_koopa_init, shelless_koopa_main, 2, 0, $70, $00, $08, $00, $00, $00)
%alloc_sprite($02, shelless_koopa_init, shelless_koopa_main, 2, 0, $70, $00, $06, $00, $00, $00)
%alloc_sprite($03, shelless_koopa_init, shelless_koopa_main, 2, 0, $70, $00, $04, $00, $00, $00)

; todo: change kicking animation frame index, to save a slot
; note: stunned frames are (eventually) not going to be used
%alloc_sprite_sharedgfx_entry_5($00,$CE,$CC,$CC,$FF,$80)
%alloc_sprite_sharedgfx_entry_mirror($01, $00)
%alloc_sprite_sharedgfx_entry_mirror($02, $00)
%alloc_sprite_sharedgfx_entry_mirror($03, $00)

%set_free_start("bank6")
shelless_koopa_init:
	%jsl2rts(!bank01_jsl2rts_rtl, $018575|!bank)
shelless_koopa_main:
	lda #$01
	pha
	plb
	%jsl2rts(!bank01_jsl2rts_rtl, $018904|!bank)
.done:
%set_free_finish("bank6", shelless_koopa_main_done)
