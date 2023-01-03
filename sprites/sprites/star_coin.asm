!starcoin_sprnum = $B9

%alloc_sprite_dynamic_512k(!starcoin_sprnum, starcoin_init_exit, starcoin_main, 4, 1,\
	$8E, $0E, $75, $9B, $B9, $46, "starcoin", "bank7")

!starcoin_collect_sfx = $1A
!starcoin_collect_port = $1DFC|!addr

!starcoin_ani_timer = !1570
!starcoin_slot      = !1602

%set_free_start("bank3_sprites")
starcoin_init:
	; todo make shared routine
;	%sprite_init_do_pos_offset(!extra_byte_1,x)
.exit:
	rtl

starcoin_main:
	%dynamic_gfx_rt_bank3("lda !starcoin_ani_timer,x : lsr #3 : and #$03", "starcoin")

	lda !sprites_locked
	bne starcoin_init_exit
	; update ani frame
	inc !starcoin_ani_timer,x
	jsr.w _suboffscr0_bank3
	jsl   mario_spr_interact_l
	bcc starcoin_init_exit
	lda #!starcoin_collect_sfx
	sta !starcoin_collect_port

	sec
	rol !yoshi_coins_collected

;.popcount:
;	stz.b $00
;	lda.w !yoshi_coins_collected
;.loop:
;	inc $00
;	lsr
;	bne .loop
;	lda.b #$08
;	clc
;	adc $00
;	; todo this routine uses mario's position, before we were using sprite's position
;	jsl $00F377|!bank

	stz !sprite_status,x
	jml sprite_write_item_memory|!bank

;.exit:
;	rtl
.done:
%set_free_finish("bank3_sprites", starcoin_main_done)
