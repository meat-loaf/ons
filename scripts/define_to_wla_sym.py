#!/bin/python3

"""convert a bunch of asar defines from a specifically-formatted file
to a usable set of wla label symbols. Expects a 'consts' file as well
(a file with only asar constant defines)"""

import re
import os
import sys

def clean_line(line, ignore) -> str:
	l = re.sub(r';.*', '', line).strip()
	if any(e in l for e in ignore):
		return ""
	elif l.startswith("assert"):
		return ""
	return l.replace("\t","").replace(" ", "").replace("|!addr", "").replace("|!bank", "")

def get_base(s) -> int:
	base = 10
	base = 2  if s[0] == '%' else base
	base = 16 if s[0] == '$' else base
	return base

def resolve_define(val, consts, ramdict) -> int:
	if val in consts:
		return consts[val]
	elif val in ramdict:
		return ramdict[val]
	else:
		raise RuntimeError("define {} not defined before use.".format(val))

def parse_ram(line, consts, ramdict) -> (str, int):
	op = '+'
	vals = line.split("=")
	rhs = vals[1]
	val = 0
	e = rhs.split(op)
	for x in e:
		if x[0] == '!':
			val += resolve_define(x, consts, ramdict)
		else:
			base = get_base(x)
			if base != 10:
				x = x[1:]
			val += int(x, base)
	return (vals[0], val)

def main(argv) -> int:
	if len(argv) != 3:
		print("Usage: {}, [RAM_DEFINES_FILE] [CONSTANTS_FILE]".format(argv[0]));
		return 1;
	consts = dict()
	ram = dict()
	barred = ['if ', 'else', 'endif', 'sa1rom', 'lorom', '?=', 'include', 'includeonce']
	with open(argv[2]) as const_defs_file:
		for line in const_defs_file:
			sanitized = clean_line(line, barred)
			if len(sanitized) == 0:
				continue;
			val_arr = sanitized.split("=")
			v = val_arr[1]
			base = get_base(v)
			if base != 10:
				v = val_arr[1][1:]
			consts[val_arr[0]] = int(v, base)

	with open(argv[1]) as ram_defs_file:
		for line in ram_defs_file:
			sanitized = clean_line(line, barred)
			if len(sanitized) == 0:
				continue
			v = parse_ram(sanitized, consts, ram)
			ram[v[0]] = v[1]

	print("\n[labels]")
	for k,v in ram.items():
		if v < 0x0100:
			print("80:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
			print("81:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
			print("82:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
			print("83:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
			print("84:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
			print("85:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
			print("86:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
			print("87:00{} {}".format(hex(v).lstrip("0x").zfill(2), k.replace("!", "")))
		elif v < 0x2000:
			print("80:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
			print("81:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
			print("82:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
			print("83:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
			print("84:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
			print("85:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
			print("86:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
			print("87:{} {}".format(hex(v).lstrip("0x").zfill(4), k.replace("!", "")))
		else:
			hv = hex(v).lstrip("0x").zfill(6)
			print("{}:{} {}".format(hv[0:2], hv[2:6], k.replace("!", "")))

if __name__ == '__main__':
	rval = 1
	try:
		rval = main(sys.argv)
	except Exception as e:
		print("Error: ", e, file=sys.stderr)
	sys.exit(rval)
