includefrom "list.def"

!ambient_player_dust_id = $00

%alloc_ambient_sprite(!ambient_player_dust_id, "turn_dust", ambient_dust_main)

%set_free_start("bank2_altspr2")
ambient_dust_main:
	lda !ambient_gen_timer,x
	bne .cont
	stz !ambient_rt_ptr,x
.cont:
	rts
.done:
%set_free_finish("bank2_altspr2", ambient_dust_main_dine)
