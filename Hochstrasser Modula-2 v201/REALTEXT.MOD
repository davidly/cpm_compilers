(***************************************************************************)
(*                                                                         *)
(*                    IMPLEMENTATION MODULE RealTexts			   *)
(*                                                                         *)
(*                                                                         *)
(*                    Modula-2 Standard Library Module			   *)
(*                                                                         *)
(*                                for the				   *)
(*                                                                         *)
(*                     Modula-2 System for Z80 / CP/M 			   *)
(*                                                                         *)
(*                                   by					   *)
(*                                                                         *)
(*                       Hochstrasser Computing AG			   *)
(*                           Leonhardshalde 21				   *)
(*                              8001 Zuerich				   *)
(*                              Switzerland				   *)
(*                                                                         *)
(*                                                                         *)
(*                                                                         *)
(*                                                                         *)
(* created	Mar - 26 - 1985 pwh                                        *)
(* updated	Mar - 27 - 1985 pwh                                        *)
(***************************************************************************)
IMPLEMENTATION MODULE RealTexts;
 

  FROM Texts IMPORT
	TEXT, TextState,
        TextStatus,
	ReadMode, Mode,
  	ReadLn, WriteString;

  FROM ConvertReal IMPORT
	RealToStr, StrToReal;


  PROCEDURE ReadReal(VAR t: TEXT; VAR r: REAL);
  VAR
    s: ARRAY [0..20] OF CHAR;
    ok: BOOLEAN;
  BEGIN
    Mode(Real);
    ReadLn(t, s);
    IF TextStatus(t) = TextOK THEN
      StrToReal(s,r,ok);
    END;
    Mode(Line);
  END ReadReal;


  PROCEDURE WriteReal(VAR t: TEXT; x:REAL; n: CARDINAL; digits: INTEGER);
  VAR
    s: ARRAY [0..40] OF CHAR;
    ok: BOOLEAN;
  BEGIN
    RealToStr(x, n, digits, s, ok);
    IF ok THEN WriteString(t, s); END;
  END WriteReal;

END RealTexts.

 
