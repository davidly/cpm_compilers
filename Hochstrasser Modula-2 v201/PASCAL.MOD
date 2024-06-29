MODULE Pascal;		(* print a Pascal triangle *)

  FROM TERM1 IMPORT
	Write, WriteCard, WriteLn, WriteString;

CONST
  n = 13;

VAR
  i, j, k: INTEGER;
  a:       ARRAY[1..n] OF INTEGER;
BEGIN
  WriteString('             Pascal Triangle with 13 levels'); WriteLn;  
  WriteString('             ------------------------------'); WriteLn;
  WriteLn;
  FOR i := 1 TO n DO
    a[i] := 1;
    FOR j := i-1 TO 2 BY -1 DO
      a[j] := a[j-1] + a[j];
    END;
    FOR k := 0 TO 2 * (n - i) DO Write(' '); END;
    FOR j := 1 TO i DO WriteCard( a[j], 4 ); END;
    WriteLn;
  END;
END Pascal.
