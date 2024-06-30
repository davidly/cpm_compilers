MODULE Cat;

(*	List one of more files to the terminal


	Call is CAT   <(wild card) file name>,.... [Options

	Where the wild card file names are the names of files to list
	The options are:

		P - run in page mode
		    in page mode, at the end of each screen of output,
		    a prompt line is presented.

		   P may be followed by the screen length in lines
		     default is 24

		N - output line numbers
		W - wrap lines longer than screen width
		    W may be followed by screen width in characters
		    default is 80

		I - expand tabs to spaces



	For example:

		CAT b:*.def b:*.mod b:*.sub[P16W100N



	This is a hack of the LIST program which comes with my
	Modula-2 compiler. (But highly modified)

	Limitations:
	============
		At most 10 (wild card) file names can be used
		Each wild card should not match more than 100 actual files

	Dave Moore *)

FROM SYSTEM IMPORT ADDRESS,ADR,TSIZE;
FROM Command IMPORT Parameter,Parclass,GetParams;
FROM Files IMPORT FileName,FILE,Lookup,Create,ReadBlock,SetBlock;
FROM GetFiles IMPORT GetNames;
FROM Terminal IMPORT WriteString,WriteLn,Write,Read,BusyRead,ClearCharBuffer;
FROM Sort IMPORT SortRecords;
FROM IntLogic IMPORT IAND;
FROM SmallIO IMPORT WriteInt,WriteHex,WriteCard;
CONST	BufferSize=4096;		(*Bytes to read in a single block*)
	BlockSize=128;			(*Block size in bytes--used for random
					  positioning*)

	CR=0dx;
	LF=0ax;
	TAB=09x;
	EOF=1ax;
	BS=08x;
	DEL=7Fx;

TYPE 	PFileName=POINTER TO FileName;

VAR	reply:INTEGER;
	i,j:INTEGER;
	Inf:FILE;	(*input file*)

	(*	The input is buffered:
		Buffer     contains the text to buffer
		BlockNo    contains the number of the first block in the buffer
			   This variable is modified by the random positioning
			   code to reflect changes in the file position
		CharPos    gives the character number of the next character to 
			   be listed from the buffer
		CharCount  gives number of valid characters in the buffer, it may be
			   less than the buffer length when end-of-file is
			   encountered
*)
	Buffer:ARRAY[0..BufferSize-1] OF CHAR;
	NextBlockNo,BlockNo:CARDINAL;
	CharPos:CARDINAL;
	CharCount:CARDINAL;
	PageNumber:INTEGER;
	PageLen:CARDINAL=24;

PROCEDURE ReadBuffer;
BEGIN
	BlockNo:=NextBlockNo;	
	ReadBlock(Inf,ADR(Buffer),0,BufferSize,reply);
	CharCount:=reply;

	(*Pad rest of buffer with end-of-file characters
	  Normally, CharCount will equal HIGH(buffer)+1, so no
	  padding takes place*)

	FOR CharPos:=CharCount TO HIGH(Buffer) DO Buffer[CharPos]:=EOF END;
	CharPos:=0;

	(*	increment NextBlock to allow for data read*)

	NextBlockNo:=INTEGER(BlockNo)+reply DIV BlockSize;
	END ReadBuffer;

VAR	ch:CHAR;		(*next character read*)

PROCEDURE NextChar;
BEGIN
	IF CharPos>=CharCount THEN 
		ReadBuffer;
		END;  (*IF CharPos>=CharCount*)
	ch:=Buffer[CharPos];
	INC(CharPos);
	END NextChar;

(*	File positioning routines

	You can position a file by:

		i)	Giving the number of the line to list from
		ii)	Giving a string to list in the form /string/ (where
			/ is any non-alphanumeric character)
		iii)	A combination of the two: 10/string/ to start search
			at a given line.
*)
TYPE	Position=RECORD
		BlockNumber:CARDINAL;		(*Block in which line starts*)
		CharOffset:CARDINAL;		(*Character offset in buffer*)
		END;
VAR	PosTable:ARRAY[1..2000] OF  Position;

	(*This code could be made more fancy by having an increment size
	  so that as the PosTable becomes full, every second entry is
	  removed and the increment doubled. But few files will have more 
	  than 2000 lines in them, so it didn't seem worth the extra effort.

	  You can change the upper bound at will to change the size of the
	  table.  *)

	HighWater:CARDINAL;	(*The top entry in Postable which is valid*)
VAR	LineOfFile:CARDINAL;
	Continuation:BOOLEAN=FALSE;	(*true if line is continuation of
					  previous line*)

PROCEDURE AddMarker;

(*	Add a marker to the position table.  LinOfFile gives line number*)
BEGIN
	IF (LineOfFile<HIGH(PosTable)) AND (LineOfFile>HighWater) THEN
		HighWater:=LineOfFile;
		WITH PosTable[HighWater] DO
			BlockNumber:=BlockNo;
			CharOffset:=CharPos
			END;
		END;
	END AddMarker;

PROCEDURE RepositionFile;

(*	Reposition file to line number given by LineOfFile.

	This line number need not be within the part of the file
	already examined (or previously skipped) so that it may be
	necessary to advance as far as possible and then scan forward.

	This routine only handles positioning by line number--see 
	Search for positioning by string match.*)

VAR	Required:CARDINAL;
BEGIN
	Required:=LineOfFile;

(*	  	Recalculate page number assuming that no lines overflowed (that
		is, that the maximum number of lines occured on each page).

	  	Note that the page number is always incremented before it is
		printed so that this code does not result in page numbers that
		are one too small.
*)

	PageNumber:=(LineOfFile-1) DIV (PageLen-2);
	IF LineOfFile>HighWater THEN LineOfFile:=HighWater END;
	Continuation:=FALSE;

	IF LineOfFile>0 THEN
	    WITH PosTable[LineOfFile] DO
		IF BlockNumber<>BlockNo THEN
			SetBlock(Inf,BlockNumber);
			NextBlockNo:=BlockNumber;
			ReadBuffer;
			END;
		CharPos:=CharOffset-1;
		NextChar;		(*re-prime character pointer*)

		(*	The required character is one less than the 
			saved marker as the character pointer is
			incremented after the first character of the line is
			returned. But the block is correct, because the
			'position beyond end of block' is not checked
			until the following character is sought*)
		END;(*WITH*)
	    END;(*IF LineOfFile>0*)
	WHILE LineOfFile<Required DO
		WHILE ch<>CR DO NextChar END;
		NextChar;
		IF ch=LF THEN NextChar END;
		INC(LineOfFile);
		AddMarker;
		END;
	END RepositionFile;

TYPE	MatchString=ARRAY[1..60] OF CHAR;

VAR	LastString:MatchString;
	LastLen:CARDINAL=0;	(*length of last matched string*)

PROCEDURE Search(Delimiter:CHAR);

(*	Search for a string from the current position in the file
	
	This routine does a plain simple search. There are much
	faster ways of doing searches, but they are probably
	going to be swamped by the IO time anyway*)
VAR	string:MatchString;
	len:CARDINAL;
	nch:CHAR;
	i,j:CARDINAL;
	PartialPos:ARRAY[1..60] OF CARDINAL;
	Partials:CARDINAL;
BEGIN
	len:=0;
	LOOP
		Read(nch);
		IF (nch=BS) OR (nch=DEL) THEN
			IF len>0 THEN DEC(len) END;
		ELSIF (nch=Delimiter) OR (len=HIGH(string))
			OR (nch=CR) OR (nch=LF) THEN
			EXIT
		ELSE
			INC(len);
			string[len]:=nch;
			END; (*IF ch=BS etc*)
		END;(*LOOP*)

	string[len+1]:=0x;	(*set so string can later be printed*)

	IF len<>0 THEN
		LastLen:=len;
		LastString:=string;
		END;
	IF LastLen=0 THEN
		WriteString(' Error - no previous search string');
		WriteLn;
	ELSE	(*start match*)
		Partials:=0;
		LOOP
			IF ch=EOF THEN EXIT END;
			WHILE ch=CR DO
				NextChar;
				IF ch=LF THEN NextChar END;
				INC(LineOfFile);
				AddMarker;
				END;
			(*add a new partial match which has just matched
			  the null string*)

			INC(Partials);
			PartialPos[Partials]:=1;

			(*try to advance all the existing partially completed
			  matches*)

			j:=0;
			FOR i:=1 TO Partials DO
				nch:=LastString[PartialPos[i]];
				IF (nch=ch) OR (CAP(nch)=ch) THEN

				(* the two conditions in the above line
				   provide for lower case to in the match 
				   string to match either case*)

					INC(j);
					PartialPos[j]:=PartialPos[i]+1;
					IF PartialPos[j]>LastLen THEN 
						EXIT  (*match found*)
						END;
					
					END;
				END;
			Partials:=j;
			NextChar;
			END;
		(*either ch=EOF or a match has been found*)
		IF ch=EOF THEN
			WriteLn;
			WriteString(LastString);
			WriteString(' could not be found');
		ELSE
			RepositionFile; (*to start of current line*)
			END;
		END;(*search string entered or existed*)
	END Search;
	
(*	Option flags and screen dimensions*)

VAR	PageMode:BOOLEAN=FALSE;
	LineWrap:BOOLEAN=FALSE;
	NumberLines:BOOLEAN=FALSE;
	ExpandTabs:BOOLEAN=FALSE;
	PageWidth:CARDINAL=80;
	LineNumber:CARDINAL;


VAR	EndOfFile:BOOLEAN;		(*set true after ** End of File ** has
					  been output by WriteLine*)

(*	Write a line of output	
	The first character of the line to be written must
	be available in the variable ch before entry to the routine
	*)

PROCEDURE WriteLine;
VAR	CharsWritten:CARDINAL;

BEGIN

	CharsWritten:=0;

	IF NumberLines THEN
		IF Continuation THEN 
			WriteString('      ');
		ELSE	
			WriteInt(LineOfFile,5);
			Write('|');
			END;
		END;
	IF NOT Continuation THEN 
		AddMarker;
		INC(LineOfFile);
		END;
	Continuation:=FALSE;

	LOOP

		(*strip top bit - should probably be option controlled*)

		IF CharsWritten>=PageWidth THEN 
			Continuation:=TRUE;
			WriteLn;
			RETURN
			END;

		IF ch>80x THEN ch:=CHR(ORD(ch)-80h) END;

		CASE ch OF
		EOF:	(*End of File character found,
			  (either from file or generated by NextChar)
			  if nothing has been printed on line,
			  just return end of file status
			  If line was incomplete, print <EOF> and 
			  return*)

			IF (CharsWritten=0) THEN
				WriteString('  	  ** End of File **');
				EndOfFile:=TRUE;
			ELSE
				WriteString('<EOF>');
				END;
			RETURN;
			|

		CR:	(*Carriage return found*)
			NextChar;
			IF (ch=LF) THEN NextChar END;
			WriteLn;
			EXIT;
			|
		LF:	(*must be a stray line feed, treat as a
			  line terminator*)
			WriteLn;
			EXIT;
			|
		TAB:	REPEAT
				INC(CharsWritten);
				IF CharsWritten>=PageWidth THEN
					WriteLn;
					Continuation:=TRUE;
					RETURN	(*note that tab gets processed again
						  at start of next line*)
					END;
				IF ExpandTabs OR NumberLines THEN Write(' ') END;
				UNTIL IAND(CharsWritten,7)=7;
			IF NOT (ExpandTabs OR NumberLines) THEN Write(TAB) END;
			|
		0x..1fx:	(*non-printing characters. This is cheating
				  slightly - should exclude CR LF and TAB*)
			IF CharsWritten>=(PageWidth-4) THEN
				WriteLn;
				Continuation:=TRUE;
				RETURN
				END;
			Write('<');
			WriteHex(ORD(ch),2);
			Write('>');
			CharsWritten:=CharsWritten+4;
			|
		ELSE	Write(ch);
			INC(CharsWritten);
			END;(*CASE*)
		NextChar;
		END;(*LOOP*)
	END WriteLine;		

(*	The next routine is used by the sort module
	to perform key comparisons*)

PROCEDURE Compar(a,b:ADDRESS):BOOLEAN;
VAR	p,q:PFileName;
BEGIN
	p:=PFileName(a);
	q:=PFileName(b);
	RETURN p^>q^
	END Compar;
PROCEDURE Usage;
BEGIN
	WriteString('Usage is:   CAT file,file,...');WriteLn;
	WriteString('      or    CAT file,file,...[options');WriteLn;
	WriteString(' where file is a file to list or a wild card for files to list');
	WriteLn;
	WriteLn;
	WriteString(' The options are:');WriteLn;
	WriteString('		P - output in page mode');WriteLn;
	WriteString('		N - number lines on output');WriteLn;
	WriteString('		W - wrap long lines');WriteLn;
	WriteString('		I - expand tabs to spaces');WriteLn;
	WriteLn;
	WriteString(' for example:  CAT *.DEF[P16W20N');WriteLn;
	HALT
	END Usage;




VAR	Param:ARRAY [0..10] OF Parameter;
	Count:INTEGER;
	Names:ARRAY [0..100] OF FileName;
	NameCount : INTEGER;
	Counter : INTEGER;
	Cnter : INTEGER;

(*	Output the file already opened*)

	
PROCEDURE OutputFile(Name:ARRAY OF CHAR);
VAR	ch:CHAR;
	i:CARDINAL;
PROCEDURE PageHeader;
BEGIN
	WriteLn;
	WriteString(Name);

	(* If terminal supports tabs, put page number on right hand side
	of screen, otherwise just go in 10 chars to save time on
	alow links*)

	IF NOT ExpandTabs THEN
		FOR i:=27 TO PageWidth BY 8 DO Write(TAB) END;
	ELSE
		FOR i:=1 TO 10 DO Write(' ') END;
		END;
	WriteString('Page: ');
	WriteInt(PageNumber,5);
	WriteLn;
	END PageHeader;

PROCEDURE Number():CARDINAL;
TYPE	CharSet=SET OF CHAR;
VAR	i:CARDINAL;
BEGIN
	i:=0;
	WHILE ch IN CharSet{'0'..'9',BS,DEL} DO
		IF (ch=BS) OR (ch=DEL) THEN i:=i DIV 10
		ELSE
			i:=10*i+(ORD(ch)-ORD('0'));
			END;
		Read(ch);
		END;
	RETURN i
	END Number;
PROCEDURE PrintHelp;
BEGIN
	WriteString(' Examples of possible responses:');WriteLn;
	WriteString(' ?           - This message');WriteLn;
	WriteString(' 227         -  list from line 227');WriteLn;
	WriteString(' +20 or -20  - go forward (back) 20 lines');
	WriteLn;
	WriteString(' q (or Q)    - go to next file');WriteLn;
	WriteString(' Control C       - abort run');WriteLn;
	WriteString('/string/     - list from next occurence of string');
	WriteLn;
	WriteString('100/string/  - list from first occurence after line 100');
	WriteLn;
	WriteString('P20          - toggle page mode set 20 lines per page');
	WriteLn;
	WriteString('W64          - toggle line wrap, set 64 columns per line');
	WriteLn;
	WriteString('I            - toggle tabs expansion');
	WriteLn;
	WriteString('N            - toggle line numbering');WriteLn;
	WriteString(' Command:');
	END PrintHelp;	

PROCEDURE NewValue(VAR default:CARDINAL;limit:CARDINAL);
VAR	i:CARDINAL;
BEGIN
	Read(ch);
	i:=Number();
	IF i>=limit THEN default:=i END
	END NewValue;
	
BEGIN
	EndOfFile:=FALSE;
	NextBlockNo:=0;
	LineNumber:=2;
	LineOfFile:=1;
	PageNumber:=1;
	CharPos:=1;
	CharCount:=0;
	HighWater:=0;
	NextChar;	(*prime look-ahead character*)
	WriteLn;
	HighWater:=0;
	IF PageMode THEN
		PageHeader;
		END;
	LOOP
		IF  EndOfFile THEN EXIT END;
		WriteLine;
		INC(LineNumber);

		(* check for anything types at console
		   if ctrl c, the abort, if q or Q*)

		BusyRead(ch);
		IF (PageMode AND ((LineNumber>=PageLen) OR EndOfFile)) 
		   OR (ch<>0x) THEN
			IF EndOfFile THEN DEC(CharPos) END;
			EndOfFile:=FALSE;
			PageMode:=TRUE;
			WriteString(' Command :');
			IF ch=0x THEN Read(ch) 
			ELSE 	Write(ch);
				ClearCharBuffer
				END;
			LOOP
			    CASE CAP(ch) OF
				'P':PageMode:=NOT PageMode;
				    NewValue(PageLen,12)|
				'N':NumberLines:=NOT NumberLines;Read(ch)|
				'I':ExpandTabs:=NOT ExpandTabs;Read(ch)|
				'W':LineWrap:=NOT LineWrap;
				    NewValue(PageWidth,40)|
				'?':PrintHelp;Read(ch)|
				'+':Read(ch);
			 	    LineOfFile:=LineOfFile+Number()
				    RepositionFile|
				'-':Read(ch);
				    i:=Number();
				    IF i>LineOfFile THEN LineOfFile:=1
				    ELSE LineOfFile:=LineOfFile-i END;
				    RepositionFile
				    |
				'0'..'9':LineOfFile:=Number();
					 RepositionFile|
				'!'..'*',',','.','/',':'..'@','{'..'~',
				'['..'`':
					Search(ch);Read(ch)|
				
				03x:
					HALT|
				ELSE EXIT
				END(*CASE*);
			    END;(*LOOP*)
			IF CAP(ch)='Q' THEN EXIT END;
			INC(PageNumber);
			PageHeader;
			LineNumber:=2;
			END;

		END;
	END OutputFile;

PROCEDURE Listit;
VAR	i:CARDINAL;

PROCEDURE GetNum(Chars:ARRAY OF CHAR;VAR Pos:CARDINAL;Len:CARDINAL):CARDINAL;

(*	Get a number from a parameter in the command line*)
TYPE	CharSet=SET OF CHAR;
VAR	i:CARDINAL;
BEGIN
	i:=0;
	WHILE (Pos<Len) AND (Chars[Pos] IN CharSet{'0'..'9'}) DO
		i:=10*i+ORD(Chars[Pos])-ORD('0');
		INC(Pos);
		END;	
	RETURN i
	END GetNum;
BEGIN

	GetParams(Param,Count);
        Counter := 1;
        IF Count=0 THEN Usage END;

	IF Param[Count-1]^.Class=option THEN
		WITH Param[Count-1]^ DO

			(*	Recognise flags*)

			i:=0;
			WHILE i<CARDINAL(Length) DO
				CASE Chars[i] OF
				'I':ExpandTabs:=TRUE;
				    INC(i)|
				'W':LineWrap:=TRUE;
				    INC(i);
				    PageWidth:=GetNum(Chars,i,ORD(Length));
				    IF PageWidth=0 THEN PageWidth:=80 END;

					(*Check page width is reasonable*)

				    IF PageWidth<32 THEN
					WriteLn;
					WriteString(' *** Page width too narrow ***');
					WriteLn;
					Usage;
					END;
				   |
				'N':NumberLines:=TRUE;
				    INC(i)|
				'P':PageMode:=TRUE;
				    INC(i);
				    PageLen:=GetNum(Chars,i,ORD(Length));
				    IF PageLen=0 THEN PageLen:=24 END;

					(*Check page length is reasonable*)

				    IF PageLen<10 THEN
					WriteLn;
					WriteString(' *** Page length too short ***');
					WriteLn;
					Usage
					END
				    |
				ELSE
				    Usage
				    END;(*CASE*)
				END;(*WHILE*)
			END; (*WITH*)
		DEC(Count);
		END; (*IF option*)

	IF Count=0 THEN Usage END;
	IF NumberLines THEN PageWidth:=PageWidth-6 END;

	FOR i:=0 TO CARDINAL(Count-1) DO
		GetNames(Param[i]^.Chars,Names,NameCount);
		IF NameCount>1 THEN
			SortRecords(ADR(Names),CARDINAL(NameCount),
				TSIZE(FileName),Compar);
			END;
		FOR j:=0 TO NameCount-1 DO
			Lookup(Inf,Names[j],reply);
			IF reply<0 THEN
				WriteString(' Could not open ');
				WriteString(Names[j]);
				WriteLn;
			ELSE
				OutputFile(Names[j]);
				END;
			END;
		END;
	END Listit;			
BEGIN
	Listit;
	END Cat.
