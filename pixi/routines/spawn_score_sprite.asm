	PHY	
	TAY	
	LDA	!D8
	PHA	
	LDA	$98
	STA	!D8
	LDA	!E4
	PHA	
	LDA	$9A
	STA	!E4
	LDA	!14D4
	PHA	
	LDA	$99
	STA	!14D4
	LDA	!14E0
	PHA	
	LDA	$9B
	STA	!14E0
	TYA	
	PHX	
	LDX	#$00
	JSL	$02ACEF|!bank
	PLX	
	PLA	
	STA	!14E0
	PLA	
	STA	!14D4
	PLA	
	STA	!E4	
	PLA	
	STA	!D8	
	PLY	
	RTL	