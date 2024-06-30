(*	Keyboard despatcher and some editing functions

	Copyright (C) Dave Moore FTL Modula-2 1986

	Modifications:
		20 July 86 Handling of backwards changed so that direction
			   of find remains same unless explicit count entered.
			   This allows use of just ^L for backwards searches

*)

IMPLEMENTATION MODULE Keyboard;

FROM	ScreenDummy IMPORT RingBell,Gotoxy,ClearScreen,OutputToScreen;
FROM	EditDisplay IMPORT ErrorMessage,Windows,DisplayError,ErrorOrdinal;
FROM	EditControl IMPORT InsOneChar,DelOneChar,DelToEOL,DelFullLine,
			   Left,Right,Down,Up,UpScreen,DownScreen,Top,Bottom,
			   CurrentWindow,FilesOpened,curx,cury,ChangeWindow,
			   ScrollUp,ScrollDown,ResetScreenPos,
			   Top,Bottom,FarLeft,FarRight,Files,Search,OverWrite, 
			   FindWord,ReDisplay,GoToLabel,Updated,CurrentFile,
			   Thisx,Thisy,WindowFile,MovedOK;
FROM	MakeEdit IMPORT PrepareString,FindString,LabelOp,BlockCopy,BlockDel,
			ErrorCount;
FROM	DoMenu  IMPORT     GetString,Redisplay;
FROM	Macros	IMPORT	DefMacro,ReadAChar,Macro,LearnMacro,PrintMacros,
			CheckInterrupt,Found;
(*	Act on commands entered from the keyboard 

	This module handles keyboard despatch during file editting*)

TYPE	TabArray=ARRAY [0x..7fx] OF PROC;
	Table=POINTER TO TabARRAY;
VAR	
	ch:CHAR;
	MainTable:TabArray;
	interpreting:BOOLEAN;
	ParValue:INTEGER=0;
	GroupOfCodes:ARRAY[1..30] OF CHAR;
	GroupLen,GroupPos:CARDINAL;
	i:CARDINAL;
	InsertMode:BOOLEAN=TRUE;
	NoBell:BOOLEAN=FALSE;
	Backwards:BOOLEAN=FALSE;
PROCEDURE Bell;

(*	ring the bell - primarilly used for un-assigned keys*)
BEGIN
	IF NOT NoBell THEN
		RingBell;
		END;
	ParValue:=0;
	END Bell;
PROCEDURE Quick;FORWARD;
PROCEDURE EscapeCount;

(*	escape character processing

	if followed by number, repeats next key given number of times
*)
VAR	i:INTEGER;
BEGIN
	ParValue:=0;
	LOOP
		IF (ch>='0') AND (ch<='9') THEN
			ParValue:=10*ParValue+(ORD(ch)-ORD('0'))
		ELSE 
			EXIT
			END;
		ReadAChar(ch);
		END;(*LOOP*)

	IF (ch=1bx) OR (ch=0ax) THEN (*escape something*)
		ReadAChar(ch);
		Macro(ch,ParValue);
		ParValue:=0;
	ELSIF ch=11x THEN Quick
	ELSE
		Found:=TRUE; (*Set false as sign of failure *)
		WHILE (ParValue>0) AND Found DO 
			IF CheckInterrupt() THEN ParValue:=0 
			ELSE
				DEC(ParValue);
				IF ch>CHR(127) THEN ch:=CHR(ORD(ch)-128) END;
				MainTable[ch];
				END;
			END;
		ParValue:=0;
		END;
	END EscapeCount;
PROCEDURE Escape;
VAR SaveBack:BOOLEAN;
BEGIN
	ReadAChar(ch);
	IF ch='-' THEN
		Backwards:=TRUE;
		ReadAChar(ch);
		EscapeCount;
		
	ELSIF (ch>='0') AND (ch<='9') THEN 
		Backwards:=FALSE;
		EscapeCount
	ELSIF ch=04x THEN DefMacro;Redisplay
	ELSIF ch=0cx THEN LearnMacro;Redisplay
	ELSIF ch=10x THEN ClearScreen;PrintMacros;Redisplay
	ELSE Macro(ch,1) END;
	END Escape;
PROCEDURE Endinterpret;

(*	End keyboard interpretation

	Note that this module can be assigned to a key so that you can
	exit from edit mode gracefully
*)
BEGIN
	interpreting:=FALSE;
	END Endinterpret;
PROCEDURE InsChar;
BEGIN
	IF InsertMode THEN 
		InsOneChar(ch);
	ELSE
		OverWrite(ch);
		END;
	END InsChar;
PROCEDURE BreakLine;
BEGIN
	InsOneChar(0dx);
	Left;
	END BreakLine;
VAR	Len:CARDINAL=0;
	ReplaceString:ARRAY[0..60] OF CHAR;
	RLen:INTEGER;
PROCEDURE DoFind;
BEGIN

	(* the passing of the backwards status is a real kludge
	   which was introduced as a quick fix while I was a long
	   way from home, to avoid having to update my work discs
	   at home with too much stuff *)

	IF Len>0 THEN 
		IF Backwards THEN Found:=Search(ReplaceString,RLen,Len+128)
		ELSE Found:=Search(ReplaceString,RLen,Len) END;
		END;
	END DoFind;
PROCEDURE Find;
VAR	SearchString:ARRAY[0..60] OF CHAR;
BEGIN
	GetString(SearchString,Len,'Find:');
	IF Len>0 THEN
		PrepareString(SearchString,Len);
		RLen:=-1;
		DoFind;
	ELSE
		ReDisplay;
		END;
	END Find;
PROCEDURE Replace;
VAR	SearchString:ARRAY[0..60] OF CHAR;
	L:CARDINAL;
	
BEGIN
	GetString(SearchString,Len,'Alter:');
	IF Len>0 THEN
		PrepareString(SearchString,Len);
		GetString(ReplaceString,L,'To   :');
		RLen:=L;
		DoFind;
	ELSE
		ReDisplay;
		END;
	END Replace;
PROCEDURE SetUpdated;
BEGIN
	Updated[CurrentFile]:=TRUE
	END SetUpdated;
PROCEDURE DelABlock(i:CARDINAL):BOOLEAN;
VAR 	b:BOOLEAN;
	j:CARDINAL;
BEGIN
	b:=BlockDel(Files[i]);
	j:=CurrentFile;
	ChangeWindow(i);
	Redisplay;
	ChangeWindow(j);
	RETURN b
	END DelABlock;
PROCEDURE DefLabel;
VAR	i:CARDINAL;
	b,r:BOOLEAN;
BEGIN
	ReadAChar(ch);
	i:=CurrentWindow;

	(*	If control B's intervene, change source window*)
	WHILE ch=02x (*CTRL B*) DO
		IF i>=Windows THEN i:=1 ELSE INC(i) END;
		Gotoxy(curx[i],cury[i]);
		ReadAChar(ch);
		END;
	ch:=CAP(ch);
	r:=FALSE;
	i:=WindowFile[i];
	CASE ch OF
		'C',03x:b:=BlockCopy(Files[i],Files[CurrentFile]);
			|
		'Y',19x:b:=DelABlock(i);
			|
		'V',16x:b:=BlockCopy(Files[i],Files[CurrentFile]);
			IF b  THEN b:=DelABlock(i) END;
			|
		ELSE 
			b:= LabelOp(Files[CurrentFile],TRUE,ch);
			r:=TRUE;
		END;
	IF b THEN
		IF NOT r THEN ReDisplay;SetUpdated END;
	ELSE
		IF r THEN ErrorMessage('Bad label',' ');
		ELSE ErrorMessage('Block Undefined',' ') END;
		Gotoxy(Thisx,Thisy);
		END;
	END DefLabel;
PROCEDURE MoveToError;
PROCEDURE GotoError(i:CARDINAL);
BEGIN
	IF i<ErrorCount THEN ErrorOrdinal:=i;DisplayError
	ELSE
		ErrorMessage(' No such error ',' ');
		END;
	END GotoError;

BEGIN
	ReadAChar(ch);
	ch:=CAP(ch);
	CASE ch OF
		'N',0ex:GotoError(ErrorOrdinal+1)|
		'P',10x:GotoError(ErrorOrdinal-1)|
		'C',03x:GotoError(ErrorOrdinal)|
		'0'..'9':GotoError(ORD(ch)-ORD('0'))
		END;
	END MoveToError;
PROCEDURE Quick;
VAR	First:BOOLEAN;
BEGIN
	First:=TRUE;
	ReadAChar(ch);
	ch:=CAP(ch);
	IF ParValue=0 THEN ParValue:=1 END;
	WHILE ParValue>0 DO
	  CASE ch OF
	    'E',05x:MoveToError|
	    'Y',19x:DelToEOL|
	    'D',04x:FarRight|
	    'S',13x:FarLeft|
	    'R',12x:Top|
	    'C',03x:Bottom|
	    'F',06x:IF First THEN Find ELSE DoFind END| 
	    'A',01x:IF First THEN Replace ELSE DoFind END|
	    'G',07x:NoBell:=NOT NoBell|
	    'K','B','0'..'9':GoToLabel(ch);
	 	END;
	  First:=FALSE;
	  DEC(ParValue);
	  END;
	END Quick;
PROCEDURE Window;
VAR	i:CARDINAL;
BEGIN
	i:=CurrentWindow+1;
	IF i>Windows THEN i:=1 END;
	ChangeWindow(i);
	ReDisplay;
	END Window;
PROCEDURE DelBack;
BEGIN
	Left;
	IF MovedOK THEN DelOneChar END;
	END DelBack;
PROCEDURE Interpret;

(*	Start keyboard interpretation*)
BEGIN
	ResetScreenPos;
	interpreting:=TRUE;
	ParValue:=0;
	WHILE interpreting DO
		ReadAChar(ch);
		IF ch>CHR(127) THEN ch:=CHR(ORD(ch)-128) END;
		MainTable[ch];
		END;
	END Interpret;

PROCEDURE FlipInsert;
BEGIN
	InsertMode:=NOT InsertMode;
	END FlipInsert;

PROCEDURE DelWord;
BEGIN
	FindWord(FALSE,TRUE);
	END DelWord;

PROCEDURE ForwardWord;
BEGIN
	FindWord(FALSE,FALSE);
	END ForwardWord;
PROCEDURE BackwardWord;
BEGIN
	FindWord(TRUE,FALSE);
	END BackwardWord;

(*	Initialise a keyboard dispatch tables*)

BEGIN
	FOR ch:=0x TO 7fx DO MainTable[ch]:=Bell END;
	
	MainTable[1bx]:=Escape;

	(*	printable characters are inserted as is *)

	FOR ch:=' ' TO '~' DO MainTable[ch]:=InsChar END;
	MainTable[0dx]:=InsChar;
	MainTable[09x]:=InsChar;

	(*	cursor control keys*)

	MainTable[13x]:=Left;
	MainTable[18x]:=Down;
	MainTable[04x]:=Right;
	MainTable[05x]:=Up;

	(*	Other control keys*)

	MainTable[07x]:=DelOneChar;	(*Ctrl G*)
	MainTable[19x]:=DelFullLine;	(*Ctrl Y*)
	MainTable[16x]:=FlipInsert;	(*Ctrl V*)
	MainTable[0ex]:=BreakLine;	(*Ctrl N*)
	MainTable[08x]:=Left;		(*Ctrl H (Backspace)*)
	MainTable[1ax]:=ScrollDown;	(*Ctrl Z*)
	MainTable[03x]:=DownScreen;	(*Ctrl C*)
	MainTable[12x]:=UpScreen;	(*Ctrl R*)
	MainTable[14x]:=DelWord;	(*Ctrl T*)
	MainTable[06x]:=ForwardWord;	(*Ctrl F*)
	MainTable[0ax]:=Escape;		(*treat line feed as if escape*)
	MainTable[01x]:=BackwardWord;	(*Ctrl A*)
	MainTable[11x]:=Quick;		(*Ctrl Q*)
	MainTable[02x]:=Window;		(*Ctrl B*)
	MainTable[17x]:=ScrollUp;	(*Ctrl W*)
	MainTable[0bx]:=DefLabel;	(*Ctrl K*)
	MainTable[7fx]:=DelBack;	(*Del *)
	MainTable[0cx]:=DoFind;		(*Ctrl L*)
	MainTable[1fx]:=DelBack;	(*^- on Osborne 1*)

	(*	The next key,  assigned to Endinterpret is called,
		'Menu' in the documentation. That is, to process a menu,
		we drop out of edit mode. The calling routine (Me) the calls
		the menu routine - not this module*)

	MainTable[0fx]:=Endinterpret;	(*Ctrl O*)
	END Keyboard.
DOC           [¶JXSc  