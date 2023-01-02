incsrc "../asm/main.asm"

incsrc "include/config.def"
incsrc "include/512kfree.def"
incsrc "include/smw_routines.def"

incsrc "macros/macros.asm"
incsrc "util/jslshims.asm"
!spriteset_offset = !spr_spriteset_off

incsrc "spritesets/spritesets.asm"

incsrc "list.def"

incsrc "engine/run.asm"
incsrc "engine/load.asm"


%write_sprite_tables()

print "freespace used: ", freespaceuse, " bytes."
print "bytes modified: ", bytes, " bytes."
