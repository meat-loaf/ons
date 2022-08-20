includeonce

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
		!___hi #= ((!___hi<<4)&19D8_flag_b8_12_seconary)|!19D8_flag_is_secondary
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

