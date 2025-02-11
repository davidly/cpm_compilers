IMPLEMENTATION MODULE Terminal;

(*	Low level terminal support

	Dave Moore 24 dec 84
*)
FROM CPM IMPORT BDOS,rccfc,wccfc,rcbfc,rcsfc,diofc;
FROM SYSTEM IMPORT ADR,WORD;
VAR	ConsoleBuffer	:ARRAY[0..128] OF BYTE;
	Position	:BYTE=129;
	i:INTEGER;
	j:CARDINAL;
	ch:CHAR;
PROCEDURE Write(b:CHAR);
VAR	i:INTEGER;	(*needed to avoid conflict with global*)
BEGIN
	IF CharEnabled THEN CharRoutine(b) 
	ELSE
		i:=BDOS(wccfc,WORD(b))
		END;
	END Write;
PROCEDURE ReadBuffer(force:BOOLEAN);
BEGIN
    IF force OR ((Position-1)>ConsoleBuffer[1]) THEN
	ConsoleBuffer[0]:=HIGH(ConsoleBuffer)-1;
	i:=BDOS(rcbfc,ADR(ConsoleBuffer));
	Position:=1;
	END;
    END ReadBuffer;
PROCEDURE Read(VAR b:CHAR);
BEGIN
	IF Position<=ConsoleBuffer[1] THEN 
		b:=ConsoleBuffer[Position+1];
		Position:=Position+1;
	ELSIF (Position-1)=ConsoleBuffer[1] THEN
		b:=0Dx;	(*carriage return*)
		Position:=Position+1;
		i:=BDOS(wccfc,0ah);
	ELSE	
		i:=BDOS(rccfc,0);
		b:=CHR(i);
		IF b=0dx THEN i:=BDOS(wccfc,0ah) END;
		END;
	END Read;
PROCEDURE BusyRead(VAR b:CHAR);
BEGIN
	(*there is a problem wiuth CP/M when these calls are
	  intermixed with calls to Read. This results in some 
	  characters being received twice*)
	i:=BDOS(diofc,255);
	b:=CHR(i);
	IF BlinkEnabled THEN BlinkRoutine END;	
	END BusyRead;
PROCEDURE ClearCharBuffer;

	(*overcome bug mentioned above*)
BEGIN
	i:=BDOS(rcsfc,0);
	IF i<>0 THEN i:=BDOS(rccfc,0) END;
	END ClearCharBuffer;
PROCEDURE ReadAgain;
BEGIN
	IF Position>1 THEN Position:=Position-1 END;
	END ReadAgain;
PROCEDURE WriteLn;
BEGIN
	Write(0dx);
	Write(0ax);
	END WriteLn;
PROCEDURE OutString(VAR s:ARRAY OF CHAR);
BEGIN
	i:=0;
	LOOP
		IF i>HIGH(s) THEN EXIT END;
		IF s[i]=0c THEN EXIT END;
		Write(s[i]);
		i:=i+1;
		END; (*LOOP*)
	END OutString;
PROCEDURE WriteString(s:ARRAY OF CHAR);
BEGIN
	OutString(s);
	END WriteString;
PROCEDURE ErrorExit(s:ARRAY OF CHAR);
BEGIN
	OutString(s);
	i:=BDOS(0,0);
	END ErrorExit;	
PROCEDURE ReadString(VAR s:ARRAY OF CHAR);

BEGIN
	ReadBuffer(FALSE);
	StringLen:=0;
	LOOP
		IF StringLen>HIGH(s) THEN EXIT END;
		Read(ch);
		IF ch<' ' THEN 
			EXIT 
			END;
		s[StringLen]:=ch;
		StringLen:=StringLen+1;
		END (*LOOP*);
	IF StringLen<=HIGH(s) THEN s[StringLen]:=0x END;
	END ReadString;
BEGIN
	ConsoleBuffer[1]:=0;
	END Terminal.

���������������������������� 