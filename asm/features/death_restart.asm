incsrc "../main.asm"

org $00D0E7|!bank
;	db $18       ; gamemode to execute on death
	db $0B       ; gamemode to execute on death
warnpc $00D0E8|!bank

org $009468|!bank
gamemode_19:
	;LDA.b #$0B
	LDA.b #$10
	STA.w $0100|!addr
	LDA.w $0DAF|!addr
	EOR.b #$01
	STA.w $0DAF|!addr
	
;	LDA.b #$02
;	STA.w $0DB1
;	JSR.w $9F29
;	STZ.w $141A|!addr
;	STZ.b $71
	;STA.w $141D|!addr
	RTS
warnpc $00968D|!bank
