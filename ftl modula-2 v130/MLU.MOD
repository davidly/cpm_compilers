MODULE MyLU;

(*	Dave Moore's own version of LU for use with his Modula-2
	compiler *)

FROM	Terminal IMPORT WriteString,WriteLn,ReadString,Write; 
FROM	Files 	IMPORT FILE,ReadBlock,WriteBlock,Lookup,Create,FileName,
			SeqReadBlock,SeqWriteBlock,ConvertFileName,Close,
			MakeBAK,SetBlock,Devicetype;
FROM	SmallIO IMPORT ReadCard,WriteCard,WriteHex;
FROM	SYSTEM  IMPORT BYTE,ADR,TSIZE;
FROM	CPM	IMPORT fcb,alfa,exten,opnfc,BDOS;
FROM	Strings IMPORT Length;
FROM	Storage IMPORT ALLOCATE;
TYPE
	IndexRecord=RECORD
		Status:BYTE;
		BaseName:alfa;
		Ext:exten;
		StartSector:CARDINAL;
		Length:CARDINAL;
		Date:CARDINAL;
		Time:CARDINAL;
		Scrunched:BOOLEAN;
		Filler :ARRAY [1..11] OF BYTE;
		END;
	Index=ARRAY[1..128] OF IndexRecord;
VAR	Lib:FILE;
	LibName:FileName;
	reply:INTEGER;
	Directory:Index;
	Slots:CARDINAL;
	NextSector:CARDINAL;
	i,j:CARDINAL;
	CommandCH:CHAR;
	FName:FileName;
PROCEDURE ReadCommand;
(*	read an input command, return command letter in CommandCH
	return file name in FName*)
VAR	Text:ARRAY[1..20] OF CHAR;
	i,j:CARDINAL;
BEGIN
	WriteString('Command:');
	ReadString(Text);
	CommandCH:=CAP(Text[1]);
	i:=2;
	WHILE (i<=HIGH(Text)) AND (Text[i]=' ') DO
		INC(i) 
		END;
	j:=0;
	WHILE (j<=HIGH(FName)) AND (i<=HIGH(Text)) AND (Text[i]<>0c) DO
		FName[j]:=CAP(Text[i]);
		INC(j);
		INC(i)
		END;
	WHILE j<=HIGH(FName) DO
		FName[j]:=' ';
		INC(j)
		END
	END ReadCommand;  
PROCEDURE AddEntry(Name:fcb;Position,Size,EDate,ETime:CARDINAL;Sc:BOOLEAN);
VAR	i,j:CARDINAL;
BEGIN
	i:=2;
	WHILE (i<=Slots) AND (Directory[i].Status<>0ffh) DO INC(i) END;
	IF i>Slots THEN
		WriteString(' Directory full - redo with more slots');
		WriteLn;
		HALT;
		END;
	WITH Directory[i] DO
		Status:=0;
		BaseName:=Name.fcbfn;
		Ext:=Name.fcbft;
		StartSector:=Position;
		Length:=Size;
		Date:=EDate;
		Time:=ETime;
		Scrunched:=Sc;
		FOR j:=1 TO HIGH(Filler) DO Filler[j]:=0 END;
		END
	END AddEntry;
PROCEDURE FindName(f:fcb):CARDINAL;
(*	find a name - return 0 if not found *)
VAR	i:CARDINAL;
BEGIN
	i:=2;
	LOOP
		IF i>Slots THEN RETURN 0 END;
		WITH Directory[i] DO
			IF (Status=0) AND (BaseName=f.fcbfn) AND (Ext=f.fcbft) THEN
				RETURN i
				END;
			END;
		INC(i);
		END;
	END FindName;
PROCEDURE Transfer(VAR From,To:FILE;MaxSectors:CARDINAL):CARDINAL;
VAR	i,j:CARDINAL;
	reply:INTEGER;
	Buffer:ARRAY[0..1023] OF BYTE;
BEGIN
	j:=0;
	LOOP
		IF MaxSectors>8 THEN i:=8*128 ELSE i:=MaxSectors*128 END;
		SeqReadBlock(From,ADR(Buffer),i,reply);
		IF reply=0 THEN EXIT END;
		SeqWriteBlock(To,ADR(Buffer),reply,reply);
		j:=j+CARDINAL(reply) DIV 128;
		IF MaxSectors<=8 THEN EXIT END;
		MaxSectors:=MaxSectors-8;
		END;
	RETURN j;
	END Transfer;
PROCEDURE UnScrunch(VAR From,To:FILE);
TYPE	PName=POINTER TO Name;
	Ident=ARRAY[0..60] OF CHAR;
	Name=RECORD
		Code:CARDINAL;
		Next:PName;
		Text:Ident;
		END;
VAR	i,j:CARDINAL;
	reply:INTEGER;
	BufferIn,BufferOut:ARRAY[0..1023] OF BYTE;
	Table:PName;
	p:PName;
	Code:CARDINAL;
	Id:Ident;
	InPos,OutPos:CARDINAL;
	ch:CHAR;
	Eof:BOOLEAN;
PROCEDURE EnterId(s:ARRAY OF CHAR);
VAR	r:PName;
	i,j:CARDINAL;
BEGIN
	j:=Length(s);
	ALLOCATE(r,j+TSIZE(CARDINAL)+TSIZE(PName)+1);
	
	r^.Code:=Code;
	WITH r^ DO
		Next:=Table;
		Table:=r;
		FOR i:=0 TO j-1 DO Text[i]:=s[i] END;
		Text[j]:=0x;
		END;
	END EnterId;
PROCEDURE EnterGId(Len:CARDINAL;s:ARRAY OF CHAR);
VAR 	i,j:CARDINAL;
	id:Ident;
BEGIN
	i:=0;
	WHILE (i<HIGH(s)) DO
		FOR j:=i TO i+Len-1 DO
			id[j-i]:=s[j]
			END;
		id[Len]:=0x;
		EnterId(id);
		INC(Code);
		i:=i+Len;
		END;
	END EnterGId;
PROCEDURE SetUpNames;
VAR	s:Ident;
PROCEDURE PutId;
BEGIN
	s[i]:=0x;
	EnterId(s);
	INC(Code);
	END PutId;
BEGIN
	Code:=128;
	EnterGId(2,'BYDOIFINOFORTO');
	EnterGId(3,'ANDDIVENDFORMODNOTSETVARADR');
	EnterGId(4,'CASEELSEEXITFROMLOOPTHENTYPEWITHHIGHCHARTRUE');
	EnterGId(5,'ARRAYBEGINCONSTELSIFUNTILWHILEFALSE');
	EnterGId(6,'EXPORTIMPORTMODULERECORDREPEATRETURN');
	EnterGId(7,'POINTERWriteLnINTEGERADDRESSBOOLEAN');
	EnterGId(8,'CARDINALTerminal');
	EnterGId(9,'PROCEDUREQUALIFIEDCopyright');
	EnterId('DEFINITION');INC(Code);
	EnterId('WriteString');INC(Code);
	(*	Enter tab codes*)
	FOR i:=1 TO 6 DO
		s[i-1]:=09x;
		PutId;
		END;
	(*	enter space sequences*)
	s[0]:=' ';
	FOR i:=2 TO 6 DO
		s[i-1]:=' ';
		PutId;
		END;
	(*	Enter CR/LF code*)
	s[0]:=0dx;
	s[1]:=0ax;
	i:=2;
	PutId;
	FOR i:=3 TO 6 DO
		s[i-1]:=09x;
		PutId;
		END;

	END SetUpNames;
PROCEDURE GetChar;
VAR	reply:INTEGER;
BEGIN
	IF InPos>HIGH(BufferIn) THEN
		SeqReadBlock(From,ADR(BufferIn),SIZE(BufferIn),reply);
		InPos:=0;
		END;
	ch:=BufferIn[InPos];
(*	WriteCard(InPos,4);WriteString(' ');WriteHex(ORD(ch),4);WriteLn;*)
	INC(InPos);
	END GetChar;
PROCEDURE FlushOut;
VAR	reply:INTEGER;
	i:CARDINAL;
BEGIN
	IF OutPos=0 THEN RETURN END;
	i:=128*((OutPos+127) DIV 128);
	IF i>HIGH(BufferOut) THEN i:=HIGH(BufferOut) END;
	WHILE OutPos<i DO
		BufferOut[OutPos]:=1ax;
		INC(OutPos);
		END;
	INC(i);
	SeqWriteBlock(To,ADR(BufferOut),i,reply);
	OutPos:=0;
	END FlushOut;
PROCEDURE PutChar(ch:CHAR);
BEGIN
	IF OutPos>HIGH(BufferIn) THEN FlushOut END;
	BufferOut[OutPos]:=ch;
	INC(OutPos);
	END PutChar;

PROCEDURE GetCode;
BEGIN
	Code:=0;
	IF ch<' ' THEN
		Code:=ORD(ch)*256;
		GetChar;
		END;
	Code:=Code+ORD(ch);
	END GetCode;
PROCEDURE PutId;
VAR	i:CARDINAL;
	p:PName;
BEGIN
	GetCode;
	p:=Table;
	WHILE (p<>NIL) AND (p^.Code<>Code) DO 
		p:=p^.Next 
		END;
	IF p=NIL THEN 
		WriteString(' error in PutId');
		WriteCard(Code,4);
		WriteString(Table^.Text);
		WriteLn;
		RETURN
		END;
	i:=0;
	WITH p^ DO
		WHILE Text[i]<>0x DO
			PutChar(Text[i]);
			INC(i);
			END;
		END;
	END PutId;
PROCEDURE DefCode;
VAR	Id:Ident;
	i:CARDINAL;
BEGIN
	GetChar;
	IF ch=0x THEN Eof:=TRUE;RETURN END;
	i:=0;
	WHILE ch<>0x DO
		Id[i]:=ch;
		PutChar(ch);
		GetChar;
		INC(i);
		END;
	Id[i]:=0c;
	GetChar;
	GetCode;
	EnterId(Id);
	END DefCode;
		
BEGIN
	Table:=NIL;
	SetUpNames;
	j:=0;
	InPos:=HIGH(BufferIn)+1;
	OutPos:=0;
	GetChar;
	Eof:=FALSE;
	LOOP
		IF ch=0x THEN DefCode 
		ELSIF (ch>07fx) OR (ch<' ') THEN PutId
		ELSE PutChar(ch) END;
		GetChar;
		IF Eof THEN EXIT END;
		END;
	FlushOut;
	END UnScrunch;
PROCEDURE DoAddition(VAR f:FILE;Sc:BOOLEAN);
VAR	i,j:CARDINAL;
BEGIN
	i:=FindName(f.f);
	IF i<>0 THEN Directory[i].Status:=0ffh END;
	SetBlock(Lib,NextSector);
	j:=NextSector;
	NextSector:=NextSector+Transfer(f,Lib,65535);
	Close(f); 
	AddEntry(f.f,j,NextSector-j,0,0,Sc);
	END DoAddition;
PROCEDURE AddFile(fn:ARRAY OF CHAR;Sc:BOOLEAN);
(*	copy a file into the current library*)
VAR	f:FILE;
	i,j:CARDINAL;
	Buffer:ARRAY[0..1023] OF BYTE;
BEGIN
	Lookup(f,FileName(fn),reply);
	IF reply<>0 THEN
		WriteString('File :');
		WriteString(fn);
		WriteString(' not found');
		WriteLn;
		RETURN;
		END;
	DoAddition(f,Sc);
	END AddFile;
PROCEDURE Yes():BOOLEAN;
VAR	s:ARRAY[1..3] OF CHAR;
BEGIN
	LOOP
		ReadString(s);
		CASE CAP(s[1]) OF
			'Y':RETURN TRUE|
			'N':RETURN FALSE|
			ELSE
				WriteLn;
				WriteString(' Please enter Yes or No:');
				END;
		END;
	END Yes;
PROCEDURE GetSlotCount;
BEGIN
	WriteString(' How many slots ?');
	ReadCard(Slots);
	IF Slots>HIGH(Directory) THEN
		WriteCard(HIGH(Directory),4);
		WriteString(' is maximum slots allowed by this program');
		WriteLn;
		Slots:=HIGH(Directory);
		END;
	Slots:=4*((Slots+3) DIV 4);
	IF Slots=0 THEN HALT END;
	WriteCard(Slots,4);
	WriteString(' Slots allocated');
	WriteLn;
	FOR i:=1 TO Slots DO 
		WITH Directory[i] DO
			Status:=0ffh;
			BaseName:='        ';
			Ext:='   ';
			END;
		END;
	WITH Directory[1] DO
		Status:=0;
		Length:=Slots DIV 4;
		StartSector:=0;
		END;
	NextSector:=Slots DIV 4;
	END GetSlotCount;
PROCEDURE OpenLibrary;
(*	open the library file *)
BEGIN
	WriteString(' Enter name of library file:');
	ReadString(LibName);
	Lookup(Lib,LibName,reply);
	IF reply<>0 THEN
		WriteString(' Could not find that file - create it ?');
		IF Yes() THEN
			Create(Lib,LibName,reply);
			IF reply<>0 THEN
				WriteString(' could not create it either');
				WriteLn;
				HALT
				END;
			GetSlotCount;
		ELSE
			WriteString(' run cancelled');
			WriteLn;
			HALT;
			END;
	ELSE
		ReadBlock(Lib,ADR(Directory),0,SIZE(Directory),reply);
		Slots:=4*Directory[1].Length;
		WriteCard(Slots,4);WriteString(' slots found');WriteLn;
		NextSector:=0;
		FOR i:=1 TO Slots DO
			WITH Directory[i] DO
				IF Status<>0ffh THEN
					j:=Length+StartSector;
					IF j>NextSector THEN NextSector:=j END;
					END;
				END;
			END;
		END;
	END OpenLibrary;
PROCEDURE CloseLibrary;
BEGIN
	WriteBlock(Lib,ADR(Directory),0,128*(Slots DIV 4),reply);
	Close(Lib);
	END CloseLibrary;
PROCEDURE DeleteFile(fn:ARRAY OF CHAR);
VAR	f:fcb;
	i:CARDINAL;
BEGIN
	ConvertFileName(f,FileName(fn));
	i:=FindName(f);
	IF i=0 THEN 
		WriteString(' Could not find :');
		WriteString(fn);
		WriteLn
	ELSE
		WriteString(fn);
		WriteString(fn);
		WriteLn;
		Directory[i].Status:=0ffh;
		END;
	END DeleteFile;
PROCEDURE ExtractFile(fn:ARRAY OF CHAR);
VAR	f:fcb;
	i:CARDINAL;
	fo:FILE;
BEGIN
	ConvertFileName(f,FileName(fn));
	i:=FindName(f);
	IF i=0 THEN 
		WriteString(' Could not find :');
		WriteString(fn);
		WriteLn
	ELSE
		WriteString('Extracting ');
		WriteString(fn);
		WriteLn;
		Create(fo,FileName(fn),reply);
		IF reply<>0 THEN
			WriteString(' Could not create ');
			WriteString(fn);
			WriteLn;
			RETURN
			END;
		WITH Directory[i] DO
			SetBlock(Lib,StartSector);
			IF Scrunched THEN UnScrunch(Lib,fo);
			ELSE i:=Transfer(Lib,fo,Length) END;
			END;
		Close(fo);
		END;
	END ExtractFile;
PROCEDURE DisplayName( d:IndexRecord);
VAR	j:CARDINAL;
BEGIN
	j:=1;
	WITH d DO
		WHILE (j<=8) AND (BaseName[j]<>' ') DO
			Write(BaseName[j]);
			INC(j);
			END;
		WriteString('.');
		WriteString(Ext);
		WHILE j<=8 DO 
			Write(' ');
			INC(j);
			END;
		END;
	END DisplayName;

PROCEDURE ListNames;
VAR	i,j,k:CARDINAL;
BEGIN
	k:=0;
	FOR i:=2 TO Slots DO
		WITH Directory[i] DO
			IF Status<>0ffh THEN
				DisplayName(Directory[i]);
				WriteCard(Length*128,5);
				INC(k);
				IF k=4 THEN WriteLn;k:=0
				ELSE WriteString('  ') END;
				END;
			END;
		END;
	IF k<>0 THEN WriteLn END;
	END ListNames; 
PROCEDURE SetUpFcb(VAR f:FILE);
BEGIN
	    f.devtype:=disc;
	    f.eof:=FALSE;
	    WITH f.f DO
		fcbex:=0;
		fcbcr:=0;
		cpmres:=0;
		fcbrc:=0;
		fcbrn.loworder:=0;
		fcbrn.highorder:=0;
		END;
	END SetUpFcb;
PROCEDURE Reorg;
VAR	i,j,k:CARDINAL;
	OldDir:Index;
	OldSlots:CARDINAL;
	OldLib:FILE;
BEGIN
	OldLib:=Lib;
	Close(Lib);
	MakeBAK(Lib,reply);
	OldDir:=Directory;
	OldSlots:=Slots;
	SetUpFcb(OldLib);
	OldLib.f.fcbft:='BAK';
	k:=BDOS(opnfc,ADR(OldLib.f));
	Create(Lib,LibName,reply);
	IF reply<>0 THEN
		WriteString(' Could not create new library');
		WriteLn;
		RETURN
		END;
	WriteString(' Old library had ');WriteCard(OldSlots,4);
	WriteString(' slots');WriteLn;
	GetSlotCount;
	FOR i:=2 TO OldSlots DO
		WITH OldDir[i] DO
			IF Status<>0ffh THEN
				SetBlock(OldLib,StartSector);
				SetBlock(Lib,NextSector);
				k:=NextSector;
				j:=Transfer(OldLib,Lib,Length);
				AddEntry(fcb(OldDir[i]),k,j,Date,Time,Scrunched);
				NextSector:=NextSector+j;
				END;
			END;
		END;
	END Reorg;
PROCEDURE UpdateAll;
VAR	i,j,k:CARDINAL;
	f:FILE;
BEGIN
	i:=0;IF FName[0]=' ' THEN FName[0]:='@' END;
	WHILE (i<=HIGH(FName))AND (FName[i]<>' ') DO
		WriteString(' Searching disk ');
		Write(FName[i]);
		WriteLn;
		FOR j:=2 TO Slots DO
			WITH Directory[j] DO
				IF Status<>0ffh THEN
				    f.f:=fcb(Directory[j]);
				    SetUpFcb(f);
				    f.f.fcbdn:=ORD(FName[i])-ORD('A')+1;
				    k:=BDOS(opnfc,ADR(f.f));
				    IF k<>0ffh THEN
					WriteString(' Updating:');
					DisplayName(IndexRecord(f.f));
					WriteLn;	
					DoAddition(f,Scrunched);
					END;
				    END;
				END;
			END;
		INC(i);
		END;
	END UpdateAll;
BEGIN
	OpenLibrary;
	WriteString(' Commands are:	F - Finish');WriteLn;
	WriteString('		A - Add or update');WriteLn;
	WriteString('		D - Delete');WriteLn; 
	WriteString('		E - Extract');WriteLn;
	WriteString('		L - List files');WriteLn;
	WriteString('		R - Reorganize');WriteLn;
	WriteString('		U - Update All');WriteLn;
	WriteLn;
	LOOP
		ReadCommand;
		CASE CommandCH OF 
			'F':CloseLibrary;EXIT|
			'A':AddFile(FName,FALSE)|
			'S':AddFile(FName,TRUE)|
			'D':DeleteFile(FName)|
			'E':ExtractFile(FName)|
			'L':ListNames|
			'U':UpdateAll|
			'R':Reorg;	
			END;
		END;
	END MyLU.
 ý  