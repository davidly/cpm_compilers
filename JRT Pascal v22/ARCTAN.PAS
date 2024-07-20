extern
function arctan ( x : real ): real;
 
const
half_pi		= 1.5707963267948;
sixth_pi	= 0.52359877559828;
twelfth_pi	= 0.26179938779914;
sqrt3		= 1.7320508075689;
 
var
flag2,flag3,i : integer;
result : real;
sign : char;
 
procedure compute;
var
flip,power,x2,odd1,result2 : real;
i,j : integer;
 
begin (* compute *)
flip:=1.0;
power:=x;
x2:=sqr(power);
odd1:=1.0;
j:=0;
i:=0;
result:=0.0;
 
repeat
  result2:=result;
  result:=result + flip * ( power/odd1 );
  odd1:=odd1+2.0;
  flip:=-flip;
  power:=power * x2;
  j:=j+1;
  i:=i+1;
  if i > 5 then
    begin
    i:=0;
    if abs(result-result2) < (1e-12*result) then
	result2:=result;
    end;
until result = result2;
end; (* compute *)
 
begin (* arctan *)
if x = 0.0 then arctan:=0.0
else
begin
if x < 0.0 then begin x:=-x; sign:='-' end
   else sign:='+';
 
if x > 1.0 then
  begin
  x:=1.0/x;
  flag2:=1;
  end
else flag2:=0;
 
if x > twelfth_pi then
  begin
  x:=( sqrt3 * x - 1.0 )/( x + sqrt3 );
  flag3:=1;
  end
else flag3:=0;
 
compute;
 
if flag3 = 1 then
  result:=result + sixth_pi;
 
if flag2 = 1 then
  result:=half_pi - result;
 
if sign = '-' then arctan:=-result else arctan:=result;
 
end; (* else *)
 
end; (* arctan *).
