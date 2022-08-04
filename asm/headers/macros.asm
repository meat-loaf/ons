includeonce

function pack_props(flip, priority, palette, page) = ((flip&03)<<$06)|((priority&03)<<$04)|((palette&$07)<<1)|(page&$01)

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

macro sprite_item_memory_invoc(routine)
	LDA !D8,x
	AND #$F0
	STA $98
	LDA !E4,x
	AND #$F0
	STA $9A
	LDA !14D4,x
	AND #$F0
	STA $99
	LDA !14E0,x
	AND #$F0
	STA $9B
	JSL <routine>
endmacro
