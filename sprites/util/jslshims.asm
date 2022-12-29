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
org $019ABB|!bank
	rtl

; spinkill
org $019AD5|!bank
	rts

; dying (not smoke)
org $019AE3
	rtl

; spr smushed state
org $019AF0|!bank
	rtl
org $019B0F|!bank
	rtl
org $01E75A|!bank
	rtl

%set_free_start("bank6")
spr_spinkill_shim:
	pea !bank01_jsl2rts_rtl
	jml spr_spinkill
.done
%set_free_finish("bank6", spr_spinkill_shim_done)
