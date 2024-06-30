IMPLEMENTATION MODULE Command;


(*	Command line processor*)
FROM Storage IMPORT ALLOCATE;
FROM SYSTEM  IMPORT ADDRESS;
VAR	i,j,k:INTEGER;
PROCEDURE GetParams(VAR p:ARRAY OF Parameter;VAR count:INTEGER);
PROCEDURE Build(len:INTEGER;ch:CHAR;c:Parclass);
VAR	ad:ADDRESS;
BEGIN

	ALLOCATE(ad,len+4);
	p[count]:=ad;
	WITH p[count]^ DO
		IF j>=INTEGER(CommLength)THEN Terminator:=0dx
		ELSE Terminator:=ch END;
		Length:=len;
		Class:=c;
		FOR k:=0 TO len-1 DO
			Chars[k]:=CommText[i+k];
			END;
		Chars[len]:=0x;
		END;
	count:=count+1
	END Build;
(*	crack the command line*)
BEGIN
	i:=0;
	count:=0;
	LOOP
		IF count>HIGH(p) THEN 
			EXIT 
			END;
		WHILE (i<INTEGER(CommLength)) AND (CommText[i]=' ') DO
			INC(i)
			END;
		IF i>=INTEGER(CommLength) THEN EXIT END;
		CASE CommText[i] OF
		'[','/':(*Option found*)
			INC(i);
			Build(INTEGER(CommLength)-i,0dx,option);
			EXIT
			|
		'"',"'":j:=i+1;
			WHILE (CommText[i]<>CommText[j]) 
				AND (j<INTEGER(CommLength)) DO
				INC(j)
				END;
			INC(i);
			Build(j-i,CommText[i-1],string);
			INC(j);
			|
		ELSE	j:=i+1;
			WHILE 		(CommText[j]<>' ') 
				AND	(CommText[j]<>',') 
				AND	(CommText[j]<>'[')
				AND	(CommText[j]<>'/')
				AND 	(j<INTEGER(CommLength)) DO
				INC(j)
				END;
			Build(j-i,CommText[j],name);
			END;(*case*)
		
		i:=j;
		IF CommText[i]=',' THEN INC(i) END;
		END; (*LOOP*)
	END GetParams;
				
END Command.
