(***************************************************************************)
(*                                                                         *)
(*                     IMPLEMENTATION MODULE FileNames			   *)
(*                                                                         *)
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
(* created	Oct -  8 - 1984 pwh                                        *)
(* updated	Oct -  8 - 1984 pwh                                        *)
(*		Mar - 23 - 1985 pwh					   *)
(***************************************************************************)
IMPLEMENTATION MODULE FileNames;

  FROM OpSys IMPORT FCBFileName;

MODULE ConvertToFCB;

  IMPORT NameState, FCBFileName;

  EXPORT StrToFCB;

  
  VAR
    illegalChars: BOOLEAN;
    default : FCBFileName;
    i,j	    : CARDINAL; 
    ch	    : CHAR;

  PROCEDURE StrToFCB(    filename: ARRAY OF CHAR;
                     VAR FCBFile : FCBFileName) : NameState;

    (*----------------------------------------------------------------------*)

    PROCEDURE GetChar;
    BEGIN
      IF i <= HIGH(filename) THEN
        ch := CAP(filename[i]); i := i + 1;
      ELSE
        ch := 0C;
      END;
    END GetChar;

    (*----------------------------------------------------------------------*)

    PROCEDURE CopyIdent;
    BEGIN
      WHILE (ch >= 'A') & (ch <= 'Z') OR (ch >= '0') & (ch <= '9') OR
            (ch = '$') OR (ch = '?') DO
        IF j <= HIGH(FCBFile.text) THEN 
	  FCBFile.text[j] := ch; 
	  j := j + 1;
	END;
        GetChar;
      END;
      IF ch = '*' THEN			   	(* expand * to ?... *)
	WHILE j <= HIGH(FCBFile.text) DO   	(* do not distinguish *)
	  FCBFile.text[j] := '?'; 		(* name and type *)
	  j := j + 1;				(* why: see code down there *)
	END;
        GetChar;
      END;
      illegalChars := illegalChars OR (ch # 0C) & (ch # '.') & (ch # ':');
    END CopyIdent;

    PROCEDURE LegalDevice(fn: FCBFileName): BOOLEAN;
    BEGIN (* as simple as that! *)
      RETURN (fn.text = 'CON') OR (fn.text = 'KBD') OR (fn.text = 'TRM') OR
	     (fn.text = 'LST') OR (fn.text = 'RDR') OR (fn.text = 'PUN');
    END LegalDevice;

  BEGIN
    j := 1; 
    i := 0;
    default := FCBFile;
    illegalChars := FALSE;
    IF filename[0] # 0C THEN	(* not an empty string *)
      FCBFile.text := '            '; (* set up empty *)
      REPEAT GetChar; UNTIL ch # ' '; (* leading blanks *)
      IF (i+2 <= HIGH(filename)) & (filename[i+2] = ':') THEN	(* device *)
        j := 0;
        CopyIdent;
        FCBFile.text[j] := 0C;
        GetChar;
	IF illegalChars THEN RETURN IllegalChars; END;
        IF (LegalDevice(FCBFile)) & (ch = 0C) THEN
	  RETURN DeviceOK;
        ELSE
	  RETURN DriveError; (* DeviceError is part of FileState *)
        END;
      ELSE					(* plain normal file name *)
        IF filename[i] = ':' THEN			(* drive *)
          FCBFile.disk := CHR(ORD(ch) - ORD('A') + 1);
          GetChar; GetChar;
        ELSE
          FCBFile.disk := 0C;
        END;
        CopyIdent;			(* file name, evt. too long/empty *)
	IF j = 1 THEN			      (* no name specified at all *)
	  FCBFile := default;      (* missing; set default name and drive *)
        END;
        WHILE (ch # 0C) & (ch # '.') DO GetChar; END;
	FCBFile.type := '   ';		 (* may be "touched" by long name *)
        IF ch = '.' THEN	        (* file type, evt. empty/too long *)
          GetChar; j := 9;
          CopyIdent;
	ELSE
	  FCBFile.type := default.type;	          (* missing; set default *)
        END;
      END;
    END;

    IF illegalChars THEN RETURN IllegalChars; END;

    (* account for possible 0C in name and type coming from default. *)
    FOR i := 1 TO HIGH(FCBFile.text) DO
      IF FCBFile.text[i] < ' ' THEN FCBFile.text[i] := ' '; END;
    END;
    (* now, test plausibility of assembled file name *)
    (* when we arrive here, no device may have been specified *)
    IF FCBFile.name = '        ' THEN	(* name has to be specified *)
      RETURN NoNameDefault;
    ELSE
      i := 0;
      REPEAT
        ch := FCBFile.text[i];
	i := i + 1;
      UNTIL (i > HIGH(FCBFile.text)) OR (ch = '?');
      IF ch = '?' THEN
        RETURN WildOK;
      ELSE
	RETURN NameOK;
      END;
    END;
  END StrToFCB;

END ConvertToFCB;


MODULE ConvertToString;

  IMPORT FCBFileName;

  EXPORT FCBToStr;

  VAR
    index, FCBPtr, i: CARDINAL;
    star	      : BOOLEAN;

  PROCEDURE FCBToStr(    FCBFile  : FCBFileName; 
		     VAR str      : ARRAY OF CHAR;
                         formatted: BOOLEAN);

    PROCEDURE Assign(ch: CHAR);
    BEGIN
      IF index <= HIGH(str) THEN
        str[index] := ch;
        index := index + 1;
      END;
    END Assign;


    PROCEDURE Field (begin, end: CARDINAL);

      PROCEDURE Skip(ch: CHAR);
      BEGIN
        WHILE (FCBPtr >= begin) & (FCBFile.text[FCBPtr] = ch) DO
          FCBPtr := FCBPtr - 1;
        END;
      END Skip;

    BEGIN
      FCBPtr := end; 		(* skip trailings blanks and '?' *)
      Skip(' ');
      star := FCBPtr = end;
      IF star THEN
        Skip('?');		(* '?' - sequence is replaced by '*' *)
	star := FCBPtr # end;	(* but only if it is at end *)
      END;

      FOR i := begin TO FCBPtr DO Assign(FCBFile.text[i]); END;

      IF star THEN Assign('*'); END;

      IF formatted THEN
	FOR i := FCBPtr + 1 TO end DO Assign(' '); END;
      END;
    END Field;

  BEGIN	(* FCBToStr *)
    index := 0;
    IF FCBFile.disk # 0C THEN         (* drive *)
      INC( FCBFile.disk, ORD('@'));
      Assign(FCBFile.disk);
      Assign(':');
      index := 2;
    END;
    Field(1, 8);
    Assign('.');
    Field(9, 11);
    Assign(0C);
  END FCBToStr;

END ConvertToString;

END FileNames.
