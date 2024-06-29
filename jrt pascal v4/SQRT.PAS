
EXTERN


{=================================================================}
FUNCTION sqrt (x : real) : real;
VAR
sq, a, b : real;
exponent, i : integer;
zap : RECORD
       
       CASE integer OF
       0 : (num : real);
       1 : (ch8 :  ARRAY [1..8] OF char);
       END;

BEGIN
IF x = 0.0 THEN
       sqrt := 0.0
ELSE
       BEGIN
       sq := abs(x);
       zap.num := sq;
       exponent := ord(zap.ch8[1]);
       exponent := (exponent DIV 2) + 32;
       zap.ch8[1] := chr(exponent);
       a := zap.num;
       b := 0;
       i := 0;
       WHILE a <> b DO
              BEGIN
              b := sq / a;
              a := (a + b) / 2;
              i := i + 1;
              IF i > 4 THEN
                     BEGIN
                     i := 0;
                     IF abs(a - b) < (1.0e-12 * a) THEN
                            a := b;
                     END;
              END;
       sqrt := a;
       END;  (* else *)
END;  (* sqrt *)  .
