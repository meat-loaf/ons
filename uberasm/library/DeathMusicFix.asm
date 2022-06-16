!miss_no_prelude = $29	; set this to the music slot number of "01 Miss(no prelude).txt"

DeathJingle:
	; death jingle
	LDA $71
	CMP #$09
	BNE +
	LDA $1496|!addr
	CMP #$2A
	BNE +
	LDA #!miss_no_prelude
	STA $1DFB|!addr
	DEC $1496|!addr
+
	RTL