(***************************************************************************)
(*                                                                         *)
(*                       IMPLEMENTATION MODULE TERM1			   *)
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
(*      created: Feb -  2 - 1984 pjk                                       *)
(* last updated: Oct - 27 - 1984 pwh                                       *)
(***************************************************************************)
IMPLEMENTATION MODULE TERM1;

  FROM OpSys IMPORT 
	Bdos;

CONST CR    =  15C;
      LF    =  12C;

VAR
  returnValue,i,k: CARDINAL;


(* returns ch=0C if no char typed at console. Char is not echoed *)
  PROCEDURE BusyRead( VAR ch: CHAR );
  BEGIN
    Bdos( 6, 255, returnValue );        (* CPM direct console io *)
    ch := CHR( returnValue );
  END BusyRead;


  PROCEDURE Read( VAR ch: CHAR );
  BEGIN
    REPEAT
      BusyRead( ch );       (* read char *)
    UNTIL ch # 0C;
  END Read;


  PROCEDURE Write( ch: CHAR );
  BEGIN
    Bdos( 2, ORD( ch ), returnValue );
  END Write;


  PROCEDURE WriteLn;
  BEGIN
    Write( CR );
    Write( LF );
  END WriteLn;


  PROCEDURE WriteString( s : ARRAY OF CHAR);
  BEGIN
    i := 0;
    WHILE ( s[i] # 0C ) & ( i <= HIGH(s)) DO
      Write( s[i] );
      i := i + 1;
    END;
  END WriteString;


  PROCEDURE WriteNum( x, n: CARDINAL );
  BEGIN
    IF x = 0 THEN                          (* write leading blanks *)
      FOR i := 1 TO n DO Write( ' ' ); END;
    ELSE
      IF n = 0 THEN n := 1; END;          (* prevent underflow *)
      WriteNum( x DIV 10, n - 1 );        (* write all higher order digits *)
      Write( CHR( x MOD 10 + ORD( '0' )));(* write this digit *)
    END;
  END WriteNum; 


  PROCEDURE WriteCard( x, n: CARDINAL );
  BEGIN
    IF x = 0 THEN                         (* process special case *)
      IF n = 0 THEN n := 1; END;          (* prevent underflow *)
      WriteNum( 0, n - 1 );               (* write leading blanks *)
      Write( '0' );                       (* write actual number *)
    ELSE
      WriteNum( x, n );                   (* normal case *)
    END;
  END WriteCard;

END TERM1.
