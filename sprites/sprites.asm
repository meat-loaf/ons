incsrc "../asm/main.asm"

incsrc "include/config.def"
incsrc "include/512kfree.def"
incsrc "include/smw_routines.def"

incsrc "macros/macros.asm"

incsrc "engine/engine.asm"

incsrc "list.def"

%write_sprite_tables()
%write_ambient_tables(ambient_rts, ambient_twk_tsz, ambient_dust_main_bad_ambient_default)

print "freespace used: ", freespaceuse, " bytes."
print "bytes modified: ", bytes, " bytes."
