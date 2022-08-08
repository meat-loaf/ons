;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Para-Beetle, by Romi, modified by imamelia
;
; This is a sprite from SMB3, a Buzzy Beetle that flies through the air and can
; carry the player.
;
; Extra byte 1:
; --dd-ppp
; -: unused
; ppp: palette/speed index
; dd: direction:
;   00: face player
;   01: face left
;   10: face right
;   11: face away from player
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ", hex(parabeetle_init)
print "MAIN ", hex(parabeetle_main)

!custom_parabeetle_acts_like    = $12
!custom_parabeetle_tile_off_loc = $09

pushpc
org shared_spr_routines_tile_offset(!custom_parabeetle_acts_like)
	db !custom_parabeetle_tile_off_loc
org $019B83+!custom_parabeetle_tile_off_loc
	db $08,$0A
pullpc

!pal_index      = !151C
!ani_timer      = !1570
!facing_dir     = !157C
!ani_frame      = !1602
!fast_ani_speed = !160E

x_speed:
	db $0C,$0C,$06,$1A,$0C,$14,$0C,$0C        ; normal speeds. order is sequential with the palette (first = palette 8, last = palette F)

parabeetle_init:
	LDA !extra_byte_1,x
	AND #$07
	STA !pal_index,x     ; pal_index = palette index for speeds
	ASL
	STA $01
	
	LDA !sprite_oam_properties,x
	AND #$F1
	ORA $01
	STA !sprite_oam_properties,x

.Direction
	LDA $94
	CMP !E4,x
	LDA $95
	SBC !14E0,x
	BPL .EndInit
	INC !facing_dir,x
.EndInit
	LDA !extra_byte_1,x
	AND #$30
	BEQ .Return
	CMP #$30
	BEQ .FaceAway
	LSR #4
	DEC
	EOR #$01
	STA !facing_dir,x
.Return
	RTL

.FaceAway
	LDA !facing_dir,x
	EOR #$01
	STA !facing_dir,x
	RTL

parabeetle_main:
	JSL.l sub_spr_gfx_2_long|!bank
	LDA !14C8,x
	CMP #$08
	BCC .dead
	LDA $9D
	BEQ .cont
.dead:
	LDA #$80
	ORA !sprite_oam_properties,x
	STA !sprite_oam_properties,x
.done:
	RTL
.cont:
	PHB
	PHK
	PLB

	LDA #$03
	%SubOffScreen()

	INC !ani_timer,x
	LDA !ani_timer,x
	LSR #2
	LDY !fast_ani_speed,x
	BNE .fastor_ani
	LSR
.fastor_ani:
	AND #$01
	STA !ani_frame,x
	LDY !pal_index,x
	LDA x_speed,y
	LDY !facing_dir,x
	BEQ .no_invert_speed
	EOR #$FF
	INC
.no_invert_speed:
	STA !B6,x
	LDA !fast_ani_speed,x
	BNE .speed_update
	LDA #$01
	LDY !AA,x
	BEQ .speed_update
	BMI .YSpeed000
	DEC : DEC
.YSpeed000:
	CLC
	ADC !AA,x
	STA !AA,x
.speed_update
	JSL $01801A|!BankB
	JSL $018022|!BankB
	LDA $1491|!Base2
	STA !1528,x
	LDY #$B9
	LDA $1490|!Base2
	BEQ .no_default_interact
	LDY #$39
.no_default_interact:
	TYA
	STA !167A,x
	LDA !15D0,x
	BNE Return2_ret
	
	JSL $01803A|!BankB
	BCC Return2
Continue:
	JSL $01B44F|!bank
	BCC .SpriteWins
	LDA !fast_ani_speed,x
	BNE .PlayerWins000
	LDA #$01
	STA !fast_ani_speed,x
	LDA #$10
	STA !AA,x
.PlayerWins000
	LDA #$08
	STA !154C,x
	LDA !AA,x
	DEC
	CMP #$F0
	BMI .Return
	STA !AA,x
.Return
	PLB
	RTL
.SpriteWins
	LDA !154C,x
	BNE Return2
	JSL $00F5B7|!bank
Return2:
	LDA !154C,x
	BNE .ret
	STZ !fast_ani_speed,x
.ret:
	PLB
	RTL
