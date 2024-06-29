IMPLEMENTATION MODULE Conversions;           (* Jan - 31 - 1985 pwh *)

  (*-----------------------------------------------------------------------*)

  FROM Moves IMPORT MoveLeft;

  FROM SYSTEM IMPORT
	ADR, WORD;

  FROM Strings IMPORT
     Assign, Concat, Delete, Length;
 
  (*-----------------------------------------------------------------------*)

  PROCEDURE Assigned(source: ARRAY OF CHAR; 
                     VAR destination: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    Assign(source,destination);
    RETURN (Length(source) <= HIGH(destination) + 1);
  END Assigned;

  (*-----------------------------------------------------------------------*)

  MODULE GeneralConversions;

    (*---------------------------------------------------------------------*)
    
    IMPORT 
	ADR, Assigned, MoveLeft;

    (*---------------------------------------------------------------------*)

    EXPORT 
	NumToStr, StrToNum;
 
    (*---------------------------------------------------------------------*)

    CONST
      hiIndex = 16; 			(* 's enough for binary, too *)
      maxCard = 65535;

    (*---------------------------------------------------------------------*)

    TYPE
      ConversionIndex = [0..hiIndex];    

    (*---------------------------------------------------------------------*)

    VAR
      ch	: CHAR;
      inx	: CARDINAL;
      digit	: CARDINAL;
      maxNum	: CARDINAL;
      converted	: ARRAY ConversionIndex OF CHAR; 


    (*--------------------------------------------------------------*)
    (* PROCEDURE NumToStr -- convert 'c' into 'string' using 'base' *)
    (* as radix. Fold any characters > '9' to 'A'..'Z', if greater  *)
    (* than 'Z' to 'a'..'z'. This allows for a maximum base of 63.  *)
    (* Bases 0 and 1 aren't accepted.			            *)
    (*--------------------------------------------------------------*)
    PROCEDURE NumToStr(num, base: CARDINAL; VAR str: ARRAY OF CHAR): BOOLEAN;
    BEGIN
      IF (base > 1) & (base < 64) THEN

        IF num = 0 THEN RETURN Assigned('0', str); END;

        converted[hiIndex] := 0C;		(* set terminator *)
  
        inx := hiIndex - 1;		        (* convert number *)
        WHILE num > 0 DO
          ch := CHR((num MOD base) + ORD('0')); (* strip last digit *)
          IF ch > '9' THEN
            ch := CHR(ORD(ch) + 7);	(* convert to 'A' .. 'Z' *)
            IF ch > 'Z' THEN 
              ch := CHR(ORD(ch) + 6);	(* convert to 'a' .. 'z' *)
            END;
          END;
          num := num DIV base; 
	  converted[inx] := ch;
          inx := inx - 1;
        END;
	MoveLeft(ADR(converted[inx+1]),ADR(converted),HIGH(converted) - inx);
        RETURN Assigned(converted, str);
      END;
      RETURN FALSE;
    END NumToStr;

    (*---------------------------------------------------------------------*)

    PROCEDURE Digit(base: CARDINAL): BOOLEAN;
    BEGIN
      IF (ch >= '0') & (ch <= '9') THEN      (* small & slow; CASE    *)
        digit  := ORD(ch) - 30H;             (* would be large & fast *)
      ELSIF (ch >= 'A') & (ch <= 'Z') THEN
        digit := ORD(ch) - 37H;
      ELSIF (ch >= 'a') & (ch <= 'z') THEN
        digit := ORD(ch) - 3DH;
      ELSE
        RETURN FALSE;
      END;
      RETURN digit < base;              (* assert digit not too large *)
    END Digit;


    (*--------------------------------------------------------------*)
    (* PROCEDURE StrToNum -- convert contents of 'string' to a      *)
    (* 2-byte number using 'base' as radix for the conversion.	    *)
    (* The number can be too big. Accepted digits are:		    *)
    (* '0'..'9', 'A'..'Z', 'a'..'z'.				    *)
    (* This allows for a maximum base of 63.			    *)
    (* The minimum base is 2; there's not much use in bases 0 and 1.*)
    (* errors if: number too big, impossible base, erroneous digits.*)
    (*--------------------------------------------------------------*)
    PROCEDURE StrToNum(str: ARRAY OF CHAR; base: CARDINAL; 
                       VAR num: CARDINAL): BOOLEAN;
    BEGIN
      IF (base > 1) & (base < 64) THEN
        inx := 0;
        num := 0;
        maxNum := maxCard DIV base;	(* cannot add another digit *)
        ch := str[0];		        (* if number >= maxNum 	    *)

        WHILE (inx <= HIGH(str)) & Digit(base) & ((maxNum > num) OR
	  (maxCard DIV num >= base) & 
	  (maxCard - num * base >= digit)) DO
	  num := base * num + digit;
	  INC(inx);
	  ch := str[inx];
	END; (* WHILE *)
	RETURN (ch = 0C) OR (inx > HIGH(str));
      END;
      RETURN FALSE;
    END StrToNum;

  (*----------------------------------------------------------------------*)

  END GeneralConversions;

  (*----------------------------------------------------------------------*)

  CONST
    maxPlaces   = 6;	   (* a positive number has 5 decimal digits + 0C *)
    decimalBase = 10;
    hexBase     = 10H;
    minInt      = -32768;
    negMinInt   = 32768;
    minIntASCII = '-32768';

   
  (*----------------------------------------------------------------------*)

  PROCEDURE IntToStr(int: INTEGER; VAR str: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    IF CardToStr(CARDINAL(ABS(int)), str) THEN
      IF int < 0 THEN
        Concat('-', str, str);                   (* make it negative *)
      END;
      RETURN TRUE;
    END;
    RETURN FALSE;
  END IntToStr;

  (*-----------------------------------------------------------------------*)

  PROCEDURE StrToInt(str: ARRAY OF CHAR; VAR int: INTEGER): BOOLEAN;
  VAR
    negative: BOOLEAN;
    j: CARDINAL;
  BEGIN
    negative := str[0] = '-';

    IF negative THEN Delete(str,0,1); END;   
    IF StrToCard(str, j) THEN	             (* ok if j < maxCard *)
      IF j < negMinInt THEN
        int := j;
        IF negative THEN		
	  int := -int;
        END;
      ELSIF (j = negMinInt) & negative THEN	(* special case *)
	int := minInt;
      ELSE
	RETURN FALSE;
      END;
      RETURN TRUE;
    END;
    RETURN FALSE;
  END StrToInt;
   
    
(*--------------------------------------------------------------*)
(* PROCEDURE CardToStr -- convert 'c' to a string.              *)
(*--------------------------------------------------------------*)
  PROCEDURE CardToStr(card: CARDINAL; VAR str: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    RETURN NumToStr(card, decimalBase, str);
  END CardToStr;


(*--------------------------------------------------------------*)
(* PROCEDURE StrToCard -- convert 'string' to a CARDINAL.       *)
(*--------------------------------------------------------------*)
  PROCEDURE StrToCard(str: ARRAY OF CHAR; VAR card: CARDINAL): BOOLEAN;
  BEGIN
    RETURN StrToNum(str, decimalBase, card);
  END StrToCard;


(*--------------------------------------------------------------*)
(* PROCEDURE HexToStr -- convert a 2-byte values hex repre-	*)
(* sentation to a string. No Base Indicator ('H') is appended.	*)
(*--------------------------------------------------------------*)
  PROCEDURE HexToStr(hex: WORD; VAR str: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    RETURN NumToStr(CARDINAL(hex), hexBase, str);
  END HexToStr;


(*--------------------------------------------------------------*)
(* PROCEDURE StrToHex -- convert 'string' that contains a hex   *)
(* number into a 2 byte value.					*)
(*--------------------------------------------------------------*)
  PROCEDURE StrToHex(str: ARRAY OF CHAR; VAR hex: WORD): BOOLEAN;
  VAR
    i: CARDINAL;
  BEGIN
    IF StrToNum(str, hexBase, i) THEN
      hex := WORD(i);
      RETURN TRUE;
    END;
    RETURN FALSE;
  END StrToHex;

END Conversions.
