includefrom "../main.asm"

struct oam_entry $0200|!addr
	.x_pos: skip 1
	.y_pos: skip 1
	.tile:  skip 1
	.props: skip 1
endstruct align 4

!oam_lo = oam_entry[$0000]
!oam_hi = oam_entry[$0100]
