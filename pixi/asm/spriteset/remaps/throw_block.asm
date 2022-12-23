includefrom "remaps.asm"

%replace_wide_pointer($018223|!bank,throw_block_init|!bank)

!throw_block_timer = !1540

org $0196C7|!bank
	JMP.w throw_block_check_respawn
warnpc $0196CA|!bank


org !bank1_koopakids_free
throw_block_check_respawn:
	LDA !spr_extra_bits,x
	AND #$04
	BNE .no_respawn
	LDY !sprite_index_in_level,x
	STA !sprite_load_table,y
.no_respawn:
	JMP.w $019ACB|!bank
.done:
warnpc !bank1_koopakids_end
!bank1_koopakids_free = throw_block_check_respawn_done


org !bank1_thwomp_free
throw_block_init:
	LDA #$09
	STA !sprite_status,x
	LDA #$FF
	STA !throw_block_timer,x
	RTS
.done:
!bank1_thwomp_free = throw_block_init_done
warnpc !bank1_thwomp_end
