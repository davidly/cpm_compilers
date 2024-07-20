extern
function ln ( x : real ): real;
 
const
index = 16;
ln4 = 0.13862943611196e+01;
r3 = 0.33333333333333e+00;
r5 = 0.20000000000000e+00;
r7 = 0.14285714285714e+00;
r9 = 0.11111111111111e+00;
r11 = 0.90909090909091e-01;
r13 = 0.76923076923077e-01;
r15 = 0.66666666666667e-01;
r17 = 0.58823529411765e-01;
r19 = 0.52631578947368e-01;
r21 = 0.47619047619048e-01;
r23 = 0.43478260869565e-01;
r25 = 0.40000000000000e-01;
r27 = 0.37037037037037e-01;
r29 = 0.34482758620690e-01;
r31 = 0.32258064516129e-01;
 
var
div_count,i : integer;
result,term,term2 : real;
p : array [1..index] of real;
 
begin (* ln - natural logarithm *)
if x <= 0.0 then ln:= -0.99999999999999e+63
else
begin
(* x must be in range 0.7 to 2.85 *)
div_count:=0;
while x < 0.7 do
  begin
  x:=x*4;
  div_count:=div_count-1;
  end;
while x > 2.85 do
  begin
  x:=x/4;
  div_count:=div_count+1;
  end;
 
term:=(x-1.0)/(x+1.0);
term2:=sqr(term);
for i:=1 to index do
  begin
  p[i]:=term;
  term:=term*term2;
  end;
 
result:= 2 * (
	p[1]
	+(p[2] * r3)
	+(p[3] * r5)
	+(p[4] * r7)
	+(p[5] * r9)
	+(p[6] * r11)
	+(p[7] * r13)
	+(p[8] * r15)
	+(p[9] * r17)
	+(p[10] * r19)
	+(p[11] * r21)
	+(p[12] * r23)
	+(p[13] * r25)
	+(p[14] * r27)
	+(p[15] * r29)
	+(p[16] * r31)
	);
ln:=result + div_count * ln4;
end; (* else *)
 
end; (* ln *).
