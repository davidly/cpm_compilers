This ZIP file contains the ISIS-II PLM-80 v3.1 compiler.

These files were pulled from the MPM2 source code disks and from the ISIS environment for MS-DOS provided by INTEL.

The file to invoke the ISIS environment under CP/M or MP/M is called ISX.COM.  Some of the submit files included with the MP/M II source refered to a IS14.COM file, so I just copied the ISX.COM to IS14.COM and ISIS.COM leaving 3 files that do the exact same thing.

Now, when the ISIS environment is running, it refers to the drives using the following syntax:

	:F0:	- This is the CP/M drive A:
	:F1:	- This is the CP/M drive B:
	:F2:	- This is the CP/M drive C:
	:F3:	- This is the CP/M drive D:

Get the picture?  ISIS doesn't know anything about user numbers, so all files MUST be in USER 0 on each drive for the system to work.  Also, if the ISIS environment can't find the file it is looking for in the current drive, it defaults to :F0:, then it fails.

Several of the CP/M commands have direct equivalant versions, e.g.;

	CP/M		ISIS-II
	----		-------
	DIR		DIR
	ERA		ERA
	TYPE		TYPE
	REN		REN
	DDT		DBUG - This does some form of trace (asks, "TRACE LEVEL:"
			!    - This is a comment indicator
	A:		:F0:
	B:		:F1:
	C:		:F2:
	D:		:F3:

While the ISIS environment is running, your command prompt will be the floppy number followed by the greater than symbol, e.g.; for floppy drive A: (defualt) = "0>", for drive B: = "1>", etc.

Some programs may allow you to extend the command line by supplying an ampersand "&" as the last character before pressing return.  I haven't tried this yet.

I haven't tried to compile CP/M using this system, so you will have to figure out how best to set up your environment to compile it.  There is a site in the UK that has some instructions for compiling CPM 3 using the MS-DOS ISIS emulator, which I believe is also available through their site, which is http://www.seasip.demon.co.uk/Cpm/

I don't have ANY idea what the command syntax is for any of these commands.  If anyone out there has documentation for the ISIS environment and utilities, I would appreciate a copy (!!!PLEASE!!!)

Here is a brief description of the files, all files WITHOUT an extension are ISIS-II executable programs, some of the programs I didn't have time to figure out.

ASM80		- ISIS-II 8080 Assembler, runs ONLY from ISIS environment.
CC.SUB	- SUBMIT file to compile & link a PLM program for execution at 0x0100.
CONV86	- ISIS 8080 to 8086 assembler converter.
CPM		- ISIS program to return to CPM from ISIS environment (used in SUBMIT files)
		  this program displays some garbage on my screen just before exiting ISIS.
		  This program also trashes the Z-System shell stack (don't know why, haven't
		  looked into it)

*.LIT		- Literal definitions for PLM programs.

GENHEX.COM	- CP/M OBJ to HEX converter utility.
GENMOD.COM	-
HEXOBJ	- ISIS hex to obj converter utility.

IS14.COM,
ISX.COM,
ISIS.COM	- The ISIS-II Environment for CP/M systems.

IXREF		- ISIS cross reference utility.
LIB		- ISIS Librarian utility.
LINK		- ISIS Linker utility.
LINK.OVL	- ISIS Linker overlay file.
LOCATE	- ISIS Object file locater utility.
MONX		-
OBJCPM.COM	- Used in CC.SUB script.
OBJHEX	-
P.SUB		-

PLM80		- The ISIS-II PL/M-80 Compiler version 3.1
PLM80.LIB	- Runtime library. All programs link to this library.
PLM80.OV#	- Overlay files for the compiler.

PLMLANG.DOC	- Brief description of the PL/M Language.
PLMSAMP.PLM	- A Sample program written in PL/M.
READ.ME	- This file.
SETEOF.COM	- Used in CC.SUB script.
SUBMIT	- ISIS-II Submit command (similar to CP/M's SUBMIT utility)

X0#00
X0#00.ASM	- Link files for PL/M Programs.  See CC.SUB script for usage.

Enjoy,

Rick Campbell
Sr. Technical Specialist
SpaceLabs Medical
rickca@jps.net

