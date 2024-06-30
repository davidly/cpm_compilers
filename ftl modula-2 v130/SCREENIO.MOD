IMPLEMENTATION MODULE ScreenIO;
FROM Terminal IMPORT CharRoutine,CharEnabled;
FROM Files IMPORT Lookup,FILE,ReadBlock;
FROM FastMove IMPORT Moveup;
FROM SYSTEM IMPORT ADR,SIZE,WORD;
FROM	CPM IMPORT wccfc,BDOS;
(*	Screen handling routines for cursor position, attribute etc

	This module is specific to this compiler*)
TYPE
	ControlSequence=RECORD
		Chars:ARRAY[1..7] OF CHAR;
		SeqLen:BYTE;
		END;


	ControlCodes=RECORD
		EditSequences:ARRAY Edits OF ControlSequence;
		Ascii:BOOLEAN; (*true if co-ordinates out output as 
				 ascii numbers rather than binary*)
		ColumnFirst:BOOLEAN;
		AddressInGraph:BOOLEAN; (*true if can change coordinates
					  in graph mode*)
		CarriageReturn:BOOLEAN; (*true if carriage return returns 
					  to start of current row*)
		ScreenDepth:CARDINAL;
		ScreenWidth:CARDINAL;
		XYOffset:CARDINAL;
		END; 
		

VAR	Control:ControlCodes;
	Active:BOOLEAN;
	InGraph:BOOLEAN;
	Lowx,Highx,Lowy,Highy:CARDINAL;
	OutputEnabled:BOOLEAN;
(*PROCEDURE Write(i:CHAR);
BEGIN
	IF (i>=' ') AND (i<='z') THEN Terminal.Write(i)
	ELSE 
		Terminal.Write('<');
		WriteHex(ORD(i),3);
		Terminal.Write('>');
		END;
	END Write;*)
PROCEDURE Write(b:CHAR);
VAR	i:INTEGER;	(*needed to avoid conflict with global*)
BEGIN
	IF OutputEnabled THEN
		i:=BDOS(wccfc,WORD(b))
		END;
	END Write;
PROCEDURE WriteAscii(i:INTEGER);
VAR	Text:ARRAY[1..3] OF CHAR;
	j,k:INTEGER;
BEGIN
	j:=3;
	WHILE (j>0) AND (i<>0) DO
		k:=i DIV 10;
		Text[j]:=CHR(i-10*k+ORD('0'));
		i:=k;
		j:=j-1;
		END;
	FOR k:=j+1 TO 3 DO Write(Text[k]) END;
	END WriteAscii; 
PROCEDURE Gotoxy(x,y:CARDINAL);		

(*		Position to given coordinates
		top left is always 0,0 

		x is column, y is row

		A 'Standard' Screen is 80 by 24. The limit is set by
		the terminal definition file	*)
VAR	i,j:INTEGER;
	ing:BOOLEAN;
BEGIN
    IF Active AND OutputEnabled THEN
	WITH Control DO
		ing:=InGraph;
		IF InGraph THEN ScreenControl(EndGraph) END;
		ScreenControl(Startxy);
		IF ColumnFirst THEN
			i:=x+XYOffset;
			j:=y+XYOffset;
		ELSE
			i:=y+XYOffset;
			j:=x+XYOffset;
			END;
		IF Ascii THEN WriteAscii(i)
		ELSE Write(CHR(i)) END;
		ScreenControl(MiddleXY);
		IF Ascii THEN WriteAscii(j)
		ELSE Write(CHR(j)) END;
		ScreenControl(EndXY);
		END; (*WITH*)
	IF ing THEN ScreenControl(StartGraph) END;
	END(*IF*)
    END Gotoxy;

PROCEDURE LoadTermCode(filename:FileName);
VAR	fn:FILE;
	reply:INTEGER;

(*		define a temporary area for reading of file
		it must be equal in size to the size of control, padded
		out to a multiple of 128 bytes*)

	block:ARRAY[0..128*(SIZE(Control) DIV 128)+127] OF CHAR;

(*		Load the terminal definition for the current terminal

		filename is the name of the file to read

		Normally, when the program is loaded, the file
		'TERMINAL.COD' is loaded from the logged in disc
		This routine only needs to be used if that
		file is not the one to use (eg, to swap screens*) 

BEGIN
	Lookup(fn,filename,reply);
	IF reply<0 THEN Active:=FALSE
	ELSE
		ReadBlock(fn,ADR(block),0,SIZE(block),reply);
		Active:=reply>=SIZE(Control);
		Moveup(ADR(block),ADR(Control),SIZE(Control));
		END;
	ScreenWidth:=Control.ScreenWidth;
	ScreenDepth:=Control.ScreenDepth;
	END LoadTermCode;

PROCEDURE ScreenControl(s:Edits);

(*		Perform a screen control operation*)
VAR	i:CARDINAL;
BEGIN
	IF Active AND OutputEnabled THEN
		WITH Control.EditSequences[s] DO
			MadeChange:=SeqLen>0;
			FOR i:=1 TO ORD(SeqLen) DO Write(Chars[i]) END;
			END;
		IF NOT Control.AddressInGraph THEN
			IF s=StartGraph THEN InGraph:=TRUE
			ELSIF s=EndGraph THEN InGraph:=FALSE END;
			END;
	ELSE  MadeChange:=FALSE;
		END;
	END ScreenControl;
PROCEDURE InBound(x,y:CARDINAL;ch:Edits);
BEGIN
	IF 	(x>=Lowx) AND (x<=Highx)
	  AND	(y>=Lowy) AND (y<=Highy) THEN 
		ScreenControl(ch);
		END
	END InBound;
PROCEDURE  DrawBox(x1,y1,x2,y2:CARDINAL);

(*		draw a box for a window on the screen

		x1,y1  is the lower left corner
		x2,y2  is upper right corner*)
VAR	i:CARDINAL;
BEGIN
    IF Active AND OutputEnabled THEN
	WITH Control DO
		Gotoxy(x1,y1);
		ScreenControl(StartGraph);
		InBound(x1,y1,CornerLL);
		FOR i:=x1+1 TO x2-1 DO InBound(i,y1,Horizontal) END;
		InBound(x2,y1,CornerLR);
		Gotoxy(x1,y2);
		InBound(x1,y2,CornerUL);
		FOR i:=x1+1 TO x2-1 DO InBound(i,y2,Horizontal) END;
		InBound(x2,y2,CornerUR);
		FOR i:=y2+1 TO y1-1  DO
			Gotoxy(x2,i);
			InBound(x2,i,Vertical);
			END;
		FOR i:=y2+1 TO y1-1 DO
			Gotoxy(x1,i);
			InBound(x1,i,Vertical);
			END;
		END;(*WITH Control*)
		ScreenControl(EndGraph);
	END; (*IF Active*)
    END DrawBox;
PROCEDURE Clip(x1,y1,x2,y2:CARDINAL);
BEGIN
	Lowx:=x1;
	Highx:=x2;
	Lowy:=y2;
	Highy:=y1;
	END Clip;
PROCEDURE ScrollWindowUp(StartofWindow,EndofWindow:CARDINAL);
BEGIN
	Gotoxy(0,EndofWindow);
	ScreenControl(DelLine);
	Gotoxy(0,StartofWindow);
	ScreenControl(InsLine);
	END ScrollWindowUp;
PROCEDURE ScrollWindowDown(StartofWindow,EndofWindow:CARDINAL);
BEGIN
	Gotoxy(0,StartofWindow);
	ScreenControl(DelLine);
	Gotoxy(0,EndofWindow);   
	ScreenControl(InsLine);
	ScreenControl(DelEol);   
	END ScrollWindowDown;

(*	Cursor blink routine - only supported in memory mapped
	version of screenio*)
PROCEDURE OutputToScreen(On:BOOLEAN);
BEGIN
	OutputEnabled:=On
	END OutputToScreen;	

BEGIN	(*Initialisation part*)
	CharRoutine:=Write;
	CharEnabled:=TRUE;	

	InGraph:=FALSE;
	OutputEnabled:=TRUE;
	LoadTermCode('CONTROL.DAT');
	Lowx:=0;Lowy:=0;
	Highx:=999;Highy:=999;
	ScreenWidth:=Control.ScreenWidth;
	ScreenDepth:=Control.ScreenDepth;
	ScreenControl(ClearScreen);
	END ScreenIO.
