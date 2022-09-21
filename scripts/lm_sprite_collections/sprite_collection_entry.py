from lm_sprite_collections.smap16_entry import smap16_entry
from lm_sprite_collections.ssc_entry import ssc_entry
from lm_sprite_collections.req_gfx_file_entry import req_gfx_file_entry

class sprite_collection_entry():
	def __handle_smap16_entry(vals):
		return smap16_entry(vals["xoff"], vals["yoff"], vals["tile"])
	def __format_exbits(custom, exbit):
		val = 0
		if custom:
			val |= 2
		if exbit:
			val |= 1
		return val
	def __lt__(self, other):
		return self.id < other.id

	def __init__(self, vals: dict):
		for key in vals:
			if key == "reqfiles":
				reqfiles_r = vals[key]
				if type(reqfiles_r) is list:
					#raise NotImplementedError("List of required graphics files is not yet implemented.")
					self.reqfiles = [req_gfx_file_entry(r) for r in reqfiles_r]
				else:
					self.reqfiles = [req_gfx_file_entry(vals[key])]
			elif key == "smap16":
				smap16_e = vals[key]
				if type(smap16_e) is not list:
					self.smap16 = [sprite_collection_entry.__handle_smap16_entry(smap16_e)]
				elif "dat" in smap16_e[0]:
					self.smap16 = None
					pass
				else:
					self.smap16 = [sprite_collection_entry.__handle_smap16_entry(e) for e in smap16_e]
			elif key == "which_exbyte" or key == "which_exbyte_val" or key == "id":
				if type(vals[key]) == str:
					setattr(self, key, int(vals[key], 16))
				else:
					setattr(self, key, vals[key])
			else:
				setattr(self, key, vals[key])
	def to_ssc_entry(self, kind):
		if kind == ssc_entry.ssc_kind.SSC_KIND_DESC:
			return str(ssc_entry(self.id,
			                     sprite_collection_entry.__format_exbits(self.custom, self.extra_bit),
			                     self.desc, kind,
			                     getattr(self, "which_exbyte", None), getattr(self, "which_exbyte_val", None)))
		elif kind == ssc_entry.ssc_kind.SSC_KIND_SMAP16:
			if not hasattr(self, "smap16"):
				return ""
			elif hasattr(self, "xpos_mask") or hasattr(self, "ypos_mask"):
				return ""
			else:
				return str(ssc_entry(self.id,
				             sprite_collection_entry.__format_exbits(self.custom, self.extra_bit),
				             str(" ".join([str(x) for x in self.smap16])), kind,
				             getattr(self, "which_exbyte", None), getattr(self, "which_exbyte_val", None)))
		elif kind == ssc_entry.ssc_kind.SSC_KIND_REQFILES:
			if not hasattr(self, "reqfiles"):
				return ""
			return str(ssc_entry(self.id,
			                     sprite_collection_entry.__format_exbits(self.custom, self.extra_bit),
			                     str(" ".join([str(x) for x in self.reqfiles])+'\n'), kind,
			                     getattr(self, "which_exbyte", None), getattr(self, "which_exbyte_val", None)))
		else:
			return ""
	def to_ssc_entries(self):
		ret = []
		for k in ssc_entry.ssc_kind.KINDS:
			ret.append(self.to_ssc_entry(k))
		return "\n".join(ret)
	def to_mwt_entry(self, omit_id=False):
		if not omit_id:
			return "{:02X}\t{}".format(self.id, self.name)
		else:
			return "\t{}".format(self.name)
	def to_mw2_entry(self, xoff, yoff, new_group=True):
		this_xoff = getattr(self, "display_xoff", 0)
		if type(this_xoff) == str:
			this_xoff = int(this_xoff, 16)
		this_yoff = getattr(self, "display_yoff", 0)
		if type(this_yoff) == str:
			this_yoff = int(this_yoff, 16)
		this_xoff += xoff
		this_xoff *= 0x10
		this_yoff += yoff
		this_yoff *= 0x10
		this_yoff |= 0x01 if new_group else 0x00
		this_yoff |= 0x08 if self.custom else 0x00
		this_yoff |= 0x04 if self.extra_bit else 0x00
		sprite_data_vals = [this_yoff, this_xoff, self.id]
		for x in range(0, getattr(self, "n_exbytes", 0)):
			if getattr(self,"which_exbyte", None) is not None and x == self.which_exbyte:
				sprite_data_vals.append(self.which_exbyte_val)
			else:
				sprite_data_vals.append(0)
		return bytearray(sprite_data_vals)
