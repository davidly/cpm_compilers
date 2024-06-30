IMPLEMENTATION MODULE GetFiles;
FROM CPM IMPORT BDOS,BDOSHL,sfofc,snofc,fcb,sdafc;
FROM CPMBIOS IMPORT directory;
FROM SYSTEM IMPORT ADR;
FROM Files IMPORT ConvertFileName;
(*	Get a list of file names meeting a wildcard description*)
VAR	i,j,k:INTEGER;
	f:fcb;
	name:FileName;
	DevChar:CHAR;
	WildCard:BOOLEAN;
PROCEDURE GetNames(Pattern:ARRAY OF CHAR;VAR names:ARRAY OF FileName;
		  VAR Count:INTEGER);
VAR	dma:ARRAY [0..3] OF directory;

PROCEDURE SearchForFileNames;
BEGIN
	ConvertFileName(f,name);

	IF f.fcbdn=0 THEN DevChar:=' '
	ELSE DevChar:=CHR(ORD(f.fcbdn)+(ORD('A')-1)) END;


	(*	Now scan for matching names*)

	i:=BDOS(sdafc,ADR(dma));	(*set dma buffer address*)	
	i:=BDOS(sfofc,ADR(f));		(*start search*)
	Count:=0;
	WHILE i<>255 DO
		j:=0;
		IF DevChar<>' ' THEN
			name[0]:=DevChar;
			name[1]:=':';
			j:=2;
			END;
		WITH dma[i] DO
			k:=1;
			WHILE (k<=HIGH(dirfn)) AND (dirfn[k]<>' ') DO
				name[j]:=dirfn[k];
				INC(j);
				INC(k);
				END;
			name[j]:='.';
			k:=1;INC(j);
			WHILE (k<=HIGH(dirft)) AND (dirft[k]<>' ') DO
				name[j]:=dirft[k];
				INC(j);
				INC(k);
				END;
			END; (*WITH DMA*)
		FOR j:=j TO HIGH(name) DO name[j]:=' ' END;
		names[Count]:=name;
		INC(Count);
		i:=BDOS(snofc,ADR(f));	(*go to next*)
		END; (*WHILE i<>255*)
	
	i:=BDOS(sdafc,80H);		(*reset to default*)
	
	END SearchForFileNames;
BEGIN

	(* Convert Pattern to a file name*)
	
	j:=HIGH(Pattern);
	WildCard:=FALSE;
	IF j>HIGH(name) THEN j:=HIGH(name) END;
	FOR i:=0 TO j DO 
		name[i]:=Pattern[i];
		IF (name[i]='*') OR (name[i]='?') THEN WildCard:=TRUE END;
		END;
	FOR i:=i+1 TO HIGH(name) DO name[i]:=' ' END;

	IF WildCard THEN SearchForFileNames
	ELSE
		Count:=1;
		names[0]:=name
		END;
	END GetNames;
END GetFiles.
