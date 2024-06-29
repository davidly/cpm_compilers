
EXTERN


{=================================================================}
FUNCTION exp (x : real) : real;
CONST
factor2 = 0.50000000000000e+00;
factor3 = 0.16666666666667e+00;
factor4 = 0.41666666666667e-01;
factor5 = 0.83333333333333e-02;
factor6 = 0.13888888888889e-02;
factor7 = 0.19841269841270e-03;
factor8 = 0.24801587301587e-04;
factor9 = 0.27557319223986e-05;
factor10 = 0.27557319223986e-06;
factor11 = 0.25052108385442e-07;
factor12 = 0.20876756987868e-08;
factor13 = 0.16059043836822e-09;
factor14 = 0.11470745597730e-10;
factor15 = 0.76471637318198e-12;
factor16 = 0.47794773323874e-13;
factor17 = 0.28114572543455e-14;
factor18 = 0.15619206968586e-15;
factor19 = 0.82206352466245e-17;
factor20 = 0.41103176233122e-18;
factor21 = 0.19572941063392e-19;
TYPE
str =  ARRAY [1..22] OF char;

VAR
result, xa : real;
p :  ARRAY [1..21] OF real;
count, i, j : integer;
sign : char;

BEGIN  (* exp *)

IF x > 145.0 THEN
       exp := 0.99999999999999e+63
ELSE
       IF x <  - 145.0 THEN
              exp := 0.0
       ELSE
              BEGIN
              IF x < 0.0 THEN
                     BEGIN
                     sign := '-';
                     x :=  - x;
                     END
              ELSE
                     sign := '+';
                (* compute exp(x) for 0<x<1.5 *)
              
              count := 0;
              IF x > 1.5 THEN
                     IF x < 6.0 THEN
                            BEGIN
                            count := 1;
                            x := x / 4
                            END
                     ELSE
                            IF x < 24.0 THEN
                                   BEGIN
                                   count := 2;
                                   x := x / 16
                                   END
                            ELSE
                                   IF x < 96.0 THEN
                                          BEGIN
                                          count := 3;
                                          x := x / 64
                                          END
                                   ELSE
                                          BEGIN
                                          count := 4;
                                          x := x / 256.0
                                          END;
              IF x < 0.007 THEN
                     result := x + 1.0
              ELSE
                     BEGIN
                     xa := x;
                     FOR i := 1 TO 21 DO
                            BEGIN
                            p[i] := xa;
                            xa := xa * x;
                            END;
                     result := 1 + x + (p[2] * factor2) + (p[3] * 
                            factor3) + (p[4] * factor4) + (p[5] * 
                            factor5) + (p[6] * factor6) + (p[7] * 
                            factor7) + (p[8] * factor8) + (p[9] * 
                            factor9) + (p[10] * factor10) + (p[11] * 
                            factor11) + (p[12] * factor12) + (p[13] * 
                            factor13) + (p[14] * factor14) + (p[15] * 
                            factor15) + (p[16] * factor16) + (p[17] * 
                            factor17) + (p[18] * factor18);
                     END;  (* else *)
              
              FOR i := 1 TO count DO
                     result := sqr(sqr(result));
              IF sign = '-' THEN
                     exp := 1.0 / result
              ELSE
                     exp := result;
              END;  (* else *)
END;  (* exp *)  .
