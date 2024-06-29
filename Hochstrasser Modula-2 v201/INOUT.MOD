IMPLEMENTATION MODULE InOut;		(* Jan - 31 - 1985 pwh *)


  FROM ASCII IMPORT lf, cr, sub;
  FROM Conversions IMPORT NumToStr;
  IMPORT FileNames;
  IMPORT OpSys;
  IMPORT SeqIO;
  IMPORT Strings;
  FROM SYSTEM IMPORT ADR;
  FROM Texts IMPORT TextState, ReadMode, input, output, Mode, TextStatus;
  IMPORT Texts;


  VAR
    ix: CARDINAL;


MODULE Redirection;

  FROM FileNames IMPORT NameState, FCBToStr, StrToFCB;
  FROM OpSys     IMPORT FCBFileName;
  FROM SeqIO     IMPORT FILE, FileState, Create, Open, Close;
  FROM Strings	 IMPORT Assign;

  FROM Texts IMPORT
	TEXT, TextState, ReadMode,
	input, output, console,
	Connect, Disconnect, TextStatus,
	Mode, ReadLn, Write, WriteLn, WriteString;

  IMPORT sub, Done;

  EXPORT
	OpenInput, OpenOutput,
	CloseInput, CloseOutput;

  VAR
    inFile, outFile, con: FILE;
    fileName: ARRAY [0..13] OF CHAR;
    defext: ARRAY [0..2] OF CHAR;
    ix: CARDINAL;
    ch: CHAR;


  PROCEDURE ReAssign(VAR t: TEXT; VAR f: FILE);
  BEGIN
    Done := (Disconnect(t) = TextOK) & (Close(f) = FileOK) &
	    (Connect(t, con) = TextOK);
  END ReAssign;

  PROCEDURE CloseInput;
  BEGIN
    ReAssign(input, inFile);
  END CloseInput;

  PROCEDURE CloseOutput;
  BEGIN
    Write(output, sub);	(* write file terminator *)
    ReAssign(output, outFile);
  END CloseOutput;


  PROCEDURE ReadName(prompt: ARRAY OF CHAR);

    PROCEDURE ParseName(): BOOLEAN;
    VAR
      fcbfn: FCBFileName;
      ns: NameState;
    BEGIN
      IF fileName = '' THEN 
        RETURN FALSE; 
      END;
      fcbfn.text := '';	(* clear it *)
      Assign(defext, fcbfn.type);
      ns := StrToFCB(fileName, fcbfn);
      FCBToStr(fcbfn, fileName, FALSE);
      RETURN (ns = NameOK) OR (ns = DeviceOK);
    END ParseName;

  BEGIN
    Mode(Str);
    REPEAT
      WriteLn(console);
      WriteString(console, prompt);
      ReadLn(console, fileName);
    UNTIL ParseName();
    Mode(Line);
  END ReadName;


  PROCEDURE OpenInput(dfx: ARRAY OF CHAR);
  BEGIN
    Assign(dfx, defext);
    ReadName('in>');
    Done := Open(inFile, fileName) = FileOK;
    IF Done & (Connect(input,inFile) # TextOK) THEN
      CloseInput;
      Done := FALSE;
    END;
  END OpenInput;  


  PROCEDURE OpenOutput(dfx: ARRAY OF CHAR);
  BEGIN
    Assign(dfx, defext);
    ReadName('out>');
    Done := Create(outFile, fileName) = FileOK;
    IF Done & (Connect(output, outFile) # TextOK) THEN
      CloseOutput;
      Done := FALSE;
    END;
  END OpenOutput;

BEGIN
  IF Open(con, 'CON:') # FileOK THEN HALT; END;
END Redirection;


PROCEDURE InputDone;
BEGIN
  Done := TextStatus(input) = TextOK;
END InputDone;


PROCEDURE OutputDone;
BEGIN
  Done := TextStatus(output) = TextOK;
END OutputDone;


PROCEDURE SetTermCH;
BEGIN
  Texts.ReadAgain(input);
  Texts.Read(input, termCH);
END SetTermCH;


PROCEDURE Read(VAR ch: CHAR);
BEGIN
  Texts.Read(input, ch);
  IF (ch = lf) & (termCH = cr) THEN
    Texts.Read(input, ch);
  END;
  termCH := ch;
  InputDone;
END Read;


PROCEDURE ReadString(VAR s: ARRAY OF CHAR);
BEGIN
  Mode(Str);
  Texts.ReadLn(input, s);
  Mode(Line);
  SetTermCH;
  InputDone;
END ReadString;


PROCEDURE ReadInt(VAR x: INTEGER);
BEGIN
  Texts.ReadInt(input, x);
  SetTermCH;
  InputDone;
END ReadInt;


PROCEDURE ReadCard(VAR x: CARDINAL);
BEGIN
  Texts.ReadCard(input, x);
  SetTermCH;
  InputDone;
END ReadCard;


PROCEDURE Write(ch: CHAR);
BEGIN
  Texts.Write(output, ch);
  IF ch = EOL THEN Write(lf); END;
  OutputDone;
END Write;


PROCEDURE WriteLn;
BEGIN
  Write(EOL);			(* this is by definition *)
END WriteLn;			(* definitely not my favourite solution... *)


PROCEDURE WriteString(s: ARRAY OF CHAR);
BEGIN
  Texts.WriteString(output,s);
  OutputDone;
END WriteString;


PROCEDURE WriteInt(x: INTEGER; n: CARDINAL);
BEGIN
  Texts.WriteInt(output, x, n);
  OutputDone;
END WriteInt;


PROCEDURE WriteCard(x, n: CARDINAL);
BEGIN
  Texts.WriteCard(output, x, n);
  OutputDone;
END WriteCard;


PROCEDURE WriteNum(base, x, n: CARDINAL);
VAR
  num: ARRAY [0..6] OF CHAR;
BEGIN
  Done := NumToStr(x, base, num);
  ix := 0;
  REPEAT
    INC(ix);
  UNTIL (num[ix] = 0C) OR (ix > HIGH(num)); (* find how many digits it has *)
  WHILE ix < n DO		                     (* put leading blanks *)
    Write(' ');
    ix := ix + 1;
  END; (* WHILE *)                      		(* ok, stuffed now *)
  WriteString(num);
END WriteNum;


PROCEDURE WriteOct(c,n: CARDINAL);
BEGIN
  WriteNum(10B, c, n);
END WriteOct;


PROCEDURE WriteHex(c,n: CARDINAL);
BEGIN
  WriteNum(10H, c, n);
END WriteHex;

BEGIN
  Done := TRUE;
  termCH := 0C;
END InOut.
