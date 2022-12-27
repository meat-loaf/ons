!castle_block_sprnum = $BB

; castle block init in spritesets.asm
%alloc_spr_nocfg(!castle_block_sprnum, castle_block_init, bank3_sprcaller)

!castle_block_phase        = !C2
!castle_block_x_movement   = !1528
!castle_block_moving_timer = !1540
castle_block_main:
	jsr spr_gfx_32x32
	lda !sprites_locked
	bne .exit
	lda !castle_block_moving_timer,x
	bne .no_phase_change
	inc !castle_block_phase,x
	lda !castle_block_phase,x
	and #$03
	tay
	lda .move_timing,y
	sta !castle_block_moving_timer,x
	lda .move_speed,y
	sta !sprite_speed_x,x
.no_phase_change:
	jsl spr_update_x_no_grv_l
	sta !castle_block_x_movement,x
	jsl spr_invis_blk_rt_l
.exit:
	rts
.move_timing:
	db $40,$50,$40,$50
.move_speed:
	db $00,$F0,$00,$10
