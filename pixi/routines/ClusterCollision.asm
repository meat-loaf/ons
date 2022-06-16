;; cluster sprite collision
;; input:
;;   A:
;;     Bits 0-4 (x00-x1F): Clipping (pulled from tables at bottom of .asm file)
;;     Bit  5   (x20):     Account for cape collision.
;;     Bit  6   (x40):     Not used.
;;     Bit  7   (x80):     Use custom clipping (write to $04/$05 for X/Y low offset, $0A/$0B for X/Y high offset, $06/$07 for width/height).
;;   $04: X-low offset
;;   $05: Y-low offset
;;   $06: width
;;   $07: height
;;   $0A: X-high
;;   $0B: Y-high
;; output:
;;  Carry Set: Collision has been made.
;;    A:
;;      x00 - Collision with Mario.
;;      x01 - Collision with Mario's cape.
;;  Carry Clear: No collision.
;; clobbers:
;; Y, $00-$0D, $0F
.main
	STA $8A
	PHB
	PHK
	PLB
	LDA $8A
	AND #$80
	BNE ..SkipClipping
	LDA $8A
	AND #$1F
	TAY
	STZ $0F
	LDA ..ClippingX,y
	BPL ?+
	DEC $0F
?+	CLC
	ADC !cluster_x_low,x
	STA $04
	LDA $0F
	LDA #$00
	ADC !cluster_x_high,x
	STA $0A
	LDA ..ClippingW,y
	STA $06
	STZ $0F
	LDA ..ClippingY,y
	BPL ?+
	DEC $0F
?+	CLC
	ADC !cluster_y_low,x
	STA $05
	LDA $0F
	ADC !cluster_y_high,x
	STA $0B
	LDA ..ClippingH,y
	STA $07
..SkipClipping
	LDA $8A
	AND #$20
	BEQ ?+
	LDA $13E8|!addr
	BEQ ?+

; set cape interaction: ripped from $029696
	LDA.W $13E9|!addr
	SEC
	SBC.B #$02
	STA.B $00
	LDA.W $13EA|!addr
	SBC.B #$00
	STA.B $08
	LDA.B #$14
	STA.B $02
	LDA.W $13EB|!addr
	STA.B $01
	LDA.W $13EC|!addr
	STA.B $09
	LDA.B #$10
	STA.B $03

	JSL $03B72B|!bank
	BCC ?+
	PLB
	LDA #$01
	RTL

?+	JSL $03B664|!bank
	JSL $03B72B|!bank
	BCC ..Return
	PLB
	LDA #$00
	RTL
..Return
	PLB
	CLC
	RTL

..ClippingX
	db $04,$02,$03
..ClippingY
	db $04,$02,$03
..ClippingW
	db $08,$0C,$01
..ClippingH
	db $08,$0C,$04
