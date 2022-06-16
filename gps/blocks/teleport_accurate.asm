db $42
JMP main : JMP main : JMP main
JMP return : JMP return : JMP return : JMP return
JMP main : JMP main : JMP main

print "Teleports the player based on block position."

main:

PHY

LDA $5B
LSR
BCC .horz

LDX $99
LDY $97

BRA .setup
.horz
LDX $9B
LDY $95

.setup
LDA $19B8,x
STA $19B8,y

LDA $19D8,x
STA $19D8,y

LDA #$06
STA $71
STZ $89
STZ $88

PLY

return:
RTL
