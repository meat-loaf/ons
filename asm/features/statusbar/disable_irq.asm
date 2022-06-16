includefrom "status.asm"
pushpc
; this is pretty much just kevin's patch. thanks kevin for making a sane patch

org $0081F4
	NOP #3         ; subroutine call to DrawStatusBar
org $0082E8
	NOP #3         ; subroutine call to DrawStatusBar

; i think this should be able to be done inline, but i fucked up
; the overworld when i tried it
org $008294
	jml check_flag_2


; disable bg3 dma to vram
org $00A5A8
	NOP #3

pullpc
check_flag_2:
	; Always enable the IRQ in mode 7 boss rooms.
	LDA $0D9B|!addr
	BMI .enable
	LDA #$81 : sta $4200
	LDA $22 : sta $2111
	LDA $23 : sta $2111
	LDA $24 : sta $2112
	LDA $25 : sta $2112
	LDA $3E : sta $2105
	LDA $40 : sta $2131
	JML $0082B0|!bank
.enable:
	LDA $4211
	STY $4209
	JML $00829A|!bank
