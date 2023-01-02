; (temporary?) jsl shims for original code
; sprite level end -> jsl to jml
org $01816D|!bank
	db !JML_OPCODE

org $019A7A|!bank
	rtl

; sprite killed
; main call when sprite is wiggler - repoint to new main caller
org $019AA8|!bank
	jml spr_handle_main
; throw block handling
;org $019ABB|!bank
;	rtl
;
;; spinkill
;org $019AD5|!bank
;	rts
;
;; dying (not smoke)
;org $019AE3
;	rtl
;
;; spr smushed state
;org $019AF0|!bank
;	rtl
;org $019B0F|!bank
;	rtl
;org $01E75A|!bank
;	rtl

%set_free_start("bank1_bossfire")
spr_spinkill_shim:
	%jsl2rts(!bank01_jsl2rts_rtl, spr_spinkill)
spr_lavadie_shim:
	%jsl2rts(!bank01_jsl2rts_rtl, spr_lavadie)
spr_smushed_shim:
	%jsl2rts(!bank01_jsl2rts_rtl, spr_smushed)
spr_killed_shim:
	%jsl2rts(!bank01_jsl2rts_rtl, spr_killed)
spr_state_shims_end:
%set_free_finish("bank1_bossfire", spr_state_shims_end)
