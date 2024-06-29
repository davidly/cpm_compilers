(***************************************************************************)
(*                                                                         *)
(*                    IMPLEMENTATION MODULE RealInOut                      *)
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
(*      created: Jan -  2 - 1985 pwh                                       *)
(* last updated: Jan -  2 - 1985 pwh                                       *)
(***************************************************************************)
IMPLEMENTATION MODULE RealInOut;


  FROM Strings IMPORT
	STRING;

  FROM InOut IMPORT
	ReadString, WriteString;
  IMPORT InOut (* .Done *);

  FROM ConvertReal IMPORT
	RealToStr, StrToReal;


  CONST 
    ScientificNotation = -1;


  PROCEDURE ReadReal(VAR x: REAL);
  VAR
    s: STRING;
  BEGIN
    Done := FALSE;
    ReadString(s);
    IF InOut.Done THEN
      StrToReal(s,x,Done);
    END;
  END ReadReal;


  PROCEDURE WriteReal(x:REAL; n: CARDINAL);
  VAR
    s: STRING;
  BEGIN
    RealToStr(x, n, ScientificNotation, s, Done);
    IF Done THEN WriteString(s); END;
  END WriteReal;

END RealInOut.
