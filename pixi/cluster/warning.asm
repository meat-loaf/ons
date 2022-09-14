print "MAIN ", hex(cls_warning_main)

!timer = $0F4A|!addr
!cls_spr_num = $1892|!addr

!tile_num = $20

cls_warning_main:
	LDA !timer,x
	DEC
	BNE .cont
	STZ !cls_spr_num,x
	RTL
.cont:
	STA !timer,x
	STA $18B8|!addr
	LSR
	BCC .no_gfx
	%ClusGetDrawInfo()
	LDA $00
	STA $0200|!addr,y
	LDA $01
	STA $0201|!addr,y
	LDA #!tile_num
	STA $0202|!addr,y
	LDA #$01
	STA $0203|!addr,y
	%ClusFinishOAM()
.no_gfx:
	RTL



