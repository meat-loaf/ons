!ambient_score_10pt_id = $13

%alloc_ambient_sprite(!ambient_score_10pt_id, "ambient_score_10pt", ambient_score, \
	!ambient_twk_pos_upd)

%set_free_start("bank2_altspr1")
ambient_score:
	rts
ambient_score_done:
%set_free_finish("bank2_altspr1", ambient_score_done)
