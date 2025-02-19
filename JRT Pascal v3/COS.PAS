extern
function cos ( x : real ): real;
 
const
half_pi = 1.5707963267948;
pi = 3.1415926535897;
two_pi = 6.2831853071796;
 
var
i : integer;
 
procedure compute_cos;
var
result,result2,f,exclam,x2,power,odd1 : real;
i : integer;
 
procedure factorial;
begin
f:=f+2.0;
exclam:=exclam * (f-1.0) * f;
end;
 
begin (* compute_cos *)
x2:=sqr(x);
power:=x*x2;
odd1:=-1.0;
i:=0;
result:=x;
exclam:=6.0;
f:=3.0;
 
repeat
  result2:=result;
  result:=result + odd1 * (power/exclam);
  power:=power*x2;
  odd1:=-odd1;
  factorial;
  i:=i+1;
  if i > 5 then
    begin
    i:=0;
    if abs(result-result2) < (1e-12*result) then
      result2:=result;
    end;
until result = result2;
 
cos:=result;
end; (* compute_cos *)
 
begin (* cos *)
if x = 0.0 then cos:=1.0 else
begin (* else_1 *)
x:=x+half_pi;
 
if (x=0.0) or (x=pi) or (x=two_pi) then cos:=0.0 else
begin
while x < 0.0 do x:=x+two_pi;
while x > two_pi do x:=x-two_pi;
 
compute_cos;
 
end; (* else *)
end; (* else_1 *)
end; (* cos *).
