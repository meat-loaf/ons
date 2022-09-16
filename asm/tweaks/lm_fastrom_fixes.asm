incsrc "../main.asm"

macro jml_bank_patch(addr, length, name)
if read1(<addr>) == !JML_OPCODE
	!hijack #= read3(<addr>+$01)
	print "JML <name> hijack @ $", hex(<addr>), " fixed to fastrom"
	org <addr>
	JML !hijack|!bank
	if read1(!hijack+<length>) == !JML_OPCODE
		!hijack_ret #= read3(!hijack+<length>+1)
		print "JML <name> hijack return @ $", hex(!hijack+<length>), " fixed to fastrom"
		org !hijack+<length>
		JML !hijack_ret|!bank
	elseif read1(!hijack+<length>) == !JSL_OPCODE
		!hijack_ret #= read3(!hijack+<length>+1)
		print "JSL <name> inter-hijack long routine call @ $", hex(!hijack+<length>), " fixed to fastrom"
		org !hijack+<length>
		JSL !hijack_ret|!bank
	endif

endif
endmacro

macro jml_bank_patch_noret(addr, name)
if read1(<addr>) == !JML_OPCODE
	!hijack #= read3(<addr>+$01)
	print "JML <name> hijack @ $", hex(<addr>), " fixed to fastrom"
	org <addr>
		JML !hijack|!bank
endif
endmacro

macro jsl_bank_patch(addr, name)
if read1(<addr>) == !JSL_OPCODE
	!hijack #= read3(<addr>+$01)
	print "JSL <name> hijack @ $", hex(<addr>), " fixed to fastrom"
	org <addr>
		JSL !hijack|!bank
endif
endmacro

macro jsl_bank_patch_follow_eptr_tablefix(addr, follow_distance, name, table_len)
if read1(<addr>) == !JSL_OPCODE
	!hijack #= read3(<addr>+$01)
	print "JSL <name> hijack @ $", hex(<addr>), " fixed to fastrom"
	org <addr>
		JSL !hijack|!bank
	if read1(!hijack+<follow_distance>) == !JSL_OPCODE
		!call2 #= read3(!hijack+<follow_distance>+$1)
		print "JSL <name> follow-call @ $", hex(!hijack+<follow_distance>), " fixed to fastrom"
		org !hijack+<follow_distance>
		JSL !call2|!bank
		!__t_ix #= 0
		while !__t_ix < <table_len>*3
			!__t_val #= read3(!hijack+<follow_distance>+$4+!__t_ix)|!bank
			print "long table val at $", hex(!hijack+<follow_distance>+$4+!__t_ix), " fixed to fastrom"
			dl !__t_val
			!__t_ix #= !__t_ix+3
		endif

	endif
endif

endmacro

macro jsl_nested_single_bank_patch(source_addr, main_hijack_distance, secondary_distance, name, fixeptrtable, table_len)
if or(equal(read1(<source_addr>), !JSL_OPCODE), equal(read1(<source_addr>), !JML_OPCODE))
	!_first #= read3(<source_addr>+$01)
	if read1(!_first+<main_hijack_distance>) == !JSL_OPCODE
		!_second #= read3(!_first+<main_hijack_distance>+$01)
		if read1(!_second+<secondary_distance>) == !JSL_OPCODE
			!_rt #= read3(!_second+<secondary_distance>+$01)
			print "JSL <name> inter-hijack subroutine call @ $", hex(<source_addr>), " @ $", hex(!_second+<secondary_distance>), " fixed to fastrom"
			org !_second+<secondary_distance>
			JSL !_rt|!bank
			if <fixeptrtable>
				!__t_ix #= 0
				while !__t_ix < <table_len>*3
					!__t_val #= read3(!_second+<secondary_distance>+$4+!__t_ix)|!bank
					print "long table val at $", hex(!_second+<secondary_distance>+$4+!__t_ix), " fixed to fastrom"
					dl !__t_val
					!__t_ix #= !__t_ix+3
				endif
			endif
		endif
	endif
endif
endmacro


; fixes lunar magic not using fastrom banks in its sprite spawn handler for exlevels
;
!hijack_orig_loc = $02A826|!bank
!length_to_first_return = $BA
!length_to_second_return = $C4
if read1(!hijack_orig_loc|!bank) == !JML_OPCODE
	!hijack_dest #= read3((!hijack_orig_loc|!bank)+$01)
	org $02A826|!bank
		print "lm smartspawn hijack fixed to fastrom"
		JML !hijack_dest|!bank
	if read1(!hijack_dest+!length_to_first_return) == !JML_OPCODE
		!hijack_return_1 #= read3(!hijack_dest+!length_to_first_return+$01)
		org !hijack_dest+!length_to_first_return
		print "lm smartspawn hijack return 1 fixed to fastrom"
			JML !hijack_return_1|!bank
	endif

	if read1(!hijack_dest+!length_to_second_return) == !JML_OPCODE
		!hijack_return_2 #= read3(!hijack_dest+!length_to_second_return+$01)
		org !hijack_dest+!length_to_second_return
		print "lm smartspawn hijack return 2 fixed to fastrom"
			JML !hijack_return_2|!bank
	endif
endif

!lm_camera_hijack = $00F6E4|!bank
!camera_hijack_len = $20
%jml_bank_patch(!lm_camera_hijack, !camera_hijack_len, "lm camera")
;
!lm_exlevel_scroll_hijack = $00F70D|!bank
!lm_exlevel_scroll_len = $14
%jml_bank_patch(!lm_exlevel_scroll_hijack, !lm_exlevel_scroll_len, "lm exlevel camera scroll")

; this one follows a couple indirect pointers and ends up here. Hopefully its correct all the time...
!lm_camera_pos_upd_maybe_hijack = $00F79D|!bank
!lm_camera_pos_upd_maybe_hijack_len = $26
%jml_bank_patch(!lm_camera_pos_upd_maybe_hijack, !lm_camera_pos_upd_maybe_hijack_len, "lm camera pos update (maybe?)")

!lm_vram_mod_1 = $008209|!bank
%jsl_bank_patch(!lm_vram_mod_1, "lm vram modification 1")
;
!lm_some_l1_update_hack = $00F7E8|!bank
!lm_some_l1_update_hack_len = $2B
%jml_bank_patch(!lm_some_l1_update_hack, !lm_some_l1_update_hack_len, "lm layer 1 update (?)")
;
!lm_horiz_scroll_fix = $009708|!bank
%jsl_bank_patch(!lm_horiz_scroll_fix, "lm horizontal scroll fix")
;
!lm_more_layer_update_code = $0586F7|!bank
%jml_bank_patch(!lm_more_layer_update_code, $25, "lm more layer update stuff (?)")
%jml_bank_patch(!lm_more_layer_update_code, $9C, "lm more layer update stuff 2 (?)")
%jml_bank_patch(!lm_more_layer_update_code, $9C, "lm more layer update stuff 2 (?)")
; NOTE: there's a big table of function pointers here that need bank updates. I can't tell just how long the table is, but
; executeptr is called with A = $1925
%jsl_nested_single_bank_patch(!lm_more_layer_update_code, $25, $5, "lm more layer update stuff (?) executeptr invoc", 1, $20)
;
!lm_sprite_loader_thing_2 = $02A830|!bank
!lm_sprite_loader_thing_2_len = $60
%jml_bank_patch(!lm_sprite_loader_thing_2, !lm_sprite_loader_thing_2_len, "lm sprite loader thing")
%jml_bank_patch(!lm_sprite_loader_thing_2, $7A, "lm sprite loader thing jml 2")
%jml_bank_patch(!lm_sprite_loader_thing_2, $A7, "lm sprite loader thing jml 3")

%jml_bank_patch_noret($06F603|!bank, "no clue")

%jsl_bank_patch_follow_eptr_tablefix($0580BF|!bank, $10, "lm early gamemode thing 1", $20)
%jsl_bank_patch($0580C3|!bank, "lm early gamemode thing 2")
%jsl_bank_patch($0580C7|!bank, "lm early gamemode thing 3")

%jml_bank_patch($0081E2|!bank, $2, "lm fuck idk 1")
%jml_bank_patch($0081E2|!bank, $6, "lm fuck idk 2")

%jsl_bank_patch($02D158|!bank, "lm berry good hack")

%jsl_bank_patch($00A6CC|!bank, "lm level load thing")
%jsl_bank_patch($05D97D|!bank, "lm level entrance thing?")
%jsl_bank_patch($05D9A1|!bank, "lm level entrance thing 2?")
%jsl_bank_patch($05DA17|!bank, "lm level entrance thing 3?")

%jml_bank_patch($05803B|!bank, $09, "lm layer related (maybe; load only) 1")
%jml_bank_patch($05803B|!bank, $1B, "lm layer related (maybe; load only) 2")
%jml_bank_patch($05803B|!bank, $38, "lm layer related (maybe; load only) 3")

%jsl_bank_patch($0583C7|!bank, "lm stz 8a 8b early")
%jsl_bank_patch($02ACA4|!bank, "lm sprite cacher horiz level")

%jsl_bank_patch($01AC46|!bank, "lm suboffscr_bank1 hack")

%jsl_bank_patch($05D8F5|!bank, "lm level sprite data bank byte getter")
%jsl_bank_patch($058B45|!bank, "lm some ow load hijack")

%jml_bank_patch($02A95B|!bank, $00, "lm sprite y-high fixer")
%jml_bank_patch($02A95B|!bank, $08, "lm sprite y-high fixer 2")
%jml_bank_patch($02A95B|!bank, $0E, "lm sprite y-high fixer 3")
%jml_bank_patch($02A95B|!bank, $17, "lm sprite y-high fixer 4")

%jml_bank_patch($02A838|!bank, $11, "lm goal tape exbit hack 1")
%jml_bank_patch($02A838|!bank, $18, "lm goal tape exbit hack 2")

%jml_bank_patch($00A5A2|!bank, $06, "lm weird thing")

%jml_bank_patch($0580A9|!bank, $1A, "lm more weird thing")
