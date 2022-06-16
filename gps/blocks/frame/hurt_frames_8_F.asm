
print "Hurts Mario on ExAnimation frames 08-0F"

!Gl = $00		; $00 if it should be based on level exAnim, and $20 if it should be based on global exAnim
!Slot = $0F		; exAnimation slot the code should be based on

!Min = $08		; First frame the code should run on

incsrc FramalMacros.asm

db $42

JMP M : JMP M : JMP M : JMP R : JMP R : JMP R : JMP R
JMP M : JMP M : JMP M

tbl:
	db $02,$0D

%LoadSlot1_7()	;\
CMP #!Min		;| Check if it is a correct frame
BCC R			;/
LDY $93
LDA $94
AND #$0F
CMP tbl,y
BEQ R


JSL $00F5B7|!bank	; If yes, hurt the player

R:
RTL
