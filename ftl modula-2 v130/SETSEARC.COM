ÒM2.COM NOT ON LOGGED IN DISC
$ML.COM NOT ON LOGGED IN DISC
$MD.COM NOT ON LOGGED IN DISC
$
 Compiler and Linker  Patch Program for FTL Modula-2

 When  prompted for  devices,   enter a list of disk
 drive identifiers.

 Use the character "@" to denote the logged in drive.

 When entering a search list, always enter the drive
 designators in descending order of importance.

 Entering "?"  as a response  to  any  question will
 produce additional information on the question.
$
 The .SYM files are files which contain the symbol 
 definitions from definition modules. The SYM file
 is produced by the  definition  module  compiler.

 When you  import a  module, the .SYM file for the 
 module must be on a disk in the search list.
$
 Enter the  drive designator (e.g. "A") onto which 
 the definition  module compiler is to  output the
 .SYM file for modules.

 It is best to use the  disk drive that headed the
 compiler  search list  entered in response to the
 preceding question.
$
 This list gives the disks to be searched for .REL
 files.

 .REL  files  are  the  (relocatable)  code  files
 generated when you compile a program.

 They are linked to form executable (.COM) files.
$
 Entering Y in  response  to  this  question  will 
 cause the linker to ask you to load  another disk
 if a .REL file  which the linker needs to load is
 missing from the currently loaded disk.
$
 Enter the  disk onto which the .COM output of the
 linker  will  be  written  if  no  explicit drive
 designator is given.

 Usually, "@"(the drive logged in when the link is
 performed) should be used.
$
 Entering "Y" will  result in the compiler listing
 the source code of programs to the screen as they
 are compiled.

 Turning the listing off speeds up compilation.

 Whichever you chose,   the other can be selected
 when you call the compiler with the /L flag.
$
Not $
Enter compiler search list (for .SYM files)        :$
Enter device to receive .SYM files (output by MD)  :$
Enter loader search list                           :$
Do you want to be able to change disks during links:$
Patching M2.COM
$
Patching MD.COM
$
Patching ML.COM
$
Done
$
Enter device to receive .COM files                 :$
Do you want listing on by default                  :$                          
 Do you really have a drive  ?$
 You have entered a possibly invalid disk drive code
$
              M2      COM                            MD      COM                            ML      COM                                                                                                                                                                                                                                                                                                                                                                                                                           �
!���
!�A���
!"��`	� !����!�	:
� ¾!��	!����!�	:
� ��!��	!����!_�	:
� � !��	��!l�	:
� �!o�	;22�!�-	;2kd	�
!�~x	�
!��~�	�
!�~�		�  � �������~ ��ʫ	� �� ��ѯ�w �� �� ���	� �	� �������� ��� ������� ���	� ���	� �

� ��:�
�?����	� �����2
:�
��� ���q#��G�
2R
2��@���[�@�a���{��_�@����o& 
�~� �p��4
!U
;�w���p���Ø���w#��
Invalid drive designator  
$y	� >2
��Û
List too long
$��	� �

� ��:�
�?���_�Y���N��þ�<����	� ��þ
PLEASE ANSWER YES OR NO
$                                                                                                                                                                                                                                             