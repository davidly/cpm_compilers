MODULE Compare;

(*	Compare two files

	Call is COMPARE   old file,new file,[List file]

	The two files are compared line by line

	lines which have been deleted from the old file are printed in italics
	lines which have been inserted are printed in emphasised mode
	lines which have been moved to a new position are printed in their new
	position with a box surrounding them

	You may need to patch the printer control codes for your printer
	These control codes are at about address 104h in the com file (i.e. 
	very near the beginning) Each control code can be up to 8 characters long
	and is terminated by a value of 0 if less than 8 characters is required

	The control characters in the supplied program are set for a STAR DPS510,
	which is supposed to be Epson compatible, so the program may well run 'as is'
	on Epsons and Epson clones

	The program is based on a method described by Paul Heckel 'A Technique for
	Isolating Differences between Files', Communications of the ACM, Vol 21
	No 4, April 1978, pp 264-268. 

	Basically, the technique consists of comparing the two files to find all
	the unique lines in each which match a unique line in the other. These 
	lines give fixed points from which matching regions can be grown outwards.
	Once all the regions so produced have been created, any line in the old file 
	which is not attached to a line in the new file is a deletion. Any line in the 
	new file which is not attached to a line in the old file is an insertion, while
	a block move is encountered when the lines pointed to in the old file are further
	down the file than some other lines which have not yet been processed and which
	are associated with lines in the new file.

	*)

FROM 	SYSTEM 		IMPORT ADDRESS,ADR,TSIZE;
FROM 	Command 	IMPORT Parameter,Parclass,GetParams;
FROM 	Files 		IMPORT FileName,FILE,Lookup,Create;
FROM 	Streams 	IMPORT Connect,Disconnect,STREAM,input,output,WriteChar,
				ReadChar,EOS,WriteRec,Reset;
FROM 	Terminal	IMPORT WriteString,WriteLn;
FROM 	Sort 		IMPORT SortRecords;
FROM 	InOut 		IMPORT WriteCard,SwitchInStream,SwitchOutStream,
				PopInStream,PopOutStream,ReadLine;
CONST	MaxFileSize=2000;	(*lines in file max*)
	FF=0cx;
	TAB=09x;
	LF=0ax;
	CR=0dx;
TYPE 	PFileName=POINTER TO FileName;
	PrintControl=ARRAY[0..7] OF CHAR;
VAR	
	(*	Printer Control Codes a zero byte terminates	*)

	ItalicsOn	:PrintControl	=[1bx,'4',0];
	ItalicsOff	:PrintControl	=[1bx,'5',0];
	BoldOn		:PrintControl	=[1bx,'E',0];
	BoldOff		:PrintControl	=[1bx,'F',0];

	List:STREAM;
	ListF:FILE;
	reply:INTEGER;
	i,j:INTEGER;

	Olds:STREAM;
	Oldf:FILE;
	
	News:STREAM;
	Newf:FILE;

	ch:CHAR;
	CharPos:CARDINAL;	(*position in line*)
	

(*	For each file, we have an array of hash totals for the lines of the file
	Using hash totals instead of the original lines causes a slight chance
	that lines will match when they should not, but allows larger files
	to be compared and also makes it possible to extend the program in the future
	to work with reasonable speed when one of the files is on a remote machine
	since then only the hash totals and the altered lines need to be transmitted*)

TYPE	HashArray=ARRAY[1..MaxFileSize] OF CARDINAL;
VAR	OldHash,NewHash:HashArray;
	OldLen,NewLen:CARDINAL;
PROCEDURE CalcHash(VAR	Text:ARRAY OF CHAR):CARDINAL;
VAR	i,j:CARDINAL;
BEGIN
	i:=0;
	j:=0;
	WHILE (i<=HIGH(Text)) AND (Text[i]<>0x) DO

		(*	add your favourite hashing function here*)

		j:=3*j+ORD(Text[i]);
		INC(i);
		END;
	RETURN j;
	END CalcHash;
PROCEDURE ReadStream(VAR s:STREAM;VAR Hash:HashArray):CARDINAL;
(*
	Read in a file and calculate the hash totals for the file
*)
VAR	i:CARDINAL;
	Line:ARRAY[1..80] OF CHAR;
BEGIN
	SwitchInStream(s);
	i:=0;
	
	WHILE (i<HIGH(Hash)) AND (NOT EOS(s)) DO
		ReadLine(Line);
		INC(i);
		Hash[i]:=CalcHash(Line);
		END;
	Reset(s);
	PopInStream;
	RETURN i;
	END ReadStream;

	   
PROCEDURE Usage;
BEGIN
	WriteString('Usage is:   COMPARE old file,new file');WriteLn;
	WriteString('      or    COMPARE old file,new file,output file');
	WriteLn;
	WriteLn;
	WriteString(' for example:  COMPARE ME.BAK ME.MOD');WriteLn;
	HALT
	END Usage;

VAR	OldLink,NewLink:HashArray;

	(*	OldLink contains the number of a line in the new file which is
		linked to a given line in the old file, and vice-versa
		An entry contains zero if no link has been made*)



PROCEDURE GenerateLinks;
VAR	i,j,k:CARDINAL;
	count:CARDINAL;
BEGIN
	FOR i:=1 TO HIGH(OldLink) DO
		OldLink[i]:=0;
		NewLink[i]:=0;
		END;

	(*	look for all old lines which match exactly one new line*)

	FOR i:=0 TO OldLen DO
		count:=0;
		j:=1;
		WHILE (count<2) AND (j<=NewLen) DO
			IF OldHash[i]=NewHash[j] THEN 
				INC(count); 
				k:=j;
				END;
			INC(j);
			END;
		IF count=1 THEN

		(*possible match - check that the new line only matches this old line*)

			count:=0;
			j:=1;
			WHILE (count<2) AND (j<=OldLen) DO
				IF OldHash[j]=NewHash[k] THEN 
					INC(count);
					END;
				INC(j);
				END;
			IF count=1 THEN

			(*	the lines are unique and they match - set up cross pointers*)

				OldLink[k]:=i;
				NewLink[i]:=k;
				END;
			END; (*IF count=1 (the outer one)*)
		END; (*FOR i*)

	(*	at this point, NewLink[i]=j <=> OldLine[j]=i
		This condition is central to the whole program	*) 	

	(*	now that the unique lines are cross-linked, we attempt to 'grow'
		the links outwards from the cross-linked lines*)

	k:=1;
	WHILE (k<=OldLen) DO
		IF NewLink[k]<>0 THEN 

			(*grow backwards*)

			j:=NewLink[k]-1;
			i:=k-1;
			WHILE (j>0) AND (i>0) AND (OldLink[j+1]=i+1)
				AND (NewHash[j]=OldHash[i]) 
				AND (OldLink[j]=0) AND (NewLink[i]=0) DO
				OldLink[j]:=i;
				NewLink[i]:=j;

				(* note central predicate still satisfied*)

				DEC(i);
				DEC(j);
				END;
			j:=NewLink[k]+1;
			i:=k+1;

			(*grow forwards - (slight optimisation) there is no need to
			  check for nonzero links on the forward pass since non-zero links
			  =>Lines match and are unique, and the back pass would be empty*)

			WHILE (j<=NewLen) AND (i<=OldLen) AND (OldLink[j-1]=i-1) 
				AND (NewHash[j]=OldHash[i]) DO
				OldLink[j]:=i;
				NewLink[i]:=j;

				(*still holds*)
 				INC(i);
				INC(j);
				END;
			k:=i;
		ELSE	INC(k)
			END (*WHILE k<=OldLen*);
		END;

	(*grow forwards from beginning of files*)

	i:=1;
	j:=1;
	WHILE (i<=OldLen) AND (j<=NewLen) 
		AND (OldHash[i]=NewHash[j]) 
		AND (NewLink[i]=0) AND (OldLink[j]=0) DO

		(*the last line of the condition is probably not
		  necessary, but avoids worrying about pathological case*)

		NewLink[i]:=j;
		OldLink[j]:=i;
		INC(i);
		INC(j);
		END;

	(*grow backwards from end of files*)
	i:=OldLen;
	j:=NewLen;
	WHILE (i>0) AND (j>0) 
		AND (OldHash[i]=NewHash[j])
		AND (NewLink[i]=0) AND (OldLink[j]=0) DO
		NewLink[i]:=j;
		OldLink[j]:=i;
		DEC(i);
		DEC(j);
		END;
	END GenerateLinks;


PROCEDURE WriteResults;
VAR	oldindex,newindex:CARDINAL;
	oldline,newline:ARRAY [1..80] OF CHAR;

PROCEDURE GetLine(VAR s:STREAM;VAR l:ARRAY OF CHAR);
BEGIN
	SwitchInStream(s);
	ReadLine(l);
	PopInStream;
	END GetLine;

PROCEDURE Print(a:ARRAY OF CHAR);

(*	Output a line truncating trailing spaces*)

VAR 	i,j:CARDINAL;
BEGIN
	i:=0;
	j:=0;
	WHILE (i<=HIGH(a)) AND (a[i]<>0x) DO
		IF a[i]<>' ' THEN
			FOR j:=j TO i DO WriteChar(List,a[j]) END;
			INC(j);
			END;
		INC(i);
		END;
	
	END Print;

PROCEDURE WriteEol;
BEGIN
(*	debug code commented out

	SwitchOutStream(List);
	WriteCard(oldindex,6);WriteCard(NewLink[oldindex],6);
	WriteCard(newindex,6);WriteCard(OldLink[newindex],6);
	PopOutStream;
*)
	WriteChar(List,0dx);
	WriteChar(List,0ax);
	END WriteEol;

PROCEDURE Deleted;

(*	Print out a line from the old file*)

BEGIN
	GetLine(Olds,oldline);
	Print(ItalicsOn);
	Print(oldline);
	Print(ItalicsOff);
	WriteEol;
	END Deleted;

PROCEDURE SkipOld;
BEGIN
	GetLine(Olds,oldline);
	END SkipOld;

PROCEDURE Inserted;
BEGIN
	GetLine(News,newline);
	Print(BoldOn);
	Print(newline);
	Print(BoldOff);
	WriteEol;
	END Inserted;
PROCEDURE NoChange;
BEGIN
	GetLine(News,newline);
	GetLine(Olds,oldline);	
	Print(newline);
	WriteEol
	END NoChange;

PROCEDURE BlockMove;
VAR i:CARDINAL;
BEGIN
	FOR i:=1 TO 25 DO WriteChar(List,'*') END;
	Print(' Block moved from line ');
	SwitchOutStream(List);
	WriteCard(OldLink[newindex],6);
	PopOutStream;
	FOR i:=25+29+1 TO 79 DO WriteChar(List,'*') END;
	WriteEol;
	i:=OldLink[newindex];
	WHILE (newindex<=NewLen) AND (i=OldLink[newindex]) DO
		GetLine(News,newline);
		Print(newline);
		WriteEol;
		INC(newindex);
		INC(i);
		END;
	FOR i:=1 TO 79 DO WriteChar(List,'*') END;
	WriteEol;
	END BlockMove;

BEGIN
	
	oldindex:=1;	(*current line in old file*)
	newindex:=1;	(*current line in new buffer*)

	(*	Caution: Well commented code ahead
			 Programmer probably didn't understand what he was doing 
		
		*)
	WHILE (oldindex<=OldLen) OR (newindex<=NewLen) DO
		(*	first check if either index is off end
			of file*)
	
		IF newindex>NewLen THEN 
			Deleted;
			INC(oldindex);
		ELSIF oldindex>OldLen THEN
			Inserted;
			INC(newindex);
		ELSIF NewLink[oldindex]=0 THEN
			Deleted;
			INC(oldindex);
		ELSIF OldLink[newindex]=0 THEN
			Inserted;
			INC(newindex);

		(*	if pointers match, line is unchanged
			or if a pointer is zero, line is new or deleted*)

		ELSIF (NewLink[oldindex]=newindex) 
		    AND (OldLink[newindex]=oldindex) THEN
			NoChange;
			INC(oldindex);
			INC(newindex);


(*		  none of the above: pointers don't match but
		  each pointer points somewhere

		  If the text in the new file pointed to by the old file has
		  been passed, it has already been written so we ignore the
		  old line and look for something more interesting (e.g. 
		  a Scotsman winning Wimbledon)

		  Because of the central predicate, we know that

		  NewLink[OldLink[newindex]]=newindex
		 and
		  OldLink[NewLink[oldindex]]=oldindex

*)

		ELSIF NewLink[oldindex]<newindex THEN
			SkipOld;
			INC(oldindex);

(* 		   so NewLink[oldindex]>=newindex

		   but, if NewLink[oldindex]=newindex then 
			   OldLink[newindex]=OldLink[NewLink[oldindex]]=newlink
			which is not true (since the cross-linked case was handled
			earlier)

		  Hence NewLink[oldindex]>newindex and we can leave the line till later

		  We must therefore do something with the new line - it is the
		  start of a moved block
*)
 		ELSE
			BlockMove;	(*inc of newindex done in blockmove*)
			END;
		END;(*LOOP*)
	END WriteResults;

VAR	Param:ARRAY [0..2] OF Parameter;
	Count:INTEGER;
	
PROCEDURE OpenInput(VAR s:STREAM;VAR f:FILE;param:Parameter);
BEGIN
	Lookup(f,FileName(param^.Chars),reply);
	IF reply<0 THEN
		WriteString(' Could not open ');
		WriteString(param^.Chars);
		WriteLn;
		HALT;
		END;
	Connect(s,f,input);
	END OpenInput;
PROCEDURE OpenFiles;
BEGIN

	(*	Input the parameters, connect the files to streams*)

	GetParams(Param,Count);

	(*	If less than 2 parameters, give usage and exit*)

	IF Count<2 THEN Usage END;

	(*	If 3 parameters, third parameter is file to receive output
		otherwise, attach output to the printer (LST:)
	*)

	IF Count=3 THEN
		Create(ListF,FileName(Param[Count-1]^.Chars),reply);
		IF reply<>0 THEN
			WriteString(' Could not create list file');
			WriteLn;
			HALT;
			END;
	ELSE
		Create(ListF,'LST:',reply);
		END;
	Connect(List,ListF,output);

	(*	Open the files to be compared	*)
	
	OpenInput(Olds,Oldf,Param[0]);
	OpenInput(News,Newf,Param[1]);	
	END OpenFiles;

PROCEDURE ReadInputFiles;
BEGIN

	WriteString(' Reading old file ');
	OldLen:=ReadStream(Olds,OldHash);
	WriteCard(OldLen,5);
	WriteString(' lines found');WriteLn;

	WriteString(' Reading new file ');
	NewLen:=ReadStream(News,NewHash);
	WriteCard(NewLen,5);
	WriteString(' lines found');WriteLn;
	END ReadInputFiles;

BEGIN	(*main program*)

	OpenFiles;
	ReadInputFiles;

	WriteString(' Generating cross links');WriteLn;
	GenerateLinks;
	WriteString(' Listing');WriteLn;

	(*reposition streams to beginning*)

	Reset(News);
	Reset(Olds);
	
	WriteResults;
	Disconnect(List,TRUE);
	END Compare.
