(*	Perform menu operations

	Copyright,  Dave Moore FTL Modula-2 1986

		26 June 86  D Moore  Put BackSpace inside IF to improve
					backspacing performance of GetString

*)
IMPLEMENTATION MODULE DoMenu;

(*	menu processor for editor

	contains all commands which are performed from a menu*)
FROM	Terminal IMPORT Write,WriteString,ReadString,ReadBuffer,WriteLn,Read,
	BusyRead,ClearCharBuffer;
FROM 	MakeEdits IMPORT OpenFile,CloseFile,AbandonFile,CallWithFile,FileType,LabelOp;
FROM	Menu IMPORT GetFromMenu,MenuText;
FROM 	EditControl IMPORT CurrentWindow,CurrentFile,FilesOpened,curx,cury,Files,
			ElideWindow,ChangeWindow,ResetScreenPos,Updated,LeftMargin,
			MakeWindow,WindowFile,FilePosition;
FROM	EditDisplay IMPORT ErrorMessage,SetWindows,DisplayFile,SetLeftMarg,Windows;
FROM	Macros IMPORT StoreMacros;
FROM	ScreenDummy IMPORT ClearScreen,DrawBox,Gotoxy;
FROM	ResetDisc IMPORT ResetAllDiscs;
VAR	Text:ARRAY [0..9] OF MenuText=[ 
			'Open  File ',
			'Save  File ',
			'Close File ',
			'Split File ',
			'Compile    ',
			'Comp/Exit  ',
			'Quit File  ',
			'Quit Window',
			'Exit Edit  ',
			'Reset Disc '];
	c:CARDINAL;
	reply:INTEGER;
	i:CARDINAL;
	ch:CHAR;
PROCEDURE Redisplay;
BEGIN
	SetWindows(Windows);
	FOR i:=1 TO Windows DO
		DisplayFile(Files[WindowFile[i]],i,curx[i],cury[i]);
		END;
	ResetScreenPos;
	END Redisplay;
PROCEDURE ClearDisplay;
BEGIN
	Gotoxy(0,0);
	ClearScreen;
	END ClearDisplay;
PROCEDURE Really():BOOLEAN;
BEGIN
	WriteString(' (Y/N)? ');
	REPEAT
		BusyRead(ch);
		ch:=CAP(ch);
		UNTIL (ch='Y') OR (ch='N');
	Write(ch);
	RETURN ch='Y'
	END Really;
PROCEDURE Open(fn:FileName;Pos:CARDINAL);
(*	Open the file whose name is in fn

	re-adjust the display as required*)
VAR	f:FILE;
	b:BOOLEAN;
BEGIN
    IF fn[1]<>' ' THEN 
	OpenFile(Files[FilesOpened+1],fn,reply,Pos);
	IF reply=(-2) THEN
		ClearDisplay;
		WriteString(' Create ');
		WriteString(fn);
		
		IF Really() THEN
			Create(f,fn,reply);
			IF reply<>0 THEN
				reply:=-4
			ELSE
				Close(f);
				OpenFile(Files[FilesOpened+1],fn,reply,Pos);
				END;
			END;
		END; (*reply=-2*)
	IF reply=(-4) THEN
		ErrorMessage('Could not create ',fn);
	ELSIF reply=(-3) THEN
		ErrorMessage('Out of Memory loading ',fn );
	ELSIF reply=(-2) THEN
		ErrorMessage('File not found:',fn);
	ELSIF reply<0 THEN
		ErrorMessage(' Other error opening file:',fn)
	ELSE 	(*file ok*)
		INC(FilesOpened);
		INC(Windows);
		WindowFile[Windows]:=FilesOpened;
		SetWindows(Windows);
		b:=LabelOp(Files[FilesOpened],TRUE,CHR(Windows));
		SetLeftMarg(Files[FilesOpened],Windows,
			curx[Windows],cury[Windows]);
		Updated[FilesOpened]:=FALSE;
		ChangeWindow(Windows);
		END;(*reply=various values*)
	END;(*fn[1]<>' '*)
    Redisplay;
    END Open;
			
PROCEDURE SetBoxPos(VAR y:CARDINAL);
BEGIN
	IF Windows=2 THEN y:=13*(CurrentWindow-1)
	ELSIF CurrentWindow=0 THEN y:=0
	ELSE	y:=8*(CurrentWindow-1) END;
	END SetBoxPos;
VAR	x,y,chars:CARDINAL;
PROCEDURE BackSpace;
BEGIN
	Write(08x);
	Write(' ');
	Write(08x);
	DEC(chars);
	END BackSpace;
PROCEDURE GetString(VAR s:ARRAY OF CHAR;VAR len:CARDINAL;prompt:ARRAY OF CHAR);
BEGIN
	SetBoxPos(y);
	DrawBox(11,y+3,14+HIGH(s)+HIGH(prompt),y+1);
	Gotoxy(12,y+2);
	FOR x:=0 TO HIGH(prompt) DO Write(prompt[x]) END;
	FOR x:=0 TO HIGH(s) DO Write(' ') END;
	Gotoxy(12+HIGH(prompt)+1,y+2);
	len:=0;ch:=0x;
	chars:=0;
	LOOP
		IF len>HIGH(s) THEN EXIT END;
		REPEAT
			BusyRead(ch);
			UNTIL ch<>0x;
		IF ch=0dx THEN EXIT END;
		IF (ch=08x) OR (ch=13x) OR (ch=7fx) THEN
			IF len>0 THEN 
				DEC(len);
				IF s[len]<' ' THEN BackSpace END;
				BackSpace;
				END;
		ELSIF ch=18x THEN
			FOR len:=1 TO chars DO BackSpace END;
			len:=0;
			chars:=0;
		ELSE
			IF ch<' ' THEN 
				Write('^');
				Write(CHR(ORD(ch)+64));
				INC(chars);
			ELSE Write(ch) END;
			INC(chars);
			s[len]:=ch;
			INC(len);
			END;
		END;(*WHILE*)
	FOR x:=len TO HIGH(s) DO s[x]:=' ' END;
	END GetString;

PROCEDURE DoMenuOp;
VAR	y:CARDINAL;
	fn:FileName;
PROCEDURE WriteAwayFile;
BEGIN
	CloseFile(Files[CurrentFile],reply);
	IF reply=-1 THEN 
		ErrorMessage('Disc Full ',' ');
	ELSIF reply=-2 THEN
		ErrorMessage('Directory Full ',' ');
		END;
	Updated[CurrentFile]:=FALSE;
	END WriteAwayFile;
PROCEDURE SaveFiles;
VAR	i:INTEGER;
BEGIN
	i:=CurrentFile;
	reply:=0;
	FOR CurrentFile:=1 TO FilesOpened DO
		IF Updated[CurrentFile] THEN WriteAwayFile END;
		IF reply<>0 THEN RETURN END;
		END;
	CurrentFile:=i;
	END SaveFiles;
PROCEDURE PrepareToLeave;
BEGIN
	SaveFiles;
	IF reply=0 THEN
		ClearDisplay;
		StoreMacros;
		END;
	END PrepareToLeave;		

PROCEDURE CallCompilers(opt1,opt2:ARRAY OF CHAR);
BEGIN
	PrepareToLeave;
	IF reply=0 THEN
	    CASE FileType(Files[CurrentFile]) OF
		1:CallWithFile(opt1,Files[CurrentFile])|
		2:CallWithFile(opt2,Files[CurrentFile]);
		END;
		Redisplay;
		ErrorMessage(' Invalid File Type',' ');
	    END;(*IF*)
	END CallCompilers;	
PROCEDURE CountRefs():CARDINAL;	
VAR	j:CARDINAL;
BEGIN
	j:=0;
	FOR i:=1 TO Windows DO
		IF WindowFile[i]=CurrentFile THEN INC(j) END;
		END;
	RETURN j
	END CountRefs;
PROCEDURE RemoveFile;
VAR	j,k:CARDINAL;ch:CHAR;
BEGIN
	j:=CurrentFile;
	k:=1;
	WHILE k<=Windows DO
		IF WindowFile[k]=j THEN
		 	ElideWindow(k)  (*which decrements windows*)
		ELSE IF WindowFile[k]>j THEN
			DEC(WindowFile[k]);
			END;
		     INC(k);
		     END;
		END;
	AbandonFile(Files[j]);
	FOR i:=j+1 TO FilesOpened DO 
		Files[i-1]:=Files[i];
		Updated[i-1]:=Updated[i];
		END;
	DEC(FilesOpened);
	ChangeWindow(1);
  	Redisplay;
	END RemoveFile;
PROCEDURE CheckRemoveFile;
BEGIN
	IF Updated[CurrentFile] THEN
		ClearDisplay;
		WriteString(' File updated - Are you sure ');
		IF NOT Really() THEN 
			Redisplay;
			RETURN 
			END;
		END;
	RemoveFile;
	END CheckRemoveFile;
BEGIN
	SetBoxPos(y);
	c:=GetFromMenu(Text,10,y,5,2);
	ClearCharBuffer;
	IF (FilesOpened=0) AND (c IN {2..8}) THEN
		ErrorMessage('You have to be editing a file to do this',' ');
	ELSE CASE c OF
	1:IF Windows=3 THEN ErrorMessage(' 3 windows is max allowed',' ')
	  ELSE
		GetString(fn,y,'File:');
		Open(fn,65535);
		END
	  |
	2:WriteAwayFile;
	  |
	3:WriteAwayFile;
	  IF reply=0 THEN 
		RemoveFile;
		END;
	  |
	4:IF Windows=3 THEN ErrorMessage(' 3 windows is max allowed',' ')
	  ELSE
		MakeWindow;
		SetWindows(Windows);
		ChangeWindow(CurrentWindow);
		Redisplay;
		END|
		
	5:CallCompilers('M2[E ','MD[E ')|
	6:CallCompilers('M2 ','MD ')|
	7:IF FilesOpened>0 THEN
		CheckRemoveFile;
		END;(*FilesOpened*)
	  |
	8:IF FilesOpened>0 THEN
		IF CountRefs()>1 THEN 
			  ElideWindow(CurrentWindow)
			  ChangeWindow(1);
			  Redisplay;
	  	ELSE CheckRemoveFile END;
		END;
	  |
	9:PrepareToLeave;
	  IF reply=0 THEN HALT 	END|
	10: ResetAllDiscs;
	   ErrorMessage(' All discs now read/write',' ');
	   END;
	END; (*IF FilesOpened etc *)
	END DoMenuOp;
	END DoMenu.
List THEN
			WriteChar(List,Device);
			WriteChar(List,ch);
			END;
		WriteString(Name);
		W