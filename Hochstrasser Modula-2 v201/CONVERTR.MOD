(***************************************************************************)
(*                                                                         *)
(*                    IMPLEMENTATION MODULE ConvertReal			   *)
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
(*                                                                         *)
(*                                                                         *)
(*      created: Dec - 14 - 1984 pwh                                       *)
(* last updated: Jan -  3 - 1985 pwh                                       *)
(***************************************************************************)
IMPLEMENTATION MODULE ConvertReal;
 

  FROM Strings IMPORT
	STRING, Assign;


  CONST 
    SignificantDigits   = 7;
    MaxExp 		=  39;
    MinExp		= -38;
    MaxMantissa		= 1701411.8;

  TYPE
    Real = RECORD
	     CASE BOOLEAN OF
	       TRUE:  r: REAL;
	     | FALSE: h,l: CARDINAL;
	     END;
	   END;



  VAR
    temp  : REAL;
    frac  : REAL;
    pot   : ARRAY [0..5] OF REAL; 		     (* c1[i] = 10^(2^i) *)
    digits,
    exp,
    fracexp,
    totexp: INTEGER;
    sign  : BOOLEAN;
    periodSeen: BOOLEAN;
    s     : STRING;
    i     : CARDINAL;		(* index into number string *)
    ch    : CHAR;		(* currently processed char *)
    scra  : REAL;		(* scratch Mantissa for Number procedure *)
  

PROCEDURE RealValue(hi, low: CARDINAL): REAL;
VAR
  r: Real;
BEGIN
  r.h := hi;
  r.l := low;
  RETURN r.r;
END RealValue;


(*--------------------------------------------------------------*)
(* PROCEDURE TenTo -- generate powers of ten. This procedure 	*)
(* accepts arguments in the range -38 <= i <= 38.		*)
(*--------------------------------------------------------------*)
  PROCEDURE TenTo(e: INTEGER): REAL;
  VAR
    result: REAL;
    i: CARDINAL;
    neg: BOOLEAN;
  BEGIN
    IF e < -38 THEN RETURN 0.0; END;
    result := 1.0;		(* 10^0 *)
    i := 0;    
    neg := e < 0;
    e := ABS(e);
    WHILE e > 0 DO
      IF ODD(e) THEN 
	result := result * pot[i]; 
      END;
      INC(i);
      e := e DIV 2;
    END;
    IF neg THEN
      result := 1.0 / result;
    END;
    RETURN result;
  END TenTo;


  PROCEDURE GetCh;
  BEGIN
    ch := s[i];
    i := i + 1;
  END GetCh;


  PROCEDURE Digit(): BOOLEAN;
  BEGIN
    RETURN (ch >= '0') & ('9' >= ch);
  END Digit;


  PROCEDURE Sign;	(* set sign of number to follow *) 
  BEGIN
     IF (ch = '+') OR (ch = '-') THEN
      sign := ch = '-';
      GetCh;
    ELSE
      sign := FALSE;
    END;
  END Sign;


(*--------------------------------------------------------------*)
(* PROCEDURE Mantissa -- scan and convert the mantissa of a     *)
(* REAL number string. EBNF:					*)
(* Mantissa = ['+'|'-'] Number ['.']  Number.			*)
(* Number   = {Digit}.						*)
(* Digit    = '0' | .. | '9'.					*)
(*--------------------------------------------------------------*)

  PROCEDURE Mantissa;
  BEGIN
    digits := 0;
    fracexp := 0;
    scra := 0.0;
    temp  := 1.0;
    frac := 0.0;
    periodSeen := FALSE;

    GetCh;
    Sign;
  
    REPEAT
      IF ch = '.' THEN periodSeen := TRUE;
      ELSE
        IF (digits = 0) & (ch = '0') THEN 	     (* skip leading zeroes *)
          IF periodSeen THEN fracexp := fracexp - 1; END; 
        ELSIF Digit() THEN
	  IF (digits < SignificantDigits) THEN 
            frac := frac * 10.0 + FLOAT(ORD(ch) - ORD('0'));
	    IF periodSeen THEN fracexp := fracexp - 1; END;
	    digits := digits + 1;
          ELSE
	    temp := temp / 10.0;
  	    frac := frac + FLOAT(ORD(ch) - ORD('0')) * temp;
	    IF NOT periodSeen THEN fracexp := fracexp + 1; END;
          END;
	END;	
      END;
      GetCh;
    UNTIL (NOT Digit()) & (ch # '.');
    IF sign THEN frac := -frac; END;		(* sign treatment *)
  END Mantissa;


  PROCEDURE Exponent;
  BEGIN
    exp := 0;
    IF CAP(ch) = 'E' THEN
      GetCh;
      Sign;
      WHILE Digit() DO
	exp := exp * 10 + INTEGER(ORD(ch) - ORD('0'));
        GetCh;
      END;
      IF sign THEN exp := -exp; END;
    END; 
  END Exponent;

  
  PROCEDURE StrToReal(    str : ARRAY OF CHAR; 
		      VAR real: REAL; 
		      VAR ok  : BOOLEAN);
  BEGIN
    ok := TRUE;
    Assign(str,s);
    i := 0;
    Mantissa;				(* -> frac, fracexp, digits *)
    Exponent;				(* -> exp	    	    *)
    exp := exp + fracexp;
    totexp := exp + digits;

    IF (totexp > MaxExp) OR (ch > ' ') THEN 
      ok := FALSE; 
      RETURN;
    ELSIF totexp = MaxExp THEN		(* compare fract with maximum *)
      IF frac * TenTo(SignificantDigits - digits) >= MaxMantissa THEN
	ok := FALSE;
  	RETURN;				(* overflow *)
      END;
    ELSIF totexp < MinExp THEN
      real := 0.0; 
      RETURN;
    END;
    IF exp > 0 THEN 
      real := frac * TenTo(exp);
    ELSIF exp < 0 THEN 
      IF exp < MinExp+1 THEN
	frac := frac / TenTo(MinExp + 1 - exp);
  	exp := MinExp + 1;
      END;
      real := frac / TenTo(-exp);
    ELSE
      real := frac;
    END;
    ok := ok & (i > 1);
  END StrToReal;


  PROCEDURE RealToStr(real       : REAL;
		      width      : CARDINAL; (* width of field in chars *)
		      decPlaces  : INTEGER;  (* neg  --> exp. notation *)
					     (* zero --> no dec point  *)
                      VAR str	   : ARRAY OF CHAR;
		      VAR success : BOOLEAN);

  CONST
    ExpDigits = 2;					(* 00..39   *)
    ExtraChars = 3;					(* '.E+'    *)
    MinScientificWidth = ExpDigits + ExtraChars + 1;	(* '0.E+00' *)
    MinDecimalWidth    = 4;				(* '-0.0'   *)
    MinIntegerWidth    = 1;				(*  '0'	    *)
  VAR 
    i: CARDINAL;

  PROCEDURE Put(ch: CHAR);
  BEGIN
    s[i] := ch;
    i := i + 1;
  END Put;


  PROCEDURE PutDigit(n: CARDINAL);
  BEGIN
    Put(CHR(n + ORD('0')));
  END PutDigit;


  PROCEDURE OutputSize(r: REAL): INTEGER;
  VAR
    i: INTEGER;
  BEGIN
    r := ABS(r);
    IF r < 1.0 THEN
      i := MinExp;
      WHILE (i < 0) & (TenTo(i) <= r) DO INC(i); END;
    ELSE
      i := 0;
      WHILE (i < MaxExp) & (TenTo(i) <= r) DO INC(i); END;
    END;
    RETURN i;
  END OutputSize;


(*--------------------------------------------------------------*)
(* PROCEDURE ScientificNotation -- convert REAL 'r' to		*)
(* scientific format, i.e. 					*)
(* REAL = ['-'] Digit '.' {Digit} E ('+'|'-') Digit Digit.      *)
(* The string has 'width' characters.				*)
(*--------------------------------------------------------------*)
  PROCEDURE ScientificNotation((* convert *) 	    r: REAL; 
			       (* using   *)    width: CARDINAL;
			       (* if      *) VAR done: BOOLEAN );
  VAR
    i		: CARDINAL;
    outputReal	: REAL;
    exp		: INTEGER;
    fracDigits	: CARDINAL;
    divider	: INTEGER;

    PROCEDURE PutOneDigit;
    VAR
      digit: CARDINAL;
    BEGIN
      digit := TRUNC(outputReal);
      PutDigit(digit);
      outputReal := (outputReal - FLOAT(digit)) * 10.0;
    END PutOneDigit;

  BEGIN
    done := (width >= MinScientificWidth + 1) OR
	    (width = MinScientificWidth) & (r >= 0.0); 
    IF done THEN
      fracDigits := width - MinScientificWidth - ORD(r < 0.0); (* sign *)
      FOR i := SignificantDigits + 1 TO fracDigits DO Put(' '); END;
      IF fracDigits > SignificantDigits THEN
	fracDigits := SignificantDigits;
      END;
      IF r = 0.0 THEN
	outputReal := 0.0;
	exp	 := 0;
      ELSE
	exp	 := OutputSize(r) - 1;
	IF exp < -38 THEN		(* prevent REAL overflow on 1E-38 *)
	  outputReal := ABS(r) * TenTo(38) * TenTo(ABS(exp) - 38);
	ELSE
	  outputReal := ABS(r) / TenTo(exp);
	END;
	outputReal := outputReal + 0.5 * TenTo(-INTEGER(fracDigits));

	IF outputReal >= 10.0 THEN
	  outputReal := outputReal / 10.0;
 	  INC(exp); 
	END;
      END;

      IF r < 0.0 THEN Put('-'); END;
      PutOneDigit;
      Put('.');      
      FOR i := 1 TO fracDigits DO PutOneDigit; END;
      
      Put('E');
      IF exp < 0 THEN Put('-'); exp := ABS(exp); ELSE Put('+'); END;
      PutDigit(exp DIV 10);
      PutDigit(exp MOD 10);
    END;
  END ScientificNotation;


  PROCEDURE DecimalNotation((* convert *)	   r: REAL; 
			    (* using   *)      width: CARDINAL;
			    (* and     *)  decPlaces: INTEGER;
			    (* if      *)  VAR  done: BOOLEAN  );
  VAR
    outputReal   : REAL;
    minNumChars: CARDINAL;
    intDigits  : CARDINAL;
    divider    : INTEGER;
    i          : CARDINAL;
    
    PROCEDURE ConvertNDigits(n: CARDINAL; VAR num: REAL);
    VAR
      i, digit : CARDINAL;
      div      : REAL;
    BEGIN
      FOR i := 1 TO n DO
        div := TenTo(divider);
        digit := TRUNC(num / div);
        PutDigit(digit);
        num := num - FLOAT(digit) * div;
        DEC(divider);
      END;
    END ConvertNDigits;

  BEGIN
    IF r = 0.0 THEN
      outputReal := 0.0;
    ELSE
      outputReal := ABS(r) + 0.5 * TenTo(-decPlaces);
    END;
    IF TRUNC(outputReal) = 0 THEN (* (0.0 <= r < 1.0) --> leading '0.' *)
      intDigits := 1;
    ELSE
      intDigits := OutputSize(outputReal);
    END;

    minNumChars := intDigits + ORD(decPlaces) + 
		   ORD(decPlaces # 0) + ORD(r < 0.0);
		      (* '.' set *)	  (* '-' set *)

    done := (width >= minNumChars) & 
	    ((minNumChars >= MinDecimalWidth) OR
	    (decPlaces = 0) & (minNumChars >= MinIntegerWidth));

    IF done THEN
      FOR i := 1 TO width - minNumChars DO Put(' '); END;
      IF r < 0.0 THEN Put('-'); END;
      divider := intDigits - 1;
      ConvertNDigits(intDigits, outputReal);
      IF decPlaces > 0 THEN
        Put('.');
        ConvertNDigits(decPlaces, outputReal);
      END;
    END;

  END DecimalNotation;


  BEGIN
    s := '';		(* default value *)
    i := 0;		(* string index  *)
    IF width > HIGH(str) THEN
      success := FALSE;
      RETURN;
    END;
    IF decPlaces < 0 THEN
      ScientificNotation(real, width, success);
    ELSE
      DecimalNotation(real, width, decPlaces, success);
    END;
    Assign(s,str);
  END RealToStr;


BEGIN
  pot[0] := RealValue(02042H, 00000H); (* 10^1  *)
  pot[1] := RealValue(0C843H, 00000H); (* 10^2  *)	(* to have "exact" *)
  pot[2] := RealValue(01C47H, 00040H); (* 10^4  *)	(* values for the  *)
  pot[3] := RealValue(0BE4DH, 00050H); (* 10^8  *)	(* powers          *)
  pot[4] := RealValue(00E5BH, 0C91BH); (* 10^16 *)
  pot[5] := RealValue(09D75H, 0AEC5H); (* 10^32 *)
END ConvertReal.
