; set as needed
!sprites_have_exbytes = 0

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
	!fmt = ""
	if !sid < 16
		!fmt = 0
	endif
	print "sprite $!fmt", hex(!sid), " init at $", hex(!{sprite_!{sid}_init})
	print "sprite $!fmt", hex(!sid), " main at $", hex(!{sprite_!{sid}_main})
	undef "fmt"
endmacro

macro __alloc_sprite_sharedgfx_begin(sprite_id)
	if not(defined("sharedgfx_tilemap_currentoff"))
		!sharedgfx_tilemap_currentoff #= 0
	endif
	assert !sharedgfx_tilemap_currentoff <= $F8, "Maximum number of sharedgfx routine tiles allocated."
	assert <sprite_id> < $54, "Only sprites with ids less than $54 can use original shared gfx routines (requested <sprite_id>)."
	; set offset
	org sprite_tilemap_offsets+<sprite_id>|!bank
		db !sharedgfx_tilemap_currentoff
	!id_f #= <sprite_id>
	!{sharedgfx_tilemap_off_sprite_!{id_f}} #= !sharedgfx_tilemap_currentoff
	undef "id_f"
endmacro
macro alloc_sprite_sharedgfx_entry_1(sprite_id, frame_1)
	%__alloc_sprite_sharedgfx_begin(<sprite_id>)
	org sprite_tilemaps+!sharedgfx_tilemap_currentoff
		db <frame_1>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_2(sprite_id, frame_1, frame_2)
	%alloc_sprite_sharedgfx_entry_1(<sprite_id>,<frame_1>)
		db <frame_2>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_3(sprite_id, frame_1, frame_2, frame_3)
	%alloc_sprite_sharedgfx_entry_2(<sprite_id>,<frame_1>,<frame_2>)
		db <frame_3>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_4(sprite_id, frame_1, frame_2, frame_3, frame_4)
	%alloc_sprite_sharedgfx_entry_3(<sprite_id>,<frame_1>,<frame_2>,<frame_3>)
		db <frame_4>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_5(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5)
	%alloc_sprite_sharedgfx_entry_4(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>)
		db <frame_5>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro

macro alloc_sprite_sharedgfx_entry_mirror(sprite_id, id_to_mirror)
	!id_f #= <id_to_mirror>
	assert defined("sharedgfx_tilemap_off_sprite_!{id_f}"), "Shared sprite gfx entry for sprite id <id_to_mirror> cannot be mirrored: has not been allocated yet!"
	org sprite_tilemap_offsets+<sprite_id>|!bank
		db !{sharedgfx_tilemap_off_sprite_!{id_f}}
	undef "id_f"
endmacro


macro write_sprite_tables()
org sprite_size_table_ptr
if !sprites_have_exbytes
	print "Sprites have extra bytes."
	; lm requirements
	dl sprite_size_table
	db $42
else
	print "No sprites have extra bytes."
	db $FF,$FF,$FF,$FF
endif
	!ix #= 0
	while !ix != $FF
	if defined("sprite_!{ix}_defined")
		if defined("sprite_!{ix}_sz")
			assert !{sprite_!{ix}_sz} >= 3, "Sprite size for sprite id !ix is less than 3."
			org !{sprite_size_table}+($100*0)+(!ix*1)
			db !{sprite_!{ix}_sz}
			org !{sprite_size_table}+($100*1)+(!ix*1)
			db !{sprite_!{ix}_sz}
			org !{sprite_size_table}+($100*2)+(!ix*1)
			db !{sprite_!{ix}_sz}
			org !{sprite_size_table}+($100*3)+(!ix*1)
		else
			error "Sprite size for sprite id !ix not defined."
		endif
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
	else
	  if !sprites_have_exbytes
		;print "Sprite id !ix not defined, but we have exbytes...populating with defaults."
		org !{sprite_size_table}+($100*0)+(!ix*1)
		db $03
		org !{sprite_size_table}+($100*1)+(!ix*1)
		db $03
		org !{sprite_size_table}+($100*2)+(!ix*1)
		db $03
		org !{sprite_size_table}+($100*3)+(!ix*1)
		db $03
	  endif
	endif

	!ix #= !ix+1
	endif
endmacro

macro set_free_start(tag)
	pushpc
	if not(defined("<tag>_free_start"))
		error "Freespace tag '<tag>' invalid [start]."
	else
		org !<tag>_free_start
		!next_free_tag = <tag>
		!free_finished = 0
	endif
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

macro jsl2rts(rtl_addr, target_addr)
	assert bank(<rtl_addr>) == bank(<target_addr>), "JSL2RTS Bank of RTL and Target do not match."
	pea.w <rtl_addr>-1
	jml.l <target_addr>|!bank
endmacro

macro jump_hijack(jump_op, prefix, target, hijack_addr, maxaddr)
	org <hijack_addr>
	<jump_op>.<prefix> <target>
	warnpc <maxaddr>
endmacro
