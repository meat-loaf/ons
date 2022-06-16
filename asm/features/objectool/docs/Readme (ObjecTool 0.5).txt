;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; ObjecTool 0.5, by imamelia, inspired by 1024's original ObjecTool patch
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This patch enables you to insert custom objects, which in a SMW context are used to create patterns of Map16 tiles in the level (not to be confused with SNES hardware objects, which are sprite tiles).  They include things like ledges, water, powerup blocks, and pipes.  In Lunar Magic, they can be placed in the level, and some of them can be stretched to different sizes (extended objects cannot).  In this patch, custobjcode.asm is where you must put all custom code, and objectool.asm is the main patch, which is what you want to patch to the ROM.  (Normally, both .asm files should be in the same folder, though you can change the file path for the incsrc command if you want.) Information about how to create and use your own custom objects is included in the other text file.

(And no, I wouldn't have chosen to spell the name of the patch that way, but that's what the original author called it.)

