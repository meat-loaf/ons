;Put this in uberasm tool's library file.
;use JSL ceilingtriangles_ceilingfix to get to it
;ONLY USE WITH LEVELASM, NOT GAME MODE

!direction = $1926|!addr

ceilingfix:

	LDA !direction
	CMP #$86 ;ceiling going to left
	BNE +
	JSL .ceilingright
	+ LDA !direction
	CMP #$87 ;ceiling going to right
	BNE +
	JSL .ceilingleft
	+ 
	LDA $14              ;\ return every certain frames
    AND #$01            ; |
    BEQ +          		;/
	LDA $13E3|!addr
	STA !direction
	+ RTL

.ceilingright
	LDA $15
	AND #$04
	BEQ + 
	LDA #$D0
	STA $7B
	RTL
	+ LDA $15
	AND #$80
	BEQ +
	LDA #$4C
	STA $7D
	LDA #$D0
	STA $7B
	RTL
	+ LDA $17
	AND #$80
	BEQ +
	LDA #$4C
	STA $7D
	LDA #$D0
	STA $7B
	+ RTL

.ceilingleft
	LDA $15
	AND #$04
	BEQ + 
	LDA #$2F
	STA $7B
	RTL
	+ LDA $15
	AND #$80
	BEQ +
	LDA #$4C
	STA $7D
	LDA #$2F
	STA $7B
	RTL
	+ LDA $17
	AND #$80
	BEQ +
	LDA #$4C
	STA $7D
	LDA #$2F
	STA $7B
	+ RTL