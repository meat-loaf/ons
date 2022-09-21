class ssc_entry():
	def __init__(self, index, exbits, data, kind, exbyte=None, exbyte_val=None, xmask=None, ymask=None):
		if (exbyte is not None and exbyte_val is None) or \
		   (exbyte is None and exbyte_val is not None):
			raise ValueError("Must have both of `exbyte' and `exbyte_val' params, can't have only one.")
		elif exbyte is not None and (xmask is not None or ymask is not None):
			raise ValueError("Can't specify based on both extra bit and x/y position.")
		self.index = index
		self.data = data
		self.kind = ssc_entry.ssc_kind(kind, exbits, exbyte, exbyte_val)
	def __str__(self):
		return "{:02X} {} {}".format(self.index, self.kind, self.data)

	class ssc_kind():
		SSC_KIND_DESC = 0
		SSC_KIND_SMAP16 = 2
		SSC_KIND_REQFILES = 8
		KINDS = (SSC_KIND_DESC, SSC_KIND_SMAP16, SSC_KIND_REQFILES)

		def __err(v, k, t):
			if (type(v) is not t):
				raise TypeError("{} must be {} (got {} with data {})".format(k, t, type(v), v))
	
		def __init__(self, base, exbits, exbyte=None, exbyte_val=None):
			ssc_entry.ssc_kind.__err(base, "base", int)
			ssc_entry.ssc_kind.__err(exbits, "exbits", int)
			if exbyte is not None:
				ssc_entry.ssc_kind.__err(exbyte, "exbyte", int)
			if exbyte_val is not None:
				ssc_entry.ssc_kind.__err(exbyte_val, "exbyte_val", int)
			
			if exbits > 4:
				raise ValueError("Exbits value is invalid.")
			if exbyte_val is not None:
				if exbyte_val > 0xFF:
					raise ValueError("Byte value cannot exceed 0xFF")
			if exbyte is not None:
				if exbyte > 4:
					raise ValueError("Extension byte to look at cannot be greater than 4.")
				elif exbyte < 0:
					raise ValueError("Don't pass negative numbers for exbyte.")
				exbyte += 2
			if base not in ssc_entry.ssc_kind.KINDS:
					raise ValueError("Bad base `{}'.".format(base))
			self.base = base;
			self.exbits = exbits
			self.exbyte = exbyte
			self.exbyte_val = exbyte_val
	
		def __str__(self):
			#eb_nb_hi = 1 if (self.exbyte_val is not None and self.exbyte_val > 10) else 0
			#eb_nb_lo = 0 if self.exbyte_val is None else (self.exbyte_val-10) if self.exbyte_val > 10 else self.exbyte_val
			eb_nb = "{:02X}".format(0 if self.exbyte_val is None else self.exbyte_val)
			
			return "{}{}{}{}".format(self.exbyte if self.exbyte is not None else 0,
			                           eb_nb, self.exbits, self.base)
	class ssc_kind_exbyte(ssc_kind):
		pass

