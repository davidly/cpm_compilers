                              Mix C                                2.1.0

   Mix C for CP/M comes with two c compilers.  CC.COM and CC.OVY is
the faster compiler.  It should be used in most cases.  If CC runs
out of heap (for symbol table space), you may wish to use C.COM .  This
is a version of the compiler that uses more overlays to allow additional
space for symbol table entries.


                    New Features in version 2.0
                    ---------------------------

. Maximum length of a line is increased to 256 characters

. Keywords are recognized in lower case only.  The compiler
  option /*$KEYWCASE*/ may be used to switch to upper and mixed
  case for keywords

. On the listing, lines are numbered separately for each include
  file.  A letter (a .. z) is present on the left of each line from
  an include file to indicate the depth of includes.

. When errors occur in include files, the error file (C.ERR) will
  have the name of the file as well as the line in error.

. Include files have a default extension of ".H" .  If a file name
  in an #include does not have an extension, the compiler looks first
  for the file as specified.  If no file exists by that name, the
  compiler trys the same name with ".H" as an extension.

. Initializers are supported for float and double.  Initializers for
  auto variables may use constant expressions.  Initializers for float
  and double static or global variables allow only a constant.

. Hexadecimal character constants are supported and hexadecimal
  characters may be included in strings.  They are represented by
  a backslash followed by "x" and a two digit hexadecimal number.
        Examples:
               '\x30'    is the character '0'
               "ab\x63d" is equivalent to "abcd"

. Enumerations are supported.  Enumerations are declared similar
  to structures with the keyword "enum".  The braces contain a
  list of identifiers with optional initialization values.  Values
  are assigned starting at zero and increasing by one for each
  identifier.  If an intialization value is present, the corresponding
  identifier is assigned the value supplied and counting continues
  from that point.

     Examples:
         enum primecolor {red, blue, green} c;
         /* declares a variable of type primecolor.  The identifiers
            are assigned values: red=0, blue=1, green=2.
            */
         typedef enum {orange, yellow=8, pink, aqua} color;
         /* defines the type color.  The values of the colors are:
            orange=0, yellow=8, pink=9, aqua=10
            */

         c = blue;  /* assigns the value "blue" (1) to c */


  . Structures and unions may be passed as parameters to functions.
    They are passed by value.

  . Functions may return structures or unions as results.



                        Optional Patches
                        ----------------

   Some people may wish to change some of the file names used by Mix C
so that it will use a different file, disk drive, or user number.
The addresses of these file names are listed below.  You can use DDT
(supplied with CP/M) to change the names to the ones that you prefer.
Be sure to make a copy of the original disk before attempting to make
the changes.  The file names are strings of characters up to 15
characters in length and terminated by a binary zero.  If a user
number is supplied, it must precede the disk drive name and a colon
":" must be present.

                   CC.OVY  C.OVY
   CERRORS.DAT      4099    6699     Error messages file
   A:CERRORS.DAT    410D    670D     Alternate error messages file
   C.ERR            472A    6D2A     File for lines in error
   A:               07C0    25C0     Prefix for include files that are
                                     enclosed in "<>"


   Load the file: CC.OVY or C.OVY with DDT.  Then use the "S" command
to change the file name.  Exit DDT and save the new copy of the file
on disk with the "SAVE" command.

Example - Sets the system directory for include files to drive C.  When
          #include statements have the file name enclosed in "<>", the
          compiler will look for the file on drive C.

   A>DDT CC.OVY
   DDT VERS 2.2
   NEXT  PC
   4A00 0100
   -D7c0,7c6
   07C0 41 3A 00 00 00 00 00  A:.....
   -S7c0
   07C0 41 43
   07C1 3A .
   -D7c0,7c6
   07C0 43 3A 00 00 00 00 00  C:.....
   -^C
   A>SAVE 73 CC.OVY
   A>

   The Mix linker has some file names that are built in.  In some
applications you may wish to change one or more of these names.  The
following table lists the addresses of these names.  They may be changed
using DDT as shown above.


   CLIB         167A    Library that is searched for standard functions.
                        The name may be up to 31 characters and must be
                        terminated by a binary zero byte.
   LINKER       16C2    Library that is searched if clib does not contain
                        all referenced functions.
   A: and 0A:   16DA    Directory prefix used to search for libraries.
                        Each prefix is terminated by a zero, and the entire
                        list is terminated by two zeros.
   0RUNTIME OVY 080C    File name for runtime.  Stored as a CP/M svc file
                        name (8 character name filled with blanks + 3
                        character extension).  The initial zero indicates
                        the default disk drive.  If this byte is zero, drive
                        A will also be searched.  If it is non-zero, it
                        specifies the drive to search.


When the short form of the linker is used to build a command file, the
runtime support routines are not inlcuded in the file.  To make the linker
include the runtime by default, make the following change.

   A>ddt linker.com
   DDT VERS 2.2
   NEXT  PC
   4200 0100
   -s13ec
   13EC AF 00
   13ED C9 .
   -^C
   A>save 65 linker.com

Note: When using the change command in the linker to use a different
      runtime file, the change command must be executed before any
      load commands.  The linker must know the size of the runtime so
      it can perform relocation as it loads the program.
nlcuded in the file.  To make the linker
include the r