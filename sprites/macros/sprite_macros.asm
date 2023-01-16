includefrom "macros.asm"

macro alloc_sprite(sprite_id, name, init_rt, main_rt, n_oam_tiles, n_exbyte, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val)
	!sid #= <sprite_id>
	if defined("sprite_!{sid}_defined")
		error "Sprite id <sprite_id> already defined."
	endif
	!{sprite_!{sid}_defined} = 1
	assert <n_exbyte> <= 4, "Maximum allowed number of extra bytes is 4."
	if <n_exbyte> > 0
		!sprites_have_exbytes = 1
	endif
	!{sprite_!{sid}_tag} = <name>
	!{sprite_!{sid}_init} = <init_rt>-1
	!{sprite_!{sid}_main} = <main_rt>-1
	!{sprite_!{sid}_sz}   #= 3+<n_exbyte>
	!{sprite_!{sid}_oamtiles} = <n_oam_tiles>*4
	!{sprite_!{sid}_1656} = <spr_1656_val>
	!{sprite_!{sid}_1662} = <spr_1662_val>
	!{sprite_!{sid}_166E} = <spr_166E_val>
	!{sprite_!{sid}_167A} = <spr_167A_val>
	!{sprite_!{sid}_1686} = <spr_1686_val>
	!{sprite_!{sid}_190F} = <spr_190F_val>
endmacro

macro alloc_sprite_dynamic_512k(sprite_id, gfx_name, init_rt, main_rt, n_oam_tiles, n_exbyte, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, free_tag)
	%alloc_sprite(<sprite_id>, <gfx_name>, <init_rt>, <main_rt>, <n_oam_tiles>, <n_exbyte>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>)
	if not(defined("n_dyn_gfx"))
		!n_dyn_gfx #= 0
	endif
	!n_dyn_gfx #= !n_dyn_gfx+1
	if not(getfilestatus("dyn_gfx/<gfx_name>.bin"))
		error "No read access to file `<gfx_name>.bin', or file doesn't exist."
	else
		if !n_dyn_gfx > !dyn_gfx_files_max
			error "Too many dynamic gfx files. Allocate more space (define dyn_gfx_files_max)"
		else
			%set_free_start(<free_tag>)
			dyn_gfx_!{n_dyn_gfx}_dat:
			incbin "../dyn_gfx/<gfx_name>.bin"
			dyn_gfx_!{n_dyn_gfx}_dat_end:
			%set_free_finish(<free_tag>, dyn_gfx_!{n_dyn_gfx}_dat_end)
			!dyn_spr_<gfx_name>_gfx_id #= !n_dyn_gfx-1
		endif
	endif
endmacro


