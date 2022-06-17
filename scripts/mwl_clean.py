#!/bin/python3


# cleans the unused 'original data location' entries in an
# MWL file (useful when adding them to source control)

import sys;

debug = 0

mwl_string_encoding = "windows-1252"
mwl_header_generic_text = "  ©2021 FuSoYa  Defender of Relm"
mwl_header_generic_text_pos = 0x20

header_pointer_loc = 0x04

nullptr = bytes("\x00\x00\x00\x00", mwl_string_encoding)

# layer 1, layer 2, sprite, and palette data offsets
data_pointer_offsets = (0x08, 0x10, 0x18, 0x20)

data_pointer_orig_ptr_off = 0x04

def read_nbytes_as_le(f, nbytes=4):
	return int.from_bytes(f.read(nbytes), "little")

if len(sys.argv) < 2:
	print("Provide MWL files as arguments.")
	sys.exit(1)

for mwl_file_name in sys.argv[1:]:
	plocs = []
	with open(sys.argv[1], "rb+") as mwl_file:
		mwl_file.seek(mwl_header_generic_text_pos)
		if (mwl_file.read(len(mwl_header_generic_text)).decode(mwl_string_encoding) != mwl_header_generic_text):
			print("Header check failed: this doesn't appear to be a MWL file.")
			sys.exit(1)
		mwl_file.seek(header_pointer_loc);
		header_start_off = read_nbytes_as_le(mwl_file, 4)
		for offset in data_pointer_offsets:
			if debug:
				 print ("Pointer at: {}".format(hex(header_start_off+offset)))
			mwl_file.seek(header_start_off+offset)
			pointer = read_nbytes_as_le(mwl_file, 4) + data_pointer_orig_ptr_off
			plocs.append(hex(pointer))
			mwl_file.seek(pointer)
			if debug:
				print ("Writing null pointer to offset {} (old val: {})".format(hex(pointer), hex(read_nbytes_as_le(mwl_file, 4))))
				mwl_file.seek(pointer)
			mwl_file.write(nullptr)
			mwl_file.seek(pointer)
	print("{}: pointers written to {}, {}, {}, {}".format(mwl_file_name, *plocs))
