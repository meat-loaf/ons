org $1CE488


db $53, $54, $41, $52				; Needed to stop Asar from treating this like an xkas patch.
dw SGEnd-SampleGroupPtrs-$01
dw SGEnd-SampleGroupPtrs-$01^$FFFF
SampleGroupPtrs:


dw $0000, SGPointer01, SGPointer02, SGPointer03, SGPointer04, SGPointer05, SGPointer06, SGPointer07, SGPointer08, $0000, $0000, SGPointer0B, SGPointer0C, SGPointer0D, SGPointer0E, SGPointer0F
dw SGPointer10, SGPointer11, SGPointer12, SGPointer13, SGPointer14, SGPointer15, SGPointer16, $0000, SGPointer18, SGPointer19, $0000, $0000, $0000, $0000, SGPointer1E


SGPointer01:

SGPointer02:

SGPointer03:

SGPointer04:

SGPointer05:

SGPointer06:

SGPointer07:

SGPointer08:

SGPointer0B:
db $28
dw $0015, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0014, $0023, $0014, $0025, $0014, $0027, $0013, $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F, $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B
SGPointer0C:
db $24
dw $0015, $0016, $0017, $0018, $0019, $0014, $001B, $001C, $001D, $0014, $001F, $0020, $0014, $0014, $0023, $0014, $0025, $0014, $0027, $0014, $003D, $003E, $003F, $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047, $0048, $0049, $004A, $004B, $004C
SGPointer0D:
db $19
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013, $004D, $004E, $0013, $004F, $0050
SGPointer0E:
db $14
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013
SGPointer0F:
db $1C
dw $0015, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F, $0020, $0021, $0014, $0023, $0014, $0025, $0014, $0027, $0013, $0051, $0052, $0053, $0054, $0055, $0056, $0057, $0058
SGPointer10:
db $1C
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013, $0059, $005A, $005B, $005C, $005D, $005E, $005F, $0060
SGPointer11:
db $14
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013
SGPointer12:
db $18
dw $0000, $0016, $0017, $0018, $0019, $0005, $001B, $001C, $001D, $0014, $001F, $0020, $000C, $0014, $0023, $0014, $0025, $0014, $0027, $0014, $0061, $0062, $0063, $0064
SGPointer13:
db $1E
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013, $0065, $0066, $0067, $0068, $0069, $006A, $006B, $006C, $006D, $006E
SGPointer14:
db $1E
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013, $006F, $0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077, $0078
SGPointer15:
db $14
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013
SGPointer16:
db $21
dw $0015, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $0014, $001F, $0020, $0021, $0014, $0023, $0014, $0025, $0014, $0014, $0014, $0079, $007A, $007B, $007C, $007D, $007E, $007F, $0080, $0081, $0082, $0083, $0084, $0085
SGPointer18:
db $14
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013
SGPointer19:
db $1B
dw $0015, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $0014, $001F, $0020, $0021, $0014, $0023, $0014, $0025, $0014, $0027, $0013, $0086, $0087, $0088, $0089, $008A, $008B, $008C
SGPointer1E:
db $14
dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $0014, $000E, $0014, $0010, $0014, $0012, $0013
SGEnd: