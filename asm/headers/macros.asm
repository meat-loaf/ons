includeonce

;function on_wram_mirror(ram) = and(less(<ram>&$FFFF,$2000),not(eq(bank(<ram>),!ramhi)))

function pack_props(flip, priority, palette, page) = ((flip&03)<<$06)|((priority&03)<<$04)|((palette&$07)<<1)|(page&$01)

function shared_spr_routines_tile_offset(spr_num) = ($019C7F+spr_num)
function shared_spr_routines_tile_addr(spr_num)   = ($019B83+read1($019C7F+spr_num))

macro replace_pointer_long(addr,ptr)
	pushpc
	org <addr>
	dl <ptr>
	pullpc
endmacro

macro replace_pointer(addr,ptr)
	pushpc
	org <addr>
	dw <ptr>
	pullpc
endmacro

macro sprite_set_cfg(sprite_id, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val)
pushpc
	org !spr_tweaker_1656_tbl+<sprite_id>
		db <spr_1656_val>
	org !spr_tweaker_1662_tbl+<sprite_id>
		db <spr_1662_val>
	org !spr_tweaker_166E_tbl+<sprite_id>
		db <spr_166E_val>
	org !spr_tweaker_167A_tbl+<sprite_id>
		db <spr_167A_val>
	org !spr_tweaker_1686_tbl+<sprite_id>
		db <spr_1686_val>
	org !spr_tweaker_190F_tbl+<sprite_id>
		db <spr_190F_val>
pullpc
endmacro

macro dump_sprite_cfg(sprite_id)
	!one #= read1(!spr_tweaker_1656_tbl+<sprite_id>)
	!two #= read1(!spr_tweaker_1662_tbl+<sprite_id>)
	!three #= read1(!spr_tweaker_166E_tbl+<sprite_id>)
	!four #= read1(!spr_tweaker_167A_tbl+<sprite_id>)
	!five #= read1(!spr_tweaker_1686_tbl+<sprite_id>)
	!six #= read1(!spr_tweaker_190F_tbl+<sprite_id>)
	error "sprite id ", <sprite_id>, "cfg vals (in decimal): !one, !two, !three, !four, !five, !six"

endmacro

macro alloc_spr(sprite_id, sprite_init, sprite_main, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val)
	%replace_pointer(!spr_inits_start+(<sprite_id>*2)|!bank, <sprite_init>|!bank)
	%replace_pointer(!spr_mains_start+(<sprite_id>*2)|!bank, <sprite_main>|!bank)
	%sprite_set_cfg(<sprite_id>,<spr_1656_val>,<spr_1662_val>,<spr_166E_val>,<spr_167A_val>,<spr_1686_val>,<spr_190F_val>)
endmacro

macro alloc_spr_nocfg(sprite_id, sprite_init, sprite_main)
	%replace_pointer(!spr_inits_start+(<sprite_id>*2)|!bank, <sprite_init>|!bank)
	%replace_pointer(!spr_mains_start+(<sprite_id>*2)|!bank, <sprite_main>|!bank)
endmacro

macro sprite_init_do_pos_offset(spr_table,index)
	; y offset
	LDA <spr_table>,<index>
	AND #$F0
	BEQ ?+
	LSR #4
	CLC
	ADC !D8,x
	STA !D8,x
	BCC ?+
	INC !14D4,x
?+

	; x offset
	LDA <spr_table>,<index>
	AND #$0F
	BEQ ?+
	CLC
	ADC !E4,x
	STA !E4,x
	BCC ?+
	INC !14E0,x
?+

endmacro

macro sprite_read_item_memory(routine)
	LDA !D8,x
	AND #$F0
	STA $98
	LDA !E4,x
	AND #$F0
	STA $9A
	LDA !14D4,x
	STA $99
	LDA !14E0,x
	STA $9B
	JSL <routine>
endmacro

macro midway_table_entry(lvl_or_secondary_exit, is_midpoint_or_water, is_secondary)
	!___lo #= <lvl_or_secondary_exit>&$FF
	!___hi #= (((<lvl_or_secondary_exit>&$FF00)>>8)|!19D8_flag_lm_modified)

	if <is_midpoint_or_water> == !true
		!___hi #= (!___hi|!19D8_flag_water_lvl_mid)
	endif
	if <is_secondary> == !true
		!___hi #= ((!___hi<<4)&!19D8_flag_b8_12_seconary)|!19D8_flag_is_secondary
	endif

	!___val #= (!___lo|(!___hi<<8))
	dw !___val
endmacro

; from uberasm
macro move_block(src,dest,len)
	PHB
	REP #$30
	LDA.w #<len>-1
	LDX.w #<src>
	LDY.w #<dest>
	MVN <dest>>>16,<src>>>16
	SEP #$30
	PLB
endmacro

macro gen_dma_stage_table(buffer_location,memsize,nstages)
!___ix #= 0
while !___ix != <nstages>
	dw <buffer_location>+((<memsize>/<nstages>)*!___ix)
	!___ix #= !___ix+1
endif
endmacro

macro load_restore(main_ram, bak_ram, bak_to_main)
if <bak_to_main> == !false
	LDA <main_ram>
	STA <bak_ram>
else
	LDA <bak_ram>
	STA <main_ram>
endif
endmacro

macro midway_backup_restore(bak_to_main)
if <bak_to_main> == !false
	LDA !red_coin_total
	CLC : ADC !red_coin_adder
	STA !rcoin_count_bak
else
	%load_restore(!red_coin_total, !rcoin_count_bak, <bak_to_main>)
endif
	%load_restore(!yoshi_coins_collected, !scoin_count_bak, <bak_to_main>)
	%load_restore(!on_off_state, !on_off_state_bak, <bak_to_main>)
	%load_restore(!moon_counter, !got_moon_bak, <bak_to_main>)
	%load_restore(!player_score, !score_bak+0, <bak_to_main>)
	%load_restore(!player_score+1, !score_bak+1, <bak_to_main>)
	%load_restore(!player_score+2, !score_bak+2, <bak_to_main>)
	%load_restore(!powerup, !player_power_bak, <bak_to_main>)

	; always the same
	LDA !time_huns_bak
	STA !timer_hundreds
	STZ !timer_tens
	STZ !timer_ones

	LDA #$28
	STA !timer_frame


; reset a bunch of timers when reloading
; TODO double-check if anything else needs doing here
if <bak_to_main> == !true
; unroll/dma? cycles probably dont matter too much here
	LDX.b #$7F
?load_loop
	STZ.w $1938,x
	DEX
	BMI ?load_loop

	REP.b #$20
	; player-related timers
	STZ.w $1497|!addr
	STZ.w $1499|!addr
	STZ.w $149B|!addr
	STZ.w $149D|!addr
	STZ.w $149F|!addr
	STZ.w $14A1|!addr
	STZ.w $14A3|!addr
	STZ.w $14A5|!addr
	STZ.w $14A7|!addr
	STZ.w $14A9|!addr
	SEP.b #$20
	STZ.w $14AB|!addr
endif

if !use_midway_imem_sram_dma == !true
  if <bak_to_main> == !false
	; runs over several frames. see status bar code.
	LDA.b #!item_memory_dma_frames+$01
	STA.w !midway_imem_dma_stage
  else
	; TODO dma?
	%move_block(!item_memory_mirror_s,!item_memory,!item_memory_size)
  endif
endif

endmacro
