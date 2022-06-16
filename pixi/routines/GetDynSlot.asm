;; 16-bit X holds the location where you have the gfx inserted, for instance:
;;	REP #$10
;;	LDX.w #GFX
;;	%GetDynSlot()
;;	BCC .NoGFX
;;	STA $0E
;; ....
;;
;; GFX:
;; incbin DynamicGFX.bin

!Temp = $09
!Timers = $0B

!SlotPointer = $0660|!Base2			;16bit pointer for source GFX
!SlotBank = $0662|!Base2			;bank
!SlotDestination = $0663|!Base2			;VRAM address
!SlotsUsed = $06FE|!Base2			;how many slots have been used

!MAXSLOTS = $04			;maximum selected slots
	STX $8A
	LDX $15E9|!addr
	SEP #$10
	PHY		;preserve OAM index
	PHA		;preserve frame
	LDA !SlotsUsed	;test if slotsused == maximum allowed
	CMP #!MAXSLOTS
	BNE +
		
	PLA
	PLY
	LDA #$00	;zero on no free slots
	RTL

+	PLA		;pop frame
	REP #$20	;16bit A
	AND.w #$00FF	;wipe high
	XBA		;<< 8
	LSR A		;>> 1 = << 7
	STA !Temp	;back to scratch
	LDA $8A		;Get 16bit address
	CLC
	ADC !Temp	;add frame offset	
	STA !SlotPointer	;store to pointer to be used at transfer time
	SEP #$20	;8bit store
	PHB : PLA
	STA !SlotBank	;store bank to 24bit pointer

	PHX		;This is how I made your boi a routine
	LDX !SlotsUsed		;calculate VRAM address + tile number
	LDA.L .SlotsTable,X	;get tile# in VRAM
	PLX
	PHA		;preserve for eventual pull
	SEC
	SBC #$C0	;staRTL at C0h, they start at C0 in tilemap
	REP #$20	;16bit math
	AND.w #$00FF	;wipe high byte
	ASL A		;multiply by 32, since 32 bytes/16 words equates to 1 32bytes tile
	ASL A
	ASL A
	ASL A
	ASL A
if !SA1 == 1
	CLC : ADC #$8000	;add 8000, base address of buffer
else
	CLC : ADC.w #!dynamic_buffer
endif
	STA !SlotDestination	;destination address in the buffer
	SEP #$20
	STZ !Timers
	
;;;;;;;;;;;;;;;;
;Transfer routine
;;;;;;;;;;;;;;;;

;DMA ROM -> RAM ROUTINE

if !SA1 == 1
;set destination RAM address
	REP #$20
	LDY #$C4
	STY $2230
	LDA.w !SlotDestination
	STA $2235	;16bit RAM dest
	        
	         	;set 7F as bank

;common DMA settings
	         	;1 reg only
	        	;to 2180, RAM write/read
	         

;first line
	LDA !SlotPointer
	STA $2232	;low 16bits
	LDY !SlotBank
	STY $2234	;bank
	LDY #$80	;128 bytes
	STZ $2238
	STY $2238
	LDY #$41
	STY $2237
	
	LDY $318C
	BEQ $FB
	LDY #$00
	STY $318C
	STY $2230	;transfer

;lines afterwards
-	LDY #$C4
	STY $2230
	LDA.w !SlotDestination	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SlotDestination	;updated base
	STA $2235	;updated RAM address

	LDA !SlotPointer	;update source address
	CLC
	ADC #$0200	;512 bytes, next row
	STA !SlotPointer
	STA $2232	;low 16bits
	LDY !SlotBank
	STY $2234	;bank
	LDY #$80
	STZ $2238
	STY $2238
	LDY #$41
	STY $2237
	
	LDY $318C
	BEQ $FB
	LDY #$00
	STY $318C
	STY $2230	;transfer
	LDY !Timers
	CPY #$02
	BEQ +
	INC !Timers
	BRA -
+
else
;common DMA settings
	REP #$20
	STZ $4300	;1 reg only
	LDY #$80	;to 2180, RAM write/read
	STY $4301
	
;set destination RAM address
	LDA !SlotDestination
	STA $2181	;16bit RAM dest
	LDY #$7F
	STY $2183	;set 7F as bank

	LDA !SlotPointer
	STA $4302	;low 16bits
	LDY !SlotBank
	STY $4304	;bank
	LDY #$80	;128 bytes
	STY $4305
	LDY #$01
	STY $420B	;transfer

;second line
-	LDA !SlotDestination	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SlotDestination	;updated base
	STA $2181	;updated RAM address

	LDA !SlotPointer	;update source address
	CLC
	ADC #$0200	;512 bytes, next row
	STA !SlotPointer
	STA $4302	;low 16bits
	LDY !SlotBank
	STY $4304	;bank
	LDY #$80
	STY $4305
	LDY #$01
	STY $420B	;transfer
	LDY !Timers
	CPY #$02
	BEQ +
	INC !Timers
	BRA -
+
endif
	
	SEP #$20	;8bit A	
	INC !SlotsUsed	;one extra slot has been used

	PLA		;return starting tile number
	PLY
	RTL

.SlotsTable			;avaliable slots.  Any more transfers and it's overflowing by a dangerous amount.
	db $CC,$C8,$C4,$C0			
