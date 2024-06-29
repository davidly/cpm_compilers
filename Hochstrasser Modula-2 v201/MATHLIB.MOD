(***************************************************************************)
(*                                                                         *)
(*                      IMPLEMENTATION MODULE MathLib			   *)
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
(* created	Dec - 11 - 1984 pwh                                        *)
(* updated	Apr -  2 - 1984 pwh                                        *)
(***************************************************************************)
IMPLEMENTATION MODULE MathLib;


  FROM Terminal IMPORT
	WriteLn, WriteString;

  FROM Strings IMPORT
	STRING;

  FROM ConvertReal IMPORT
	RealToStr;

  FROM MODLIB IMPORT
	SQRT;			(* fast assembly language square root *)


  CONST
    HalfPi	    = 1.57079632675;		(* pi / 2      *)
    QuarterPi	    = 0.7853981634;		(* p1 / 4      *)
    TwoDivPi	    = 0.6366197724;		(* 2 / pi      *)

    LnTwo	    = 0.6931471806;
    DivLn2	    = 1.442695041;		(* 1/ln(2)     *)

    SqrtTwo	    = 1.414213562;		(* sqrt(2)     *)
    SqrtTwoPlusOne  = 2.414213562;		(* sqrt(2) + 1 *)
    SqrtTwoMinusOne = 0.414213562;		(* sqrt(2) - 1 *)


(* because of the used hidden bit format, the following applies:

	- numbers are between 2^-128 and 2^127.
	- calculation precision is 7 digits. Watch for digit erasure, though!
	
	- relational operations use about  200.. 400 clock cycles.
        - addition operations    "    "   1100..1900   "     "   .
	- multiplications        "    "   3000         "     "   .
        - divisions	         "    "   4000	       "     "   .
	- square roots	         "    "   6200	       "     "   .

*)


  TYPE
    Real = RECORD
	     CASE BOOLEAN OF
	       TRUE : R: REAL;
	     | FALSE: H,L: CARDINAL;
	     END;
	   END;   	


  PROCEDURE Assert(condition: BOOLEAN; msg: ARRAY OF CHAR);
  BEGIN
    IF NOT condition THEN
      WriteLn;
      WriteString('---- ');
      WriteString(msg);
      HALT;
    END;
  END Assert;


  PROCEDURE GetExponent(r: REAL): INTEGER;
  VAR
    x: Real;
  BEGIN
    x.R := r;		(* hi bit of low byte is mantissa-sign *)
			(* low bit of hi byte is low bit of exponent *)
    RETURN INTEGER(((x.H MOD 80H) * 2 + x.H DIV 8000H) - 80H);
  END GetExponent;


  PROCEDURE SetExponent(exp: INTEGER; VAR r: REAL);
  VAR
    x: Real;
    s: BITSET;
  BEGIN  
    x.R := r;
    s := {};
    exp := exp + 128;
    IF ODD(exp) THEN s := {15}; END;
    s := s + BITSET(exp DIV 2);
    x.H := CARDINAL((BITSET(x.H) * {7..14}) + s); (* bits 7..14 are non-exponent *)
    r := x.R;
  END SetExponent;


  PROCEDURE sqrt(x: REAL): REAL;
  BEGIN
    RETURN SQRT(x);
  END sqrt;


  PROCEDURE exp(x: REAL): REAL;
  VAR 
    x2, y: REAL;
    n: INTEGER;
  BEGIN		(* e^89 > MAX(REAL) > e^88 *)
    Assert(x < 88.02969, "arg of exp too large");
    x := x * DivLn2;		(* x := x / ln(2) *)
    n := entier((x + 0.5));
    x := x - real(n);
    IF n < -128 THEN RETURN 0.0; END;
    x2 := x * x;
    y := (7.2150468 + 0.057699579 * x2) * x;
    x := y / (20.818221 + x2 - y) + 0.5;
    SetExponent( n + GetExponent(x) + 1, x);
    RETURN x
  END exp;


  PROCEDURE ln(x: REAL): REAL;
  VAR
    n: INTEGER;
  BEGIN
    Assert(x > 0.0, "log with neg arg");
    n := GetExponent(x);
    SetExponent(0, x);
    x := SqrtTwo * x; 
    x := (x - 1.0)/ (x + 1.0);
    RETURN LnTwo * (real(n) - 0.5) + 
	   x * (0.89554059 + 1.8298441 / (1.6567778 - x * x));
  END ln;


  PROCEDURE sin(x: REAL): REAL;
  VAR
    x2, y	: REAL;
    n		: INTEGER;
  BEGIN
    x := TwoDivPi * x;		(* normalize to period 0..2 instead of *)
    n := entier((x + 0.5));	(* 0..Pi *)
    x := (x - real(n)) * 2.0;	
    x2 := x * x;
    IF ODD(n) THEN
      y := (47.68728 + x2 * (-13.707995 + x2 * 0.44782233)) /
		(47.68728 + x2);
    ELSE
      y := x * (52.818590 + x2 * (-4.6447998 + x2 * 0.086754506)) /
		(67.250728 + x2);
    END;
    IF ODD(CARDINAL(n) DIV 2) THEN 
      RETURN -y;
    END;
    RETURN y;
  END sin;


  PROCEDURE cos(x: REAL): REAL;
  BEGIN
    RETURN sin(HalfPi + x);
  END cos;


  PROCEDURE arctan(x: REAL): REAL;
  VAR
    s, x2, y: REAL;
  BEGIN
    y := ABS(x);
    s := 0.0;
    IF y > SqrtTwoPlusOne THEN
      y := (-1.0) / y;
      s := HalfPi;
    ELSIF y > SqrtTwoMinusOne THEN
      y := (y - 1.0) / (y + 1.0);
      s := QuarterPi;
    END;
    x2 := y * y;
    s := s + 6.3691878 * y / 
	 (x2 + 8.6014193 + (-4.4369858) / (x2 + 1.9876915));
    RETURN ABS(s);
  END arctan;


  PROCEDURE power(x, y: REAL): REAL;
  BEGIN 			    (* use x^y = e^(y * ln(x)) *)
    IF    x = 0.0 THEN RETURN 0.0;
    ELSIF y = 0.0 THEN RETURN 1.0;
    END;
    RETURN exp(y * ln(x));
  END power;


  PROCEDURE real(i: INTEGER): REAL;
  BEGIN
    IF i < 0 THEN RETURN -FLOAT(CARDINAL(ABS(i))); 
    ELSE	  RETURN  FLOAT(CARDINAL(i));
    END;
  END real;


  PROCEDURE entier(x: REAL): INTEGER;
  VAR
    y: REAL;
  BEGIN
    y := FLOAT(CARDINAL(MAX(INTEGER)));
    IF    x < -(y + 1.0) THEN RETURN MIN(INTEGER);
    ELSIF x > y          THEN RETURN MAX(INTEGER);
    ELSIF x < 0.0        THEN RETURN -INTEGER(TRUNC(ABS(x)));
    ELSE	              RETURN  INTEGER(TRUNC(x));
    END;
  END entier;


END MathLib.
