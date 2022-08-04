;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Shared GFX subroutine
;
;	Input:	A = How many tiles to draw.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Shared_GFX:
		DEC
		STA $04
	
		%GetDrawInfo()
	
		LDA !spr_extra_bits,x
		AND #$04
		BEQ .no_ex_bit
		LDA !15F6,x
		AND #$01
		ORA #$0C
		BRA .ex_bit
.no_ex_bit:
		LDA !15F6,x
.ex_bit
		ORA $64
		STA $03

GraphicLoop:
		LDX $04
		INX
	-
		DEX
		BMI +
		
		GetTileNumber:
			CPX $04
			BNE ++
				LDA #$88	; Right edge of the platform
				BRA Draw
				
		++
			CPX #$00
			BNE ++
				LDA #$86	; Left edge of the platform
				BRA Draw
				
		++
			LDA #$87		; middle of the platform
			
		Draw:
			STA $02			; store which tile here
				
			TXA				; x times 16 = tile x-disp
			ASL				
			ASL
			ASL
			ASL
			
			CLC
			ADC $00
			STA $0300|!Base2,y	; X disp
			
			LDA $01
			STA $0301|!Base2,y	; Y Disp
			
			LDA $02
			STA $0302|!Base2,y	; Tile
			
			LDA $03
			STA $0303|!Base2,y	; Props
			
			INY
			INY
			INY
			INY
			BRA -
			
	+	
		LDX $15E9|!addr
FinishGFX:
		LDA $04
		LDY #$02
		%FinishOAMWrite()
		
		RTS
