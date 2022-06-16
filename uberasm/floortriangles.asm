;Put this in uberasm tool's library file.
;use JSL floortriangles_buttoncheck to get to it

buttoncheck:
	LDA $15 ;we check if we're holding run
	AND #$40
	BNE .directioncheck
	RTL
	
.directioncheck
	;corners always need to check first to prevent the small mario death glitch
	;they're not direction dependent and never trigger elsewhere
	;so it shouldn't cause any issues
	LDA $13E3|!addr
	CMP #$05 ;fix corner cuts
	BNE +
	LDA #$F0
	STA $7D
	+ LDA $13E3|!addr
	CMP #$04 ;fix corner cuts
	BNE +
	LDA #$F0
	STA $7D
	+ LDA $15 ;check if we're holding left
	AND #$02
	CMP #$02
	BEQ .left
	LDA $15 ;or right
	AND #$01
	CMP #$01
	BEQ .right
	RTL
	
.left
	LDA $13E3|!addr
	CMP #$02 ;fix corner BL
	BNE +
	LDA #$D0
	STA $7B
	RTL
	+ LDA $13E3|!addr
	CMP #$06 ;fix wall
	BNE +
	LDA #$D0
	STA $7B
	+ RTL
	
.right
	LDA $13E3|!addr
	CMP #$03 ;fix corner BR
	BNE +
	LDA #$2F
	STA $7B
	RTL
	+ LDA $13E3|!addr
	CMP #$07 ;fix wall
	BNE +
	LDA #$2F
	STA $7B
	+ RTL