(*	menu handler

	Copyright Dave Moore FTL Modula-2 1986

	Modifications:	Changed to allow position to option using first
			letter of option. If more than one option starts
			with a given letter, always moves to next *)


IMPLEMENTATION MODULE Menu;

(*	Menu driver

	Bring up a menu at selected point on screen and accept an option

	options can be selected either by striking first character of

	option or by entering option no (limited to 0-9)

	option 0 is always exit without selection as is escape*)

FROM	ScreenIO	IMPORT	Gotoxy,DrawBox,Dim,StartGraph,
				EndGraph,Vertical,Inverse,Normal,
				ScreenControl,RingBell;
FROM	Terminal	IMPORT 	WriteString,Read,Write,BusyRead;
CONST	width=11;	(*width of one option*)
	ESC=1bx;
	CR=0dx;
	CtrlX=18x;
	CtrlE=05x;
	CtrlD=04x;
	CtrlS=13x;
	LF=0ax;
	BS=08x;
PROCEDURE GetFromMenu(VAR Text:ARRAY OF MenuText;x,y:CARDINAL;
		depth,columns:CARDINAL):CARDINAL;

(* 	Text is the text to display


	x and y are the position for the top left corner of the box
	depth is the number of options in a column
	columns is the number of columns that will be required	*)

VAR	x1,y1:CARDINAL;
	i,j:CARDINAL;
	OptionNo:CARDINAL;
	ch:CHAR;
PROCEDURE ChangeOption(by:INTEGER);

(*	change the current option number y given increment

	ensure it remains in range*)
BEGIN
	by:=by+INTEGER(OptionNo);
	IF by<0 THEN by:=HIGH(Text) 
	ELSIF by>HIGH(Text) THEN by:=0 END;
	OptionNo:=by
	END ChangeOption;
PROCEDURE ChangePos;

(*	Change position using first character of menu as option
	Always move - so that if more than one command starts with
	the same character you can get to other than the first *)
VAR	i:INTEGER;
BEGIN
	i:=HIGH(Text);
	REPEAT
		ChangeOption(1);
		DEC(i);
		UNTIL (i<0) OR (CAP(Text[OptionNo][1])=CAP(ch));
	END ChangePos;
BEGIN
	(*	draw the box*)

	x1:=x+(width+1)*columns;
	y1:=y+depth+1;
	DrawBox(x,y1,x1,y);
	ScreenControl(Dim);
	ScreenControl(StartGraph);
	FOR i:=1 TO columns-1 DO
		x1:=x+i*(width+1);
		FOR j:=y+1 TO y1-1 DO
			Gotoxy(x1,j);
			ScreenControl(Vertical);
			END;
		END;
	ScreenControl(EndGraph);
	ScreenControl(Normal);

	(*we now have a box around the menu with dim bars between columns*)

	OptionNo:=0;	(*actually one less than value returned*)
	j:=0;		(*row number*)
	x1:=x+1;	(*position for text*)
	y1:=y+1;	
	FOR i:=0 TO HIGH(Text) DO	
		Gotoxy(x1,y1);
		WriteString(Text[i]);
		INC(j);
		IF j=depth THEN (*next column*)
			x1:=x1+width+1;
			y1:=y+1;
			j:=0
		ELSE
			INC(y1);
			END;
		END; (*FOR*)

	(*finish off current column*)

	IF y1<>(y+1) THEN
		WHILE j<depth DO
			Gotoxy(x1,y1);
			WriteString('           ');
			INC(j);
			INC(y1);
			END;
		END;
	
	(*accept an option*)

	LOOP

		(*inverse currently selected option*)

		x1:=x+1;
		y1:=y+1+OptionNo;
		WHILE y1>=(y+depth+1) DO
			y1:=y1-depth;
			x1:=x1+width+1
			END;
		Gotoxy(x1,y1);
		ScreenControl(Inverse);
		WriteString(Text[OptionNo]);
		ScreenControl(Normal);
		Gotoxy(x1,y1);
		REPEAT
			BusyRead(ch);
			UNTIL ch<>0x;
		Gotoxy(x1,y1);
		ScreenControl(Normal);
		WriteString(Text[OptionNo]);
		CASE CAP(ch) OF
		ESC,' ': RETURN 0|
		CR:  RETURN OptionNo+1|
		CtrlS,BS:ChangeOption(-depth)|
		CtrlE:ChangeOption(-1)|
		CtrlD:ChangeOption(depth)|
		CtrlX,LF:ChangeOption(1)|
		'A'..'Z':ChangePos|
		ELSE ScreenControl(RingBell)
		END;(*case*)
		END;(*LOOP*)
	END GetFromMenu;
	END Menu.

			END;
		Loc:=Loc+128;
		END;
	END CompBin.
