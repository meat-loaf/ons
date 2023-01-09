includefrom "engine.asm"

%set_free_start("bank2_altspr1")
ambient_rts:
	skip !ambient_sprid_max*2
.done
%set_free_finish("bank2_altspr1", ambient_rts_done)

%set_free_start("bank2_altspr2")
ambient_sprcaller:
	rep #$30
	ldx.w #(!num_ambient_sprs*2)-2
.loop:
	lda !ambient_rt_ptr,x
	beq .cont
	stx !current_ambient_process
	%implement_timer("!ambient_gen_timer,x")
	jsr (!ambient_rt_ptr,x)
.cont
	dex : dex
	bpl .loop
	sep #$30
.default:
	rts
ambient_sprcaller_end:
%set_free_finish("bank2_altspr2", ambient_sprcaller_end)
