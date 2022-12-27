#!/bin/python3

import sys

READ_CHUNK_SIZE  = 32*4*4*4
WRITE_CHUNK_SIZE = 32*4

def main(argv):
	if len(argv) != 3:
		print("usage: {} input_file output_file".format(argv[0]), file=sys.stderr)
		return 1
	in_fname = argv[1]
	out_fname = argv[2]
	with open(in_fname, 'rb') as infile:
		with open(out_fname, 'wb') as outfile:
			while(True):
				dat = infile.read(READ_CHUNK_SIZE)
				if len(dat) == 0:
					break;

				outfile.write(dat[WRITE_CHUNK_SIZE*0:WRITE_CHUNK_SIZE*1])
				outfile.write(dat[WRITE_CHUNK_SIZE*8:WRITE_CHUNK_SIZE*9])

				outfile.write(dat[WRITE_CHUNK_SIZE*1:WRITE_CHUNK_SIZE*2])
				outfile.write(dat[WRITE_CHUNK_SIZE*9:WRITE_CHUNK_SIZE*10])

				outfile.write(dat[WRITE_CHUNK_SIZE*4:WRITE_CHUNK_SIZE*5])
				outfile.write(dat[WRITE_CHUNK_SIZE*12:WRITE_CHUNK_SIZE*13])

				outfile.write(dat[WRITE_CHUNK_SIZE*5:WRITE_CHUNK_SIZE*6])
				outfile.write(dat[WRITE_CHUNK_SIZE*13:WRITE_CHUNK_SIZE*14])

				outfile.write(dat[WRITE_CHUNK_SIZE*2:WRITE_CHUNK_SIZE*3])
				outfile.write(dat[WRITE_CHUNK_SIZE*10:WRITE_CHUNK_SIZE*11])

				outfile.write(dat[WRITE_CHUNK_SIZE*3:WRITE_CHUNK_SIZE*4])
				outfile.write(dat[WRITE_CHUNK_SIZE*11:WRITE_CHUNK_SIZE*12])

				outfile.write(dat[WRITE_CHUNK_SIZE*6:WRITE_CHUNK_SIZE*7])
				outfile.write(dat[WRITE_CHUNK_SIZE*14:WRITE_CHUNK_SIZE*15])

				outfile.write(dat[WRITE_CHUNK_SIZE*7:WRITE_CHUNK_SIZE*8])
				outfile.write(dat[WRITE_CHUNK_SIZE*15:WRITE_CHUNK_SIZE*16])
	return 0

if __name__ == '__main__':
	sys.exit(main(sys.argv))
