from pylibmwl.mwl_exception import MWLException

class lm_version:
	def __init__(self, major, minor):
		self.major = int(major)
		self.minor = int(minor)

class mwl_pointers:
	def __init__(self, pointer_buff):
		self.level_id               = int.from_bytes(pointer_buff[0x00:0x04], byteorder='little')

		self.layer1_off             = int.from_bytes(pointer_buff[0x08:0x0C], byteorder='little')

		self.layer2_off             = int.from_bytes(pointer_buff[0x10:0x14], byteorder='little')

		self.sprite_off             = int.from_bytes(pointer_buff[0x18:0x1C], byteorder='little')
		self.sprite_size            = int.from_bytes(pointer_buff[0x1C:0x20], byteorder='little')

		self.palette_off            = int.from_bytes(pointer_buff[0x20:0x24], byteorder='little')

		self.secondary_entrance_off = int.from_bytes(pointer_buff[0x28:0x2C], byteorder='little')

		self.exanimation_off        = int.from_bytes(pointer_buff[0x30:0x34], byteorder='little')

		self.exgfx_etc_off          = int.from_bytes(pointer_buff[0x38:0x3C], byteorder='little')

class sprite_entry:
	def __init__(self, sprite_id, sprite_ypos_exb, sprite_xpos, *args):
		self.id = sprite_id
		self.y_pos = sprite_ypos_exb
		self.x_pos = sprite_xpos
		self.exbytes = args
		pass
	def __repr__(self):
		return "id: {}, xpos: {}, ypos: {}, exbytes: {}".format(hex(self.id), hex(self.x_pos), hex(self.y_pos), self.exbytes)
	#def serialize(self):
	#	ret = b''
	#	b += self.y_pos

class object_entry:
	pass

class mwl_header:
	def __init__(self, fpath, sprite_sizes):
		self.file_path    = fpath
		self.sprite_sizes = sprite_sizes
		self.file         = None
		self.lm_version   = None
		self.mwl_pointers = None
		self.sprites = list()

	def __enter__(self):
		self.setup_file()
		return self
	def __exit__(self, type_, value, traceback):
		self.file.close()
		return self

	def setup_file(self):
		# check file validity
		self.file = open(self.file_path, 'rb+')
		marker = self.file.read(2)
		if marker != b'LM':
			raise MWLException("File does not appear to be an MWL file.")
		# setup version from file
		version = self.file.read(2)
		self.lm_version = lm_version(version[0], version[1])
		header_offset = int.from_bytes(self.file.read(4), byteorder='little')
		self.file.seek(header_offset)
		self.mwl_pointers = mwl_pointers(self.file.read(0x40))
		self.read_sprites()


	def replace_sprites_inplace(self, index_sub):
		try:
			print ("replace sprites inplace")
			self.file.seek(self.mwl_pointers.sprite_off)
			sprsz = self.mwl_pointers.sprite_size
			sprlist = bytearray(self.file.read(sprsz))
			print(sprlist)
			print("^ before v after")
			head = sprlist[8]
			exlevel = False
			if head & (0x01<<5):
				exlevel = True
			ix = 9
			while True:
				if sprlist[ix] == 0xFF:
					if exlevel:
						ix += 1
						if sprlist[ix] == 0xFE:
							break
						else:
							continue
					else:
						break
				# extract old 'is custom' exbit from y position
				exbit = (sprlist[ix] & 0x0C)>>2
				if (exbit & 0x02):
					# remove 'is custom' bit
					sprlist[ix] = (sprlist[ix]) & (~0x08)
				# skip from y pos to sprite id
				ix += 2
				sid = sprlist[ix]
				replaced_with = "none"
				if (exbit & 0x02) and (sid in index_sub):
					replaced_with = str(hex(index_sub[sid]))
					sprlist[ix] = index_sub[sid]
				elif (exbit == 0x00) and (sid == 0x5F):
					replaced = True
					repaced_with = "0x60"
					# hack for rotating plat
					sprlist[ix] = 0x60
				thissz = self.sprite_sizes[sid+(0x100*exbit)]
				ix += (thissz-3)+1
				print("sprite id", hex(sid), "exbits", exbit, "size", thissz, "replaced_with", replaced_with)
			print(sprlist)
			self.file.seek(self.mwl_pointers.sprite_off)
			self.file.write(bytes(sprlist))
		except Exception as x:
			print(x)


	def read_sprites(self):
		self.file.seek(self.mwl_pointers.sprite_off)
		sprsz = self.mwl_pointers.sprite_size-9
		csprsz = 0
		#print("sprite data at", hex(self.mwl_pointers.sprite_off), "in mwl, has size", sprsz)
		# mwl list header
		self.file.read(8)
		# sprite header
		head = self.file.read(1)
		exlevel = False
		if int.from_bytes(head, byteorder='little') & (0x1<<5):
			exlevel = True
			#print("exlevel sprite list")
			

		#while csprsz < sprsz:
		while True:
			#print("current file off: ", hex(self.mwl_pointers.sprite_off+csprsz))
			spr_dat = self.file.read(1)
			csprsz += 1
			# check done
			# assumes new lm sprite header for exlevels
			if spr_dat[0] == 0xFF:
				if not exlevel:
					return
				marker = self.file.read(1)
				csprsz += 1
				print("y-pos is 0xff, y-pos+1 is", hex(int.from_bytes(marker, byteorder='little')))
				if marker[0] == 0xFE:
					return;
				else:
					continue;
			spr_dat += self.file.read(2)
			csprsz += 2
			exbit = (spr_dat[0] & 0x0C)>>2
			#if exbit > 0x02 and int.from_bytes(spr_dat[2], byteorder='little') in index_sub:
					
			#print(hex(spr_dat[0]), hex(spr_dat[1]), hex(spr_dat[2]))
			sz = self.sprite_sizes[spr_dat[2]+(0x100*exbit)]
			#print("sprite_id ", hex(spr_dat[2]), "(exbit: ", hex(exbit), ") size ", hex(sz))
			if (sz == 3):
				self.sprites.append(sprite_entry(spr_dat[2], spr_dat[0], spr_dat[1]))
			else:
				spr_dat_exb = self.file.read(sz-3)
				csprsz += (sz-3)
				self.sprites.append(sprite_entry(spr_dat[2], spr_dat[0], spr_dat[1], *spr_dat_exb))

