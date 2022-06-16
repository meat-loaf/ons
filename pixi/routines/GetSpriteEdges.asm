GetSpriteEdges:
	PHY
	%SpriteEdgeBottom()
	BCS .SetBelow
	%SpriteEdgeTop()
	BCS .SetAbove
.SetSides
	LDA #$01
	BRA ?+
.SetBelow
	LDA #$02
	BRA ?+
.SetAbove
	LDA #$00
?+	STA $0F
	PLY
	RTL