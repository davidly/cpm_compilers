(*********************************************************************)
(*                  The Sieve Benchmark                              *)
(*                                                                   *)
(*  Compile with test, overflow switches off and native code on.     *)
(*                                                                   *)
(*********************************************************************)
MODULE sieve;

import terminal;
import inout;

CONST
  size = 8190;

VAR
  flags : ARRAY [ 0 .. size ] OF BOOLEAN;
  i, prime, k, count, iter : integer;

BEGIN
  terminal.writestring( '10 iterations$' );
  terminal.writeln;

  FOR iter := 1 TO 10 DO
    count := 0;
    FOR i := 0 TO size DO flags[i] := TRUE END;
    FOR i := 0 TO size DO
      IF flags[i] THEN
        prime := i + i + 3;
        k := i + prime;
        WHILE k <= size DO
          flags[k] := FALSE;
          k := k + prime;
        END;
        count := count + 1;
      END;
    END;
  END;

  inout.writeint( count, 6 );
  terminal.writestring( ' primes$' );
  terminal.writeln;
END sieve.
