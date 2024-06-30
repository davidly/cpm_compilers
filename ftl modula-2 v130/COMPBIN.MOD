MODULE CompBin;

(*	Compare two binary files *)

FROM	Terminal IMPORT WriteString,WriteLn;
FROM	SmallIO  IMPORT WriteHex;
FROM	Streams IMPORT Direction;
FROM	QuickStr IMPORT StreamRecord,OpenStreams,OptionsSet;
FROM	SYSTEM   IMPORT ADR,BYTE;
FROM	Files IMPORT FILE,SeqReadBlock;
VAR	In1,In2:FILE;
	Block1,Block2:ARRAY [0..127] OF BYTE;
	reply1,reply2:INTEGER;
	Loc:CARDINAL;
	i,j:CARDINAL;
PROCEDURE VeryQuick():BOOLEAN;

(*	Open a stream for input and a stream for output *)
VAR	S:ARRAY[1..2] OF StreamRecord;
	o:OptionsSet;
BEGIN
	WITH S[1] DO
		IsStream:=FALSE;
		Dir:=input;
		LookupFirst:=FALSE;
		MustSupply:=FALSE;
		File:=ADR(In1);
		END;
	WITH S[2] DO
		IsStream:=FALSE;
		DefaultName:='CON:';
		Dir:=input;
		LookupFirst:=FALSE;
		MustSupply:=TRUE;
		File:=ADR(In2);
		END;
	RETURN OpenStreams(S,o);
	END VeryQuick;
BEGIN
	IF  VeryQuick() THEN
		WriteString('Files not found ');
		WriteLn;
		HALT;
		END;
	Loc:=0;
	LOOP
		SeqReadBlock(In1,ADR(Block1),128,reply1);
		SeqReadBlock(In2,ADR(Block2),128,reply2);
		WriteHex(Loc,4);
		WriteString(0dx);
		IF (reply1<>128) OR (reply2<>128) THEN EXIT END;
		i:=0;
		WHILE (i<128) AND (Block1[i]=Block2[i]) DO INC(i) END;
		IF i<128 THEN
			FOR i:=0 TO 127 BY 8 DO
				WriteHex(Loc+i,4);
				WriteString(':');
				FOR j:=i TO i+7 DO
					WriteHex(Block1[j],2);
					WriteString(' ');
					END;
				WriteString(' ');
				FOR j:=i TO i+7 DO
					WriteHex(Block2[j],2);
					WriteString(' ');
					END;
				WriteLn;
				END;
			END;
		Loc:=Loc+128;
		END;
	END CompBin.
