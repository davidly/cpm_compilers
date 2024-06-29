(****************************************************************************)
(*									    *)
(*                              MODULE Queens				    *)
(*									    *)
(* EightQueens - Program from "Algorithms & Data Structures = Programs"     *)
(* translated to MODULA-2 for use with the MODULA-2 Compiler for Z80 CP/M   *)
(* as a benchmark program. No output is made during calculation to prevent  *)
(* slowdown by peripherals.					    	    *)
(*									    *)
(* 									    *)
(*									    *)
(*									    *)
(*									    *)
(* created	Feb - 10 - 1984 pwh					    *)
(* updated	Oct - 27 - 1984 pwh					    *)
(*		Mar - 21 - 1985 pwh -- OA    			            *)
(*									    *)
(*									    *)
(*									    *)
(*									    *)
(****************************************************************************)
MODULE Queens;


  FROM TERM1 IMPORT
	Read, Write, WriteLn, WriteCard, WriteString;

CONST
  BEL = 7C;

VAR
  i, k: INTEGER;
  solutions: CARDINAL;
  ch: CHAR;
  a: ARRAY [ 1.. 8] OF BOOLEAN;
  b: ARRAY [ 2..16] OF BOOLEAN;
  c: ARRAY [-7.. 7] OF BOOLEAN;
  x: ARRAY [ 1.. 8] OF INTEGER;


PROCEDURE Try(i: INTEGER);
VAR
  j: INTEGER;
BEGIN
  FOR j := 1 TO 8 DO

    IF a[j]  & b[i + j] & c[i - j] THEN 

      x[i] := j;
      a[j] := FALSE;
      b[i + j] := FALSE;
      c[i - j] := FALSE;

      IF i < 8 THEN Try(i + 1); ELSE INC(solutions); END;

      a[j] := TRUE;
      b[i + j] := TRUE;
      c[i - j] := TRUE;
    END;
  END; (* FOR *)
END Try;

BEGIN (* Queens *)
  WriteLn;
  WriteString('Eight Queens Problem Benchmark'); WriteLn;
  WriteString('------------------------------'); WriteLn;
  WriteLn;
  WriteString('Hit any key to start: ');
  Read(ch);
  WriteLn;
  FOR k := 1 TO 10 DO				(* do 10 iterations        *)
    FOR i :=  1 TO  8 DO a[i] := TRUE; END;	(* to reduce dependency    *)
    FOR i :=  2 TO 16 DO b[i] := TRUE; END;	(* of operator's fast      *)
    FOR i := -7 TO  7 DO c[i] := TRUE; END;	(* finger on the stopwatch *)
    solutions := 0;
    Try(1);
  END;
  Write(BEL); 
  WriteString('There were '); 
  WriteCard(solutions, 1);
  WriteString(' solutions.');
END Queens.
