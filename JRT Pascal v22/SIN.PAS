extern
function sin ( x : real ): real;
 
const
pi = 3.1415926535897;
two_pi = 6.2831853071796;
 
var
i : integer;
 
procedure compute_sin;
var
result,result2,f,exclam,x2,power : real;
odd1,i : integer;
 
 
begin (* compute_sin *)
x2:=sqr(x);
power:=x*x2;
odd1:=-1;
i:=0;
result:=x;
exclam:=6.0;
f:=3.0;
 
repeat
  result2:=result;
  if odd1 = 1 then
	result := result + (power/exclam)
  else
	result := result - (power/exclam);
  power:=power*x2;
  odd1:=-odd1;
f:=f+2.0;
exclam := f * (f-1.0) * exclam;
  i:=i+1;
  if i > 5 then
    begin
    i:=0;
    if abs(result-result2) < (1e-12*result) then
      result2:=result;
    end;
until result = result2;
 
sin:=result;
end; (* compute_sin *)
 
begin (* sin *)
if (x=0.0) or (x=pi) or (x=two_pi) then sin:=0.0 else
begin
while x < 0.0 do x:=x+two_pi;
while x > two_pi do x:=x-two_pi;
 
if x > 1.0e-08 then compute_sin
else sin := x;
 
end; (* else *)
end; (* sin *).
