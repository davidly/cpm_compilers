extern
function sqrt ( x : real ): real;
 
var
sq,a,b : real;
exponent,i : integer;
zap : record
	case integer of
	0 : (num : real);
	1 : (ch8 : array [1..8] of char);
	end;
 
begin
if x = 0.0 then sqrt:=0.0 
else
begin
sq:=abs(x);
 
zap.num:=sq;
exponent:=ord(zap.ch8[1]);
exponent:=(exponent div 2) + 32;
zap.ch8[1]:=chr(exponent);
a:=zap.num;
 
b:=0;
i:=0;
 
while a <> b do
  begin
  b:=sq/a;
  a:=(a+b)/2;
  i:=i+1;
  if i > 4 then
    begin
    i:=0;
    if abs(a-b) < (1.0e-12 * a) then a:=b;
    end;
  end;
 
sqrt:=a;
end; (* else *)
 
end; (* sqrt *).
