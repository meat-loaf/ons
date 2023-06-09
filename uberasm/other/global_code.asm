; Note that since global code is a single file, all code below should return with RTS.

load:
	rts
init:
	rts
main:
	rts
; blockchanges stuff
;You can change the ram here if needed
;lorom
!VRAMUploadTblSmall = $7FB700
!VRAMUploadTblLarge = $7FB800
!VRAMUploadTblSmallIndex = $06F9
!VRAMUploadTblLargeIndex = $06FB

;SA-1
!VRAMUploadTblSmallSA1 = $40A000
!VRAMUploadTblLargeSA1 = $40A100
!VRAMUploadTblSmallIndexSA1 = $66F9
!VRAMUploadTblLargeIndexSA1 = $66FB

if !sa1
!VRAMUploadTblSmall = !VRAMUploadTblSmallSA1
!VRAMUploadTblLarge = !VRAMUploadTblLargeSA1
!VRAMUploadTblSmallIndex = !VRAMUploadTblSmallIndexSA1
!VRAMUploadTblLargeIndex = !VRAMUploadTblLargeIndexSA1
endif

nmi:
	PHP
	REP #$10
	LDX !VRAMUploadTblSmallIndex
	BEQ .SkipUploadSmallTable
	JSR RunVRAMUploadSmall
.SkipUploadSmallTable
	LDX !VRAMUploadTblLargeIndex
	BEQ .SkipUploadLargeTable
	JSR RunVRAMUploadLarge
.SkipUploadLargeTable
	PLP
	RTS

RunVRAMUploadSmall:
	LDA #$80
	STA $2115
	STX $4325
	LDX #$1604
	STX $4320
	LDX.w #!VRAMUploadTblSmall
	STX $4322
	LDA.b #!VRAMUploadTblSmall>>16
	STA $4324
	LDA #$04
	STA $420B
	LDX #$0000
	STX !VRAMUploadTblSmallIndex
	RTS

RunVRAMUploadLarge:
	PHB
	PEA.w (!VRAMUploadTblLarge>>16)|(!VRAMUploadTblLarge>>8)
	PLB
	PLB
	REP #$20
	STZ $00
	LDX #$0000
.Loop
	LDA.w !VRAMUploadTblLarge+10,x
	BEQ .NoDelay
	DEC.w !VRAMUploadTblLarge+10,x
	LDY $00
	LDA.w !VRAMUploadTblLarge,x
	STA.w !VRAMUploadTblLarge,y
	LDA.w !VRAMUploadTblLarge+2,x
	STA.w !VRAMUploadTblLarge+2,y
	LDA.w !VRAMUploadTblLarge+4,x
	STA.w !VRAMUploadTblLarge+4,y
	LDA.w !VRAMUploadTblLarge+6,x
	STA.w !VRAMUploadTblLarge+6,y
	LDA.w !VRAMUploadTblLarge+8,x
	STA.w !VRAMUploadTblLarge+8,y
	LDA.w !VRAMUploadTblLarge+10,x
	STA.w !VRAMUploadTblLarge+10,y
	LDA $00
	CLC
	ADC #$000C
	STA $00
	BRA .NextEntry
.NoDelay
	LDA.w !VRAMUploadTblLarge,x
	STA $004320
	LDA.w !VRAMUploadTblLarge+2,x
	STA $004322
	LDA.w !VRAMUploadTblLarge+4,x
	STA $004324
	LDA.w !VRAMUploadTblLarge+5,x
	STA $004325
	LDA.w !VRAMUploadTblLarge+7,x
	STA $002115
	LDA.w !VRAMUploadTblLarge+8,x
	STA $002116
	LDA.w !VRAMUploadTblLarge-1,x
	BPL $04
	LDA $002139
	SEP #$20
	LDA #$04
	STA $00420B
	REP #$20
.NextEntry
	TXA
	CLC
	ADC #$000C
	TAX
	CMP.l !VRAMUploadTblLargeIndex
	BCC .LoopJump
.Break
	PLB
	LDA $00
	STA !VRAMUploadTblLargeIndex
	RTS
.LoopJump
	JMP .Loop	
