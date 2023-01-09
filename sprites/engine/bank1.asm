org $01801A|!bank
spr_upd_y_no_grv_l:
	jsr.w _spr_upd_y_no_grav
	rtl
spr_upd_x_no_grv_l:
	jsr.w _spr_upd_x_no_grav
	rtl
spr_upd_yx_no_grav_l:
	jsr.w _spr_upd_x_no_grav
	jsr.w _spr_upd_y_no_grav
	rtl
warnpc $018029|!bank
