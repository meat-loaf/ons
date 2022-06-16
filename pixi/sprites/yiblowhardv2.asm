;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Island BlowHard Plant (v2.2)
; Programmed by SMWEdit
;
; Uses first extra bit: YES
; It will be upside-down if the first extra bit is set
;
; You will need to patch SMKDan's dsx.asm to your ROM with asar
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

prot BlowHardGFX

;; Variables:
        !SPRITE_NUM = $24               ; custom sprite of needlenose bullet bomb
        !TARGETSND = $23                ; sound when ready to spit, played continuously
        !TARGETSNDPORT = $1DFC|!Base2   ; RAM adress the spit sound effect will be stored to ($1DFC or $1DF9)
        !SHOOTSND = $10                 ; sound after needlenose fired
        !SHOOTSNDPORT = $1DFC|!Base2    ; RAM adress the shoot sound effect will be stored to ($1DFC or $1DF9)
        !KNOCKOUTSND = $37              ; sound when you hit it with a shell
        !KNOCKOUTSNDPORT = $1DFC|!Base2 ; RAM adress the KO sound effect will be stored to ($1DFC or $1DF9)

;; Sprite Tables:
        !ACTSTATUS = !C2                ; 0 = normal, 1 = targeting, 2 = hit, 3 = moving to be knocked out, 4 = head deflating, 5 = knocked out, 6 = waking up
        !OFFSET = !1504
        !YDISP = !1528
        !XDISP = !1534
        !XFLIP = !157C
        !FRAME = !1570
        !FBANK = !1602
        !LASTACTSTATUS = !151C
        !TIMER = !163E
        !LOCKTIMER = !1540
        !EXTRA_BITS = !7FAB10

;; Scratch RAM:
        !EXTRA_BIT = $59

;; Routines:
        !PHYSICS = $01802A|!BankB
        !SPRSPRINTERACT = $018032|!BankB
        !MARIOSPRINTERACT = $01A7DC|!BankB
        !FINISHOAMWRITE = $01B7B3|!BankB
        !GETSPRITECLIPPINGA = $03B69F|!BankB
        !GETSPRITECLIPPINGB = $03B6E5|!BankB
        !CHECKFORCONTACT = $03B72B|!BankB
        !SPINJUMPSTARS = $07FC3B|!BankB

;; Dynamic routine defines:
        !Temp = $09
        !Timers = $0B

        !SlotPointer = $0660|!Base2                     ;16bit pointer for source GFX
        !SlotBank = $0662|!Base2                        ;bank
        !SlotDestination = $0663|!Base2                 ;VRAM address
        !SlotsUsed = $06FE|!Base2                       ;how many slots have been used

        !MAXSLOTS = $04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INIT_OFFSET:    db $0F,$2E
FLIP_YPOS_LO:   db $00,$FE
FLIP_YPOS_HI:   db $00,$FF

		PRINT "INIT ",pc
		PHB
		PHK
		PLB
		%SubHorzPos()           ; \  set
		LDA INIT_OFFSET,y       ;  | initial
		STA !OFFSET,x           ; /  rotation
		TAY                     ; \
		LDA YCOORDS,y           ;  | set GFX
		STA !YDISP,x            ;  | information
		LDA XCOORDS,y           ;  | based on
		STA !XDISP,x            ;  | initial
		LDA XDIRECTION,y        ;  | offset
		STA !XFLIP,x            ;  |
		LDA FRAMES,y            ;  |
		STA !FRAME,x            ;  |
		LDA FBANKS,y            ;  |
		STA !FBANK,x            ; /
		LDA #$60                ; \ set initial (shorter)
		STA !TIMER,x            ; / timer for shooting
		LDA !EXTRA_BITS,x       ; \
		LSR A                   ;  | set initial
		LSR A                   ;  | Y position
		AND #%00000001          ;  | depending
		TAY                     ;  | on extra
		LDA FLIP_YPOS_LO,y      ;  | bit
		CLC                     ;  |
		ADC !D8,x               ;  |
		STA !D8,x               ;  |
		LDA FLIP_YPOS_HI,y      ;  |
		ADC !14D4,x             ;  |
		STA !14D4,x             ; /
		PLB
		RTL

		PRINT "MAIN ",pc                        
		PHB
		PHK                     
		PLB
		JSR SPRITE_ROUTINE
		PLB
		RTL     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XCOORDS:        db $00,$01,$02,$02
		db $03,$04,$05,$05
		db $06,$06,$07,$07
		db $08,$08,$08,$08
		db $08,$08,$08,$07
		db $07,$06,$06,$05
		db $05,$04,$03,$02
		db $02,$01,$00
		db $00,$FF,$FE,$FE
		db $FD,$FC,$FB,$FB
		db $FA,$FA,$F9,$F9
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F9
		db $F9,$FA,$FA,$FB
		db $FB,$FC,$FD,$FE
		db $FE,$FF,$00

YCOORDS:        db $ED,$ED,$ED,$ED
		db $EE,$EE,$EE,$EF
		db $EF,$F0,$F1,$F1
		db $F2,$F3,$F3,$F4
		db $F5,$F5,$F6,$F7
		db $F8,$F8,$F9,$F9
		db $FA,$FA,$FA,$FB
		db $FB,$FB,$FB
		db $FB,$FB,$FB,$FB
		db $FA,$FA,$FA,$F9
		db $F9,$F8,$F8,$F7
		db $F6,$F5,$F5,$F4
		db $F3,$F3,$F2,$F1
		db $F1,$F0,$EF,$EF
		db $EE,$EE,$EE,$ED
		db $ED,$ED,$ED

XCOORDS2:       db $00,$01,$02,$03
		db $04,$05,$06,$07
		db $08,$09,$0A,$0A
		db $0A,$0B,$0B,$0B
		db $0B,$0B,$0A,$0A
		db $0A,$09,$08,$07
		db $06,$05,$04,$03
		db $02,$01,$00
		db $00,$FF,$FE,$FD
		db $FC,$FB,$FA,$F9
		db $F8,$F7,$F6,$F6
		db $F6,$F5,$F5,$F5
		db $F5,$F5,$F6,$F6
		db $F6,$F7,$F8,$F9
		db $FA,$FB,$FC,$FD
		db $FE,$FF,$00

YCOORDS2:       db $EA,$EA,$EA,$EA
		db $EA,$EB,$EC,$EC
		db $ED,$EE,$EF,$F0
		db $F1,$F2,$F3,$F4
		db $F5,$F6,$F7,$F8
		db $F9,$FA,$FB,$FC
		db $FC,$FD,$FE,$FE
		db $FE,$FE,$FF
		db $FF,$FE,$FE,$FE
		db $FE,$FD,$FC,$FC
		db $FB,$FA,$F9,$F8
		db $F7,$F6,$F5,$F4
		db $F3,$F2,$F1,$F0
		db $EF,$EE,$ED,$EC
		db $EC,$EB,$EA,$EA
		db $EA,$EA,$EA

FRAMES:         db $72,$71,$70,$63
		db $62,$61,$60,$53
		db $52,$51,$50,$43
		db $42,$41,$40,$33
		db $32,$31,$30,$23
		db $22,$21,$20,$13
		db $12,$11,$10,$03
		db $02,$01,$00
		db $00,$01,$02,$03
		db $10,$11,$12,$13
		db $20,$21,$22,$23
		db $30,$31,$32,$33
		db $40,$41,$42,$43
		db $50,$51,$52,$53
		db $60,$61,$62,$63
		db $70,$71,$72

FBANKS:         db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00

FRAMES2:        db $F1,$F0,$E3,$E2
		db $E1,$E0,$D3,$D2
		db $D1,$D0,$C3,$C2
		db $C1,$C0,$B3,$B2
		db $B1,$B0,$A3,$A2
		db $A1,$A0,$93,$92
		db $91,$90,$83,$82
		db $81,$80,$73
		db $73,$80,$81,$82
		db $83,$90,$91,$92
		db $93,$A0,$A1,$A2
		db $A3,$B0,$B1,$B2
		db $B3,$C0,$C1,$C2
		db $C3,$D0,$D1,$D2
		db $D3,$E0,$E1,$E2
		db $E3,$F0,$F1

FBANKS2:        db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00

XDIRECTION:     db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00
		db $01,$01,$01,$01
		db $01,$01,$01,$01
		db $01,$01,$01,$01
		db $01,$01,$01,$01
		db $01,$01,$01,$01
		db $01,$01,$01,$01
		db $01,$01,$01,$01
		db $01,$01,$01

ROTATEDEC:      db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$01
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$01

ROTATEINC:      db $01,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00
		db $01,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00

XFIRE:          db $00,$02,$03,$05
		db $07,$08,$09,$0B
		db $0C,$0D,$0E,$0F
		db $0F,$10,$10,$10
		db $10,$10,$0F,$0F
		db $0E,$0D,$0C,$0B
		db $09,$08,$07,$05
		db $03,$02,$00
		db $00,$FE,$FD,$FB
		db $F9,$F8,$F7,$F5
		db $F4,$F3,$F2,$F1
		db $F1,$F0,$F0,$F0
		db $F0,$F0,$F1,$F1
		db $F2,$F3,$F4,$F5
		db $F7,$F8,$F9,$FB
		db $FD,$FE,$00

YFIRE:          db $E5,$E5,$E5,$E6
		db $E6,$E7,$E8,$E9
		db $EA,$EB,$ED,$EE
		db $EF,$F1,$F2,$F4
		db $F6,$F7,$F9,$FA
		db $FC,$FD,$FE,$FF
		db $00,$01,$02,$02
		db $03,$03,$03
		db $03,$03,$03,$02
		db $02,$01,$00,$FF
		db $FE,$FD,$FC,$FA
		db $F9,$F7,$F6,$F4
		db $F2,$F1,$EF,$EE
		db $ED,$EB,$EA,$E9
		db $E8,$E7,$E6,$E6
		db $E5,$E5,$E5

XSPEEDS:        db $00,$07,$0D,$14
		db $1A,$20,$26,$2B
		db $30,$34,$37,$3A
		db $3D,$3F,$40,$40
		db $40,$3F,$3D,$3A
		db $37,$34,$30,$2B
		db $26,$20,$1A,$14
		db $0D,$07,$00
		db $00,$F9,$F3,$EC
		db $E6,$E0,$DA,$D5
		db $D0,$CC,$C9,$C6
		db $C3,$C1,$C0,$C0
		db $C0,$C1,$C3,$C6
		db $C9,$CC,$D0,$D5
		db $DA,$E0,$E6,$EC
		db $F3,$F9,$00

YSPEEDS:        db $C0,$C0,$C1,$C3
		db $C6,$C9,$CC,$D0
		db $D5,$DA,$E0,$E6
		db $EC,$F3,$F9,$00
		db $07,$0D,$14,$1A
		db $20,$26,$2B,$30
		db $34,$37,$3A,$3D
		db $3F,$40,$40
		db $40,$40,$3F,$3D
		db $3A,$37,$34,$30
		db $2B,$26,$20,$1A
		db $14,$0D,$07,$00
		db $F9,$F3,$EC,$E6
		db $E0,$DA,$D5,$D0
		db $CC,$C9,$C6,$C3
		db $C1,$C0,$C0

HITFRAMES:      db $33,$00,$01,$02
		db $03,$02,$01,$00
		db $33,$10,$11,$12
		db $13,$12,$11,$10
		db $33,$00,$01,$02
		db $03,$02,$01,$00
		db $33,$10,$11,$12
		db $13,$12,$11,$10
		db $33,$00,$01,$02
		db $03,$02,$01,$00

HITFBANKS:      db $00,$01,$01,$01
		db $01,$01,$01,$01
		db $00,$01,$01,$01
		db $01,$01,$01,$01
		db $00,$01,$01,$01
		db $01,$01,$01,$01
		db $00,$01,$01,$01
		db $01,$01,$01,$01
		db $00,$01,$01,$01
		db $01,$01,$01,$01

DEFLATEFRAMES:  db $33,$32,$31,$30
		db $23,$22,$21,$20

DEFLATEFBANKS:  db $01,$01,$01,$01
		db $01,$01,$01,$01

DEFLATEYDISP:   db $08,$07,$06,$05
		db $04,$03,$02,$01

WAKEUPFRAMES:   db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $33,$33,$33,$33
		db $20,$21,$22,$23
		db $30,$31,$32,$33

WAKEUPFBANKS:   db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $00,$00,$00,$00
		db $01,$01,$01,$01
		db $01,$01,$01,$01

WAKEUPXDISP:    db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $08,$08,$08,$08
		db $09,$0A,$0B,$0C
		db $0D,$0E,$0F,$10
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F8,$F8,$F8,$F8
		db $F7,$F6,$F5,$F4
		db $F3,$F2,$F1,$F0

DISABLEINTERACT:
		db $00,$00,$01,$01,$01,$01,$00

MARIOYOSHI:     db $10,$20,$20

		!TRACKTIME = $FF
		!TARGETTIME = $28
TRACKTIMES:     db !TARGETTIME,!TRACKTIME

		!RIGHTMAX = $12
		!LEFTMAX = $2B
KO_OFFSETS:     db !RIGHTMAX,!LEFTMAX

WAKE_OFFSETS:   db $17,$26

KO_XDISP:       db $0E,$F2

RETURN1:        RTS

SPRITE_ROUTINE: LDA !EXTRA_BITS,x       ; \
		AND #%00000100          ;  | store extra bit to
		LSR A                   ;  | scratch RAM so it's
		LSR A                   ;  | easily accessible
		STA !EXTRA_BIT          ; /
		JSR SUB_GFX             ; GFX
		LDA !14C8,x             ; \  return if
		CMP #$08                ;  | sprite
		BNE RETURN1             ; /  status != 8
		LDA $9D                 ; \ return if
		BNE RETURN1             ; / sprites locked
		%SubOffScreen()         ; only process sprite while on screen
		                        ;  A will be always #$00 due to the previous BNE.

		LDA !ACTSTATUS,x        ; get currrent status
		STA !LASTACTSTATUS,x    ; GFX routine needs previous frame's status (GFX routine already called this frame)
		PHA                     ; push status

		LDA !EXTRA_BIT          ; get extra bit
		PHA                     ; push extra bit, some INTERACTION routines use the same scratch RAM address
		BNE NOFALL              ; skip "physics" if it's set
		JSL !PHYSICS            ; update position based on speed values
		JSL !SPRSPRINTERACT     ; interact with other sprites
NOFALL:
		LDY.w !ACTSTATUS,x      ; \
		LDA DISABLEINTERACT,y   ;  | decide whether or not to interact
		BNE NOMARIOINTERACT     ; /
		LDA !167A,x             ; \
		AND #%11111101          ;  | consider sprite to be an enemy
		STA !167A,x             ; /
		JSR HEADINTERACT        ; head interactions
		JSL !MARIOSPRINTERACT   ; check for mario/sprite contact
		BRA ENDINTERACT         ; skip no-interact code
NOMARIOINTERACT:
		LDA !167A,x             ; \
		ORA #%00000010          ;  | consider sprite not to be an enemy
		STA !167A,x             ; /
ENDINTERACT:
		JSR SHELLINTERACT       ; knock out if hit with shell

		PLA                     ; \ pull
		STA !EXTRA_BIT          ; / extra bit

		PLA                     ; pull status
		ASL
		TAX
		JMP (behaviors,x)

behaviors:
		dw TRACKING
		dw TRACKING
		dw HIT
		dw STUNNED
		dw DEFLATE
		dw KNOCKEDOUT
		dw WAKINGUP

;;;;;;;;;;;;;;;;

TRACKING:
		LDX !current_sprite_process
		LDA !LOCKTIMER,x        ; \ don't ROTATE if ROTATE
		BNE NOROTATE            ; / disable timer is going
		LDA $14                 ; \
		AND #%00000001          ;  | only ROTATE every other frame
		BNE NOROTATE            ; /
		LDY $187A|!Base2                ; get riding Yoshi status
		LDA $96                 ; get Mario Y low byte
		PHA                     ; back up
		CLC                     ; \ offset by different numbers depending
		ADC MARIOYOSHI,y        ; / on whether Mario is riding Yoshi or not
		STA $96                 ; set Y low byte
		LDA $97                 ; get Mario Y high byte
		PHA                     ; back up
		ADC #$00                ; add high byte of offset (allow carry)
		STA $97                 ; set Y high byte
		JSR CALCBHFULLFRAME     ; calculate what frame to ROTATE to
		JSR ROTATE              ; ROTATE towards that frame
		PLA                     ; \ load backed up
		STA $97                 ; / Y high byte
		PLA                     ; \ load backed up
		STA $96                 ; / Y low byte
NOROTATE:

		LDY !OFFSET,x           ; \
		LDA YCOORDS,y           ;  | set head
		STA !YDISP,x            ;  | coords
		LDA XCOORDS,y           ;  |
		STA !XDISP,x            ; /
		LDA XDIRECTION,y        ; \ set flip
		STA !XFLIP,x            ; /
		LDA !ACTSTATUS,x        ; \ if not targeting, branch
		BEQ NOTTARGETING        ; / to "not targeting" code
		LDA FRAMES2,y           ; \
		STA !FRAME,x            ;  | set target
		LDA FBANKS2,y           ;  | frame
		STA !FBANK,x            ; /
		LDA $14                 ; \  only play target
		AND #%00000011          ;  | sound effect once
		BNE ENDSETFRAME         ; /  every 4 FRAMES
		LDA #!TARGETSND         ; \ play targeting
		STA !TARGETSNDPORT      ; / sound effect
		BRA ENDSETFRAME         ; skip "not targeting" code
NOTTARGETING:   LDA FRAMES,y            ; \
		STA !FRAME,x            ;  | set track
		LDA FBANKS,y            ;  | frame
		STA !FBANK,x            ; /
ENDSETFRAME:

		LDA !TIMER,x            ; \ if timer not expired,
		BNE ENDTRACKING         ; / then skip to end of code
		LDY !ACTSTATUS,x                ; \  set timer
		LDA TRACKTIMES,y        ;  | for next
		STA !TIMER,x            ; /  status
		TYA                     ; \  set
		EOR #%00000001          ;  | next
		STA !ACTSTATUS,x                ; /  status
		BNE ENDTRACKING         ; skip to end of code if not finishing targeting
		JSR SHOOT               ; fire projectile
		LDA #!SHOOTSND          ; \ play shooting
		STA !SHOOTSNDPORT       ; / sound effect
		LDA #$10                ; \ set ROTATE
		STA !LOCKTIMER,x        ; / lock timer
ENDTRACKING:    RTS

;;;;;;;;;;;;;;;;

HIT:
		LDX !current_sprite_process
		LDY !OFFSET,x           ; offset -> Y
		CPY #!RIGHTMAX          ; \
		BCC NOTTOOLOW           ;  | if head not too
		CPY #!LEFTMAX           ;  | low, skip next code
		BCS NOTTOOLOW           ; /
		LDA XDIRECTION,y        ; \
		TAY                     ;  | set offset to minimum
		LDA KO_OFFSETS,y        ;  | for the side it is on
		STA !OFFSET,x           ; /
		TAY                     ; new offset -> Y
NOTTOOLOW:      LDA YCOORDS2,y          ; \
		STA !YDISP,x            ;  | set head
		LDA XCOORDS2,y          ;  | coordinates
		STA !XDISP,x            ; /
		LDY !TIMER,x            ; timer -> Y
		LDA HITFRAMES,y         ; \
		STA !FRAME,x            ;  | set head
		LDA HITFBANKS,y         ;  | frame
		STA !FBANK,x            ; /
		CPY #$00                ; \ if timer hasn't expired
		BNE ENDHIT              ; / then skip status-advance
		INC !ACTSTATUS,x        ; next status
ENDHIT:         RTS

;;;;;;;;;;;;;;;;

STUNNED:
		LDX !current_sprite_process
		LDY !OFFSET,x           ; \  get direction
		LDA XDIRECTION,y        ;  | the blowhard
		TAY                     ; /  is facing -> Y
		LDA KO_OFFSETS,y        ; get offset to ROTATE towards based on flip
		PHY                     ; back up direction so it can be loaded instead of calculated again
		JSR ROTATE              ; ROTATE towards deflation offset
		LDY !OFFSET,x           ; get new offset -> Y
		LDA YCOORDS2,y          ; \
		STA !YDISP,x            ;  | set new coordinates
		LDA XCOORDS2,y          ;  | based on offset
		STA !XDISP,x            ; /
		TYA                     ; offset -> Acc.
		PLY                     ; load backed up direction
		CMP KO_OFFSETS,y        ; \ skip status-advance code if
		BNE ENDSTUNNED          ; / destination offset not reached
STUNNEDDONE:    LDA #$08                ; \ set deflation
		STA !TIMER,x            ; / timer
		INC !ACTSTATUS,x                ; next status
ENDSTUNNED:     RTS

;;;;;;;;;;;;;;;;

DEFLATE:        LDX !current_sprite_process
		LDY !TIMER,x            ; get time left -> Y
		LDA DEFLATEFRAMES,y     ; \  
		STA !FRAME,x            ;  | set frame based
		LDA DEFLATEFBANKS,y     ;  | on time left
		STA !FBANK,x            ; /
		LDA DEFLATEYDISP,y      ; get relative Y disposition
		LDY !OFFSET,x           ; get offset -> Y
		CLC                     ; \ add base Y
		ADC YCOORDS2,y          ; / disposition
		STA !YDISP,x            ; set Y disposition
		LDA !TIMER,x            ; \ if timer hasn't expired
		BNE ENDDEFLATE          ; / then skip status-advance
		LDA #$FF                ; \ set time for
		STA !TIMER,x            ; / knock-out
		INC !ACTSTATUS,x                ; next status
ENDDEFLATE:     RTS

;;;;;;;;;;;;;;;;

KNOCKEDOUT:
		LDX !current_sprite_process
		LDA #$F2                ; \
		STA !FRAME,x            ;  | set knocked-out frame
		STZ !FBANK,x            ; /
		LDA #$F8                ; \ set Y
		STA !YDISP,x            ; / offset
		LDY !OFFSET,x           ; \
		LDA XDIRECTION,y        ;  | set X offset
		TAY                     ;  | depending on
		LDA KO_XDISP,y          ;  | direction
		STA !XDISP,x            ; /
		LDA !TIMER,x            ; \ if timer hasn't expired
		BNE ENDKO               ; / then skip status-advance
		LDA #$40                ; \ set time for
		STA !TIMER,x            ; / waking up
		INC !ACTSTATUS,x                ; next status
ENDKO:          RTS

;;;;;;;;;;;;;;;;

WAKINGUP:
		LDX !current_sprite_process
		LDY !TIMER,x            ; get time left -> Y
		LDA WAKEUPFRAMES,y      ; \
		STA !FRAME,x            ;  | set frame
		LDA WAKEUPFBANKS,y      ;  | based on timer
		STA !FBANK,x            ; /
		LDY !OFFSET,x           ; \
		LDA XDIRECTION,y        ;  | get flip -> Y
		TAY                     ; /
		ASL A                   ; \
		ASL A                   ;  | get X
		ASL A                   ;  | disp
		ASL A                   ;  | index
		ASL A                   ;  |
		ASL A                   ;  |
		CLC                     ;  |
		ADC !TIMER,x            ; /
		PHY                     ; back up flip
		TAY                     ; index -> Y
		LDA WAKEUPXDISP,y       ; \ set X
		STA !XDISP,x            ; / disp
		PLY                     ; load backed up flip
		LDA #$01                ; \ set Y
		STA !YDISP,x            ; / disp
		LDA !TIMER,x            ; \ if timer hasn't expired
		BNE ENDWAKINGUP         ; / then skip status reset
		LDA WAKE_OFFSETS,y      ; \ set wake-
		STA !OFFSET,x           ; / up offset
		LDA #!TARGETTIME                ; \ set targeting
		STA !TIMER,x            ; / timer
		LDA #$01                ; \ set targeting
		STA !ACTSTATUS,x                ; / status
ENDWAKINGUP:    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!ROT_TEMP1 = $00

ROTATE:         STA !ROT_TEMP1          ; temporarily store destination offset
		SEC                     ; \ minus current
		SBC !OFFSET,x           ; / frame offset
		BEQ ROTATEDONE          ; if it's zero (they're equal) then don't ROTATE
		JSR WRAPOFFSET          ; wrap offset at #$3E (means #$3E would be #$00)
		CMP #$1F                ; \ CW (+) rotation if diff is less
		BCC INCROT              ; / than #$1F, else CCW (-) rotation
DECROT:         LDA !OFFSET,x           ; get offset
		DEC A                   ; subtract 1
		JSR WRAPOFFSET          ; wrap at #$3E
		CMP !ROT_TEMP1          ; \ if result is at destination,
		BEQ SETOFFSET           ; / avoid any extra rotation
		TAY                     ; \  do extra rotation if there is any
		SEC                     ;  | to do (this makes 0/180 degree
		SBC ROTATEDEC,y         ; /  FRAMES skip their mirror image)
		BRA FINISHOFFSET        ; branch over CW rotation
INCROT:         LDA !OFFSET,x           ; \ if result is at destination,
		INC A                   ; / avoid any extra rotation
		JSR WRAPOFFSET          ; wrap at #$3E
		CMP !ROT_TEMP1          ; \ if result is at destination,
		BEQ SETOFFSET           ; / avoid any extra rotation
		TAY                     ; \  do extra rotation
		CLC                     ;  | if there is any
		ADC ROTATEINC,y         ; /  to do
FINISHOFFSET:   JSR WRAPOFFSET          ; wrap at #$3E
SETOFFSET:      STA !OFFSET,x           ; set new offset
ROTATEDONE:     RTS

WRAPOFFSET:     BPL NOWRAP1             ; \
		CLC                     ;  | wrap if negative
		ADC #$3E                ; /
NOWRAP1:        CMP #$3E                ; \
		BCC NOWRAP2             ;  | wrap if
		SEC                     ;  | >= #$3E
		SBC #$3E                ; /
NOWRAP2:        RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!FC_TEMP1 = $00         ; will use 2 bytes
		!FC_TEMP2 = $02         ; will use 2 bytes
		!FC_TEMP3 = $04         ; will use 2 bytes
		!FC_TEMP4 = $06         ; will use 2 bytes

CALCBHFULLFRAME:
		JSR CALCFRAME
		JSR CALCBHQUADFLIP
		RTS

CALCBHQUADFLIP: PHA
		%SubVertPos()
		TYA
		EOR !EXTRA_BIT
		TAY
		PLA
		CPY #$00
		BNE CHKHORZ
		EOR #$FF
		CLC
		ADC #$1F
CHKHORZ:        PHA
		%SubHorzPos()
		PLA
		CPY #$00
		BEQ ENDQUADCHK
		EOR #$FF
		CLC
		ADC #$3E
ENDQUADCHK:     RTS

CALCFRAME:      LDA !D8,x
		SEC
		SBC $96
		STA !FC_TEMP2
		LDA !14D4,x
		SBC $97
		STA !FC_TEMP2+1
		BNE HORZDIST
		LDA !FC_TEMP2
		BNE HORZDIST
		BRA SETHORZ
HORZDIST:       LDA !E4,x
		SEC
		SBC $94
		STA !FC_TEMP1
		LDA !14E0,x
		SBC $95
		STA !FC_TEMP1+1
		BNE BEGINMATH
		LDA !FC_TEMP1
		BNE BEGINMATH
		BRA SETVERT
BEGINMATH:      PHP
		REP #%00100000
		LDA !FC_TEMP2
		BPL CHKXDIST
		EOR #$FFFF
		INC A
		STA !FC_TEMP2
CHKXDIST:       LDA !FC_TEMP1
		BPL MULT
		EOR #$FFFF
		INC A
		STA !FC_TEMP1
MULT:           ASL A
		ASL A
		ASL A
		ASL A
		STA !FC_TEMP3
		LDA !FC_TEMP1
		CLC
		ADC !FC_TEMP2
		STA !FC_TEMP4
		LDY #$00
		LDA !FC_TEMP4
		DEC A
DIVLOOP:        CMP !FC_TEMP3
		BCS END_DIVIDE
		INY
		CLC
		ADC !FC_TEMP4
		BRA DIVLOOP
END_DIVIDE:     TYA
		PLP
		RTS
SETHORZ:        LDA #$0F
		RTS
SETVERT:        LDA #$00
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NOFREESLOTS:    PLA
		;STA !EXTRA_BIT
		RTS

SHOOT:          LDA !EXTRA_BIT          ; \ back up extra
		PHA                     ; / bit scratch RAM
		JSL $02A9DE|!BankB      ; \ get slot or else
		BMI NOFREESLOTS         ; / end if no SLOTS
		PLA                     ; \ load backed up extra
		STA !EXTRA_BIT          ; / bit scratch RAM
		LDA #$01                ; \ set sprite status
		STA !14C8,y             ; / as a new sprite
		PHX                     ; back up X
		TYX                     ; new sprite index to X
		LDA #!SPRITE_NUM        ; \ store custom
		STA !7FAB9E,x           ; / sprite number
		JSL $07F7D2|!BankB      ; reset sprite properties
		JSL $0187A7|!BankB      ; get table values for custom sprite
		LDA #$08                ; \ mark as a
		STA !7FAB10,x           ; / custom sprite
		PLX                     ; load backed up X
		LDA !E4,x               ; \
		STA.w !E4,y             ;  | set center
		LDA !14E0,x             ;  | position for
		STA !14E0,y             ;  | needlenose
		LDA !D8,x               ;  | so that in next
		STA.w !D8,y             ;  | code, it can
		LDA !14D4,x             ;  | be shifted
		STA !14D4,y             ; /
		LDA !OFFSET,x           ; \
		PHX                     ;  | X
		TAX                     ;  |
		LDA XFIRE,x             ;  |
		LDX #$00                ;  |
		CMP #$00                ;  |
		BPL ADDPROJXDISP        ;  |
		DEX                     ;  |
ADDPROJXDISP:   CLC                     ;  |
		ADC.w !E4,y             ;  |
		STA.w !E4,y             ;  |
		TXA                     ;  |
		ADC !14E0,y             ;  |
		STA !14E0,y             ;  |
		PLX                     ; /
		LDA !OFFSET,x           ; \
		PHX                     ;  | Y
		TAX                     ;  |
		LDA YFIRE,x             ;  |
		LDX !EXTRA_BIT          ;  |
		BEQ NOFLIPPROJY         ;  |
		EOR #$FF                ;  |
		INC A                   ;  |
NOFLIPPROJY:    LDX #$00                ;  |
		CMP #$00                ;  |
		BPL ADDPROJYDISP        ;  |
		DEX                     ;  |
ADDPROJYDISP:   CLC                     ;  |
		ADC.w !D8,y             ;  |
		STA.w !D8,y             ;  |
		TXA                     ;  |
		ADC !14D4,y             ;  |
		STA !14D4,y             ;  |
		PLX                     ; /
		LDA !OFFSET,x           ; \
		PHX                     ;  | speeds
		TAX                     ;  |
		LDA XSPEEDS,x           ;  |
		STA.w !B6,y             ;  |
		LDA YSPEEDS,x           ;  |
		LDX !EXTRA_BIT          ;  |
		BEQ NOFLIPPROJYS        ;  |
		EOR #$FF                ;  |
		INC A                   ;  |
NOFLIPPROJYS:   STA.w !AA,y             ;  |
		PLX                     ; /
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HEADINTERACT:   LDA !E4,x               ; \
		PHA                     ;  | back up
		LDA !14E0,x             ;  | sprite
		PHA                     ;  | positions
		LDA !D8,x               ;  |
		PHA                     ;  |
		LDA !14D4,x             ;  |
		PHA                     ; /
		LDA !XDISP,x            ; \
		LDY #$00                ;  | X
		SEC                     ;  |
		SBC #$08                ;  |
		BPL ADDXDISP            ;  |
		DEY                     ;  |
ADDXDISP:       CLC                     ;  |
		ADC !E4,x               ;  |
		STA !E4,x               ;  |
		TYA                     ;  |
		ADC !14E0,x             ;  |
		STA !14E0,x             ; /
		LDA !YDISP,x            ; \
		LDY !EXTRA_BIT          ;  | Y
		BEQ NOTUPSIDEDOWN       ;  |
		EOR #$FF                ;  |
		INC A                   ;  |
NOTUPSIDEDOWN:  LDY #$00                ;  |
		SEC                     ;  |
		SBC #$08                ;  |
		BPL ADDYDISP            ;  |
		DEY                     ;  |
ADDYDISP:       CLC                     ;  |
		ADC !D8,x               ;  |
		STA !D8,x               ;  |
		TYA                     ;  |
		ADC !14D4,x             ;  |
		STA !14D4,x             ; /
		LDA !1662,x             ; \
		PHA                     ;  | set head clipping
		AND #%11000000          ;  | offset and backup
		ORA #$0E                ;  | that sprite table
		STA !1662,x             ; /
		JSR INTERACTION         ; Mario/Yoshi INTERACTION
		JSR STOPFIREBALLS       ; interact with fireballs
		JSR SHELLINTERACT       ; interact with shells
		PLA                     ; \ load backed-up
		STA !1662,x             ; / tweaker value $1662
		PLA                     ; \
		STA !14D4,x             ;  | load backed up
		PLA                     ;  | sprite positions
		STA !D8,x               ;  |
		PLA                     ;  |
		STA !14E0,x             ;  |
		PLA                     ;  |
		STA !E4,x               ; /
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SHELLINTERACT:  LDY #!SprSize           ; load number of times to go through loop
KO_LOOP:        CPY #$00                ; \ zero? if so,
		BEQ ENDSHELLLOOP        ; / end loop
		DEY                     ; decrease # of times left+get index
		LDA !14C8,y             ; \  if sprite's status
		CMP #$09                ;  | is less than 9 (9,A,B = shell modes)
		BCC KO_LOOP             ; /  ignore sprite
		LDA !1686,y             ; \  if sprite doesn't
		AND #%00001000          ;  | interact with others
		BNE KO_LOOP             ; /  don't continue
		JSL !GETSPRITECLIPPINGA ; \
		PHX                     ;  | if sprite is
		TYX                     ;  | not touching
		JSL !GETSPRITECLIPPINGB ;  | this sprite
		PLX                     ;  | don't continue
		JSL !CHECKFORCONTACT    ;  |
		BCC KO_LOOP             ; /
		LDA !14C8,y             ; \  speed doesn't matter
		CMP #$0B                ;  | if Mario is holding
		BEQ GETHIT              ; /  the shell (status=B)
		LDA.w !AA,y             ; \ continue if sprite
		BNE GETHIT              ; / has Y speed
		LDA.w !B6,y             ; \ continue if sprite
		BNE GETHIT              ; / has X speed
		BRA KO_LOOP             ; no speed / not holding -> don't kill
GETHIT:         LDA #$04                ; \ give mario
		JSL $02ACE5|!BankB      ; / 1000 points
		LDA #!KNOCKOUTSND       ; \ play knockout
		STA !KNOCKOUTSNDPORT    ; / sound
		LDA.w !9E,y             ; \
		CMP #$53                ;  | if throw block, don't do star animation
		BEQ NOSTARANI           ; /
		LDA #$04                ; \ set sprite to
		STA !14C8,y             ; / spin-jump kill
		LDA #$1F                ; \ set spin jump
		STA !1540,y             ; / animation timer
		PHX                     ; \
		STY $15E9|!Base2        ;  | do star
		JSL $07FC3B|!BankB      ;  | animation
		PLX                     ;  |
		STX $15E9|!Base2        ; /
STARTKNOCKOUT:  LDA !ACTSTATUS,x                ; \
		CMP #$02                ;  | if not TRACKING/targeting, shell won't hurt
		BCS ENDSHELLLOOP        ; /
		LDA #$28                ; \ set
		STA !TIMER,x            ; / timer
		LDA #$02                ; \ set hit
		STA !ACTSTATUS,x                ; / status
ENDSHELLLOOP:   RTS

NOSTARANI:      LDA !1656,y             ; \  force shell
		ORA #%10000000          ;  | to disappear
		STA !1656,y             ; /  in smoke
		LDA #$02                ; \ set shell into
		STA !14C8,y             ; / death mode (status=2)
		BRA STARTKNOCKOUT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INTERACTION:    LDA $77                 ; \
		AND #%00000100          ;  | if on ground, always do Yoshi check
		BNE YOSHI_CHECK         ; /
		LDA $7D                 ; \ if moving downward
		BPL MARIO_INTERACT      ; / skip Yoshi check
YOSHI_CHECK:    LDA $187A|!Base2        ; \ yoshi interact
		BNE YOSHI_INTERACT      ; / if riding Yoshi
MARIO_INTERACT: JSL !MARIOSPRINTERACT   ; normal interact with mario
		RTS
YOSHI_INTERACT: LDA $1490|!Base2        ; \ Mario INTERACTION
		BNE MARIO_INTERACT      ; / if Mario has star
		LDA !154C,x             ; \ don't interact if disable
		BNE END_INTERACT        ; / INTERACTION timer is set
		LDA !167A,x             ; \
		PHA                     ;  | set "no default INTERACTION"
		ORA #%10000000          ;  | flag temporarily and back-up
		STA !167A,x             ; /
		JSL !MARIOSPRINTERACT   ; detect if mario touching
		PLA                     ; \ load backed up
		STA !167A,x             ; / interact flag
		BCC END_INTERACT        ; if mario is not touching, don't lose yoshi
		JSR LOSEYOSHI           ; else lose yoshi
END_INTERACT:   RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LOSEYOSHI:      PHX
		LDX $18E2|!Base2
		LDA #$10
		STA !163E-$01,x
		LDA #$03
		STA $1DFA|!Base2
		LDA #$13
		STA $1DFC|!Base2
		LDA #$02
		STA !C2-$01,x
		STZ $187A|!Base2
		STZ $0DC1|!Base2
		LDA #$C0
		STA $7D
		STZ $7B
		LDY !157C-$01,x
		PHX
		TYX
		LDA $02A4B3|!BankB,x
		PLX
		STA !B6-$01,x
		STZ !1594-$01,x
		STZ !151C-$01,x
		STZ $18AE|!Base2
		LDA #$30
		STA $1497|!Base2
		PLX
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STOPFIREBALLS:  LDY #$09                ; index of first fireball
FB_LOOP_BEGIN:  LDA $170B|!Base2,y      ; \
		CMP #$05                ;  | ignore if not fireball
		BNE FB_LOOP             ; /
		JSL !GETSPRITECLIPPINGA ; \
		LDA $171F|!Base2,y      ;  | ignore
		SEC                     ;  | if not
		SBC #$02                ;  | touching
		STA $00                 ;  | sprite
		LDA $1733|!Base2,y      ;  |
		SBC #$00                ;  |
		STA $08                 ;  |
		LDA #$0C                ;  |
		STA $02                 ;  |
		LDA $1715|!Base2,y      ;  |
		SEC                     ;  |
		SBC #$04                ;  |
		STA $01                 ;  |
		LDA $1729|!Base2,y      ;  |
		SBC #$00                ;  |
		STA $09                 ;  |
		LDA #$13                ;  |
		STA $03                 ;  |
		JSL !CHECKFORCONTACT    ;  |
		BCC FB_LOOP             ; /
		LDA #$0F                ; \
		STA $176F|!Base2,y      ;  | turn fireball
		LDA #$01                ;  | into smoke
		STA $170B|!Base2,y      ; /
		LDA #$01                ; \ play
		STA $1DF9|!Base2        ; / SFX
FB_LOOP:        DEY                     ; \
		CMP #$08                ;  | loop if not reached end
		BCS FB_LOOP_BEGIN       ; /
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!GFXTMP_HORIZFLIP = $02
		!GFXTMP_TILECOUNT = $03
		!GFXTMP_DSLOTTILE = $04
		!GFXTMP_XPOSITION = $05
		!GFXTMP_YPOSITION = $06
		!GFXTMP_FRAMEBANK = $07

HEAD_TILES:     db $00,$02,$20,$22
HEAD_XPOS:      db $F8,$08,$F8,$08
HEAD_YPOS:      db $F8,$F8,$08,$08

BASE_TILES:     db $0C,$0E
BASE_XPOS:      db $F8,$08

FLASHPALETTES:  db %00000100,%00001010,%00001000

SUB_GFX:        %GetDrawInfo()
		LDA #$FF                ; \ zero tiles
		STA !GFXTMP_TILECOUNT   ; / drawn
		LDA !XFLIP,x            ; \ set X
		STA !GFXTMP_HORIZFLIP   ; / flip
		JSR DRAW_HEAD           ; draw head
		JSR DRAW_BASE           ; draw base
		LDY #$02                ; #$02 means the tiles are 16x16
		LDA !GFXTMP_TILECOUNT   ; # of tiles drawn -1
		;BMI RETURN_SUB_GFX     ; return if no tiles drawn (commented out because there will never be zero tiles drawn)
		JSL !FINISHOAMWRITE     ; don't draw if offscreen, set sizes
RETURN_SUB_GFX: RTS

DRAW_HEAD:      LDA !XDISP,x            ; \
		STA !GFXTMP_XPOSITION   ;  | store head coordinates
		LDA !YDISP,x            ;  | into scratch RAM
		STA !GFXTMP_YPOSITION   ; /
		LDA !FBANK,x            ; \ set frame bank (will be used
		STA !GFXTMP_FRAMEBANK   ; / in modified dynamic routine)
		LDA !FRAME,x            ; \ reserve dynamic
;		REP #$10
;		LDX #BlowHardGFX
;		%GetDynSlot()
;		BCC RETURN_SUB_GFX      ; if none available, return
		JSR GETSLOT
		BEQ RETURN_SUB_GFX
		STA !GFXTMP_DSLOTTILE   ; store dynamic sprite slot to scratch RAM
		PHX                     ; back up sprite index
		LDX #$00                ; load X with zero
HEADLOOP:       CPX #$04                ; \ if end of loop,
		BCS ENDHEADLOOP         ; / branch to end
		LDA HEAD_XPOS,x         ; \
		PHX                     ;  | X
		LDX !GFXTMP_HORIZFLIP   ;  |
		BNE HEADNOFLIPX         ;  |
		EOR #$FF                ;  |
		INC A                   ;  |
HEADNOFLIPX:    PLX                     ;  |
		CLC                     ;  |
		ADC !GFXTMP_XPOSITION   ;  |
		CLC                     ;  |
		ADC $00                 ;  |
		STA $0300|!Base2,y      ; /
		LDA HEAD_YPOS,x         ; \
		CLC                     ;  | Y
		ADC !GFXTMP_YPOSITION   ;  |
		PHX                     ;  |
		LDX !EXTRA_BIT          ;  |
		BEQ HEADNOFLIPY         ;  |
		EOR #$FF                ;  |
		INC A                   ;  |
HEADNOFLIPY:    PLX                     ;  |
		CLC                     ;  |
		ADC $01                 ;  |
		STA $0301|!Base2,y      ; /
		LDA HEAD_TILES,x        ; \
		CLC                     ;  | set tile
		ADC !GFXTMP_DSLOTTILE   ;  | number
		STA $0302|!Base2,y      ; /
		PHX                     ; \
		LDX $15E9|!Base2        ;  | sprite
		LDA !15F6,x             ;  | props
		LDX !GFXTMP_HORIZFLIP   ;  |
		BNE HEADNOFLIPXT        ;  |
		ORA #%01000000          ;  |
HEADNOFLIPXT:   ;PLX                    ;  |
		;PHX                    ;  |
		LDX !EXTRA_BIT          ;  |
		BEQ HEADNOFLIPYT        ;  |
		ORA #%10000000          ;  |
HEADNOFLIPYT:   PLX                     ;  |
		JSR FLASH               ;  |
		ORA $64                 ;  |
		STA $0303|!Base2,y      ; /
		INY                     ; \
		INY                     ;  | next OAM
		INY                     ;  | index
		INY                     ; /
		INX                     ; next tile
		INC !GFXTMP_TILECOUNT   ; another tile was drawn
		BRA HEADLOOP            ; loop
ENDHEADLOOP:    PLX                     ; load backed up X
RETURNHEAD:     RTS

DRAW_BASE:	LDX #$00                ; load X with zero
BASELOOP:       CPX #$02                ; \ if end of loop,
		BCS ENDBASELOOP         ; / branch to end
		LDA BASE_XPOS,x         ; \
		PHX                     ;  | X
		LDX !GFXTMP_HORIZFLIP   ;  |
		BNE BASENOFLIPX         ;  |
		EOR #$FF                ;  |
		INC A                   ;  |
BASENOFLIPX:    PLX                     ;  |
		CLC                     ;  |
		ADC $00                 ;  |
		STA $0300|!Base2,y      ; /
		LDA $01                 ; \ Y
		STA $0301|!Base2,y      ; /
		LDA BASE_TILES,x        ; \
		CLC
		ADC !tile_off_scratch
		STA $0302|!Base2,y      ;  | sprite
		PHX                     ;  | props
		LDX $15E9|!Base2        ;  |
		LDA !15F6,x             ;  |
		LDX !GFXTMP_HORIZFLIP   ;  |
		BNE BASENOFLIPXT        ;  |
		ORA #%01000000          ;  |
BASENOFLIPXT:   ;PLX                    ;  |
		;PHX                    ;  |
		LDX !EXTRA_BIT          ;  |
		BEQ BASENOFLIPYT        ;  |
		ORA #%10000000          ;  |
BASENOFLIPYT:   PLX                     ;  |
		JSR FLASH               ;  |
		ORA $64                 ;  |
		STA $0303|!Base2,y      ; /
		INY                     ; \
		INY                     ;  | next OAM
		INY                     ;  | index
		INY                     ; /
		INX                     ; next tile
		INC !GFXTMP_TILECOUNT   ; another tile was drawn
		BRA BASELOOP            ; loop
ENDBASELOOP:    LDX !current_sprite_process
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FLASH:          PHX                     ; \
		LDX $15E9|!Base2        ;  | FLASH if
		PHA                     ;  | targeting
		LDA !LASTACTSTATUS,x    ;  |
		TAX                     ;  |
		PLA                     ;  |
		CPX #$01                ;  |
		BNE NOFLASH             ;  |
		JSR DOFLASH             ;  |
NOFLASH:        PLX                     ; /
		RTS

DOFLASH:        AND #%11110001          ; remove current palette bits
		PHA                     ; back up A
		PHX                     ; back up tile index
		LDX $15E9|!Base2        ; get sprite index -> X
if !SA1 == 1
		LDA #$01
		STA $2250
		LDA #$00 : XBA
		LDA !TIMER,x
		PLX
		REP #$20
		STA $2251
		LDA #$0003
		STA $2253
		SEP #$20
		PLA
		PHX
		LDX $2308
else
		LDA !TIMER,x            ; \ get time
		PLX                     ; / left
		STA $4204               ; set as dividend
		LDA #$03                ; \ set 3 as
		STA $4206               ; / divisor
		LDA ($00,s),y
		NOP
		PLA                     ; load backed up A
		PHX                     ; back up X
		LDX $4216               ; load X with remainder
endif
		ORA.l FLASHPALETTES,x   ; get palette according to remainder
		PLX                     ; load backed up X
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dynamic sprite routine
; Programmed mainly by SMKDan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GETSLOT:
        PHY             ;preserve OAM index
        PHA             ;preserve frame
        LDA !SlotsUsed  ;test if slotsused == maximum allowed
        CMP #!MAXSLOTS
        BNE +
                
        PLA
        PLY
        LDA #$00        ;zero on no free slots
        RTS

+       PLA             ;pop frame
        REP #$20        ;16bit A
        AND.w #$00FF    ;wipe high
        XBA             ;<< 8
        LSR A           ;>> 1 = << 7
        STA !Temp       ;back to scratch
        LDA.w #BlowHardGFX ;Get 16bit address
        CLC
        ADC !Temp       ;add frame offset       
        STA !SlotPointer        ;store to pointer to be used at transfer time
        SEP #$20        ;8bit store
        LDA #BlowHardGFX/$10000
        CLC
        ADC !GFXTMP_FRAMEBANK
        STA !SlotBank   ;store bank to 24bit pointer

        PHX             ;This is how I made your boi a routine
        LDX !SlotsUsed          ;calculate VRAM address + tile number
        LDA.L SlotsTable,X      ;get tile# in VRAM
        PLX
        PHA             ;preserve for eventual pull
        SEC
        SBC #$C0        ;starts at C0h, they start at C0 in tilemap
        REP #$20        ;16bit math
        AND.w #$00FF    ;wipe high byte
        ASL A           ;multiply by 32, since 32 bytes/16 words equates to 1 32bytes tile
        ASL A
        ASL A
        ASL A
        ASL A
if !SA1 == 1
        CLC : ADC #$8000        ;add 8000, base address of buffer
else
        CLC : ADC.w #!dynamic_buffer
endif
        STA !SlotDestination    ;destination address in the buffer
        SEP #$20
        STZ !Timers
        
;;;;;;;;;;;;;;;;;
;Transfer routine
;;;;;;;;;;;;;;;;;

;DMA ROM -> RAM ROUTINE

if !SA1 == 1
;set destination RAM address
        REP #$20
        LDY #$C4
        STY $2230
        LDA.w !SlotDestination
        STA $2235       ;16bit RAM dest
                
                        ;set 7F as bank

;common DMA settings
                        ;1 reg only
                        ;to 2180, RAM write/read
                 

;first line
        LDA !SlotPointer
        STA $2232       ;low 16bits
        LDY !SlotBank
        STY $2234       ;bank
        LDY #$80        ;128 bytes
        STZ $2238
        STY $2238
        LDY #$41
        STY $2237
        
        LDY $318C
        BEQ $FB
        LDY #$00
        STY $318C
        STY $2230       ;transfer

;lines afterwards
-       LDY #$C4
        STY $2230
        LDA.w !SlotDestination  ;update buffer dest
        CLC
        ADC #$0200      ;512 byte rule for sprites
        STA !SlotDestination    ;updated base
        STA $2235       ;updated RAM address

        LDA !SlotPointer        ;update source address
        CLC
        ADC #$0200      ;512 bytes, next row
        STA !SlotPointer
        STA $2232       ;low 16bits
        LDY !SlotBank
        STY $2234       ;bank
        LDY #$80
        STZ $2238
        STY $2238
        LDY #$41
        STY $2237
        
        LDY $318C
        BEQ $FB
        LDY #$00
        STY $318C
        STY $2230       ;transfer
        LDY !Timers
        CPY #$02
        BEQ +
        INC !Timers
        BRA -
+
else
;common DMA settings
        REP #$20
        STZ $4300       ;1 reg only
        LDY #$80        ;to 2180, RAM write/read
        STY $4301
        
;set destination RAM address
        LDA !SlotDestination
        STA $2181       ;16bit RAM dest
        LDY #$7F
        STY $2183       ;set 7F as bank

        LDA !SlotPointer
        STA $4302       ;low 16bits
        LDY !SlotBank
        STY $4304       ;bank
        LDY #$80        ;128 bytes
        STY $4305
        LDY #$01
        STY $420B       ;transfer

;second line
-       LDA !SlotDestination    ;update buffer dest
        CLC
        ADC #$0200      ;512 byte rule for sprites
        STA !SlotDestination    ;updated base
        STA $2181       ;updated RAM address

        LDA !SlotPointer        ;update source address
        CLC
        ADC #$0200      ;512 bytes, next row
        STA !SlotPointer
        STA $4302       ;low 16bits
        LDY !SlotBank
        STY $4304       ;bank
        LDY #$80
        STY $4305
        LDY #$01
        STY $420B       ;transfer
        LDY !Timers
        CPY #$02
        BEQ +
        INC !Timers
        BRA -
+
endif
        
        SEP #$20        ;8bit A 
        INC !SlotsUsed  ;one extra slot has been used

        PLA             ;return starting tile number
        PLY
        RTS

SlotsTable:                     ;avaliable slots.  Any more transfers and it's overflowing by a dangerous amount.
        db $CC,$C8,$C4,$C0      

incbin yiblowhardv2.bin -> BlowHardGFX
