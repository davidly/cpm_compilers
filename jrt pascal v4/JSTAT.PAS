(*  JSTAT ver 4.0	JRT Systems		*)
(*						*)
(* jstat computes several basic statistics on	*)
(* an input array.				*)
(*						*)
(* parameters:					*)
(*	n - the number of data items in the	*)
(*		input array			*)
(*	x - the input array of real numbers,	*)
(*		may be up to 1000 elements,	*)
(*		actual variable in calling pgm	*)
(*		may be much smaller array	*)
(*	r - the computed statistics are stored	*)
(*		in this record			*)


EXTERN

TYPE
jstat_interface = RECORD
       mean, standard_deviation, variance, skewness, kurtosis, m1, 
              m2, m3, m4 : real;
       END;
jstat_array =  ARRAY [1..1000] OF real;


{=================================================================}
PROCEDURE jstat (n : integer; VAR x : jstat_array; VAR r : jstat_interface);
       
VAR
i : integer;
total_x, total_x2, total_x3, total_x4 : real;


{=================================================================}
FUNCTION cube (x : real) : real;

BEGIN
cube := x * sqr(x);
END;


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
END;  (* sqrt *)


{=================================================================}
PROCEDURE totals;
VAR
i : integer;
tx, tx2, tx3, tx4 : real;
sum_x, mean : real;

BEGIN  (* totals *)

total_x := 0;
total_x2 := 0;
total_x3 := 0;
total_x4 := 0;
sum_x := 0;
FOR i := 1 TO n DO
       sum_x := sum_x + x[i];
mean := sum_x / n;
r.mean := mean;
FOR i := 1 TO n DO
       BEGIN
       tx := x[i] - mean;
       tx2 := sqr(tx);
       tx3 := tx * tx2;
       tx4 := tx * tx3;
       total_x := total_x + tx;
       total_x2 := total_x2 + tx2;
       total_x3 := total_x3 + tx3;
       total_x4 := total_x4 + tx4;
       END;
END;  (* totals *)

BEGIN  (* jstat *)

totals;
r.m1 := total_x / n;
r.m2 := total_x2 / n;
r.m3 := total_x3 / n;
r.m4 := total_x4 / n;

r.standard_deviation := sqrt(r.m2);
r.variance := r.m2;
r.kurtosis := r.m4 / sqr(r.m2);
r.skewness := r.m3 / sqrt(cube(r.m2));
END;  (* jstat *)  .
