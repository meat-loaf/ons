!starcoin_sprnum = $B9

%alloc_spr(!starcoin_sprnum, starcoin_init, bank3_sprcaller,\
	$8E, $0E, $75, $9B, $B9, $46)

!starcoin_collect_sfx = $1A
!starcoin_collect_port = $1DFC|!addr

!starcoin_ani_timer = !1570
!starcoin_slot      = !1602

pushpc
org !bank1_koopakids_free
starcoin_init:
	; todo make shared routine
	%sprite_init_do_pos_offset(!extra_byte_1,x)
	rts
.done:

warnpc !bank1_koopakids_end
!bank1_koopakids_free = starcoin_init_done
pullpc

starcoin_main:
	lda !starcoin_ani_timer,x
	lsr #3
	and #$03
	sta $0E
	lda #$01
	sta $0F
	jsr spr_dyn_gfx_rt

	lda !sprites_locked
	bne .exit
	; update ani frame
	inc !starcoin_ani_timer,x
	jsr.w _suboffscr0_bank3
	jsl   mario_spr_interact_l
	bcc .exit
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

	jsl sprite_write_item_memory|!bank

	stz !sprite_status,x
.exit:
	rts
.done:
