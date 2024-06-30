IMPLEMENTATION MODULE TermAtt;
(*                                                             *)
(*(C)Copyright 1987 Bob Catiller all commercial rights reserved*)
(*                                                             *)

FROM Terminal IMPORT
  WriteChar, WriteString;

FROM Terminal IMPORT
  BusyRead, ClearToEOL;

FROM Convert IMPORT
  StrToCard;

(* ******** IReadChar ******* *)
(* This procedure is used in place of the ReadChar *)
(* procedure from the texts module. This procedure *)
(* provides for time sharing of independently running *)
(* tasks while the system is waiting for console input. *)
(* The procedure functions identical to the ReadChar *)
(* procedure by returning with a character when a *)
(* key is pressed on the terminal. *)

PROCEDURE IReadChar():CHAR;

VAR
  c: CHAR;

BEGIN
  c := CHR(0);
  WHILE c = CHR(0) DO
    BusyRead(c)
    (* Time sharing of other tasks occurs at this point. *)
    (* Calls to independently running proceedures will *)
    (* be placed at this point in the program. *)
  END;(* WHILE *)
  IF c = CHR(27) THEN
    escape := TRUE;
  END;(* IF *)
  RETURN c;
END IReadChar;

(* ******** RangeCard ******* *)
(* Reads a cardinal with the selected input range. *)

VAR
  i1:CARDINAL;

PROCEDURE RangeCard(min,max: CARDINAL): CARDINAL;
BEGIN
  GetRC();
  LOOP
    i1:= max+1;(* Force out-of-range *)
    SetRC(r,c);
    i1 := IReadCard();
    IF escape THEN
      EXIT;
    END;(* IF *)
    IF NOT Valid THEN
      SetRC(CHR(ORD(r)+1),c);
      WriteString("Invalid entry.");
      SetRC(r, c);
      ClearToEOL;
    ELSE
      SetRC(CHR(ORD(r)+1),c);
      ClearToEOL;
    END;(* IF *)
    SetRC(CHR(ORD(r)+1),c);
    IF i1 < min THEN
      WriteString("Value too small.");
      SetRC(r, c);
      ClearToEOL;
    ELSIF i1 > max THEN
      WriteString("Value too large.");
      SetRC(r, c);
      ClearToEOL;
    ELSE
      EXIT;
    END;(* IF *)
  END;(* LOOP *)
  RETURN i1;
END RangeCard;

(* ******** IReadCard ******** *)
(* Reads a cardinal value from the terminal *)
(* and returns with it. *)

VAR
  i2: CARDINAL;
VAR
  str: ARRAY [0..1] OF CHAR;

PROCEDURE IReadCard():CARDINAL;
BEGIN
  IReadString(str);
  Valid := StrToCard(str,i2);
  RETURN i2;
END IReadCard;

(* ******** IReadString ******** *)
(* reads a 2 character numeric string from the terminal *)

VAR
  c4: CHAR;

PROCEDURE IReadString(VAR str: ARRAY OF CHAR);
BEGIN
  LOOP
    REPEAT
      CursorOn;
      c4 := IReadChar();
      IF escape THEN
        CursorOff;
        EXIT;
      END;(* IF *)
    UNTIL ((c4 >= "0") AND (c4 <= "9"));
    str[0] := c4;
    WriteChar(c4);
    REPEAT
      c4 := IReadChar();
      IF escape THEN
        CursorOff;
        EXIT;
      END;(* IF *)
    UNTIL ((c4 >= "0") AND (c4 <= "9"));
    str[1] := c4;
    WriteChar(c4);
    CursorOff;
    EXIT;
  END;(* LOOP *)
END IReadString;

(* ******** GetRC ******* *)
(* Gets current Row (r) and Column (c) cursor *)
(* position from Wyse 50 terminal. *)

PROCEDURE GetRC();
BEGIN
  WriteChar(CHR(27));(* ASCII escape character *)
  WriteChar("?");
  r := IReadChar();(* Get row address *)
  c := IReadChar();(* Get Column address *)
END GetRC;

(* ******** SetRC ******* *)
(* Set selected Row (row) and Column (col) cursor address *)
(* on Wyse 50 terminal. *)

PROCEDURE SetRC(row,col: CHAR);
BEGIN
  WriteChar(CHR(27));(* ASCII escape character *)
  WriteChar("=");
  WriteChar(row);(* Set Row address *)
  WriteChar(col);(* Set Column address *)
END SetRC;

(* ******** SetAtt ******* *)
(* Set selected attribute at present cursor location *)
(* on Wyse 50 terminal. *)

PROCEDURE SetAtt(ch: CHAR);
BEGIN
(* Control sequence to set attributes on Wyse 50 *)
  WriteChar(CHR(27));(* ASCII escape character *)
  WriteChar("G");
  WriteChar(ch);
END SetAtt;

(* ******** RevVideo ********* *)
(* Set reverse video attribute at present cursor *)
(* location on Wyse 50. *)

PROCEDURE RevVideo();
BEGIN(* Attribute code to activate reverse video on Wyse 50 *)
  SetAtt("4");
END RevVideo;

(* ******** DimRevVideo ********* *)
(* Set dim and reverse video attribute at present cursor *)
(* location on Wyse 50. *)

PROCEDURE DimRevVideo();
BEGIN(* Attribute code to activate reverse video on Wyse 50 *)
  SetAtt("t");
END DimRevVideo;

(* ********* NormVideo ******** *)
(* Set normal (non-reverse) video on Wyse 50. *)

PROCEDURE NormVideo();
BEGIN
(* Attribute code to activate normal video on Wyse 50 *)
  SetAtt("0");
END NormVideo;

(* ********* Dim ******** *)
(* Set dim attribute on Wyse 50. *)

PROCEDURE Dim();
BEGIN
(* Attribute code to activate dim video on Wyse 50 *)
  SetAtt("p");
END Dim;

(* ********* Blink ******** *)
(* Set dim attribute on Wyse 50. *)

PROCEDURE Blink();
BEGIN
(* Attribute code to activate blinking on Wyse 50 *)
  SetAtt("2");
END Blink;

(* ********** CursorOn ************ *)
  (* Turns on cursor *)
  (* Sends cursor on control sequence *)
  (* for Wyse 50 terminal. *)

  PROCEDURE CursorOn;

  BEGIN
    WriteChar(CHR(27));(* escape character *)
    WriteChar("`");
    WriteChar("1");(* cursor on code *)
  END CursorOn;

(* ********** CursorOff ************ *)
  (* Turns off cursor *)
  (* Sends cursor off control sequence *)
  (* for Wyse 50 terminal. *)

  PROCEDURE CursorOff();

  BEGIN
    WriteChar(CHR(27));(* escape character *)
    WriteChar("`");
    WriteChar("0");(* cursor off code *)
  END CursorOff;

(* ********** GraphicOn ************ *)
(* Initiate graphics mode on a Wyse 50 terminal. *)

  PROCEDURE GraphicOn();

  BEGIN
    WriteChar(CHR(27));(* ASCII escape character *)
    WriteChar("H");
    WriteChar(CHR(2));(* ASCII STX character *)
  END GraphicOn;

(* ********** GraphicOff ************ *)
(* Wyse 50 terminal to normal display mode. *)

  PROCEDURE GraphicOff();

  BEGIN
    WriteChar(CHR(27));(* ASCII escape character *)
    WriteChar("H");
    WriteChar(CHR(3));(* ASCII ETX character *)
  END GraphicOff;

(* ********** GraphicChar ************ *)
(* Outputs single character as graphic character *)
(* on Wyse 50 terminal. *)

  PROCEDURE GraphicChar(ch: CHAR);

  BEGIN
    WriteChar(CHR(27));(* ASCII escape character *)
    WriteChar("H");
    WriteChar(ch);(* write graphics char *)
  END GraphicChar;


END TermAtt.