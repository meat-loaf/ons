!hdma_free_indir = $7FC7FC

init:
	LDX.b #!num_sprites-1
.loop:
	LDA   !14C8,x
	BEQ.b .found
	DEX
	BPL.b .loop
	BRA .noslot
.found:
	LDA.b #$70
	STA   !9E,x
	JSL.l $07F7D2|!bank
	LDA   !9E,x
	STA   !spr_new_sprite_num,x
	JSL.l $0187A7|!bank
	LDA.b #$08
	STA   !spr_extra_bits,x
	LDA.b #$01
	STA   !14C8,x
.noslot:

	REP #$20
	; ram init for scrolling
	LDA.w #$0000
	STA.l !hdma_free_indir
	STA.l !hdma_free_indir+2

	LDA.w #$3200
	STA.w $4330
	LDA.w #RedTable
	STA.w $4332
	LDY.b #RedTable>>16
	STY.w $4334
	LDA.w #$3200
	STA.w $4340
	LDA.w #GreenTable
	STA.w $4342
	LDY.b #GreenTable>>16
	STY.w $4344
	LDA.w #$3200
	STA.w $4350
	LDA.w #BlueTable
	STA.w $4352
	LDY.b #BlueTable>>16
	STY.w $4354

	LDA.w #$0F42
	STA.w $4360
	LDA.w #parallax_table
	STA.w $4362
	SEP.b #$20

	LDA.b #parallax_table>>16
	STA.w $4364
	LDA.b #!hdma_free_indir>>16
	LDA.b #$7F
	STA.w $4367

	LDA #%01111000
	TSB $0D9F|!addr
main:
	REP.b #$20
	LDA.b $1A
	LSR   #3
	STA.l !hdma_free_indir+2
	SEP.b #$20
	RTL

RedTable:
   db $7C : db $20
   db $01 : db $27
   db $02 : db $2C
   db $03 : db $31
   db $03 : db $37
   db $5B : db $3F
   db $00

GreenTable:
   db $69 : db $41
   db $04 : db $44
   db $0F : db $46
   db $01 : db $47
   db $02 : db $49
   db $03 : db $4C
   db $03 : db $4D
   db $5B : db $50
   db $00

BlueTable:
   db $69 : db $8E
   db $04 : db $8F
   db $0F : db $90
   db $01 : db $92
   db $05 : db $93
   db $03 : db $96
   db $5B : db $9B
   db $00

parallax_table:
	db $7F : dw !hdma_free_indir+0
	db $80 : dw !hdma_free_indir+2
	db $00
