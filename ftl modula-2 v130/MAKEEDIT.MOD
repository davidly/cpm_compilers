IMPLEMENTATION MODULE MakeEdits;


(*	Routines to edit a file

	(i.e., actually make changes to the file)

	D Moore 11 Jan 85*)
FROM 	Files IMPORT FILE,Lookup,Create,SeqReadBlock,SeqWriteBlock,
	MakeBAK,Close;
FROM	Storage IMPORT ALLOCATE,DEALLOCATE,FreeSpace;
FROM	SYSTEM IMPORT ADR,BYTE;
FROM  	FastMove IMPORT Moveup,Movedown,Searchup,Searchdown;
FROM	SetUpCall IMPORT MakeCall;
IMPORT	EditStatus;
CONST	TextLen=140;	(* must exceed a block on the disc
			   remaining space is for padding*)
	BlockSize=128;	(* characters in a disc block*)
	HeadRoom=512;	(*minimum head room to leave between stack and heap*)
	CR=0dx;
	LF=0ax;
	FF=0cx;
	EOF=1ax;
TYPE	PText=POINTER TO Text;
	PPosition=POINTER TO Position;
	Text=RECORD
		BlockLen:BYTE;
		Chars:ARRAY[0..TextLen-1] OF CHAR;
		Next:PText;		(*next block*)
		Pred:PText;		(*preceding block*)
		END;

		
	Position=RECORD
		Block:PText;
		Offset:BYTE;
		END;
	EditFile=RECORD
		f:FILE;
		Chain:PText;
		CurPos:Position;
		Labels:ARRAY[0..24] OF Position;

		(*labels 0 to 9 are  ^k0 to ^k9
		   10 is ^kB
		   11 is ^kk
		   12 through 14 are the positions in the windows
		   15 through 24 are error markers*)

		END;
VAR	Done:BOOLEAN;
	reply:INTEGER;	

	(*variables used for text position during move operations etc*)

	Working:PText;
	CharPos:INTEGER;
	ch:CHAR;
	pos:Position;
	pos1,pos2:PPosition;
	Charno,Charsread:CARDINAL;

PROCEDURE NewBlock;
BEGIN
	NEW(Working);
	Working^.Pred:=NIL;
	Working^.Next:=NIL;
	END NewBlock;

PROCEDURE setcurpos(VAR f:EditFile);
BEGIN
	WITH f.CurPos DO
		Working:=Block;
		CharPos:=Offset;
		END;
	END setcurpos;

PROCEDURE savecurpos(VAR f:EditFile);
BEGIN
	WITH f.CurPos DO
		IF CharPos>ORD(Working^.BlockLen) THEN 
			CharPos:=Working^.BlockLen 
			END;
		Block:=Working;
		Offset:=CharPos;
		END;
	END savecurpos;
VAR	i:INTEGER;
PROCEDURE Backup():BOOLEAN;

(*	back up a character position in the current file
	returns TRUE if successful*)
BEGIN
	IF CharPos<=0 THEN
 		IF Working^.Pred<>NIL THEN
			Working:=Working^.Pred;
			CharPos:=Working^.BlockLen;
		ELSE
			RETURN FALSE
			END;
		END; (*CharPos<=0*)
	DEC(CharPos);
	RETURN TRUE
	END Backup;
PROCEDURE OpenFile(VAR f:EditFile;fn:FileName;VAR reply:INTEGER;Pos:CARDINAL);
VAR	p:PText;
BEGIN
	Lookup(f.f,fn,reply);
	IF Pos=65535 THEN Charno:=EditStatus.GetPosition(f.f);
	ELSE Charno:=Pos END;
	Charsread:=0;
	IF reply<0 THEN 
		reply:=-2;
		RETURN
		END;
	p:=NIL;
	reply:=0;
	FOR i:=0 TO HIGH(f.Labels) DO f.Labels[i].Block:=NIL END;
	LOOP	(*read in the file*)
		IF FreeSpace()<HeadRoom THEN
			AbandonFile(f);
			reply:=-3;
			RETURN
			END;
		NewBlock;
		Working^.Pred:=p;
		IF p=NIL THEN f.Chain:=Working
		ELSE p^.Next:=Working END;
		SeqReadBlock(f.f,ADR(Working^.Chars),BlockSize,i);
		IF i<>BlockSize THEN (*end of file found*)
			IF p<>NIL THEN 
				p^.Next:=NIL;
				DISPOSE(Working);
			ELSE	(*always keep at least one block*)
				Working^.BlockLen:=1;
   				Working^.Chars[0]:=EOF;
				CharPos:=0;
				savecurpos(f);
				END;
			EXIT
		ELSE	
		
			WHILE (i>0) AND (Working^.Chars[i-1]=EOF) DO
				DEC(i);
				END;
			IF (Working^.Chars[i-1]<>0ax) AND (i<BlockSize) THEN
				INC(i);
				Working^.Chars[i-1]:=EOF;
				END;
			Working^.BlockLen:=i;
			IF Charsread<=Charno  THEN 
				CharPos:=Charno-Charsread;
				savecurpos(f);
				p:=Working;
				IF (Working^.Chars[CharPos]=LF) 
				   AND Backup() THEN
					savecurpos(f);
					END;
				Working:=p;
				END;
			Charsread:=Charsread+ORD(Working^.BlockLen);
			END;
		p:=Working;
		reply:=reply+1;
		END; (*read file loop*)
	Close(f.f);
	END OpenFile;
		
PROCEDURE CloseFile(VAR f:EditFile;VAR reply:INTEGER);
VAR	
	b:ARRAY[0..BlockSize-1] OF CHAR;
	pos:INTEGER;
BEGIN
	MakeBAK(f.f,reply);
	Charno:=1;
	IF reply=0 THEN 
		Working:=f.Chain;
		pos:=0;
		reply:=BlockSize;
		LOOP
		    IF  (Working=NIL) THEN EXIT END;
		    WITH Working^ DO
			FOR i:=0 TO INTEGER(BlockLen)-1 DO
				IF pos>=BlockSize THEN
					SeqWriteBlock(f.f,ADR(b),BlockSize,
						reply);
					pos:=0;
					IF reply<>BlockSize THEN EXIT END;
					END; (*IF*)
				b[pos]:=Chars[i];
				INC(pos);
				END;(*FOR*)
		
			IF Working=f.CurPos.Block THEN
			    EditStatus.SetPosition(f.f,Charno+ORD(f.CurPos.Offset))
			    END;
			Charno:=Charno+ORD(BlockLen);
			Working:=Next
			END;(*WITH Working*)
		    END; (*WHILE Working<>NIL and not disc full*)
		FOR pos:=pos TO BlockSize-1 DO b[pos]:=EOF END;
		IF reply=BlockSize THEN 
			SeqWriteBlock(f.f,ADR(b),BlockSize,reply) 
			END;
		Close(f.f);
		IF reply<>BlockSize THEN reply:=-1
		ELSE reply:=0 END;
	ELSE	reply:=-2 
		END;
	END CloseFile;
			
	
PROCEDURE AbandonFile(f:EditFile);
VAR	p:PText;
(*	Abandon changes to an edit file*)
BEGIN
	Working:=f.Chain;
	WHILE Working<>NIL DO 
		p:=Working^.Next;
		DISPOSE(Working);
		Working:=p;
		END;
	END AbandonFile;
PROCEDURE GetPosition(VAR f:EditFile;VAR p:Position);
BEGIN
	p:=f.CurPos;
	END GetPosition;
		
PROCEDURE SetPosition(VAR f:EditFile;p:Position);
(*	get/set position in a file*)
BEGIN
	f.CurPos:=p;
	
	(*	pointer may be pointing just after end of block
		(after deletes), regularize that situation*)

	WITH f.CurPos DO
		IF 	    (Offset>=Block^.BlockLen) 
			AND (Block^.Next<>NIL) THEN
			Offset:=0;
			Block:=Block^.Next
			END;
		END; 
	END SetPosition;
PROCEDURE LabelOp(VAR f:EditFile;Define:BOOLEAN;ch:CHAR):BOOLEAN;
(*
	perform a label operation , return true if successful
	Define is true if the operation is a define label
	it is false if it is a goto label
*)

VAR	i:CARDINAL;
BEGIN
	(*$A^*)
	ch:=CAP(ch);
	CASE ch OF
		'B': i:=10|
		'^K','K': i:=11|
		1x..3x:i:=ORD(ch)+11|
		'0'..'9':i:=ORD(ch)-ORD('0')|
		0b0x..0b9x:i:=ORD(ch)-0b0h+15
		ELSE RETURN FALSE
		END;
	IF Define THEN
		GetPosition(f,f.Labels[i]);
	ELSE
		IF f.Labels[i].Block=NIL THEN RETURN FALSE END;
		SetPosition(f,f.Labels[i]);
	 	END;
	RETURN TRUE;
	END LabelOp;
PROCEDURE Advance():BOOLEAN;

(*	advance a character position in the current file*)
BEGIN		
	INC(CharPos);
	IF CharPos>=INTEGER(Working^.BlockLen) THEN
		
		IF Working^.Next<>NIL THEN
			Working:=Working^.Next;
			CharPos:=0;
		ELSE
			RETURN FALSE
			END;
		END; (*CharPos>BlockLen*)
	RETURN Working^.Chars[CharPos]<>EOF
	END Advance;
PROCEDURE InsideBlock(VAR F:EditFile):BOOLEAN;

(*	Check if current position is inside block *)
VAR	b:PText;
	CouldBe:BOOLEAN;
BEGIN
	setcurpos(F);
	IF (F.Labels[10].Block=NIL) OR (F.Labels[11].Block=NIL) THEN
		RETURN FALSE;
		END;
	b:=F.Labels[10].Block;

	WHILE (b<>NIL) AND (b<>F.Labels[11].Block) AND (b<>Working) DO
		b:=b^.Next;
		END;

	
	(*if end precedes beginning of block*)
	CouldBe:=b=Working;
	IF NOT CouldBe THEN RETURN FALSE END;
	IF b=F.Labels[10].Block THEN
		(*	in start block - check after label start*)
		CouldBe:=CharPos>=ORD(F.Labels[10].Offset)
		END;
	IF b=F.Labels[11].Block THEN
		(*	in start block - check after label start*)
		CouldBe:=CouldBe AND (CharPos<=ORD(F.Labels[11].Offset))
		END;
	IF CouldBe THEN
		WHILE (b<>NIL) AND (b<>F.Labels[11].Block) DO b:=b^.Next END;
		CouldBe:=b<>NIL
		END;
	RETURN CouldBe;
	END InsideBlock;

PROCEDURE CheckBlock(VAR F:EditFile):BOOLEAN;

(*	Check if begin and end of block have been correctly set up*)

BEGIN
	IF (F.Labels[10].Block=NIL) OR (F.Labels[11].Block=NIL) THEN
		RETURN FALSE;
		END;
	Working:=F.Labels[10].Block;
	reply:=0;

	WHILE (Working<>NIL) AND (Working<>F.Labels[11].Block) DO
		reply:=reply+ORD(Working^.BlockLen);
		Working:=Working^.Next;
		END;

	IF Working=NIL THEN RETURN FALSE END;
	
	(*if end precedes beginning of block*)

	reply:=reply+ORD(F.Labels[11].Offset)-ORD(F.Labels[10].Offset);
	RETURN reply>=0
	END CheckBlock;
PROCEDURE BlockCopy(VAR FromFile,ToFile:EditFile):BOOLEAN;

(*	Careful - Easy - Ouch!

	FromFile and ToFile may be the same  variable*)

VAR	i:INTEGER;
	c:ARRAY[1..TextLen] OF CHAR;
	p,q,r:Position;

(*	This code is a little odd for the following reason:

	1/	InsChars cannot insert more than half a block of characters
	2/	If you don't read at least a block at a time and the
		to and from files are the same, you may have to change the
		position in the from file to reflect insertions, which is
		awkward (though you could always add a temporary label)

	Therefore, text is read and then inserted in up to three goes!*)

	Third:CARDINAL;
BEGIN
	Third:=TextLen DIV 3;
	IF NOT CheckBlock(FromFile) THEN RETURN FALSE END;
	WITH FromFile.Labels[10] DO
		CharPos:=Offset;
		Working:=Block;
		END;
	Charsread:=0;
	i:=reply;
	r:=FromFile.CurPos;
	q:=ToFile.CurPos;
	FromFile.CurPos:=FromFile.Labels[10];
	LOOP
		IF i=0 THEN 
			EXIT 
			END;
		INC(Charsread);
		c[Charsread]:=Working^.Chars[CharPos];
		IF (Charsread=HIGH(c)) OR (i=1) THEN
			savecurpos(FromFile);
			p:=FromFile.CurPos;
			ToFile.CurPos:=q;
			WHILE Charsread>0 DO
				IF Charsread>Third THEN
					InsChars(ToFile,c,Third);
					Charsread:=Charsread-Third;
					Movedown(ADR(c[Third+1]),
						ADR(c),Charsread);
				ELSE
					InsChars(ToFile,c,Charsread);
					Charsread:=0;
					END;
				END;
			q:=ToFile.CurPos;
			FromFile.CurPos:=p;
			setcurpos(FromFile);
			END;
		IF NOT Advance() THEN EXIT (* never taken*) END;
		DEC(i);
		END;	(*LOOP*)
	FromFile.CurPos:=r;
	ToFile.CurPos:=q;
	RETURN TRUE;
	END BlockCopy;
PROCEDURE BlockDel(VAR FromFile:EditFile):BOOLEAN;
VAR	p:Position;
BEGIN
	IF NOT CheckBlock(FromFile) THEN RETURN FALSE END;
	WITH FromFile DO
		Labels[25]:=CurPos;
		CurPos:=Labels[10];
	        DelChars(FromFile,reply);
		CurPos:=Labels[25];
		Labels[25].Block:=NIL;
		END;
	RETURN TRUE;
	END BlockDel;
PROCEDURE RelocateLabels(VAR f:EditFile;number:INTEGER);
(*	Relocate labels for the current block
	number is number of characters being deleted 
	(-ve for insertions)
*)
BEGIN
        FOR reply:=0 TO HIGH(f.Labels) DO
		WITH f.Labels[reply] DO
			IF (Block=Working) AND (ORD(Offset)>=CharPos) THEN
				IF (number=ORD(Working^.BlockLen)) THEN
					Block:=Working^.Next;
					Offset:=0;
				ELSIF (number+CharPos)>ORD(Offset) THEN
					Offset:=CharPos
				ELSE
					Offset:=ORD(Offset)-number
					END;(*IF*)
				END;(*IF Block=Working etc*)
			END; (*WITH*)
		END;(*FOR*)
	END RelocateLabels;


PROCEDURE DelChars(VAR f:EditFile;number:INTEGER);

(*	delete a number of characters*)

PROCEDURE DelInBlock(number:INTEGER);

(*	Perform a delete which does not span a block*)
BEGIN
	RelocateLabels(f,number);
	WITH Working^ DO
		IF (number=ORD(BlockLen)) (*=>CharPos=0*) THEN
			(*Delete block*)

			IF Next<>NIL THEN Next^.Pred:=Pred END;
			IF Pred<>NIL THEN 
				Pred^.Next:=Next;
				DISPOSE(Working);
			ELSIF Next<>NIL THEN 
				f.Chain:=Next;
				DISPOSE(Working);
			ELSE	(*only block in file so keep*)
				BlockLen:=1;
				Working^.Chars[0]:=EOF;
				END;(*Pred<>NIL*)
		ELSE	
			IF ORD(BlockLen)>(CharPos+number) THEN
			    Movedown(ADR(Chars[CharPos+number]),
				ADR(Chars[CharPos]),
				ORD(BlockLen)-ORD(CharPos)-number);
				END;
			BlockLen:=ORD(BlockLen)-number;
			IF (Next=NIL) AND (Chars[BlockLen-1]<>EOF) THEN
				Chars[BlockLen]:=EOF;
				INC(BlockLen); 
				END;
			END(* Block not now empty*);
		END;(*WITH*)
	END DelInBlock;

VAR	NextBlock:PText;
BEGIN
	setcurpos(f);
	WHILE (number>0) AND (Working<>NIL) DO
		NextBlock:=Working^.Next;
		IF number<=(ORD(Working^.BlockLen)-CharPos) THEN
			DelInBlock(number);
			number:=0;
		ELSE
			number:=number-ORD(Working^.BlockLen)+CharPos;
			DelInBlock(ORD(Working^.BlockLen)-CharPos);
			END;
		IF (number>0) OR (Working=NIL) THEN 
			Working:=NextBlock;
			CharPos:=0; 
			END;
		END; (*WHILE*)
	IF Working=NIL THEN 
		Working:=f.Chain;
		WHILE Working^.Next<>NIL DO Working:=Working^.Next END;
		CharPos:=Working^.BlockLen
		END;(*deleted everything*)
	savecurpos(f);
	END DelChars;

PROCEDURE InsChars(VAR f:EditFile;VAR S:ARRAY OF CHAR;len:INTEGER);
(*	insert characters*)
VAR	left,follows:INTEGER;
	MainBlock:PText;
PROCEDURE InsInBlock;
VAR	start:INTEGER;
	i:INTEGER;
BEGIN

		(*adjust labels*)
	RelocateLabels(f,-len);
	start:=0;
	WITH Working^ DO
		IF ORD(BlockLen)>CharPos THEN
		    Moveup(ADR(Chars[CharPos]),ADR(Chars[CharPos+len]),
			ORD(BlockLen)-CharPos);
		    END;
		BlockLen:=ORD(BlockLen)+len;
		WHILE len>0 DO
			Chars[CharPos]:=S[start];
			INC(start);
			DEC(len);
			INC(CharPos);
			END;
		END;
	END InsInBlock;
			
(*	If text will fit in current block, enter in current block
	else split block and enter in appropriate block*)

BEGIN
	setcurpos(f);
	left:=TextLen-ORD(Working^.BlockLen);

	(*	left is characters left in block*)

	IF left>=len THEN InsInBlock
	ELSE

		(*split the block so that after insert the two blocks
		  will be approx equal in size*)
		left:=ORD(Working^.BlockLen) DIV 2;
		MainBlock:=Working;
		NewBlock;
		Working^.Pred:=MainBlock;
		FOR reply:=0 TO HIGH(f.Labels) DO
			WITH f.Labels[reply] DO
				IF (Block=MainBlock) AND (ORD(Offset)>=left) THEN
					Block:=Working;
					Offset:=ORD(Offset)-left;
					END;
				END;
			END;
					
		WITH MainBlock^ DO
			Working^.Next:=Next;
			IF Next<>NIL THEN Next^.Pred:=Working END;
			Next:=Working;
			Working^.BlockLen:=ORD(BlockLen)-left;
			BlockLen:=left;
			Moveup(ADR(Chars[BlockLen]),
			    ADR(Working^.Chars),
			    left+1);
			IF CharPos<ORD(BlockLen) THEN Working:=MainBlock
			ELSE CharPos:=CharPos-ORD(BlockLen) END;
			InsInBlock;
			END;(*WITH*)
		END;(*left>=len*)
	savecurpos(f);
	END InsChars;


VAR	b:BOOLEAN;

PROCEDURE BackupLine():INTEGER;

(*	Backup to beginning of current line
	returns number of characters backed up

	after the call, the position is the first character
	after of the line*)
VAR	pos:INTEGER;
BEGIN
	pos:=0;
	LOOP
		IF NOT Backup() THEN EXIT END;
		ch:=Working^.Chars[CharPos];
		IF ((ch=CR) OR (ch=LF) OR (ch=FF))  THEN 
			b:=Advance();
			EXIT 
			END;
		pos:=pos+1;
		END; (*LOOP*)
	RETURN pos;
	END BackupLine;
VAR	AdvanceOK:BOOLEAN;
PROCEDURE AdvanceLine():INTEGER;

(*	move  to start of next line
	returns characters advanced
	positions to first character of next line*)
VAR	pos:INTEGER;
	b:BOOLEAN;
BEGIN
	AdvanceOK:=TRUE;
	pos:=0;
	LOOP
		ch:=Working^.Chars[CharPos];
		IF ch=EOF THEN 
			AdvanceOK:=FALSE;
			EXIT 
			END;
		IF (ch=CR) OR (ch=LF) OR (ch=FF) THEN 
			IF NOT Advance() THEN EXIT END;
			ch:=Working^.Chars[CharPos];
			IF ch=LF THEN b:=Advance() END;
			EXIT
			END;
		INC(pos);
		IF NOT Advance() THEN 
			AdvanceOK:=FALSE;
			EXIT 
			END;
		END; (*LOOP*)
	RETURN pos;
	END AdvanceLine;

	
PROCEDURE Retrline(VAR f:EditFile;VAR len,pos:INTEGER;VAR p:Position;
		VAR linesmoved:INTEGER;linestomove:INTEGER);
(*	return the position in the current line*)
VAR	ch:CHAR;
	i:INTEGER;
	b:BOOLEAN;
BEGIN
	setcurpos(f);
	linesmoved:=0;

	IF CharPos>INTEGER(Working^.BlockLen) THEN
		CharPos:=Working^.BlockLen 
		END;

	IF linestomove=-16736 THEN (*go to top of file
				    This is a recent mod to speed up 
				     ^QC and ^QR*)
		Working:=f.Chain;
		CharPos:=0;
		pos:=0;
	ELSIF linestomove=16736 THEN
		WHILE Working^.Next<>NIL DO
			Working:=Working^.Next;
			END;
		CharPos:=ORD(Working^.BlockLen);
		IF Working^.Chars[CharPos-1]=EOF THEN
			DEC(CharPos);
			END;
		savecurpos(f);
		p:=f.CurPos;
		pos:=BackupLine();
		f.CurPos:=p;
	ELSE
	    (*chase backwards until a CR, LF or FF is found and
	      calculate position in line*)
	    pos:=BackupLine();
	    len:=0;

	    (*	now positioned to beginning of current line
		move required number of lines*)

	    IF linestomove<0 THEN
		WHILE 	(linestomove<0)
		     AND ((CharPos>0) OR (Working^.Pred<>NIL)) DO
			INC(linestomove);

			(*move back over cr/lf*)

			IF Backup() AND (Working^.Chars[CharPos]=LF) THEN
				b:=Backup()
				END;
			DEC(linesmoved);
			len:=BackupLine();
			END;
	    ELSE
		WHILE 	(linestomove>0)
			AND (  (CharPos<INTEGER(Working^.BlockLen))
			    OR (Working^.Next<>NIL)) DO 

			DEC(linestomove);
			len:=AdvanceLine();
			IF AdvanceOK THEN INC(linesmoved) END;
			END;
		END;
	    END;
	savecurpos(f);p:=f.CurPos;
	IF Working^.Chars[CharPos]=EOF THEN

		(*IF we are at end of file, reposition to start
		  of current line as Retrline always returns
		  position as at start of line*)

		len:=BackupLine();
		savecurpos(f);
		p:=f.CurPos;
		pos:=len
	ELSE
		len:=AdvanceLine();
		END;
	f.CurPos:=p;
	END Retrline;
PROCEDURE ReadNextChar(VAR p:Position;VAR ch:CHAR);
BEGIN
	WITH p DO
		IF Offset>=Block^.BlockLen THEN
			IF Block^.Next=NIL THEN
				ch:=EOF;
				RETURN
			ELSE
				Block:=Block^.Next;
				Offset:=0;
				END;
			END;
		ch:=Block^.Chars[Offset];
		IF ch<>EOF THEN Offset:=Offset+1 END;
		END;
	END ReadNextChar;
PROCEDURE GetCurrentChar(VAR f:EditFile):CHAR;

BEGIN
	pos:=f.CurPos;
	ReadNextChar(pos,ch);
	RETURN ch
	END GetCurrentChar;
PROCEDURE  BackOneChar(VAR f:EditFile):BOOLEAN;
BEGIN
	setcurpos(f);
	b:=Backup();
	savecurpos(f);
	RETURN b
	END BackOneChar;				
	
PROCEDURE  ForwardOneChar(VAR f:EditFile):BOOLEAN;
BEGIN
	setcurpos(f);
	b:=Advance();
	savecurpos(f);
	RETURN b
	END ForwardOneChar;				
VAR	String:ARRAY[0..59] OF CHAR;
	StringLen:CARDINAL=0;	
	MatchCharNo:CARDINAL;
	MatchChar:CHAR;

PROCEDURE Matches():BOOLEAN;
BEGIN
	RETURN (Working^.Chars[CharPos]=String[MatchCharNo])
	    OR (Working^.Chars[CharPos]=CAP(String[MatchCharNo]))
	END Matches;
PROCEDURE PrepareString(s:ARRAY OF CHAR;len:INTEGER);

BEGIN
	StringLen:=len;
	Moveup(ADR(s),ADR(String),len);
	END PrepareString;
(*	prepare a string for use in a find command*)

PROCEDURE FindString(VAR f:EditFile;Backwards:BOOLEAN):BOOLEAN;


(*	backwards not yet implemented*)
BEGIN
	IF StringLen=0 THEN RETURN TRUE END;
	setcurpos(f);
	IF Backwards THEN
		MatchChar:=String[StringLen-1];
		LOOP
			IF NOT Backup() THEN EXIT END;
			IF (Working^.Chars[CharPos]=MatchChar) 
			  OR (Working^.Chars[CharPos]=CAP(MatchChar)) THEN
				MatchCharNo:=StringLen-2;
				savecurpos(f);
				WHILE (MatchCharNo>0)
				    AND (Backup())
				    AND Matches() DO
					DEC(MatchCharNo);
					END;
				IF Backup() AND Matches() 
				   AND (MatchCharNo=0) THEN
					RETURN TRUE;
					END;
				setcurpos(f);
				END;
			END;
	ELSE
		MatchChar:=String[0];
		LOOP
			IF NOT Advance() THEN EXIT END;
			IF (Working^.Chars[CharPos]=MatchChar)
			  OR (Working^.Chars[CharPos]=CAP(MatchChar)) THEN
				MatchCharNo:=1;
				savecurpos(f);
				WHILE (MatchCharNo<StringLen)
				    AND (Advance())
				    AND  Matches() DO
					INC(MatchCharNo);
					END;
				IF MatchCharNo>=StringLen THEN
					RETURN TRUE;
					END;
				setcurpos(f);
				END;
			END;
		END;
	savecurpos(f);
	RETURN FALSE;
	END FindString;
(*	Actually find the next occurrence of the string	

	Done returns true if one is found*)
PROCEDURE CallWithFile(Name:ARRAY OF CHAR;VAR f:EditFile);
BEGIN
	MakeCall(Name,f.f.f);
	END CallWithFile;
PROCEDURE FileType(VAR f:EditFile):CARDINAL;
BEGIN
	IF f.f.f.fcbft='MOD' THEN RETURN 1
	ELSIF f.f.f.fcbft='DEF' THEN RETURN 2
	ELSE RETURN 0
		END
	END FileType;
PROCEDURE MoveToChar(VAR File:EditFile;Pos:CARDINAL);
VAR	i:CARDINAL;w:PText;
BEGIN
	Working:=File.Chain;
	w:=NIL;
	i:=0;
	LOOP
		IF Working=NIL THEN EXIT END;
		i:=i+ORD(Working^.BlockLen);
		w:=Working;
		IF i<Pos THEN Working:=Working^.Next ELSE EXIT END;
		END;
	IF Working=NIL THEN 
		Working:=w;
		CharPos:=w^.BlockLen;
	ELSE
		CharPos:=Pos-(i-ORD(Working^.BlockLen));
		END;
	savecurpos(File);
	END MoveToChar;
PROCEDURE DefineErrors(VAR f:EditFile);
VAR	i:CARDINAL;
	b:BOOLEAN;
BEGIN
	IF ErrorCount=0 THEN RETURN END;
	FOR i:=0 TO ErrorCount-1 DO
		MoveToChar(f,ErrorList[i].CharP);
		b:=LabelOp(f,TRUE,CHR(0b0h+i));
		END;
	END DefineErrors;

END MakeEdits.
          [  2  PATTERN DEF €             b    PATTERN MOD €             e €  RECMPED SUB €             i    