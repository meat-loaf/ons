incsrc "../asm/main.asm"

incsrc "include/config.def"
incsrc "include/512kfree.def"
incsrc "include/smw_routines.def"

incsrc "macros/macros.asm"

incsrc "engine/engine.asm"

incsrc "list.def"

%write_sprite_tables()

print "freespace used: ", freespaceuse, " bytes."
print "bytes modified: ", bytes, " bytes."
