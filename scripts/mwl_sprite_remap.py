#!/usr/bin/python3
from pylibmwl.mwl import mwl_header

import sys

# lorom
def snes_to_pc(val):
	bank = (val>>16)&(0xFF)
	return bank*0x8000+(val&0x7FFF)+0x200

def main(argv) -> int:
	if len(argv) < 2:
		print("Requires two arguments, mwl file and rom to read sprite sizes from.", file=sys.stderr)
		return 1
	sprite_size_dat = None
	with open(argv[2], 'rb') as oldfile:
		oldfile.seek(0x7750C)
		size_ptr_snes = int.from_bytes(oldfile.read(3), byteorder='little')
		# clear mirroring
		size_ptr_snes = size_ptr_snes & 0x7FFFFF
		size_ptr = snes_to_pc(size_ptr_snes)
		oldfile.seek(size_ptr)
		print("size_ptr_snes", hex(size_ptr_snes), "size_ptr", hex(size_ptr))
		oldfile.seek(size_ptr)
		sprite_size_dat = oldfile.read(0x400)


	print("reading sprites")
	with mwl_header(argv[1], sprite_size_dat) as header:
		header.replace_sprites_inplace({0x00: 0x91, 0x1F: 0xB9, 0x15: 0xBA, 0x2: 0x69, 0x4: 0x6F, 0x3A: 0xA8, 0x03: 0xA9})
		#print(header.sprites)

	return 0

if __name__ == '__main__':
	sys.exit(main(sys.argv))
