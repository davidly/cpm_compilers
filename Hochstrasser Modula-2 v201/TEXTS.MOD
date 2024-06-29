(***************************************************************************)
(*                                                                         *)
(*                       IMPLEMENTATION MODULE Texts			   *)
(*                                                                         *)
(*                                                                         *)
(*                     Modula-2 Standard Library Module			   *)
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
(*      created: Dec - 28 - 1984 pwh                                       *)
(* last updated: Dec - 28 - 1984 pwh                                       *)
(***************************************************************************)
IMPLEMENTATION MODULE Texts;
 

  FROM SeqIO IMPORT 
	FILE, FileState, FileUsage,
	FileStatus, FileUse,
	Open,
	EOF; 
  IMPORT SeqIO;			(* Read and Write *)

  FROM Moves IMPORT Fill;

  FROM Strings IMPORT Length;

  FROM Conversions IMPORT
	StrToInt, IntToStr, StrToCard, CardToStr;

  FROM ASCII IMPORT nul, bs, ht, cr, lf, sub, del;
  FROM Controls IMPORT CtrlX, CtrlC;
  FROM SYSTEM IMPORT ADR;



  TYPE
    TEXT = POINTER TO Text;
    Text = RECORD
	     state: TextState;
             in, out,                   (* input or output TEXT *)
	     eol,eot: BOOLEAN;		(* set by Read *)
	     again: BOOLEAN;		(* set by ReadAgain *)
	     buf: CHAR;			(* last char read (ReadAgain) *)
	     file: FILE;		(* associated file *)
	     handler: TextHandler;	(* error handling procedure *)
	   END;

    CharacterCheck = PROCEDURE(CHAR): BOOLEAN;
    UsageSet = SET OF FileUsage;


  VAR
    ch: CHAR;
    leadIn: BOOLEAN;	(* to determine whether to accept & skip or abort *)
    terminal: FILE;
    CharOk: CharacterCheck; (* character validation for ReadLn *)


  PROCEDURE LineChar(ch: CHAR): BOOLEAN; (* complies to CharOk *)
  BEGIN
    leadIn := FALSE;
    RETURN ch >= ' ';
  END LineChar;


  PROCEDURE StringChar(ch: CHAR): BOOLEAN; (* complies to CharOk *)
  BEGIN
    leadIn := leadIn & (ch <= ' '); (* skip leading blanks *)
    RETURN (ch > ' ') OR leadIn;
  END StringChar;


  PROCEDURE NumChar(ch: CHAR): BOOLEAN; (* complies to CharOk, too *)
  BEGIN
    leadIn := leadIn & (ch <= ' '); (* skip leading blanks *)
    RETURN (ch >= '0') & (ch <= '9') OR (ch = '-') OR (ch = '+')
	OR leadIn;
  END NumChar;


  PROCEDURE RealChar(ch: CHAR): BOOLEAN; (* complies to CharOk, too *)
  BEGIN
    RETURN NumChar(ch) OR (CAP(ch) = 'E') OR (ch = '.');
  END RealChar;


  PROCEDURE EOL(t: TEXT): BOOLEAN;
  BEGIN
    RETURN t^.eol;
  END EOL;


  PROCEDURE EOT(t: TEXT): BOOLEAN;
  BEGIN
    RETURN t^.eot;
  END EOT;


  PROCEDURE TextStatus(t: TEXT): TextState;
  BEGIN
    RETURN t^.state;
  END TextStatus;


  PROCEDURE Connect(VAR t: TEXT; f: FILE): TextState;
  BEGIN
    IF FileStatus(f) # FileOK THEN
      RETURN FileError;
    ELSE
      NEW(t);
      WITH t^ DO
        again := FALSE;
	buf := nul;
	file := f;
	handler := DummyTextHandler;
        in := FileUse(f) IN UsageSet{ReadFile,ReadDev,TextDev};
        out := FileUse(f) IN UsageSet{WriteFile,TextDev,WriteDev};
	IF in THEN
	  eot := EOF(f); (* may be empty! *)
 	  eol := eot;
	  again := FALSE;
	END;
      END;
      RETURN TextOK;
    END;
  END Connect;


  PROCEDURE Disconnect(VAR t: TEXT): TextState;
  BEGIN
    IF (t = NIL) OR (t = console) THEN 
      RETURN ConnectError;
    ELSE
      DISPOSE(t);
      RETURN TextOK;
    END;
  END Disconnect;


  PROCEDURE NewStatus(t: TEXT; status: TextState);
  BEGIN
    t^.state := status;
    t^.handler(status);
  END NewStatus;


  PROCEDURE DummyTextHandler(state: TextState);
  BEGIN
    (* same as in SeqIO: doesn't so too much. *)
  END DummyTextHandler;


  PROCEDURE SetTextHandler(t: TEXT; handler: TextHandler);
  BEGIN
    t^.handler := handler;
  END SetTextHandler;


  PROCEDURE Write(t: TEXT; ch: CHAR);
  BEGIN
    WITH t^ DO
      IF out THEN
        SeqIO.Write(file, ch);
        IF FileStatus(file) # FileOK THEN NewStatus(t, FileError); END;
      ELSE
        NewStatus(t, ConnectError);
      END;
    END;
  END Write;


  PROCEDURE WriteString(t: TEXT; s: ARRAY OF CHAR);
  VAR
    i: CARDINAL;
  BEGIN
    i := 0;
    WHILE (i <= HIGH(s)) & (s[i] # 0C) DO
      Write(t, s[i]);
      INC(i);
    END;
  END WriteString;


  PROCEDURE WriteWithLeadingBlanks(t: TEXT; s: ARRAY OF CHAR; n: CARDINAL);
  BEGIN
    IF n > Length(s) THEN
      n := n - Length(s);
      WHILE n # 0 DO Write(t,' '); DEC(n); END;
    END;
    WriteString(t,s);
  END WriteWithLeadingBlanks;


  PROCEDURE WriteInt(t: TEXT; i: INTEGER; n: CARDINAL);
  VAR
    s: ARRAY[0..5] OF CHAR;
  BEGIN
    IF IntToStr(i,s) THEN 
      WriteWithLeadingBlanks(t,s,n);
    ELSE
      NewStatus(t, FormatError);
    END;
  END WriteInt;


  PROCEDURE WriteCard(t: TEXT; c,n: CARDINAL);
  VAR
    s: ARRAY [0..4] OF CHAR;
  BEGIN
    IF CardToStr(c,s) THEN 
      WriteWithLeadingBlanks(t,s,n);
    ELSE
      NewStatus(t, FormatError);
    END;
  END WriteCard;


  PROCEDURE WriteLn(t: TEXT);
  BEGIN
    Write(t, cr);
    Write(t, lf);
  END WriteLn;


  PROCEDURE Read(t: TEXT; VAR ch: CHAR);
  BEGIN
    WITH t^ DO
      IF NOT in THEN 
        NewStatus(t, ConnectError);
      ELSIF again THEN
        ch := buf;		(* flags are already set by last operation *)
        again := FALSE;
      ELSE
        SeqIO.Read(file, ch);
        IF FileStatus(file) # FileOK THEN NewStatus(t, FileError); END;
        eot := (ch = sub) OR EOF(file);
        eol := (ch = cr) OR eot OR NOT eol & (ch = lf); (* multiple LFs *)
        buf := ch;
      END;
    END; (* WITH *)
  END Read;


  PROCEDURE ReadLn(t: TEXT; VAR s: ARRAY OF CHAR);
  VAR 
    i	 : CARDINAL;

    PROCEDURE AssignCh(ch: CHAR);
    BEGIN
      IF (i <= HIGH(s)) & NOT leadIn THEN
        s[i] := ch;
        INC(i);
      END;
    END AssignCh;

  BEGIN
    WITH t^ DO
      i := 0;
      Read(t,ch);
      LOOP
        IF eol THEN EXIT; END;
        IF ch = del THEN ch := bs; END; (* saves CASE table space *)
        CASE ch OF
          CtrlC  : IF i = 0 THEN HALT; END;
        | bs,del : IF i > 0 THEN 
		     IF in # out THEN Write(t,bs); END;
		     Write(t,' '); (* usually, an operating system *)
		     Write(t,bs);  (* eases your work...	   *)
		   END;
	| ht	 : WHILE (i <= HIGH(s)) & ((i+1) MOD 8 # 0) DO
		     AssignCh(' ');
		   END;
		   AssignCh(' ');
        | CtrlX  : WHILE i > 0 DO
		     Write(t,bs); Write(t,' '); Write(t,bs);
		     i := i - 1;
		   END;
        ELSE
          IF (i <= HIGH(s)) & CharOk(ch) THEN
            AssignCh(ch);
	  ELSE
	    EXIT;
          END;
        END; (* CASE *)
        IF i > HIGH(s) THEN EXIT; END;
        Read(t, ch);
      END; (* LOOP *)
      Fill(ADR(s[i]), HIGH(s) + 1 - i, nul); (* zero rest *)
      eol := TRUE; (* any case *)
    END;
  END ReadLn;


  PROCEDURE ReadNum(t: TEXT; VAR s: ARRAY OF CHAR);
  BEGIN
    Mode(Num);
    ReadLn(t, s);
    WITH t^ DO eol := eot OR (buf = cr); END;
  END ReadNum;


  PROCEDURE ReadInt(t: TEXT; VAR i: INTEGER);
  VAR
    s: ARRAY [0..6] OF CHAR; (* '-32768' is longest string *)
  BEGIN
    ReadNum(t, s);
    IF NOT StrToInt(s,i) THEN NewStatus(t, FormatError); END;
  END ReadInt;   


  PROCEDURE ReadCard(t: TEXT; VAR c: CARDINAL);
  VAR 
    s: ARRAY [0..5] OF CHAR; (* '65535' is longest string *)
  BEGIN
    ReadNum(t, s);
    IF NOT StrToCard(s,c) THEN NewStatus(t, FormatError); END;
  END ReadCard;


  PROCEDURE ReadAgain(t: TEXT);
  BEGIN
    t^.again := TRUE;
  END ReadAgain;


  PROCEDURE Mode(m: ReadMode);
  BEGIN
    leadIn := TRUE;
    CASE m OF
      Line: CharOk := LineChar; leadIn := FALSE;
    | Num : CharOk := NumChar;
    | Real: CharOk := RealChar;
    | Str : CharOk := StringChar;
    END;
  END Mode;

BEGIN
  Mode(Line);
  IF NOT ((Open(terminal, 'CON:') = FileOK) &
    (Connect(console,terminal) = TextOK) &
    (Connect(output,terminal) = TextOK) &
    (Connect(input,terminal) = TextOK)) THEN
    HALT;
  END;
END Texts.
