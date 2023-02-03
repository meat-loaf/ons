!move_plats_x_or_y_sprid  = $54
!move_plats_x_and_y_sprid = !plats_x_or_y_sprid+$1

;%alloc_sprite(

!move_plats_accel_timer = !sprite_misc_1540
!move_plats_direction   = !sprite_misc_c2

%set_free_start("bank1_plats")
plats_init:
	lda #$04
	sta !move_plats_accel_timer,x

	; todo: set clipping/style via extra byte?
	rtl

plats_main:
	lda !sprites_locked
	bne .exit
	inc !move_plats_direction,x
	lda !move_plats_direction,x
.exit:
	rtl
