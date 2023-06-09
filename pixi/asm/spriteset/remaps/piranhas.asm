includefrom "remaps.asm"

if !remap_jumpin_pplant_vine
org $019BBD|!bank
	db $04,$0E,$06,$0E
  if !jumpin_pirana_stem_sp0_1
	db $83,$83,$A6,$A6,$83,$83,$A7,$A7
  else
	db $16,$16,$06,$06,$16,$16,$07,$07
  endif
; jumpin' piranha plant: stem properties
; (head properties loaded from cfg)
org $02E10E|!bank
  if !jumpin_pirana_stem_sp0_1
	db $0A
  else
	db $0B
  endif

;; growing vine tiles
;org $01C19E|!bank
;	db $04
;org $01C1A2|!bank
;	db $06

; uses generic sprite routine into late tilestore
;org $01C1A3|!bank
;	JSR.w store_tile1_bank1|!bank

; 166E vals
org ($07F3FE+$4F)|!bank
	db $09,$09
; growing vine
;org ($07F3FE+$79)|!bank
;	db $3B

; normal piranha plant
org ($07F3FE+$1A)|!bank
	db $09

; upside-down piranha plant
org ($07F3FE+$2A)|!bank
	db $09
else ; !remap_jumpin_pplant_vine = 0
org $019BBD|!bank
	db $AC,$CE,$AE,$CE
	db $83,$83,$C4,$C4,$83,$83,$C5,$C5
org $02E10E|!bank
	db $0A
; growing vine
;org $01C19E
;	db $AC
;org $01C1A2
;	db $AE

; 166E vals
org ($07F3FE+$4F)|!bank
	db $08,$08
; growing vine
;org ($07F3FE+$79)|!bank
;	db $3A

; normal piranha plant
org $(07F3FE+$1A)|!bank
	db $08
; upside-down piranha plant
org $(07F3FE+$2A)|!bank
	db $08
endif
