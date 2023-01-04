;#####################################################################################################
;# Camera enhancer v0.1
;# by lx5
;#
;# Makes possible have more control over the camera.
;# Features:
;#  1) Lets you have a different target to lock the camera onto instead of the player.
;#  2) Adds the possibilty of having dynamic boundaries in the Y axis of the camera instead of hardcoded values.
;#     Basically, copies over the algorithm for $7E142A and creates a Y axis one.

; TODO convert to lorom, currently SA1 only

sa1rom

;# Settings for the camera in the X axis.
;# Reset every frame.
;# 1 byte
;# Format: c--- ---
;#  c = Enables using !camera_target_x_pos instead of the player position as the camera's target
!camera_x_flags = $343E

;# Settings for the camera in the Y axis.
;# Reset every frame.
;# 1 byte.
;# Format: c--- ---r
;#  c = Enables using !camera_target_y_pos instead of the player position as the camera's target
;#  r = Enables being able to use !camera_target_y_center, which is $7E142A but for Y coordinates.
;#      Otherwise, it'll use the original logic which has no dynamic bounds.
!camera_y_flags = $343F

;# Equivalent to $7E142A but uses the Y axis.
;# Basically it controls at which region the camera should catch up with the player or the target.
;# 2 bytes.
!camera_target_y_center = $3440

;# Coordinates that the camera will attempt to keep on the screen.
;# Requires setting MSB of !camera_x_flags and !camera_y_flags in order to use each one.
;# 2 bytes.
!camera_target_y_pos = $3442
!camera_target_x_pos = $3444

;# Used to hold data equivalent to $7E142C and $7E142E for the Y coordinates
;# Requires to be 4 consecutive bytes. Only used if LSB of !camera_y_flags is enabled.
!scratch_ram = $3120

;# RAM defines
!player_x_pos = $94
!player_y_pos = $96

sa1rom

org $00F718
    autoclean jsl horizontal_camera
org $00F7FC
    autoclean jml vertical_camera

freecode

horizontal_camera:  
    ldy !camera_x_flags
    php
    ldy #$00
    sty !camera_x_flags
    ldy #$02
    plp 
    bpl .player
    lda !camera_origin_x_pos
    rtl 
.player
    lda !player_x_pos
    rtl 

vertical_camera:
    ldy !camera_y_flags
    bne .custom
.vanilla
    ldy #$00
    sty !camera_y_flags
    lda !player_y_pos
    sec 
    jml $00F801
.custom 
    cpy #$80
    php 
    ldy #$00
    sty !camera_y_flags
    lda !camera_y_bound_center
    sec 
    sbc #$000C
    sta $3140
    clc 
    adc #$0018
    sta $3142
    plp 
    bcc .regular_origin
.custom_origin
    lda !camera_origin_y_pos
    bra +
.regular_origin
    lda !player_y_pos
+   
    ldy #$00
    sec 
    sbc $1C
    sta $00
    cmp !camera_y_bound_center
    bmi +
    ldy #$02
+   
    sty $55
    sty $56
    sec 
    sbc $3140,y
    sta $02
    eor $F6A3,y
    bmi .handle_vertical_scroll
.stop_scrolling
    ldy #$02
    stz $02
    jml $00F81F
.handle_vertical_scroll
    phb 
    phk
    plb 
    phy 
    tya 
    asl #2
    tax 
    ldy #$08
    lda !camera_y_bound_center
    cmp $00F6B3,x
    bpl +
    ldy #$0A
+   
    lda .scroll_speed-2,y
    eor $02
    bpl .return
    lda .scroll_speed-2,x
    eor $02
    bpl .return
    lda $02 
    clc 
    adc .catch_up-8,y
    beq .return
    sta $02
.return
    ply
    plb 
    jml $00F81F

.scroll_distances
	dw $007C,$0064,$0000
	dw $0000,$0000,$0000
	dw $0000
.scroll_speed
    dw $FFFE,$0002,$0000
    dw $FFFE,$0002,$0000
.catch_up
	dw $0001,$FFFF
