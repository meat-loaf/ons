incsrc "../main.asm"

%replace_pointer($018191|!bank, red_parakoopa_ebit)
%replace_pointer($018193|!bank, red_parakoopa_ebit)

; overwrite feather superkoopa main
org $01852E|!bank
red_parakoopa_ebit:
	LDA !extra_bits,x
	AND #$04
	BEQ init_std_sprite
	; make palette sprite pal 1
	LDA !sprite_oam_properties,x
	AND #$F1
	ORA #($01<<1)
	STA !sprite_oam_properties,x
	; make inedible
	LDA !1686,x
	ORA #$01
	STA !1686,x
	BRA init_std_sprite
warnpc $01854B|!bank
	
org $018575|!bank
init_std_sprite:
