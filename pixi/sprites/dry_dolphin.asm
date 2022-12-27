print "INIT ", hex(dry_dolphin_init)
print "MAIN ", hex(dry_dolphin_main)

!state         = !C2
!crumble_timer = !154C

!origin_x_lo   = !1504
!origin_x_hi   = !1510

!die_sfx_id    = $07
!die_sfx_port  = $1DF9|!addr

spr_update_x_no_grav = $018022|!bank
spr_update_y_no_grav = $01801A|!bank
spr_obj_interact     = $019138|!bank
spr_mario_interact   = $01A7DC|!bank
spr_pos_update_main  = $01802A|!bank
displ_contact_p      = $01AB99|!bank
mario_bounce         = $01AA33|!bank
;finish_oam_write     = $01B7B3|!bank


dry_dolphin_init:
	INC !state,x

	LDA !sprite_x_low,x
	STA !origin_x_lo,x
	LDA !sprite_x_high,x
	STA !origin_x_hi,x
	RTL

dry_dolphin_main:
	PHB
	PHK
	PLB
	JSR dry_dolphin_main_rt
	PLB
	RTL

dry_dolphin_main_rt:
	JSR dry_dolphin_gfx
	LDA !14C8,x
	EOR #$08
	ORA $9D
	BNE .done
	JSL spr_mario_interact
	LDA !state,x
	BCC .no_interact
	CMP #$02
	BCS .no_interact
	LDA $1490|!bank
	BEQ .no_star
	LDA #$02
	STA !14C8,x
	%SubHorzPos()
	LDA #$D0
	STA !AA,x
	LDA .star_die_x_speeds,y
	STA !B6,x
	RTS
.no_star:
	LDA $D3
	CLC
	ADC #$14
	CMP !sprite_y_low,x
	BPL .dolphin_wins
	LDA $7D
	BMI .dolphin_wins
;	JSR CODE_01AB46 // give points based on stomp counter
	LDA #!die_sfx_id
	STA !die_sfx_port

	JSL displ_contact_p
	JSL mario_bounce
	STZ !sprite_speed_x,x
	STZ !sprite_speed_y,x
	DEC !crumble_timer,x
	LDA #$02
	STA !state,x
	BRA .no_interact
.dolphin_wins:
	JSL hurt_mario
.do_behavior
	LDA !state,x
.no_interact:
	ASL
	TAX
	JSR (.behaviors,x)
.done:
	RTS
.behaviors
	dw return_to_origin
	dw jumping
	dw oh_god_hes_fucking_dead
	dw God_bless_for_He_has_risen
.star_die_x_speeds:
	db $F0, $10
.behavior_bounce_x_spd:


return_to_origin:
	LDX $15E9|!addr
	RTS
jumping:
	LDX $15E9|!addr
	RTS
oh_god_hes_fucking_dead:
	LDX $15E9|!addr
	JSL spr_pos_update_main
	LDA !sprite_in_water,x
	BEQ .not_yet_doused
	LDA #$E0
	STA !sprite_speed_y,x
.not_yet_doused:
	LDA !crumble_timer,x
	BNE .still_dead
	INC !state,x
.still_dead:
	RTS
God_bless_for_He_has_risen:
	LDX $15E9|!addr
	STZ !state,x
	RTS

dry_dolphin_gfx:
	%GetDrawInfo()
	LDA !B6,x
	AND #$80
	EOR #$80
	LSR
	STA $02
	TAX
	BEQ .noflip
	LDX #$03
.noflip:
	LDA $00
	CLC
	ADC .horz_dolphin_xpos_off_table,x
	STA $0300|!addr,y
	CLC
	ADC .horz_dolphin_xpos_off_table+1,x
	STA $0304|!addr,y
	CLC
	ADC .horz_dolphin_xpos_off_table+2,x
	STA $0308|!addr,y
	LDA $14
	AND #$08
	LSR #3
	TAX
	LDA .dolphin_head_tiles,x
	STA $0302|!addr,y
	LDA .dolphin_body_tiles,x
	STA $0306|!addr,y
	LDA .dolphin_tail_tiles,x
	STA $030A|!addr,y
	LDX $15E9|!addr
	LDA !15F6,x
	ORA $64
	ORA $02
	STA $0303|!addr,y
	STA $0307|!addr,y
	STA $030B|!addr,y
	; tile y pos
	LDA $01
	STA $0301|!addr,y
	STA $0305|!addr,y
	STA $0309|!addr,y
	LDY #$02
	LDA #$02
	JSL finish_oam_write|!bank
	RTS
.dolphin_head_tiles:
	db $05,$00
.dolphin_body_tiles:
	db $07,$02
.dolphin_tail_tiles:
	db $08,$03
.horz_dolphin_xpos_off_table:
	db $00,$10,$08
	db $18,$F0,$F8

