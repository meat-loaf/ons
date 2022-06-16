

LOROM


ORG $00A0BF
	autoclean JML OW_EVENT_CODE	; jump to routine

freecode
MainStart:




OW_EVENT_CODE:
	LDA $0DBE
	BPL OW_EVENT_CODE_1	; restore old code
	INC $1B87
OW_EVENT_CODE_1:
	STA $0DB4,x

	PHX
	PHY
	PHP		; wrapper
	PHB

	SEP #$30	; 8 bit A X Y

	LDA #$04
	PHA		; set bank
	PLB

	PHK		;\ set return address 1
	PER $0006	;/
	PEA $DC68	; set return address 2 (points to an RTL)

	JML $04DD40	; reload OW event tiles

	
	PLB
	PLP		; restore these
	PLY
	PLX

	JML $00A0CA	; return
