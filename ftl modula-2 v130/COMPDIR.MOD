(*		Revision History:

		24 March 86  Dave Moore
			Fixed compilation errors caused by upgrading of
			compiler error checking.
			Increased MaxFiles to 512.

		Bugs:

			Fails if more than MaxFiles files are found. This
			is not a problem under CP/M since directories fill
			before that many files are found, but it can cause
			problems under MSDOS (with a Z80 card)
*)
			

(*$l-*)
MODULE CompDir;

(*	CompDir - Compare two directories

	Dave Moore
	Cerenkof Computing
	PO Box 305 Wynnum Central 4178


	Call is COMPDIR   wild card,wild card,list file [options

	Where each wild card produces one of the lists to compare

	For example, to compare two discs, do: COMPDIR a:*.* b:*.*

	Options are any of the following:
		T	compare only file type (by default, the whole name is compared)
			(by file type, I mean the (3) characters after the dot)
		N	compare only file name
		C	if file names match, check file contents as well
		
		
			These two options are mutually exclusive

		E	Output file names which match to list file
		A	Output file names which have been added to the second list
		D	Output file names which have been deleted from the first list
		M	Output files which have been modified to the list file

			These options may be combined


	The program can be very useful for updating discs based on their
	existing contents, which is an area in which sweep is weak. 

	This is a modified and enhanced version of the original CompDir program
	which was written for expository purposes. The program is written in 
	FTL Modula-2.
	*)

FROM 	SYSTEM 		IMPORT ADDRESS,ADR,TSIZE;
FROM 	Command 	IMPORT Parameter,Parclass,GetParams;
FROM 	Terminal	IMPORT WriteString,WriteLn,Write;
FROM 	Sort 		IMPORT SortRecords;
FROM	Files 		IMPORT FileName,FILE,Create;
FROM	GetFiles	IMPORT GetNames;
FROM	Strings		IMPORT Length;
FROM	Streams		IMPORT STREAM,Connect,Disconnect,WriteChar,Direction;
IMPORT	InOut;
FROM	FileOps		IMPORT FileComp;
CONST	MaxFiles=512;	(*max files to be matched*)

TYPE 	
	CompClass=(Whole,Name,Type);
	FileRecord=RECORD
		Device:CHAR;
		Name:ARRAY[1..8] OF CHAR;
		Type:ARRAY[1..3] OF CHAR;
		END;
	PFileName=POINTER TO FileRecord;
	FileArray=ARRAY[1..MaxFiles] OF FileRecord;
VAR	
	Param:ARRAY[1..4] OF Parameter;		(*area for command line*)
	Count:INTEGER;				(*parameters*)

	LeftNames,RightNames:FileArray;
	LeftNameCount,RightNameCount:INTEGER;

	Compclass:CompClass=Whole;
	OutputAdded:BOOLEAN=FALSE;
	OutputEqual:BOOLEAN=FALSE;
	CompareContents:BOOLEAN=FALSE;
	OutputDeleted:BOOLEAN=FALSE;
	OutputModified:BOOLEAN=FALSE;

	ListOpen:BOOLEAN=FALSE;
	List:STREAM;
	ListF:FILE;
PROCEDURE CrackFileName(Text:ARRAY OF CHAR;VAR Rec:FileRecord);

(*	Convert the text form of a file name to the
	expanded form*)
VAR	i,j:CARDINAL;
BEGIN
	WITH Rec DO
		IF Text[1]=':' THEN
			Device:=CAP(Text[0]);
			i:=2;
		ELSE
			Device:=' ';
			i:=0;
			END;
		j:=1;

		(*	pick up file name *)

		WHILE   (i<=HIGH(Text))
		    AND	(Text[i]<>0x)
		    AND (Text[i]<>' ')
		    AND	(Text[i]<>'.') DO
			IF  j<=HIGH(Name) THEN Name[j]:=Text[i] END;
			INC(j);
			INC(i);
			END;
		FOR j:=j TO HIGH(Name) DO Name[j]:=0x END;

		(*Note that I use zero instead of blank fill to simplify listing
		  of the names*)
		j:=1;
		IF Text[i]='.' THEN INC(i) END;
		WHILE   (i<=HIGH(Text))
		    AND	(Text[i]<>0x)
		    AND	(Text[i]<>' ') DO
			IF  j<=HIGH(Type) THEN Type[j]:=Text[i] END;
			INC(j);
			INC(i);
			END;
		FOR j:=j TO HIGH(Type) DO Type[j]:=0x END;
		END;(*WITH*)
	END CrackFileName;
	
PROCEDURE Usage;
BEGIN
	WriteLn;
	WriteString('Usage is:   COMPDIR wild card file name');
	WriteString(', wild card file name [, list file] [/options]');
	WriteLn;WriteLn;
	WriteString(' Options are:  ');WriteLn;
	WriteString('		T	compare only file type ');WriteLn;
	WriteString('		N	compare only file name');WriteLn;
	WriteString('		C	compare contents of matching files');WriteLn;
	WriteString('		E	Output file names which match to list file');WriteLn;
	WriteString('		A	Output file names which have been added to the second list');WriteLn;
	WriteString('		D	Output file names which have been deleted from the first list');WriteLn;
	WriteString('		M	Output file names of modified files ');WriteLn;
	WriteString('			(Implies C option)');WriteLn;
	HALT
	END Usage;


PROCEDURE GetOptions(p:Parameter);
VAR	i:CARDINAL;
BEGIN
	WITH p^ DO
		i:=0;
		LOOP
			CASE Chars[i] OF
				0x:EXIT|
				'T':Compclass:=Type|
				'N':Compclass:=Name|
				'E':OutputEqual:=TRUE|
				'A':OutputAdded:=TRUE|
				'D':OutputDeleted:=TRUE|
				'M':OutputModified:=TRUE;
				    CompareContents:=TRUE|
				'C':CompareContents:=TRUE
				ELSE Usage;
				END;(*Usage*)
			INC(i);
			END;
		END;(*WITH*)
	END GetOptions;
			
PROCEDURE Compar(a,b:ADDRESS):BOOLEAN;

(*	key comparison routine for the sort module
	Returns TRUE if a is greater than b

	This routine always compares the full name as it is used
	for sorting. The equality routine only compares the part
	of the name requested by the flags. As a result, a test
	for equality should be made first*)

VAR	p,q:PFileName;
BEGIN
	p:=PFileName(a);
	q:=PFileName(b);
	CASE Compclass OF
		Type:IF  p^.Type<>q^.Type THEN RETURN p^.Type>q^.Type
		     ELSE RETURN p^.Name>q^.Name END; 
			|
		Name,Whole:IF p^.Name<>q^.Name THEN RETURN p^.Name>q^.Name
		      ELSE RETURN p^.Type>q^.Type END;
		END;(*CASE*)

	END Compar;
PROCEDURE Equal(p,q:FileRecord):BOOLEAN;

(*	compare to names for equality
	patterned after the preceding routine*)


BEGIN
	CASE Compclass OF
		Type:RETURN p.Type=q.Type|
		Name:RETURN p.Name=q.Name|
		Whole:IF p.Name<>q.Name THEN RETURN FALSE
		      ELSE RETURN p.Type=q.Type END;
		END;(*CASE*)

	END Equal;

PROCEDURE ExpandNames(Param:Parameter;VAR Names:FileArray;
			VAR NameCount:INTEGER);

(*	Expand wild card file name into list of files
	and sort result *)
VAR	i,j:INTEGER;
	NameText:ARRAY [1..MaxFiles] OF FileName;
	Text:ARRAY[0..5] OF CHAR;
BEGIN
	IF (Param^.Chars[2]=0x) AND (Param^.Chars[1]=':') THEN
		Text:=' :*.*';
		Text[0]:=Param^.Chars[0];
		GetNames(Text,NameText,NameCount);
	ELSE
		GetNames(Param^.Chars,NameText,NameCount);
		END;
	
	(*crack names*)

	FOR i:=1 TO NameCount DO
		CrackFileName(NameText[i],Names[i]);
		END;

	IF NameCount>1 THEN
		SortRecords(ADR(Names),CARDINAL(NameCount),
			TSIZE(FileRecord),Compar);
		END;
			
			
	END ExpandNames;

VAR	i,j:INTEGER;
PROCEDURE WriteToList(VAR N:FileRecord);
BEGIN
	WITH N DO
		InOut.WriteString(Name);
		WriteChar(List,'.');
		InOut.WriteString(Type);
		InOut.WriteLn;
		END;
	END WriteToList;
	
PROCEDURE WriteName(VAR N:FileRecord;ToList:BOOLEAN);

(*	output a file record as a valid file name
	IF Tolist, output it to list as well*)

VAR	i:CARDINAL;
	ch:CHAR;
BEGIN
	WITH N DO
		IF Device<>' ' THEN 
			ch:=':'
		ELSE
			ch:=' '
			END;
		Write(Device);
		Write(ch);
		IF ToList THEN
			WriteChar(List,Device);
			WriteChar(List,ch);
			END;
		WriteString(Name);
		Write('.');
		WriteString(Type);
		IF ToList THEN
			WriteToList(N);
			END;

		(*Now pad name out to 16 columns*)

		FOR i:=Length(Name)+Length(Type)+4 TO 16 DO
			Write(' ');
			END;
		END;
	END WriteName;
PROCEDURE PrintLeft;
BEGIN
	WriteName(LeftNames[i],OutputDeleted);
	WriteLn;
	END PrintLeft;
PROCEDURE PrintRight;
BEGIN
 	WriteString('                ');
	WriteName(RightNames[j],OutputAdded);
	WriteLn;
	END PrintRight;

PROCEDURE CompareOK(f1,f2:FileRecord):BOOLEAN;

VAR	fn1,fn2:FileName;

PROCEDURE SetName(f:FileRecord;VAR fn:FileName);
VAR	i,j:CARDINAL;

PROCEDURE Put(ch:CHAR);
BEGIN
	fn[i]:=ch;
	INC(i);
	END Put;

BEGIN
	i:=0;
	WITH f DO
		IF Device<>' ' THEN 
			Put(Device);
			Put(':');
			END;
		j:=1;
		WHILE (j<=HIGH(Name)) AND (Name[j]<>0x) DO
			Put(Name[j]);
			INC(j);
			END;
		j:=1;
		Put('.');
		WHILE (j<=HIGH(Type)) AND (Type[j]<>0x) DO
			Put(Type[j]);
			INC(j);
			END;
		WHILE i<=HIGH(fn) DO Put(' ') END;
		END;
	END SetName;
BEGIN
	SetName(f1,fn1);
	SetName(f2,fn2);
	RETURN FileComp(fn1,fn2)
	END CompareOK;
		
VAR	reply:INTEGER;
BEGIN


	GetParams(Param,Count);
	IF (Count>0) AND (Param[Count]^.Class=option) THEN
		GetOptions(Param[Count]);
		DEC(Count);
		END;
	IF Count<2 THEN Usage END;
        IF Count=3 THEN 
		Create(ListF,FileName(Param[3]^.Chars),reply);
		IF reply<0 THEN
			WriteString(' Could not open output file ');
			WriteString(Param[3]^.Chars);
			WriteLn;
			HALT;
			END;
		Connect(List,ListF,output);
		InOut.SwitchOutStream(List);
		ListOpen:=TRUE;
	ELSE
		IF OutputAdded OR OutputDeleted OR 
		   OutputEqual OR OutputModified THEN 
			WriteString(' A D E and M options require output file name$')
			WriteLn;
			Usage;
			END;
		END;
	ExpandNames(Param[1],LeftNames,LeftNameCount);
	ExpandNames(Param[2],RightNames,RightNameCount);

	(*now perform merge pass of two lists*)

	i:=1;
	j:=1;
	WHILE (i<=LeftNameCount) AND (j<=RightNameCount) DO
		IF Equal(LeftNames[i],RightNames[j]) THEN

			WriteName(LeftNames[i],OutputEqual);
			WriteName(RightNames[j],FALSE);
			IF CompareContents AND 
			  NOT CompareOK(LeftNames[i],RightNames[j]) THEN
				WriteString(' Files Differ ');
				IF OutputModified THEN
					WriteToList(LeftNames[i]);
					END;
				END;
			WriteLn;
			INC(i);
			INC(j);

		ELSIF NOT Compar(ADR(LeftNames[i]),ADR(RightNames[j])) THEN

			PrintLeft;
			INC(i);

		ELSE (*Leftnames[i]>RightNames[j]*)
	
			PrintRight;	
			INC(j);
			END;(*IF*)
		END;(*WHILE*)

	(*process stragglers*)

	WHILE i<=LeftNameCount DO
		PrintLeft;
		INC(i);
		END;

	WHILE j<=RightNameCount DO
		PrintRight;
		INC(j);
		END;
	IF ListOpen THEN
		Disconnect(List,TRUE);
		END;	
	END CompDir.

