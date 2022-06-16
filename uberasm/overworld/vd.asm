init:
main:
	REP #$20

	LDA #$3200
	STA $4330
	LDA #.RedTable
	STA $4332
	LDY.b #.RedTable>>16
	STY $4334
	LDA #$3200
	STA $4340
	LDA #.GreenTable
	STA $4342
	LDY.b #.GreenTable>>16
	STY $4344
	LDA #$3200
	STA $4350
	LDA #.BlueTable
	STA $4352
	LDY.b #.BlueTable>>16
	STY $4354
	SEP #$20
	LDA #$38
	TSB $0D9F|!addr
	RTL


.RedTable:           ; 
   db $01 : db $2A   ; 
   db $04 : db $2B   ; 
   db $11 : db $2A   ; 
   db $11 : db $29   ; 
   db $12 : db $28   ; 
   db $11 : db $27   ; 
   db $08 : db $26   ; 
   db $09 : db $25   ; 
   db $11 : db $24   ; 
   db $11 : db $23   ; 
   db $63 : db $22   ; 
   db $00            ; 

.GreenTable:         ; 
   db $01 : db $49   ; 
   db $04 : db $4A   ; 
   db $11 : db $49   ; 
   db $11 : db $48   ; 
   db $12 : db $47   ; 
   db $11 : db $46   ; 
   db $08 : db $45   ; 
   db $09 : db $44   ; 
   db $11 : db $43   ; 
   db $11 : db $42   ; 
   db $62 : db $41   ; 
   db $01 : db $40   ; 
   db $00            ; 

.BlueTable:          ; 
   db $05 : db $87   ; 
   db $22 : db $86   ; 
   db $23 : db $85   ; 
   db $11 : db $84   ; 
   db $22 : db $83   ; 
   db $63 : db $82   ; 
   db $00            ; 
