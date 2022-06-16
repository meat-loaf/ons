
;Input:  A   = type of speed update
;              0 ... x+y with gravity
;              1 ... x+y without gravity
;              2 ... x only
;              3 ... y only

   BEQ .SpriteSpd
   DEC : BEQ .SpriteSpdNoGravity
   DEC : BEQ .SpriteXSpd
   DEC : BEQ .SpriteYSpd
   RTL

;; sprite x + y speed handler; has gravity.
.SpriteSpd
	LDA $1E52|!addr,x
	CMP #$40
	BPL .SpriteSpdNoGravity
	CLC
	ADC #$03
	STA $1E52|!addr,x

;; sprite x + y speed handler; no gravity.
.SpriteSpdNoGravity
	JSL .SpriteYSpd

;; original sprite x speed handler.
.SpriteXSpd
	PHK
	PEA.w ..donex-1
	PEA.w $B889-1        ;RTS in bank 02
	JML $02FFA3|!BankB
..donex	RTL

;; original sprite y speed handler.
.SpriteYSpd
	PHK
	PEA.w ..doney-1
	PEA.w $B889-1        ;RTS in bank 02
	JML $02FF98|!BankB
..doney	RTL
