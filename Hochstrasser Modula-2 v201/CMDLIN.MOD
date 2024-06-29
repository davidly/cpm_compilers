(***************************************************************************)
(*                                                                         *)
(*									   *)
(*                       IMPLEMENTATION MODULE CmdLin			   *)
(*                                                                         *)
(*                     Modula-2 Utility Library Module			   *)
(*                                                                         *)
(*                                for the				   *)
(*                                                                         *)
(*                     Modula-2 System for Z80 / CP/M 			   *)
(*                                                                         *)
(*                                   by					   *)
(*                                                                         *)
(*                        Hochstrasser Computing AG			   *)
(*                           Leonhardshalde 21				   *)
(*                              8001 Zuerich				   *)
(*                              Switzerland				   *)
(*                                                                         *)
(*                                                                         *)
(*                                                                         *)
(*      created: Oct - 29 - 1984 pwh                                       *)
(* last updated: Jan -  8 - 1985 pwh                                       *)
(***************************************************************************)
IMPLEMENTATION MODULE CmdLin;

  FROM SYSTEM IMPORT
	ADR;

  FROM Strings IMPORT
	STRING,
	Assign, Concat, Delete, Pos, Length;

  FROM Moves IMPORT
	MoveLeft, Fill;

  FROM Terminal IMPORT
	Write, WriteLn, ReadString;

  FROM ASCII IMPORT
	nul;


  TYPE 
    CPMCmdLine = RECORD
                   length: CHAR;
                   text	 : STRING;
                 END;

    ShortFCB = RECORD
                 drive	  : CHAR;
                 name	  : ARRAY [0..7] OF CHAR;
                 extension: ARRAY [0..2] OF CHAR;
               END;
                  
  VAR
    i, n, l: CARDINAL;
    used: BOOLEAN;

(*--------------------------------------------------------------*)
(* PROCEDURE ReadCommandLine -- read command line into comLin.  *)
(* Correctness is checked. comLin cannot be empty on return	*)
(* from this procedure.				        	*)
(*--------------------------------------------------------------*)
  PROCEDURE ReadCommandLine(VAR comLin: ARRAY OF CHAR);
  VAR 
    commandLine[80H]: CPMCmdLine;
    fcb        [5CH]: ShortFCB;
    expString       : STRING;

  PROCEDURE AppendWithoutBlanks(VAR string : ARRAY OF CHAR; 
				    newPart: ARRAY OF CHAR);
  BEGIN
    Concat(expString,newPart,expString);
    n := Pos(' ',expString);
    IF n <= HIGH(expString) THEN 
      Delete(expString,n,HIGH(expString) + 1 - n);
    END;
  END AppendWithoutBlanks;

  PROCEDURE SkipBlanks;
  BEGIN
    i := 0;
    WHILE comLin[0] = ' ' DO Delete(comLin,0,1); END;
  END SkipBlanks;

  PROCEDURE Prompt;
  BEGIN
    REPEAT
      WriteLn; Write('*'); ReadString(comLin);
      SkipBlanks;
    UNTIL comLin[0] # nul;
  END Prompt;

  BEGIN (* ReadCommandLine *)
    IF NOT used THEN		(* get it first time *)
      used := TRUE;
      Assign(comLin,commandLine.text);
      i := 0; n := 0;
      IF fcb.drive > nul THEN	(* construct expected command line *)
        expString[0] := CHR(ORD(fcb.drive) + ORD('@'));
        expString[1] := ':'; 
        expString[2] := 0C;
      END;
      AppendWithoutBlanks(expString,fcb.name);
      Concat(expString,'.', expString);
      AppendWithoutBlanks(expString,fcb.extension);
      SkipBlanks;
      n := 0;
      LOOP
        IF (expString[n] = nul) OR
           (expString[n] = '.') & (comLin[i] # '.') THEN 
	  i := 0; 
	  EXIT;
	END;

        IF comLin[i] # expString[n] THEN
          WHILE (i <= HIGH(comLin)) & 
		(comLin[i] # ' ') & (comLin[i] # nul) DO 
	     i := i + 1; 
	  END;
          EXIT;
        END;

        n := n + 1;
	i := i + 1;
      END;

      IF comLin[i] = nul THEN   (* commandline empty *)
	Prompt;
      END;
    ELSE
      Prompt;
    END;
    MoveLeft(ADR(comLin[i]), ADR(comLin), HIGH(comLin) + 1 - i);
    i := 0;
    WHILE (i <= HIGH(comLin)) & (comLin[i] # nul) DO i := i + 1; END;
    Fill(ADR(comLin[i]),HIGH(comLin)+1-i, 0C);
  END ReadCommandLine;

BEGIN
  used := FALSE;
END CmdLin.
