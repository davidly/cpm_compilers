
EXTERN


{=================================================================}
FUNCTION cos (x : real) : real;
CONST
half_pi = 1.5707963267948;
pi = 3.1415926535897;
two_pi = 6.2831853071796;
VAR
i : integer;


{=================================================================}
PROCEDURE compute_cos;
VAR
result, result2, f, exclam, x2, power, odd1 : real;
i : integer;


{=================================================================}
PROCEDURE factorial;

BEGIN
f := f + 2.0;
exclam := exclam * (f - 1.0) * f;
END;

BEGIN  (* compute_cos *)

x2 := sqr(x);
power := x * x2;
odd1 :=  - 1.0;
i := 0;
result := x;
exclam := 6.0;
f := 3.0;
REPEAT
       result2 := result;
       result := result + odd1 * (power / exclam);
       power := power * x2;
       odd1 :=  - odd1;
       factorial;
       i := i + 1;
       IF i > 5 THEN
              BEGIN
              i := 0;
              IF abs(result - result2) < (1e-12 * result) THEN
                     result2 := result;
              END;
UNTIL result = result2;
cos := result;
END;  (* compute_cos *)

BEGIN  (* cos *)

IF x = 0.0 THEN
       cos := 1.0
ELSE
       BEGIN  (* else_1 *)
       
       x := x + half_pi;
       IF (x = 0.0) OR (x = pi) OR (x = two_pi) THEN
              cos := 0.0
       ELSE
              BEGIN
              WHILE x < 0.0 DO
                     x := x + two_pi;
              WHILE x > two_pi DO
                     x := x - two_pi;
              compute_cos;
              END;  (* else *)
       END;  (* else_1 *)
END;  (* cos *)  .
