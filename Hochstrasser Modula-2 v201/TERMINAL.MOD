IMPLEMENTATION MODULE Terminal;              (* Jan - 31 - 1985, pwh *)


  FROM SYSTEM IMPORT 
	ADR;

  FROM OpSys IMPORT
	BdosFunctions, Bdos;

  FROM Moves IMPORT
	Fill;

  FROM ASCII IMPORT
	bs, cr, lf, del;

  FROM Controls IMPORT
	CtrlX, CtrlC;

VAR
  result: CARDINAL;
  buf   : CHAR;
  gotBuf: BOOLEAN;

(*--------------------------------------------------------------*)
(* PROCEDURE BusyRead - read a character from the console.      *)
(* returns 0C if no character available; the character is not	*)
(* echoed to the console.					*)
(*--------------------------------------------------------------*)
  PROCEDURE BusyRead(VAR ch: CHAR);
  BEGIN
    Bdos(ORD(dirIO), 255, result);
    ch := CHR(result);
  END BusyRead;


(*--------------------------------------------------------------*)
(* PROCEDURE Read -- read a character from the console.         *)
(* Polls if no character is ready; the character is not echoed. *)
(*--------------------------------------------------------------*)
  PROCEDURE Read(VAR ch: CHAR);
  BEGIN
    IF gotBuf THEN
      REPEAT
        BusyRead(buf);       (* read char *)
      UNTIL buf # 0C;
      ch := buf;
    ELSE
      ch := buf;
      gotBuf := TRUE;
    END;
  END Read;


(*--------------------------------------------------------------*)
(* PROCEDURE ReadAgain -- causes a last character to be 	*)
(* rewritten.							*)
(*--------------------------------------------------------------*)
  PROCEDURE ReadAgain;
  BEGIN
    gotBuf := FALSE;
  END ReadAgain;


  MODULE StringInput;

  
    IMPORT
	bs, cr, lf, del, CtrlX, CtrlC,
	termCH,
	ADR, Fill, Read, Write;

    EXPORT
	ReadString, ReadLn;


    VAR 
      done : BOOLEAN;
      i	   :CARDINAL;
      StopOnWhiteChar: BOOLEAN;


(*--------------------------------------------------------------*)
(* PROCEDURE Clear -- clear 'n' characters on the screen.       *)
(*--------------------------------------------------------------*)
PROCEDURE Clear(n: CARDINAL);
VAR
  i: CARDINAL;
BEGIN
  FOR i := 1 TO n DO Write(bs); Write(' '); Write(bs); END;
END Clear;


(*--------------------------------------------------------------*)
(* PROCEDURE ReadString -- read a string from the console.      *)
(* Any character <= ' ' (20H,40C) except bs, and CtrlX 		*)
(* terminates the read operation.				*)
(*--------------------------------------------------------------*)
    PROCEDURE ReadString(VAR s: ARRAY OF CHAR);
    BEGIN
      done := FALSE;
      i := 0;
      Read(termCH);

      REPEAT
        IF termCH = del THEN		(* change del to bs *)
          termCH := bs
        END;
        IF (i <= HIGH(s)) & (termCH > ' ') OR 
	   (NOT StopOnWhiteChar & (termCH = ' ') & (i > 0)) THEN
				        (* normal char, put in string   *)
          Write(termCH);			(* echo char to console *)
          s[i] := termCH;
          i := i + 1;
	ELSIF (termCH = CtrlC) & (i = 0) THEN
	  HALT;
        ELSIF termCH = bs THEN
          IF i > 0 THEN
            Clear(1);         		(* backspace one position       *)
            i := i - 1;
          END
        ELSIF termCH = CtrlX THEN  	(* ^X restarts input            *)
	  Clear(i);
          i := 0;
        ELSE
          done := StopOnWhiteChar OR (termCH = cr) OR (termCH = lf);
        END;
        IF NOT done THEN Read(termCH) END;
      UNTIL done OR (i > HIGH(s));
      Fill(ADR(s[i]), HIGH(s) + 1 - i, 0C); (* zero rest *)
    END ReadString;


(*--------------------------------------------------------------*)
(* PROCEDURE ReadLn -- read a string from the console.          *)
(* cr or lf ONLY terminate the read operation.         		*)
(*--------------------------------------------------------------*)
    PROCEDURE ReadLn(VAR s: ARRAY OF CHAR);
    BEGIN
      StopOnWhiteChar := FALSE;
      ReadString(s); 
      StopOnWhiteChar := TRUE;
    END ReadLn;

  BEGIN
    StopOnWhiteChar := TRUE;
  END StringInput;


(*--------------------------------------------------------------*)
(* PROCEDURE Write -- write a character to the console.         *)
(*--------------------------------------------------------------*)
PROCEDURE Write(ch: CHAR);
BEGIN				
  Bdos(ORD(dirIO), ORD(ch), result); 
END Write;


(*--------------------------------------------------------------*)
(* PROCEDURE WriteLn -- write line end.                         *)
(*--------------------------------------------------------------*)
PROCEDURE WriteLn;
BEGIN
  Write(cr);               (* write cr lf pair     *)
  Write(lf);
END WriteLn;


(*--------------------------------------------------------------*)
(* PROCEDURE WriteString -- write a string to console.          *)
(*--------------------------------------------------------------*)
  PROCEDURE WriteString(s : ARRAY OF CHAR);
  VAR
    i: CARDINAL;
  BEGIN
    i := 0;
    WHILE (s[i] # 0C) & (i <= HIGH(s)) DO
      Write(s[i]);
      i := i + 1;
    END
  END WriteString;

BEGIN
  gotBuf := TRUE;	(* prevent fetch of 'buf' *)
END Terminal.
