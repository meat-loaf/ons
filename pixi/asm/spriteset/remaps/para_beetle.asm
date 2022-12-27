;..this is actually a custom sprite.
includefrom "remaps.asm"

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

!parabeetle_sprnum = $12
!parabeetle_tile_off_loc = $09

%alloc_spr(!parabeetle_sprnum, parabeetle_init, parabeetle_main, \
	$10, $95, $11, $B9, $90, $01)

;org spr_tweaker_1656_tbl+!parabeetle_sprnum
;	db $10
;org spr_tweaker_1662_tbl+!parabeetle_sprnum
;	db $95
;org spr_tweaker_166E_tbl+!parabeetle_sprnum
;	db $11
;org spr_tweaker_167A_tbl+!parabeetle_sprnum
;	db $B9
;org spr_tweaker_1686_tbl+!parabeetle_sprnum
;	db $90
;org spr_tweaker_190F_tbl+!parabeetle_sprnum
;	db $01

org ($019C7F+!parabeetle_sprnum)|!bank
	db !parabeetle_tile_off_loc
org ($019B83+!parabeetle_tile_off_loc)|!bank
	db $08,$0A

!pal_index      = !151C
!ani_timer      = !1570
!facing_dir     = !157C
!ani_frame      = !1602
!fast_ani_speed = !160E

;%replace_wide_pointer($0181A1|!bank,parabeetle_init|!bank)
;%replace_wide_pointer($0185F0|!bank,parabeetle_main|!bank)

org !bank1_thwomp_free|!bank
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
	RTS

.FaceAway
	LDA !facing_dir,x
	EOR #$01
	STA !facing_dir,x
	RTS

parabeetle_main:
	JSR.w sub_spr_gfx_2
	LDA !sprites_locked
	BNE .done
	LDA !sprite_status,x
	CMP #$08
	BCS .cont
; TODO? figure out how to do this in vanilla if needed
.dead:
	LDA #$80
	ORA !sprite_oam_properties,x
	STA !sprite_oam_properties,x
.done:
	RTS
.cont:
	JSR.w _suboffscr2_bank1

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
	LDY !sprite_speed_y,x
	BEQ .speed_update
	BMI .YSpeed000
	DEC : DEC
.YSpeed000:
	CLC
	ADC !sprite_speed_y,x
	STA !sprite_speed_y,x
.speed_update
	JSR.w _spr_upd_y_no_grav
	JSR.w _spr_upd_x_no_grav
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
	
	JSR.w _sprspr_mario_spr_rt
	BCC Return2
Continue:
	JSR.w _spr_invis_solid_rt
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
	RTS
.SpriteWins
	LDA !154C,x
	BNE Return2
	JSL $00F5B7|!bank
Return2:
	LDA !154C,x
	BNE .ret
	STZ !fast_ani_speed,x
.ret:
	RTS
nop
parabeetle_done:
warnpc !bank1_thwomp_end
!bank1_thwomp_free = parabeetle_done|!bank
