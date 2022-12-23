includefrom "remaps.asm"

!falling_spike_tile = $0E
!falling_spike_sprnum = $34

org spr_tweaker_1656_tbl+!falling_spike_sprnum
	db $00
org spr_tweaker_1662_tbl+!falling_spike_sprnum
	db $00
org spr_tweaker_166E_tbl+!falling_spike_sprnum
	db $31
org spr_tweaker_167A_tbl+!falling_spike_sprnum
	db $00
org spr_tweaker_1686_tbl+!falling_spike_sprnum
	db $1D
org spr_tweaker_190F_tbl+!falling_spike_sprnum
	db $00

; sprite tilemap
org $019B83+read1(($019C7F|!bank)+!falling_spike_sprnum)
	db !falling_spike_tile

; moved to bank 1, replaces part of boss fireball code
org !bank1_bossfire_free
falling_spike_main:
	JSR.w sub_spr_gfx_2
	LDY.w !sprite_oam_index,x
	LDA.w $0301|!addr,y
	DEC
	STA.w $0301|!addr,y
	LDA.w !1540,x
	BEQ.b .no_shuffle
	; clear carry for free
	AND.b #$04
	LSR   #2
	ADC.w $0300|!addr,y
	STA.w $0300|!addr,y
.no_shuffle:
	LDA.b !sprites_locked
	BNE .fin
	; suboffscreen 0 - bank 1
	JSR.w $01AC31|!bank
	; update sprite pos
	JSR.w $019032|!bank
	LDA   !C2,x
	BNE.b .wait_fall
.shake:
	STZ   !sprite_speed_y,x
	; sub horiz pos
	JSR.w $01AD30|!bank
	LDA.b $0F
	CLC
	ADC.b #$40
	CMP.b #$80
	BCS.b .notyet
	INC   !C2,x
	LDA.b #$40
	STA.w !1540,x
.notyet:
	RTS
	
.wait_fall:
	LDA.w !1540,x
	BNE.b .fin
	JMP.w $01A7E4|!bank
.fin:
	STZ !sprite_speed_y,x
	RTS
.done:
warnpc !bank1_bossfire_end
!bank1_bossfire_free = falling_spike_main_done
