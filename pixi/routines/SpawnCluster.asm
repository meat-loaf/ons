; Routine that spawns a cluster sprite
;
; Input:  A   = number of cluster sprite to spawn
;         Y   = slot to start searching from (highest is #$13)
;         $00 = x offset  \
;         $01 = y offset  | you could also just ignore these and set them later
;         $02 = x speed   | using the returned Y.
;         $03 = y speed   /
;
; Output: Y   = index to spawned sprite (#$FF means no sprite spawned)
;         C   = Carry Clear = spawn failed, Carry Set = spawn successful.
;
; ensure you set $18B8 to non-zero to actually run cluster sprites
.SpawnCluster
	XBA
	; y should contain the starting slot already
?-	LDA $1892|!addr,y
	BEQ ..FoundSlot
	DEY
	BPL ?-
?+	DEC $191D|!addr
	BPL ?+
	LDA #$13
	STA $191D|!addr
?+	LDY $191D|!addr
..FoundSlot
	LDA !spr_spriteset_off,x
	STA !cls_spriteset_off,y
	XBA
	STA $1892|!addr,y
	STZ $8A
	LDA $00
	BPL ?+
	DEC $8A
?+	CLC
	ADC !E4,x
	STA !cluster_x_low,y
	LDA $8A
	ADC !14E0,x
	STA !cluster_x_high,y
	STZ $8A
	LDA $01
	BPL ?+
	DEC $8A
?+	CLC
	ADC !D8,x
	STA !cluster_y_low,y
	LDA $8A
	ADC !14D4,x
	STA !cluster_y_high,y
	LDA $02
	STA $1E66|!addr,y
	LDA $03
	STA $1E52|!addr,y
	SEC
	RTL
..fail	LDX $15E9|!addr
	LDY #$FF
	CLC
	RTL
