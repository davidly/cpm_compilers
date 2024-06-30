IMPLEMENTATION MODULE Macros;
FROM	DoMenu IMPORT GetString,Redisplay;
FROM	Storage IMPORT  ALLOCATE,DEALLOCATE;
FROM	Terminal IMPORT BusyRead,WriteString,WriteLn,Write;
FROM	Files IMPORT FILE,SeqReadBlock,SeqWriteBlock,Lookup,Create,Close;
FROM	SYSTEM IMPORT ADR,TSIZE;
FROM	EditDisplay IMPORT ErrorMessage;
FROM	FastMove IMPORT Moveup;
FROM	ScreenDu IMPORT OutputToScreen;
CONST	BlockLen=128;
	ESC=1bx;
TYPE
	KeyDef=RECORD
		Length:[1..61];
		CommChars:ARRAY[1..20] OF CHAR;
		END;
	PKeyDef=POINTER TO KeyDef;
	MacroPoint=RECORD
		Pos:CARDINAL;
		Def:PKeyDef;
		Count:INTEGER;
		END;
	PKeyChain=POINTER TO KeyChain;
	KeyChain=RECORD
		ch:CHAR;
		NextAlt:PKeyChain; (*next alternative*)
		CASE Terminator:BOOLEAN OF
			TRUE: (*terminates a key sequence *)
				Def:PKeyDef|
			FALSE: (*in the moddle of a key sequence *)
				NextChar:PKeyChain
			END; (*CASE*)
		END;(*RECORD*)
				
VAR
	ch:CHAR;
	Commands:ARRAY['@'..'Z'] OF PKeyDef;
	MacroDepth:CARDINAL=0;
	MacroStack:ARRAY[1..5] OF MacroPoint;
	Learnch:CHAR;
	LearnLen:CARDINAL;
	Learning:BOOLEAN=FALSE;
	Text:ARRAY[1..60] OF CHAR;
	i:CARDINAL;
	KeySeq:ARRAY[1..10] OF CHAR;
	KeyChainBase:PKeyChain=NIL;	(*base of table of key defs*)
	LastKeyPos,KeyPos:PKeyChain;	(*pointers used for searching*)
	LearnKey:PKeyChain;		(*pointer to key being defined*)

	(*	keep a circular buffer of characters while matching is
		happening*)

	in:CARDINAL=1;
	out:CARDINAL=1;
	look:CARDINAL;
	Buffer:ARRAY[1..11] OF CHAR;	
	ShowChange:BOOLEAN;
PROCEDURE SearchToNext(ch:CHAR);

(*	Search for the character ch

	KeyPos points to the first table  to examine
	for a match
*)
BEGIN
	WHILE (KeyPos<>NIL) AND (KeyPos^.ch<>ch) DO
		KeyPos:=KeyPos^.NextAlt;
		END;
	END SearchToNext;
PROCEDURE BuildKeySeq;

(*	Enter a key sequence into the key sequence tree

	On entry, KeySeq contains sequence to build

	On exit, KeyPos points to entry for macro pointer*)
BEGIN
	i:=1;
	KeyPos:=KeyChainBase;
	LastKeyPos:=NIL;
	(* First scan down common part *)

	WHILE (KeyPos<>NIL) AND  (KeySeq[i]<>' ') DO
		
		SearchToNext(KeySeq[i]);
		IF KeyPos<>NIL THEN 
			INC(i);
			LastKeyPos:=KeyPos;
			LearnKey:=KeyPos;
			KeyPos:=KeyPos^.NextChar;
			END;
		END;
	IF KeySeq[i]=' ' THEN (*must already be in table*)
		RETURN
		END;
	
	(* Assuming this is not the first entry, LastKeyPos points
	   to the entry to which we should attach this new character
	*)
	WHILE  (KeySeq[i]<>' ') DO
		NEW(KeyPos);
		WITH KeyPos^ DO
			ch:=KeySeq[i];
			NextChar:=NIL;
			Terminator:=FALSE;
			IF LastKeyPos<>NIL THEN
				NextAlt:=LastKeyPos^.NextChar;
				LastKeyPos^.NextChar:=KeyPos;
			ELSE
				NextAlt:=KeyChainBase;
				KeyChainBase:=KeyPos;
				END;
			END;
		LastKeyPos:=KeyPos;
		INC(i);
		END;
	LearnKey:=KeyPos;
	END BuildKeySeq; 

PROCEDURE WaitForCh;
BEGIN
	IF NOT ShowChange THEN
		ShowChange:=TRUE;
		OutputToScreen(TRUE);
		Redisplay;
		END;
	REPEAT
		BusyRead(ch);
		UNTIL ch<>0x;
	END WaitForCh;
PROCEDURE CheckInterrupt():BOOLEAN;

(*	Check the keyboard for an interupt (Control U)

	Also, if Escape has been typed, stop terminal output
	until another character is typed*)

VAR	ch1:CHAR;
BEGIN
	BusyRead(ch1);
	CASE ch1 OF 
		15x:RETURN TRUE
		    |
		1bx:ShowChange:=FALSE;
		    OutputToScreen(FALSE);
		END;
	RETURN FALSE
	END CheckInterrupt;
PROCEDURE GetAChar(VAR ch1:CHAR);
BEGIN
	IF MacroDepth=0 THEN
		WaitForCh;
		ch1:=ch;
		IF Learning AND (LearnLen<HIGH(Text)) THEN
			INC(LearnLen);
			Text[LearnLen]:=ch;
			END;
	ELSE
		WITH MacroStack[MacroDepth] DO
			IF Pos>Def^.Length THEN
			    DEC(Count);
			    IF CheckInterrupt() OR NOT Found THEN
				MacroDepth:=1;
				Count:=0;
				END;
			    IF Count<1 THEN
				DEC(MacroDepth);
			    ELSE
				Pos:=1;
				END;
			    GetAChar(ch1);
			ELSE
				ch1:=Def^.CommChars[Pos];
				INC(Pos);
				END;
			END;
		END;
	END GetAChar;
PROCEDURE AddMacro(p:PKeyDef;repeat:INTEGER);
BEGIN
	IF (p<>NIL) AND (MacroDepth<=HIGH(MacroStack)) THEN

		(*make sure that macro is not recursive*)


		FOR i:=1 TO MacroDepth DO
			IF MacroStack[i].Def=p THEN
				ErrorMessage('Recursive macros!',' ');
				MacroDepth:=0;
				RETURN;
				END;
			END;
		INC(MacroDepth);
		WITH MacroStack[MacroDepth] DO
			Pos:=1;
			Def:=p;
			Count:=repeat;
			END;(*WITH*)
		END;(*p<>NIL etc*)
	END AddMacro;
VAR	SpecialSequence:BOOLEAN=FALSE;
PROCEDURE ReadAChar(VAR Result:CHAR);

(*	read next character, checking for arrows/function keys
	in and out point to the characters which have been read ahead
	By ReadAChar in an attempt to resolve a macro

	When ReadAChar is entered, if this buffer is not empty,
	the first character is to be looked up to see if it is a 
	start of a key definition*)
PROCEDURE IncPointer(VAR i:CARDINAL);
BEGIN
	IF i=HIGH(Buffer) THEN i:=0 END;
	INC(i);
	END IncPointer;
BEGIN
	look:=out;
	IF SpecialSequence THEN 

		(* @ is used for function/arrow keys as a macro
		   so that repeat counts can still be used*)

		Result:='@';
		SpecialSequence:=FALSE;
		RETURN
		END;
	KeyPos:=KeyChainBase;
	LOOP
		IF in<>look THEN
			Result:=Buffer[look];
			IncPointer(look);
		ELSE
			GetAChar(Result);
			Buffer[in]:=Result;
			IncPointer(in);
			look:=in;
			END;
		SearchToNext(Result);
		IF KeyPos=NIL THEN
			Result:=Buffer[out];
			IncPointer(out);
			RETURN
			END;
		WITH KeyPos^ DO
			IF Terminator THEN
				out:=look;
				in:=look;

				(* we could add the macro 
				directly at this point (the first
				version did so), but that would prevent the
				use of repeat counts with function/arrow
				keys. So instead ESC @ is returned, where
				ESC @ is always the macro we just found*)

				Commands['@']:=Def;
				SpecialSequence:=TRUE;
				Result:=ESC;
			
				RETURN;
			ELSE
				KeyPos:=NextChar;
				END;
			END;
		END;
	END ReadAChar;
					
PROCEDURE GetDefChar;
VAR	Text:ARRAY[1..1] OF CHAR;
BEGIN
	GetString(Text,LearnLen,'Char to define:');
	Learnch:=CAP(Text[1]);
	IF Learnch=ESC THEN
		GetString(KeySeq,LearnLen,'Key to define:');
		BuildKeySeq;
		END;
	END GetDefChar;
PROCEDURE DefMacroText;
VAR	p:PKeyDef;
BEGIN
	IF LearnLen>0 THEN
		ALLOCATE(p,TSIZE(CARDINAL)+LearnLen);
		IF Learnch=ESC THEN 
			LearnKey^.Def:=p;
			LearnKey^.Terminator:=TRUE
		ELSE 
			Commands[Learnch]:=p 
			END;
		WITH p^ DO
			Length:=LearnLen;
			FOR LearnLen:=LearnLen TO 1 BY -1 DO
				CommChars[LearnLen]:=Text[LearnLen];
				END;
			END;

		END;
	END DefMacroText;
PROCEDURE LearnMacro;

(*	Learn a macro definition	
	called at either end of definition*)

BEGIN
	IF NOT Learning THEN
		GetDefChar;
		Learning:=TRUE;
		LearnLen:=0;
	ELSE
		LearnLen:=LearnLen-2;
		DefMacroText;
		Learning:=FALSE;
		END;
	END LearnMacro;
PROCEDURE DefMacro;
BEGIN
	GetDefChar;
	IF (Learnch>='A') AND (Learnch<='Z') OR (Learnch=ESC) THEN
		GetString(Text,LearnLen,'Macro:');
		DefMacroText;
		END;
	END DefMacro;
PROCEDURE Macro(ch:CHAR;repeat:INTEGER);
VAR	i:CARDINAL;
BEGIN
	ch:=CAP(ch);
	IF ch<' ' THEN ch:=CHR(ORD(ch)+64) END;
	IF (ch>='@') AND (ch<='Z') THEN
		AddMacro(Commands[ch],repeat);
		END;
	END Macro;
VAR	F:FILE;
	reply:INTEGER;
PROCEDURE LoadMacros;
VAR	Block:ARRAY[0..BlockLen-1] OF CHAR;
BEGIN
	LOOP
		SeqReadBlock(F,ADR(Block),BlockLen,reply);
		IF reply<>BlockLen THEN EXIT END;
		reply:=0;
		WHILE Block[reply]<>0x DO
			LearnLen:=ORD(Block[reply]);
			Learnch:=Block[reply+1];
			IF Learnch=ESC THEN
				Moveup(ADR(Block[reply+2]),ADR(KeySeq),10);
				BuildKeySeq;
				reply:=reply+10;
				END;

			reply:=reply+2;
			FOR i:=1 TO LearnLen DO
				Text[i]:=Block[reply];
				INC(reply);
				END;
			DefMacroText;
			END;
		END;
	END LoadMacros;			
PROCEDURE StoreMacros;
VAR	Block:ARRAY[0..BlockLen-1] OF CHAR;

PROCEDURE StoreOneMacro(p:PKeyDef);
BEGIN
	IF p<>NIL THEN
		WITH p^ DO
			IF (reply+Length+14)>=BlockLen THEN
				Block[reply]:=0x;
				SeqWriteBlock(F,ADR(Block),BlockLen,reply);
				reply:=0;
				END;
			Block[reply]:=CHR(Length);
			Block[reply+1]:=Learnch;
			IF Learnch=ESC THEN
				Moveup(ADR(KeySeq),ADR(Block[reply+2]),10);
				reply:=reply+10;
				END;
			reply:=reply+2;
			FOR i:=1 TO Length DO
				Block[reply]:=CommChars[i];
				INC(reply);
				END;
			END;(*WITH p^*)
		END (*IF <>NIL*)
	END StoreOneMacro;
PROCEDURE OutKeySeq(CharNo:CARDINAL;p:PKeyChain);
BEGIN
	IF p<>NIL THEN
		WITH p^ DO
			KeySeq[CharNo]:=ch;
			IF Terminator THEN
				StoreOneMacro(Def);
			ELSE
				OutKeySeq(CharNo+1,NextChar);
				KeySeq[CharNo+1]:=' ';
				END;
			OutKeySeq(CharNo,NextAlt);
			END;
		END;
	END OutKeySeq;
BEGIN
	Learnch:='A';
	WHILE (Commands[Learnch]=NIL) AND (Learnch<='Z') DO 
		Learnch:=CHR(ORD(Learnch)+1);
		END;
	IF Learnch>'Z' THEN RETURN END;
	Create(F,'MACROS.DAT ',reply);
	IF reply<>0 THEN
		WriteString(' could not save macros file');
		WriteLn;
		RETURN
		END;
	IF reply<>0 THEN RETURN END;
	reply:=0;
	FOR Learnch:='A' TO 'Z' DO StoreOneMacro(Commands[Learnch]) END;

	(*Now output key sequences*)

	Learnch:=ESC;
	KeySeq:='          ';
	OutKeySeq(1,KeyChainBase);
	
	IF reply<>0 THEN
		Block[reply]:=0x;
		SeqWriteBlock(F,ADR(Block),BlockLen,reply);
		END;
	Close(F);
	END StoreMacros;
PROCEDURE OutCh(ch:CHAR);
BEGIN
	IF ch<' ' THEN
		Write('^');Write(CHR(ORD(ch)+64));
	ELSE
		Write(ch);
		END;
	END OutCh;
PROCEDURE PrintMacros;
BEGIN
	FOR ch:='A' TO 'Z' DO
		IF Commands[ch]<>NIL THEN 
		    WITH Commands[ch]^ DO
			OutCh(ch);
			FOR i:=1 TO Length DO 
				OutCh(CommChars[i]) 
				END;
			END;
		    WriteLn;
		    END;
		END;
	WriteString(' Enter any character to continue :');
	WaitForCh;
	END PrintMacros;
BEGIN
	FOR ch:='@' TO 'Z' DO Commands[ch]:=NIL END;
	ShowChange:=TRUE;
	Lookup(F,'MACROS.DAT ',reply);
	IF reply=0 THEN
		LoadMacros;
		END;
		
	END Macros.
);
			W