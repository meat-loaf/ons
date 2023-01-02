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
;	jsr allocate_oam_dec_timers
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
;org $0180D2|!bank
;allocate_oam_dec_timers:
;	lda !sprite_status,x
;	beq .done
;	lda !next_oam_index
;	sta !sprite_oam_index,x
;	lda !sprite_num,x
;	cmp #$35
;	bne .cont
;.yoshi:
;	ldy #$3C
;	lda $13F9|!addr
;	beq +
;	ldy #$1C
;+	tya
;	sta !sprite_oam_index,x
;	bra .handle_timers
;.cont:
;	lda !sprite_num,x
;	tax
;	lda !next_oam_index
;	tay
;	clc
;	adc.l oam_tile_count,x
;	sta !next_oam_index
;	ldx !current_sprite_process
;.handle_timers
;	lda !sprites_locked
;	bne .done
;	%implement_timer("!sprite_misc_1540,x")
;	%implement_timer("!sprite_misc_154c,x")
;	%implement_timer("!sprite_misc_1558,x")
;	%implement_timer("!sprite_misc_1564,x")
;	%implement_timer("!sprite_cape_disable_time,x")
;	%implement_timer("!sprite_misc_15ac,x")
;	%implement_timer("!sprite_misc_163e,x")
;.done:
;	rts
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
	dw spr_killed_shim-1
	; 3
	dw spr_smushed_shim-1
	; 4
	dw spr_spinkill_shim-1
	; 5
	dw spr_lavadie_shim-1
	; 6
	dw spr_levelend-1
	; 7 - unused: TODO yoshi tongue state?
	dw !bank01_jsl2rts_rtl-1
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

org $00A1DA|!bank
oam_refresh_hijack:
	jml oam_refresh|!bank
	nop
;.done:
oam_refresh_hijack_done  = $00A1DF|!bank
oam_refresh_hijack_done2 = $00A1E4|!bank

%set_free_start("bank6")
oam_refresh:
	lda $1426|!addr
	beq +
	jml oam_refresh_hijack_done
+	ldy #$44
	lda $13F9|!addr
	beq +
	ldy #$24
+	sty !next_oam_index
	jml oam_refresh_hijack_done2
oam_tile_count:
	db $08,$08,$08,$08,$0C,$0C,$0C,$0C ; 00-07
	db $0C,$0C,$0C,$0C,$0C,$0C,$08,$04 ; 08-0F
	db $0C,$0C,$04,$04,$10,$04,$04,$00 ; 10-17
	db $04,$00,$08,$04,$04,$04,$08,$00 ; 18-1F
	db $04,$08,$08,$08,$08,$08,$14,$10 ; 20-27
	db $50,$04,$08,$08,$04,$04,$04,$10 ; 28-2F
	db $0C,$04,$0C,$10,$04,$00,$00,$04 ; 30-37
	db $04,$04,$14,$14,$14,$04,$08,$08 ; 38-3F
	db $08,$0C,$0C,$08,$08,$08,$14,$04 ; 40-47
	db $04,$08,$04,$08,$04,$04,$04,$0C ; 48-4F
	db $0C,$04,$10,$24,$00,$14,$14,$14 ; 50-57
	db $14,$14,$14,$0C,$14,$14,$24,$28 ; 58-5F
	db $08,$04,$0C,$14,$24,$0C,$0C,$10 ; 60-67
	db $04,$00,$04,$14,$14,$00,$10,$14 ; 68-6F
	db $14,$0C,$0C,$0C,$04,$04,$04,$04 ; 70-77
	db $04,$04,$D8,$0C,$00,$04,$0C,$0C ; 78-7F
	db $04,$04,$00,$0C,$0C,$00,$18,$00 ; 80-87
	db $00,$00,$04,$08,$04,$28,$00,$10 ; 88-8F
	db $40,$14,$14,$14,$14,$14,$14,$14 ; 90-97
	db $14,$0C,$10,$10,$10,$14,$18,$40 ; 98-9F
	db $00,$40,$14,$18,$10,$04,$14,$14 ; A0-A7
	db $14,$18,$0C,$08,$14,$14,$28,$04 ; A8-AF
	db $04,$04,$04,$08,$10,$00,$04,$0C ; B0-B7
	db $0C,$10,$10,$10,$10,$10,$04,$10 ; B8-BF
	db $14,$14,$04,$10,$10,$50,$04,$00 ; C0-C7
	db $04,$00,$00,$00,$00,$00,$00,$00 ; C8-CF
	db $00,$00,$00,$00,$00,$00,$00,$00 ; D0-D7
	db $00,$00,$0C,$0C,$0C,$0C,$00,$0C ; D8-DF
	db $00,$00,$40,$40,$00,$00,$00,$00 ; E0-E7
	db $00,$00,$00,$00,$00,$00,$00,$00 ; E8-EF
	db $00,$00,$00,$00,$00,$00,$00,$00 ; F0-F7
	db $00,$00,$00,$00,$00,$00,$00,$00 ; F8-FF
oam_alloc_free_done:
%set_free_finish("bank6", oam_alloc_free_done)
