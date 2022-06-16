; The extra bit determines whether the spawned sprite will have its extra byte activated or not.

!Sprite = $23

; 0 means no, 1 means yes
!IsCustom = 1
!ShootIfNear = CLC ; This time, CLC means yes and SEC means no

print "INIT ",pc
print "MAIN ",pc
PHB : PHK : PLB
	JSR Shooter
PLB
RTL

Return:
RTS

Shooter:
	LDA #$64 : !ShootIfNear	; Set the timer and don't ignore Mario
	%ShooterMain_HorzOffscreen()
	BCS Return

	LDA #$00
	STA $0F
	LDA $1783|!Base2,x
	AND #$40
	BEQ +
	LDA #$04
	STA $0F
+	PHX
	TYX
if !IsCustom
	LDA #!Sprite
	STA !7FAB9E,x
	JSL $07F7D2|!BankB
	JSL $0187A7|!BankB
	LDA #$88
	ORA $0F
	STA !7FAB10,x
	STZ !C2,x
else
	LDA #!Sprite
	STA !9E,x
	JSL $07F7D2|!BankB
	LDA $0F
	STA !7FAB10,x
endif
	PLX

	LDA $178B|!Base2,x
	SEC : SBC #$01
	STA.w !D8,y
	LDA $1793|!Base2,x
	SBC #$00
	STA !14D4,y
	LDA $179B|!Base2,x
	STA.w !E4,y
	LDA $17A3|!Base2,x
	STA !14E0,y

	LDA #$01
	STA !14C8,y

	RTS

