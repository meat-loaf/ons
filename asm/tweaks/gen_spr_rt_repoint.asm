!custom_parabeetle_acts_like = $12

pushpc
org shared_spr_routines_tile_offset(!custom_parabeetle_acts_like)
	db $09
org shared_spr_routintes_tile_addr(!custom_parabeetle_acts_like)
	db $08,$0A
pullpc


