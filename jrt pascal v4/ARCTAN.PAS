
EXTERN


{=================================================================}
FUNCTION arctan (x : real) : real;
CONST
half_pi = 1.5707963267948;
sixth_pi = 0.52359877559828;
twelfth_pi = 0.26179938779914;
sqrt3 = 1.7320508075689;
VAR
flag2, flag3, i : integer;
result : real;
sign : char;


{=================================================================}
PROCEDURE compute;
VAR
flip, power, x2, odd1, result2 : real;
i, j : integer;

BEGIN  (* compute *)

flip := 1.0;
power := x;
x2 := sqr(power);
odd1 := 1.0;
j := 0;
i := 0;
result := 0.0;
REPEAT
       result2 := result;
       result := result + flip * (power / odd1);
       odd1 := odd1 + 2.0;
       flip :=  - flip;
       power := power * x2;
       j := j + 1;
       i := i + 1;
       IF i > 5 THEN
              BEGIN
              i := 0;
              IF abs(result - result2) < (1e-12 * result) THEN
                     result2 := result;
              END;
UNTIL result = result2;
END;  (* compute *)

BEGIN  (* arctan *)

IF x = 0.0 THEN
       arctan := 0.0
ELSE
       BEGIN
       IF x < 0.0 THEN
              BEGIN
              x :=  - x;
              sign := '-'
              END
       ELSE
              sign := '+';
       IF x > 1.0 THEN
              BEGIN
              x := 1.0 / x;
              flag2 := 1;
              END
       ELSE
              flag2 := 0;
       IF x > twelfth_pi THEN
              BEGIN
              x := (sqrt3 * x - 1.0) / (x + sqrt3);
              flag3 := 1;
              END
       ELSE
              flag3 := 0;
       IF (abs(x) <= 1.0e-08) THEN
              result := x
       ELSE
              compute;
       IF flag3 = 1 THEN
              result := result + sixth_pi;
       IF flag2 = 1 THEN
              result := half_pi - result;
       IF sign = '-' THEN
              arctan :=  - result
       ELSE
              arctan := result;
       END;  (* else *)
END;  (* arctan *)  .
