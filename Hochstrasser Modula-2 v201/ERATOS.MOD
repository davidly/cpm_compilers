MODULE ERATOS;

  FROM TERM1 IMPORT 
    WriteString, WriteCard, WriteLn;

  CONST
    Size = 8192;		(* size of array *)
    Iterations = 10;		(* minimum 1 *)

  VAR
    count, i, iter, k, prime: CARDINAL;
    flags: ARRAY[0..Size-1] OF BOOLEAN;

BEGIN
  WriteString('10 Iterations'); WriteLn;
  FOR iter := 1 TO Iterations DO
    count := 0;
    FOR i := 0 TO Size DO flags[i] := TRUE; END;
    FOR i := 0 TO Size DO
      IF flags[i] THEN
        prime := i * 2 + 3;
        k := i + prime;
        WHILE k <= Size DO
          flags[k] := FALSE;
          INC(k, prime);
        END;
        INC(count);
      END;
    END; (* FOR *)
  END; (* FOR *)
  WriteString('There were ');
  WriteCard(count, 0); WriteString(' primes');
END ERATOS.
