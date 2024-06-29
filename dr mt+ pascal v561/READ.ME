









          ********************************************************************
          ********************************************************************
          **********************                         *********************
          **********************        PASCAL/MT+       *********************
          **********************                         *********************
          ********************************************************************
          ********************************************************************
          **********                                                **********
          *******                     Release Notes                    *******
          ******                                                        ******
          ********************************************************************
          ********************************************************************
          ********************************************************************
          *****                                                          *****
          *****           Copyright (c) 1983 by Digital Research         *****
          *****                                                          *****
          *****    CP/M is a registered trademark of Digital Research.   *****
          *****                                                          *****
          ********************************************************************




          These  release  notes  pertain  to  both  the   software   and   the
          documentation set for the Digital Research product:

               Pascal/MT+ For the CP/M Family of Operating Systems

          They provide the most current information regarding:

             o Sofware bugs that have been identified since the  product
               was released.

             o Errors or omissions in the documentation set  that  could
               not  be  corrected  because  of  the lead time needed for
               typesetting and printing.

















                                          1







                                     SOFTWARE BUGS



          The following software bugs have  been  identified  in  the  current
          release (5.6):



          Problem:  When compiling with the D (debugger)  command-line  option
                    enabled,  symbol  table  overflow is not always detected.
                    This problem is related to the total number of constants,
                    types,  and  variables  declared  in  the program you are
                    compiling.

          Solution: Reduce the number  of  entries  in  the  symbol  table  by
                    breaking   the  program  down  into  separately  compiled
                    modules.

          Problem:  Conformant arrays do not always work correctly.  They work
                    for  one-dimensional arrays of simple types.  They do not
                    work for one-dimensional arrays of structured  types,  or
                    multi-dimensional arrays of any type.

          Solution: There is no fix  available  at  this  time.   Work  is  in
                    progress.

          Problem:  Run-time range checking enabled  by  the  $R+  source-code
                    option does NOT work when indexing into string variables.

          Solution: Use the predefined functions  and  procedures  for  string
                    handling when working with the STRING data type.

          Problem:  The ODD function does not return values in the set  [0,1].

          Solution: Application Note #3, available through  Technical  Support
                    fixes this problem.

          Problem:  The $K9 and $K10 compiler options cause  the  compiler  to
                    erroneously  issue  Error #103 upon encountering the EXIT
                    procedure.

          Solution: If you intend to use EXIT, you cannot use the $K9 and $K10
                    options.

          Problem:  Using the construct

                        WRITE(f,data)

                    with  files  of  characters  is  NOT  equivalent  to  the
                    sequence of statements

                        f^ := data, PUT (f)

          Solution: Declare the file variable f, to be of type BYTE.



                                          2








          Problem:  The compiler does not detect the erroneous assignment of a
                    REAL  number  to  a  variable  of  type  WORD.  A program
                    containing such  an  assignment  will  compile  and  link
                    properly, but will halt indefinitely when executed.

          Solution: Do not assign a REAL variable to a variable of type  WORD;
                    it is an invalid assignment.

          Problem:  When using FPREALS.ERL, some formatted real numbers in the
                    interval  (0,1) default to scientific notation on output.

          Solution: There is no fix available at this  time;  the  problem  is
                    being studied.

          Problem:  The  procedures  BLOCKREAD  and  BLOCKWRITE  do  not  work
                    correctly  on  operating  systems  with  allocation block
                    sizes larger than 1K because the correct extents are  not
                    always opened.

          Solution: On systems with allocation block sizes  greater  than  1K,
                    you  must  use the procedures SEEKREAD and SEEKWRITE with
                    the file variable declared as follows:

                        VAR
                          f : FILE of PACKED ARRAY[0..127] OF BYTE

          Problem:  The MOD function does not work correctly when the  modulus
                    is a negative integer; otherwise, it works correctly.

          Solution: There is no fix available at this  time;  the  problem  is
                    being  studied.  In  the  interim,  do  not  use MOD with
                    negative modulus.

          Problem:  When using BCD reals, the run-time system does not  detect
                    division by zero.  This problem can indefinitely halt the
                    application program.

          Solution: You can avoid this problem by adding code to  the  program
                    that  tests  the  divisor  for zero BEFORE performing the
                    division, and  takes  appropriate  action  based  on  the
                    outcome.

          Problem:  When using BCD reals, dividing a very small  number  (such
                    as   0.0001)   by   a   very   large   number   (such  as
                    10000000000000.0000) can cause an indefinite halt in  the
                    application program.

          Solution: There is no solution at this time; the  problem  is  being
                    studied.

          Problem:  When using BCD reals, multiplication and division are very
                    slow.

          Solution: This performance problem is currently being studied.



                                          3







                         **************************************
                         * SPECIAL INSTRUCTIONS FOR SPP USERS *
                         **************************************



          The Speed Programming Package SPP, as distributed will NOT run  with
          Pascal/MT+ release 5.6.  You must use the utility program SPPFIX.COM
          to remove the excess entry point names from the name tables  at  the
          end  of  the  overlay file SPP.002.  SPPFIX.COM is included with the
          5.6 distribution disks.

          Note: The file STRIP.SRC, supplied on your  distribution  disk  will
          NOT work on SPP.002.  (See Documenatation Errata, below).

          In order to get SPP to run with Pascal/MT+ (release 5.6),  you  must
          perform the following steps:

            1) Compile NSB.SRC

            2) Change the linker command file SPPMAIN.CMD as follows

                   /V:1700/D:8300/X:1500

            3) Change all the other CMD files to

                   /P:1700

            4) Link the SPP files using the SUBMIT command

                   A>submit linkspp

            5) Use the command

                   A>sppfix 1700 [<drive>:]

               to strip all the unused entry points.





















                                          4







                        ****************************************
                        * AMD9511 HARDWARE MATH CHIP INTERFACE *
                        ****************************************



          The distribution disks contain several  files  that  enable  you  to
          create a hardware floating point package using the AM9511 math chip.

          To use this interface you must perform the following steps:


            1) Edit the file AMDIO.SRC, on your distribution disk, so that the
               constant  definitions  for  the  port addresses agree with your
               hardware configuration.

            2) Compile AMDIO.SRC.

            3) Link the application with the following command line:

               A>LINKMT <user modules>,AMDIO,FPRTNS,TRAN9511,FPREALS/S,PASLIB/S

            4) To use an early release of the AM9511 chip, declare @I95 as  an
               external  procedure  and  call  it from the main program.  This
               routine will initialize the chip.

          Note: The file APUSUB.MAC contains the AMD9511 drivers that TRAN9511 
          uses and is included for your information only.  APUSUB.MAC does NOT 
          need  to  be  assembled  because  it   is   alreadly   included   in 
          TRAN9511.ERL.




























                                          5







                                ************************
                                * DOCUMENTATION ERRATA *
                                ************************



          The following are errors in the Pascal/MT+ Language Reference Manual 
          (February 1983 edition):


          Page 2-2.   Replace the second paragraph with following:

                      "You cannot use reserved words such as BEGIN or  IF  as 
                      identifiers.   Also,  you  should  not  use  predefined  
                      identifiers  to  name  any  object  in  your   program, 
                      especially  if the predefined identifier is the name of 
                      a routine in the run-time  library  PASLIB.ERL.   Using 
                      the  name  of a run-time routine as an identifier makes 
                      the routine inaccessible from inside the scope  of  the 
                      new  definition.  This will cause unpredictable results 
                      in your program.

          Page 3-3.   Change WORD(x) to WRD(x)

          Page 6-2.   Change the third paragraph to read:

                      "The data type for a function must be  a  simple  type.  
                      Put  the  type  name  after  a  colon at the end of the 
                      function heading.

          Page 6-8.   In Table 6-1, change the Returns type for  the  Function 
                      ABS from REAL to "same as NUM".

          Page 6-10.  In Table 6-1, the Function @HERR returns a BOOLEAN type, 
                      and  the  the  Function  ADDR  returns a POINTER not an 
                      INTEGER type.  Also change FUNCTION @RLS  to  PROCEDURE 
                      @RLS.

          Page 6-12.  Change the first sentence in  the  second  paragraph  to 
                      read:

                      "You can use ADDR to reference external variables."

          Page 6-13.  Change the example to ARCTAN(1) = 0.78539

          Page 6-19.  Change the first sentence in  the  second  paragraph  to 
                      read:

                      "CLOSEDEL closes and deletes files after use."  In  the 
                      last  paragraph,  change  File Control Blocks (FCBs) to 
                      File Information Blocks (FIBs).







                                          6







          Page 6-44.  Change the explanation of the PACK and UNPACK  functions 
                      to read:

                      "The Pascal/MT+ compiler accepts PACK  and  UNPACK  for 
                      compatibility  with  other  versions  of Pascal.  These 
                      procedures are not necessary because Pascal/MT+ is byte 
                      oriented.  However,  in Pascal/MT+ both PACK and UNPACK 
                      generate calls to the MOVE function (see MOVE)."

          Page 6-56.  At the top of the page, change

                           SEEKREAD, SEEKWRITE Function

                      to read as follows:

                           SEEKREAD, SEEKWRITE Procedure

          Page 6-68.  Change the fifth paragraph to read:

                      "WRITE  and  WRITELN  treat  strings   as   arrays   of 
                      characters.  They  do not write the length byte to TEXT 
                      files.  They do write the length byte to files of other 
                      types."

          Page 6-75.  At the top of the page, change

                           @HERR Function

                      to read as follows:

                           @HERR

                      Also, change the syntax description from

                           FUNCTION @HERR

                      to read as follows:

                          VAR
                            @HERR : EXTERNAL BOOLEAN


          Page 7-2.  In the second paragraph, change F2 to F3 in:

                          F2^ := 45;

                      puts the integer value 45 in the  buffer  of  the  file 
                      variable F2.

          Page 7-5.  Add the following to the end of the  first  paragraph  in 
                      Section 7.4:

                      "Note: You cannot use the debugger with redirected I/O.  





                                          7







          The  following  are  errors in the Pascal/MT+ Programmer's Guide for 
          the CP/M Family of Operating Systems (March 1983 edition):


          Page 1-1.   In the third paragraph, change 8K bytes to 3K bytes.

          Page 1-3.   In Table 1-1, under filetype SRC, make the change

                      "(the compiler also accepts PAS as a source filetype)"

          Page 1-3.   In Table 1-1, under filetype SYM, make the change

                      "Symbol file used by SID, the symbolic debugger"

          Page 1-4.   In Table  1-2,  change  DEMOPROG.SRC  to  PROG.SRC,  and 
                      LIBMT+.COM to LIBMT.COM.

          Page 1-5.   In Table 1-2, change USCD-style to UCSD-style.

          Page 1-7.   The second paragraph states you can use the distribution 
                      disks  just  as  they  are.  This is not true; they are 
                      write-protected.  You must copy them onto backup disks.  

          Page 2-3.  Change the first paragraph in Section 2.2.2 to read:

                      "During Phase 0,  When  the  compiler  finds  a  syntax 
                      error,  it  displays the line containing the error.  If 
                      you are using the MTERRS.TXT file,  the  compiler  also 
                      displays  an  error  description.  In all other Phases, 
                      the compiler displays the  line  number  and  an  error 
                      identification number."

          Page 2-4.   In Table 2-1, change  the  description  of  the  default 
                      action for the A option to read

                      "Compiler does not automatically chain"

          Page 2-16.  Table  2-5  is  incomplete.  Add  the  following   error 
                      message:

                      Undefined symbol: xxxxxxxxx

                      Explanation: The specified symbol is referenced but not 
                      defined in the module.














                                          8







          Page 3-6.   Section  3.2.2,  second  paragraph.   Change  the  first 
                      sentence to read as follows:

                      "When part  of  a  program  calls  an  overlay-resident 
                      routine,  the  program accesses that routine through an 
                      entry-point table at the end of the overlay."

          Page 3-9.   In the first paragraph, change 80H to 100H.

          Page 3-9.   Under the /X option, in the second paragrap, change  the 
                      last sentence to read as follows:

                      "nnnn is the hexadecimal number of bytes to reserve for 
                      overlay data."

          Page 3-10.  In the first paragraph, change the last sentence to read 
                      as follows:

                      "The minimum value for  /D  is:  100H  +  size  of  the 
                      largest overlay (rounded to the next multiple of 128) + 
                      the size of the root code."

          Page 3-10.  Change the fourth paragraph to read as follows:

                      "When you  link  a  root  program  the  first  time  to 
                      generate  the SYM file, you must use the /V:n option to 
                      tell the linker to save an area in the code segment for 
                      use as the overlay area address table."

          Page 3-10.  Change the command line for linking an overlay to:

               LINKMT <prog>=<sym file>/O:n,<modules|libraries>/P:mmmm/X:ssss


          Page 3-11.  Change section 3.2.5 to 3.2.6.  Insert section 3.2.5  as 
                      follows:

                      3.2.5  Overlay Name Table

                      The first three  bytes  of  an  overlay  file  are  the 
                      overlay  number  followed  by a two byte pointer to the 
                      name table for the overlay.  Entries in the name  table 
                      are  ten  bytes long, eight bytes for the name followed 
                      by two bytes for the address.

                      After the overlay manager ensures that the  overlay  is 
                      in  memory,  it  searches  this table for the requested 
                      routine.  The overlay  manager  then  branches  to  the 
                      address found in the name table.

                      The linker always includes  all  entry  points  to  the 
                      overlay,  including  run-time  routines,  in  this name 
                      table  even  if  only  one  of  the  entry  points   is 
                      necessary.




                                          9







                      STRIP is a utility program which reduces the  disk  and 
                      memory    requirements   for   overlays   by   removing        
                      unnecessary entry point names from the  name  table  at 
                      the end of an overlay file.

                      Note: STRIP is included on  the  distribution  disk  in 
                      source form (STRIP.SRC) only.

                      In order to use STRIP, you must know:

                        o the load address of the overlay (the  parameter  to 
                      the V and P linker options).  This is used to calculate 
                      the offset of the name table within the overlay file.

                        o the names of all the essential entry  points.   For 
                      example,  those  declared  as  EXTERNAL  in your Pascal 
                      program or module.


                      You invoke STRIP with the command:

                           STRIP [<filename>]

                      If you omit the <filename>, STRIP prompts you  for  the 
                      filename.  You then enter the name of the overlay file, 
                      for example ROOT.001.  STRIP then prompts you  for  the 
                      base  address, the loading address.  You then enter the 
                      hexadecimal address of the overlay area into which  you 
                      want the overlay file to be loaded when it is executed, 
                      for example 1600.

                      STRIP first displays all of the entry point names,  and 
                      then  begins  displaying each entry point one at a time 
                      followed by the prompt

                           (Y/N/Q)?

                      If you want to retain the name, enter  a  Y;  otherwise 
                      enter  a N if the name is to be removed, or a Q to exit 
                      this phase of the operation.

                      When  all  entry  points  have  been  processed,  STRIP 
                      displays  all  of  the  entry points that have not been 
                      deleted, and asks whether to write the  stripped  file.  
                      If  everything  is  correct, enter Y, and STRIP deletes 
                      the old file and replaces  it  with  the  new  stripped 
                      file.

          Page 3-13.  Change all three link command lines as follows:

                          A>LINKMT PROG,PASLIB/S/V1:2000/D:4000/X:100

                          A>LINKMT PROG=PROG/O:1,MOD1,PASLIB/S/P:2000/L

                          A>LINKMT PROG=PROG/O:2,MOD2,PASLIB/S/P:2000/L



                                         10








                      Also, change  the  values  described  in  the  text  to 
                      reflect the values given in these command lines.

          Page 4-6.  In Table 4-1, change the size of the FLOATING  REAL  data 
                      type to 4 8-bit bytes.

          Page 4-7.  Change the paragraph under the example to read:

                      "The  assembly  language  program   must   remove   all 
                      parameters  from  the  stack  before  returning  to the 
                      calling routine."

          Page 4-10.  Change  the  example  function  KEYPRESSED  to  read  as 
                      follows:

                          FUNCTION KEYPRESED : BOOLEAN;

                          BEGIN
                            KEYPRESSED := (@BDOS(11,WRD(0)) <> 0)
                          END;


          Page 4-12.  In the example illustrating INLINE, change LHD to  LHLD.  

          Page 4-18.  Add the following to the end of the second paragraph  in 
                      Section 4.4:

                      "Note:  You  should  avoid  using  local  variables  in 
                      recursive procedures and functions."

          Page 5-4.   Add this sentence to the end of the first paragraph:

                      "If you want to use  breakpoints,  you  must  set  them 
                      before starting to debug with the BE or TR commands."

          Page 5-5.   In Table 5-2, 320 bytes should be 32 bytes.

          Page 5-6.  In Table 5-3, change the syntax of the E command to

                      E          enables display entry and exit of each
                                 procedure or function during execution
                                 (default is off).

          Page A-15. In the explanation of Error #253, change the limit to 2560 bytes.













                                         11


