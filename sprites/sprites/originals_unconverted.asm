includefrom "list.def"

%alloc_sprite($00, shelless_koopa_init, shelless_koopa_main, 0, $70, $00, $0A, $00, $00, $00)
%alloc_sprite($01, shelless_koopa_init, shelless_koopa_main, 0, $70, $00, $08, $00, $00, $00)
%alloc_sprite($02, shelless_koopa_init, shelless_koopa_main, 0, $70, $00, $06, $00, $00, $00)
%alloc_sprite($03, shelless_koopa_init, shelless_koopa_main, 0, $70, $00, $04, $00, $00, $00)

%set_free_start("bank6")
shelless_koopa_init:
	pea !bank01_jsl2rts_rtl
	jml $018575|!bank
shelless_koopa_main:
	lda #$01
	pha
	plb
	pea !bank01_jsl2rts_rtl
	jml $018904|!bank
.done:
%set_free_finish("bank6", shelless_koopa_main_done)
