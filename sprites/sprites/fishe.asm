includefrom "list.def"

!fish_sprnum = $15
%alloc_sprite(!fish_sprnum, fish_init, fish_main, 1, 0, \
	$00, $10, $00, $45, $99, $00)

%alloc_sprite_sharedgfx_entry_4(!fish_sprnum,$04,$06,$00,$02)

; 0: normal horiz
; 1: normal vert
; 2: like dolphin, straight up and down
; 3: like dolphin, in arc
!fish_move_kind = !spr_extra_bits

%set_free_start("bank1_fish")
fish_init:
	lda !fish_move_kind,x
	beq .exit
	jsr.w _spr_face_mario_rt
.exit
	rtl

fish_main:
	rtl

fish_done:
%set_free_start("bank1_fish", fish_done)
