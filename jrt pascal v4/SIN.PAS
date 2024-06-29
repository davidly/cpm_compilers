
EXTERN


{=================================================================}
FUNCTION sin (x : real) : real;
CONST
pi = 3.1415926535897;
two_pi = 6.2831853071796;
VAR
i : integer;


{=================================================================}
PROCEDURE compute_sin;
VAR
result, result2, f, exclam, x2, power : real;
odd1, i : integer;

BEGIN  (* compute_sin *)

x2 := sqr(x);
power := x * x2;
odd1 :=  - 1;
i := 0;
result := x;
exclam := 6.0;
f := 3.0;
REPEAT
       result2 := result;
       IF odd1 = 1 THEN
              result := result + (power / exclam)
       ELSE
              result := result - (power / exclam);
       power := power * x2;
       odd1 :=  - odd1;
       f := f + 2.0;
       exclam := f * (f - 1.0) * exclam;
       i := i + 1;
       IF i > 5 THEN
              BEGIN
              i := 0;
              IF abs(result - result2) < (1e-12 * result) THEN
                     result2 := result;
              END;
UNTIL result = result2;
sin := result;
END;  (* compute_sin *)

BEGIN  (* sin *)

IF (x = 0.0) OR (x = pi) OR (x = two_pi) THEN
       sin := 0.0
ELSE
       BEGIN
       WHILE x < 0.0 DO
              x := x + two_pi;
       WHILE x > two_pi DO
              x := x - two_pi;
       IF x > 1.0e-08 THEN
              compute_sin
       ELSE
              sin := x;
       END;  (* else *)
END;  (* sin *)  .
