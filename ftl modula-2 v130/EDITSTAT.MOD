IMPLEMENTATION MODULE EditStatus;

(*	Save/return edit status for a file

	The file EDITSTAT.DAT on the default drive is always used
	for edit statii*)
FROM Files IMPORT Lookup,Create,Close,SeqReadBlock,SeqWriteBlock,SetBlock,
		ConvertFileName;
FROM ScreenIO IMPORT Gotoxy,ScreenDepth;
FROM SYSTEM IMPORT ADR,TSIZE;
FROM Terminal IMPORT WriteString;
TYPE	FileRec=RECORD
		Filefn:alfa;
		Fileft:exten;
		FilePos:CARDINAL;
		END;

CONST	BytesPerBlock=128;	(*Bytes per disc block*)
	EntriesPerBlock=(BytesPerBlock-TSIZE(CARDINAL)) DIV TSIZE(FileRec);
	FillSize=BytesPerBlock-TSIZE(CARDINAL)-EntriesPerBlock*TSIZE(FileRec);
TYPE	Block=RECORD
		Entries:CARDINAL;	(*in this block*)
		FileEntry:ARRAY[0..EntriesPerBlock-1] OF FileRec;
		Filler:ARRAY[1..FillSize] OF CHAR;
		END;

VAR	datfile:FILE;
	BlockNo:CARDINAL;
	EntryNo:CARDINAL;
	Buffer:Block;
	f:FILE;
	reply:INTEGER;
	opened:BOOLEAN;
	ch:CHAR;
PROCEDURE WriteFile;
BEGIN
	SetBlock(datfile,BlockNo);
	SeqWriteBlock(datfile,ADR(Buffer),BytesPerBlock,reply);
	Close(datfile);
	Lookup(datfile,'EDITSTAT.DAT ',reply);
	END WriteFile;

PROCEDURE MakeEntry;
BEGIN
	WITH Buffer.FileEntry[EntryNo] DO
		Filefn:=f.f.fcbfn;
		Fileft:=f.f.fcbft;
		FilePos:=0;
		END;
	WriteFile;
	END MakeEntry;

PROCEDURE ExamineBlock;
BEGIN
	EntryNo:=0;
	WHILE (EntryNo<Buffer.Entries) 
	    AND (   (Buffer.FileEntry[EntryNo].Filefn<>f.f.fcbfn)
		  OR (Buffer.FileEntry[EntryNo].Fileft<>f.f.fcbft)) DO
		INC(EntryNo);
		END;
	IF EntryNo>=Buffer.Entries THEN
		IF Buffer.Entries<HIGH(Buffer.FileEntry) THEN
			INC(Buffer.Entries);
			MakeEntry;
		ELSE	EntryNo:=60000 END;	
		END;
	END ExamineBlock;
PROCEDURE Search;

(*	Find entry - create entry if neccessary*)
BEGIN
	IF BlockNo<60000 THEN ExamineBlock
	ELSE EntryNo:=60000 END;
	IF EntryNo=60000 THEN
		SetBlock(datfile,0);
		BlockNo:=0
		END;
	WHILE EntryNo=60000 DO
		SeqReadBlock(datfile,ADR(Buffer),BytesPerBlock,reply);
		IF reply<>BytesPerBlock THEN
			Buffer.Entries:=1;
			EntryNo:=0;
			MakeEntry;
		ELSE	
			ExamineBlock;
			END;
		IF EntryNo=60000 THEN INC(BlockNo) END;
		END;
	END Search;
		

PROCEDURE GetPosition(Fn:FILE):CARDINAL;
BEGIN
	f:=Fn;
	IF opened THEN
		Search;
		RETURN Buffer.FileEntry[EntryNo].FilePos;
	ELSE	RETURN 0 END;
	END GetPosition;

PROCEDURE SetPosition(Fn:FILE;Pos:CARDINAL);
BEGIN
	f:=Fn;
	IF opened THEN
		Search;
		Buffer.FileEntry[EntryNo].FilePos:=Pos;
		WriteFile
		END
	END SetPosition;

BEGIN
	opened:=TRUE;	(*assume file can be opened*)
	Lookup(datfile,'EDITSTAT.DAT ',reply);
	IF reply<>0 THEN
		Create(datfile,'EDITSTAT.DAT',reply);
		IF reply<>0 THEN 
			Gotoxy(0,ScreenDepth-1);
			WriteString(' Could not open status file');
			opened:=FALSE;
			END;
		END;
	BlockNo:=60000;	(*set impossibly big*)
	
	END EditStatus.
