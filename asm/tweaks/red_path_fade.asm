; This patch removes the red path transition's opening/closing animation
; and replaces it with a brightness fadeout/fadein.
; Useful for example to avoid HDMA effects from being turned off by the animation
; (or looking weird while the transition is happening).

if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
else
    lorom
    !addr = $0000
endif

; Prevent red path transition from disabling HDMA.
org $049625
    bra $01

; Tables for brightness fadein/fadeout.
org $04DB14
delta:
    db $FF,$01
limits:
    db $00,$0F

org $04DB18
    ; Update the brightness.
    ldx $1B8C|!addr
    lda $0DAE|!addr : clc : adc.w delta,x : sta $0DAE|!addr

    ; If not at the end, return.
    and #$0F : cmp.w limits,x : bne +

    ; Otherwise, switch to the opposite direction.
    txa : eor #$01 : sta $1B8C|!addr

    ; Increase the red path state.
    inc $1DE8|!addr

    ; Update Mario's position.
    rep #$20
    jsr $9A93
    sep #$20
+   rts

warnpc $04DB9D
