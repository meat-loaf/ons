!falldown_timer = !1564
!platform_prop = !1594
!behavior = !C2
!platform_move = !1528

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Fallingplatform routine, for platforms that act pretty much
;	just like the grey falling platform at some point.
;
; Contains a table that determines which way a platform falls.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FallingPlatform:
		JSR DoYouFall

		JSL $01B44F|!bank
		BCC .nofall
			LDA !spr_extra_bits,x
			AND #$04
			BEQ .not_slippery
			STA !mario_slip
.not_slippery:
			LDA !behavior,x
			BNE .nofall
			
			LDA #$01
			STA !behavior,x
			
			LDA #20
			STA !falldown_timer,x
			
.nofall:
		
		RTS
		
DoYouFall:
		LDA !behavior,x
		BEQ FallingPlatform_return
		
	FallingPlatform_falling:
			LDA !platform_prop,x
			LSR
			LSR
			AND #$03
			JSL $0086DF|!bank
		FallingPlatform_Directions:
			dw Falldown
			dw Fallup
			dw Fallright 
			dw Fallleft
			
FallingPlatform_return:
		RTS
