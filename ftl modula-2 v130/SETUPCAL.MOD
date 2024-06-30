IMPLEMENTATION MODULE SetUpCall;

(*	SET Up call parameters for a program and chain to it
	*)
FROM	Chain IMPORT LoadAndExecute;
FROM	SYSTEM IMPORT BYTE;
(*	Low core variables*)
VAR	fcb1[5ch]:fcb;
	fcb2[6ch]:fcb;
	commandlen[80h]:BYTE;
	command[81h]:ARRAY[0..80] OF CHAR;
	i,j:INTEGER;
PROCEDURE MakeCall(progname:ARRAY OF CHAR;VAR f:fcb);
BEGIN
 	fcb1:=f;
	fcb2.fcbdn:=0;
	fcb2.fcbfn[1]:=' ';
	(*set up command line*)

	i:=0;
	j:=1;
	IF fcb1.fcbdn<>0 THEN
		command[i]:=CHR(ORD(fcb1.fcbdn)+ORD('A')-1);
		INC(i);
		command[i]:=':';
		INC(i);
		END;
	WHILE (j<=8) AND (fcb1.fcbfn[j]<>' ') DO
		command[i]:=fcb1.fcbfn[j];
		INC(i);
		INC(j);
		END;
	j:=1;
	command[i]:='.';
	INC(i);
	WHILE (j<=3) AND (f.fcbft[j]<>' ') DO
		command[i]:=fcb1.fcbft[j];
		INC(i);
		INC(j);
		END;
	j:=0;
	WHILE (j<=HIGH(progname)) AND (progname[j]<>'[') DO INC(j) END;
	IF (j<HIGH(progname)) THEN 
		command[i]:='[';
		INC(i);
		command[i]:=progname[j+1];
		INC(i);
		END;
	commandlen:=i;
	f.fcbfn:='        ';
	FOR i:=0 TO j-1 DO
		f.fcbfn[i+1]:=progname[i];
		END;
	f.fcbft:='COM';
	f.fcbdn:=0;
	f.fcbex:=0;
	f.fcbcr:=0;
	LoadAndExecute(f);
	END MakeCall;	
END SetUpCall.

