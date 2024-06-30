V1.30 Release Notice 26 July 1988
=================================

1/	A problem with exporting types from nested modules has been fixed.

V1.29 Release Notice
====================

1/	There was a problem with procedures with more than 256 bytes of 
parameters. Parameters were having the top byte of their addresses set to
zero. Now works as intended.

2/	Here is an example program doing random I/O using the Z80 Streams 
module. I have tested this module and it works:

MODULE Testm;

FROM	Files IMPORT FILE,Create,Lookup,Close;

FROM	Streams IMPORT STREAM,Connect,Disconnect,ReadWord,WriteWord,Direction,
		ChangeDirection,SetPos;

FROM	Terminal IMPORT WriteString,WriteLn;

FROM	SmallIO IMPORT WriteCard,ReadCard;

VAR	f:FILE;
	s:STREAM;
	i,j,k:CARDINAL;
	reply:INTEGER;
BEGIN
	Create(f,'test.dat',reply);
	IF reply<>0 THEN
		WriteString('Could not create test.dat');
		WriteLn;
		HALT
		END;
	Connect(s,f,output);
	FOR i:=0 TO 200 DO WriteWord(s,i) END;
	Disconnect(s,TRUE);
	Lookup(f,'TEST.DAT',reply);
	IF reply<>0 THEN
		WriteString('Could not create test.dat');
		WriteLn;
		HALT
		END;
	Connect(s,f,input);
	LOOP
		WriteString('Enter word to change: ');
		ReadCard(i);
		WriteLn;
		SetPos(s,0,2*i);
		ReadWord(s, j);
		WriteString('Found: ');
		WriteCard(j, 1);
		WriteLn;
		ChangeDirection(s, output);
		SetPos(s,0,2*i);
		j:=10;
		WriteWord(s,10);
		ChangeDirection(s,input);
		END;
	END Testm.


V1.28 Release Notice
====================

1/ The compiler did not perform comparisons of subranges of integer correctly.
They were treated as if insigned. This now works. 

2/	Range checking was causing some spurious exceptions. This is now fixed.

V1.27 Release Notice.
=====================

This was an internal test version only.  Not released.

V1.26 Release Notice.
====================

There are four differences between V1.26 and V1.25.

1/ A new loader table has been added to support the trimmer in the advanced 
programmer kit. If you are using the advanced programmer's kit, you must 
recompile all modules with V1.26 of the compiler. If you are not using the 
kit, there is no need to recompile since the v1.26 linker will
link modules compiled with the V1.25 compiler. If you do not want to 
recompile, you should contune using the library files from V1.25.

2/ Some of the standard modules used initialized variables which were later
written to. This was not a problem in the past because these modules were
associated with CP/M. However, now some of our customers are using a Z80 
board with a stand-alone emulation of CP/M and they are putting their 
programs in ROM. Therefore, the initialized variables have been changed
to uninitialized variables and the initilization has been done in the main
program parts of the offending modules. The modules that have been altered 
are: realinout, terminal, streams, smallio, processes, inout.

Also, all global variables have been removed from SmallIO and Strings. This
ensures that you will not have problems using these modules from a
multi-tasking program.

The advanced programmer's kit (that's left associative) is now available.
This provides a program that removes the unused parts of modules, an 
overlayer, and a multi-tasking kernel.

3/ The strings module contained several bugs:

   a)The delete module left a bad character on the end of a string if it
filled the array holding it.
   b)Inserting a null string looped the machine.
   c)Copying a string that filled the destination resulted in one too few
characters being copied.
   d) Insert could overflow in some cuircumstances and was moving more 
characters than it should anyway.

 4/ The compiler used top clear the top bit of each character read. This 
was because some people would edit their source in Wordstar document mode
which uses the high bit for nefarious purposes. Some people complained that
this made it impossible to output messages in foreign languages so I took it 
out.

V1.25 Release Notice.
====================

There is a new error message:
Error 159:Only 40 labels allowed per CASE variant (linker limit)

Exceeding this limit in earlier versions (actually, the limit was 20)
would cause the linker to hang. You can have more than 40 labels
total in a CASE statement but only 40 are allowed per variant (i.e.
per alternative). A range (e.g. 'A'..'Z')counts as two.

REALINOUT has been extensively modified and now supports reading
and writing from/to a string as well as a file. The routines
WriteRealText(VAR Text:ARRAY OF CHAR;Val:REAL;Places:CARDINAL);
and WriteRealFixedText(VAR Text:ARRAY OF CHAR;Val:REAL;Places,decimals:CARDINAL);
are now available.  

Values are read in using ReadRealText(VAR Text:ARRAY OF CHAR;VAR Pos:CARDINAL;
VAR Value:REAL);

See REALINOUT.DEF for more details.

Bug Fix:
========

For one byte sets (eg SET OF [0..3]) checking if a value was in the set,
when the value was less than the smallest value or larger than the largest
caused 1 byte to be left on the stack. The problem did not occur if the
value was in the possible range of the set but was not in the set, which is
why it was not detected by the test set. 

V1.24 Release Notice
====================

Changes limited to minor bug fixes.
V1.23 Release Notice
====================
This was a local release fixing a couple of minor bugs. It was 
not generally distributed.
V1.22 Release notes
===================

Recent releases have been concerned with fixing bugs. With this
release, the integration of the editor and the compiler is improved.

You can now save up to 10 errors before calling the editor from the compiler.
Each time an error is detected, you will be presented with the choices:
	a - abort the compile
	e - call the editor
	i - ignore this error and continue compiling
	space - save this error and continue compiling

When you enter the editor, the editor positions to the first saved error
as it did before but you can now position to other errors as well.

The sequence ^Q^E^N moves to the next error
	     ^Q^E^P goes back to the previous error
	     ^Q^E^C redisplays the current error

In addition ^Q^E0 through ^Q^E9 move the the zeroth through
ninth error respectively.


V1.17 Release Notice
====================

With release 1.17, a number of bugs have been fixed and some new 
facilities added. The new facilities are:

1/ The editor now allows you to use the first letter of a menu option to
   select that option.

2/ Range Checks

There is a new compiler flag /R. This flag allows you to include range 
checks in your module. In addition, while this flag is active, checks
are performed for integer and cardinal arithmetic overflows.

You can turn the checking code on and off using the psuedo-comments 
(*$R+*) and (*$R-*) respectively. You can use these instead of or as well 
as the /R compiler flag.

There is a new linker flag: /O which causes all checking code to be omitted.
Thus, once your program is working, you can re-link without the checking
code without re-compiling.

When a range error or an integer or cardinal overflow is detected, you will
receive the message 
	out of range near xxxx

where xxxx is the address of the error. In a later version, we will provide
a link between this error checking and M2DEBUG. You can use the LINKER /R
flag to determine approximately where the error is, or you can run the
program in trace mode using M2DEBUG to find the error.

There is also a new error message in the compiler:

147	Constant out of range.

This error is produced when you attempt to use a constant for a subrange
and the constant is not in the subrange. For example:

TYPE	Subr=[0..10];
VAR	s:Subr;
	a:ARRAY Subr OF CARDINAL;
	i:CARDINAL;

	s:=11;
	a[11]:=0;

Both these statements would produce error 147.


Note that the checking is for range errors, not just array bound errors,
so that the statement:

	i:=11;
	s:=i;

would produce an out of range error. Also, no check is made when the 
value cannot be out of range. Hence,

	a[s]:=0;

produces no checking code because s is of type Subr and so its value must
be within the bounds of the array. Of course, if it is undefined, then it
may have a bad value but this will not be detected here. To catch these
errors, I have added a /U compiler flag. If you use /U instead of /R, the
compiler ignores the fact that a particular value 'has' to be in range 
and generates check code anyway. /U is a last minute addition. You CANNOT
use (*$u+*) or (*$u-*). Instead, use (*$R+*) and (*$R-*) to turn off 
checking in either case - once you have selected /U on the compiler line
(eg M2 Prog.mod/U), then undefined checking will always be on whenever
checking is enabled. The U flag does not itself enable checking - so you
should use M2PROG.MOD/UR to enable undefined and range checking.

Of course, using /U increases the size of your modules compare to /R. /R
gives larger modules than no checking. You can mix checked and unchecked
modules in a given link, so you only need check those modules you are
working on.

If you use the /T option on the link edit, then all traps for bound errors
and integr and cardinal overflows will be directed to the debug module
M2DEBUG (which you must run before the program being debugged - it will
terminate and stay resident). This allows you to get a traceback of where
you are without having to watch the number fly by. Use CTRL-A to gain the 
attention of M2DEBUG and then disable all tracing. Of course, you must use
both the R and T compiler flags for this to be useful.

V1.18 Release Notice
====================

V1.18 fixes all known bugs. It has been made smaller than V1.17 by replacing
some Pascal code by assembly langauge code in the compiler. 

SYM files can now be placed in a library called SYMFILES.LBR. This file must
be on one of the searched disks if it is to be found. A free standing SYM file
will be used in preference to one contained in SYMFILES.LBR. There is a limit
of 48 SYM files to the library.

Processes has been updated to support mode 2 interrupts. See the comments in
that module for details.


===============================
Note on initializers in FTL

Error message number 76 "initialization error" also is printed when attempting
to use an initializer in a procedure.  Initializers are not standard Modula-2
and FTL does not allow them except in the declaration section of a module.

V1.20
=====

Version 1.20 reflects the updated documentation. Some bugs have 
been fixed. A new library utility called MLU has been provided. The
assembler now assembles all known opcodes with a very small number of
exceptions (out n,a in a,n instead of out (n),a in a,(n) and EX AF instead
of EX AF,AF'). The error message file is half the size.

You still need to unsqueeze the Modula2.lbr file but the other libraries
are not squeezed.
==============================
UNLOAD2.COM

UNLOAD2.COM is provided to convert files into
Intel Hex format.  This is useful for making ROMable code.
To use, type: "UNLOAD2 ufn.ext", <return>.  Unload will do
the rest.

                                                                 ^ €¿  åODULA2 LQR               n €?  