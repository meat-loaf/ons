; set as needed
!sprites_have_exbytes = 0

macro alloc_sprite(sprite_id, init_rt, main_rt, n_oam_tiles, n_exbyte, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val)
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
	!{sprite_!{sid}_oamtiles} = <n_oam_tiles>*4
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
	
	print "sprite $!fmt", hex(!sid), " init ptr-1 = $", hex(!{sprite_!{sid}_init}), ", main ptr-1 = $", hex(!{sprite_!{sid}_main})
	undef "fmt"
endmacro

macro alloc_sprite_dynamic_512k(sprite_id, init_rt, main_rt, n_oam_tiles, n_exbyte, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, gfx_name, free_tag)
	%alloc_sprite(<sprite_id>, <init_rt>, <main_rt>, <n_oam_tiles>, <n_exbyte>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>)
	if not(defined("n_dyn_gfx"))
		!n_dyn_gfx #= 0
	endif
	!n_dyn_gfx #= !n_dyn_gfx+1
	if not(getfilestatus("dyn_gfx/<gfx_name>.bin"))
		error "No read access to file `<gfx_name>.bin'."
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

macro write_dynamic_spr_gfx_ptrs()
org !spr_dyn_gfx_tbl
print "Dynamic gfx pointers start at $", pc, " (max !dyn_gfx_files_max)"
!ix #= 0
while !ix < !n_dyn_gfx
	!ix_real #= !ix+1
	print "write pointer to dyn_gfx_!{ix_real}_dat"
	dl dyn_gfx_!{ix_real}_dat
	!ix #= !ix+1
endif
print "Dynamic gfx pointers end at $", pc, " (total used: !ix)"
undef "ix"
undef "ix_real"

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

if defined("spr_dyn_gfx_tbl")
	%write_dynamic_spr_gfx_ptrs()
endif

if and(!sprites_have_exbytes, not(!sprites_use_exbytes))
	error "Sprites have extra bytes, but extra byte functionality is not enabled."
endif
org sprite_size_table_ptr
if !sprites_have_exbytes
	print "Sprites have extra bytes."
	; lm requirements
	dl sprite_size_table
	db $42
else
	; the code in the sprite loader isn't reliable to undo (because it needs to overwrite
	; lm hijacks), so if the code gets written once, it stays.
	!magic #= read1(!sprite_size_table_ptr+3)
	if !magic == $42
		print "No sprites have extra bytes, but they did previously. Overriding."
		!sprites_have_exbytes = 1
	else
		print "No sprites have extra bytes."
		; db $FF,$FF,$FF,$FF
	endif
	undef "magic"
endif
	!ix #= 0
	while !ix < $100
	if defined("sprite_!{ix}_defined")
		if defined("sprite_!{ix}_oamtiles")
			org oam_tile_count+!ix
			db !{sprite_!{ix}_oamtiles}
		else
			error "Number of OAM tiles to allocate for sprite not defined."
		endif
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
		org oam_tile_count+!ix
			db $00
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
		;print "(<tag>) free start: ", pc
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
		;print "(<tag>) free finish: ", hex(<label>)
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

macro jump_hijack(jump_op, length, target, hijack_addr, maxaddr)
	org <hijack_addr>
	<jump_op>.<length> <target>
	warnpc <maxaddr>
endmacro
