;==========
;The rock which Gulpit spits out.
;==========

!Tile = $E4             ; The sprite tile to use for the rock.

print "INIT ", pc
    %SubHorzPos()
    TYA
    STA !157C,x
    RTL

Return:
    RTS

print "MAIN ", pc
    PHB : PHK : PLB
    LDA !1626,x
    BEQ +
        DEC !1626,x
+   JSR Run
    PLB
    RTL

Run:
    LDA !1626,x
    CMP #$42
    BCC Skip
    CMP #$D0
    BCS Skip
    STZ !14C8,x
Skip:
    LDA #$00
    %SubOffScreen()
    JSR Graphics

    LDA !extra_bits,x
    AND #$04
    STA !1504,x

    LDA !14C8,x                 ; If the sprite is dead..
    CMP #$08
    BNE Return                  ; ..return
    LDA $9D
    BNE Return                  ; Also return if sprites are locked.

    JSL $01A7DC|!BankB

    LDA !1588,x
    AND #$03
    BEQ +
        JSR DrawSmoke           ; It disappears when it touches a wall.
        STZ !14C8,x
+   STZ !AA,x
    LDA !1504,x
    BEQ DontMove
    LDY !157C,x
    LDA Speeds,y
    STA !B6,x
    JSL $01802A|!BankB
DontMove:
    RTS

Speeds:
    db $30,$D0

; Sprite Routines
; Graphics

Properties:
    db $7D,$3D

Graphics:
    %GetDrawInfo()
    LDA !157C,x
    STA $02
    LDA $00
    STA $0300|!Base2,y
    LDA $01
    STA $0301|!Base2,y
    LDA.b #!Tile
    STA $0302|!Base2,y
    PHX
    LDX $02
    LDA Properties,x
    ORA $64
    STA $0303|!Base2,y
    PLX
    INY #4
    LDY #$02
    LDA #$00
    JSL $01B7B3|!BankB
    RTS

DrawSmoke:
    LDY #$03
-   LDA $17C0|!Base2,y
    BEQ +
    DEY
    BPL -
    RTS

+   LDA #$01
    STA $17C0|!Base2,y
    LDA #$1C
    STA $17CC|!Base2,y
    LDA !D8,x
    STA $17C4|!Base2,y
    LDA !E4,x
    STA $17C8|!Base2,y
    RTS
