macro alloc_sprite(sprite_id, init_rt, main_rt, n_exbyte, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val)
	!sid #= <sprite_id>
	if defined("sprite_!{sid}_defined")
		error "Sprite id !sid already defined."
	endif
	!{sprite_!{sid}_defined} = 1
	assert <n_exbyte> <= 4, "Maximum allowed number of extra bytes is 4."
	if <n_exbyte> > 0
		!sprites_have_exbytes = 1
	endif
	!{sprite_!{sid}_init} = <init_rt>-1
	!{sprite_!{sid}_main} = <main_rt>-1
	!{sprite_!{sid}_sz}   #= 3+<n_exbyte>
	!{sprite_!{sid}_1656} = <spr_1656_val>
	!{sprite_!{sid}_1662} = <spr_1662_val>
	!{sprite_!{sid}_167A} = <spr_167A_val>
	!{sprite_!{sid}_166E} = <spr_166E_val>
	!{sprite_!{sid}_1686} = <spr_1686_val>
	!{sprite_!{sid}_190F} = <spr_190F_val>
	print "sprite $", hex(!sid), " init at ", hex(!{sprite_!{sid}_init})
	print "sprite $", hex(!sid), " main at ", hex(!{sprite_!{sid}_main})
endmacro

macro write_sprite_tables()
org sprite_size_table_ptr
	;; lm requirements
	;dl sprite_size_table
	;db $42

	!ix #= 0
	while !ix != $FF
	if defined("sprite_!{ix}_defined")
		;if defined "sprite_!{ix}_sz")
		;	assert !{sprite_!{ix}_sz} >= 3, "Sprite size for sprite id !ix is less than 3."
		;	org !{sprite_size_table}+($FF*0)+(!ix*1)
		;	db !{sprite_!{ix}_sz}
		;	org !{sprite_size_table}+($FF*1)+(!ix*1)
		;	db !{sprite_!{ix}_sz}
		;	org !{sprite_size_table}+($FF*2)+(!ix*1)
		;	db !{sprite_!{ix}_sz}
		;	org !{sprite_size_table}+($FF*3)+(!ix*1)
		;else
		;	error "Sprite size for sprite id !ix not defined."
		;endif
		if defined("sprite_!{ix}_init")
			org !sprite_init_table_lo+(!{ix})
			db !{sprite_!{ix}_init}
			org !sprite_init_table_hi+(!{ix})
			db (!{sprite_!{ix}_init})>>8
			org !sprite_init_table_bk+(!{ix})
			db (!{sprite_!{ix}_init})>>16
		else
			error "Init routine for sprite id !ix not defined."
		endif
		if defined("sprite_!{ix}_main")
			org !sprite_main_table_lo+(!{ix})
			db !{sprite_!{ix}_main}
			org !sprite_main_table_hi+(!{ix})
			db (!{sprite_!{ix}_main})>>8
			org !sprite_main_table_bk+(!{ix})
			db (!{sprite_!{ix}_main})>>16
		else
			error "Main routine for sprite id !ix not defined."
		endif
			org !spr_tweaker_1656_tbl+(!ix)
			db !{sprite_!{ix}_1656}
			org !spr_tweaker_1662_tbl+(!ix)
			db !{sprite_!{ix}_1662}
			org !spr_tweaker_166E_tbl+(!ix)
			db !{sprite_!{ix}_166E}
			org !spr_tweaker_167A_tbl+(!ix)
			db !{sprite_!{ix}_167A}
			org !spr_tweaker_1686_tbl+(!ix)
			db !{sprite_!{ix}_1686}
			org !spr_tweaker_190F_tbl+(!ix)
			db !{sprite_!{ix}_190F}
		
	endif
	!ix #= !ix+1
	endif
endmacro

macro set_free_start(tag)
	pushpc
	assert defined("<tag>_free_start"), "Freespace tag '<tag>' invalid [end]."
	org !<tag>_free_start
	!next_free_tag = <tag>
	!free_finished = 0
endmacro

macro set_free_finish(tag, label)
	if not(defined("<tag>_free_end"))
		error "Freespace tag '<tag>' invalid [finish]."
		pullpc ; silence error
	else
	warnpc !<tag>_free_end
	if or(not(defined("free_finished")), notequal(!free_finished,0))
		error "use 'set_free_start' before 'set_free_finish'."
		pullpc ; silence error
	else
	assert stringsequal("<tag>","!next_free_tag"), "Expected to free tag !next_free_tag next."
	!<tag>_free_start = <label>
	!free_finished = 1
	pullpc
	endif
	endif
endmacro
