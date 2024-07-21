implementation module realinout;

import inout;
import conversions;


procedure readreal ( var x : real );
var
i : integer;
b : conversions.buffer;
begin
inout.readstring(b);
i := 1;
while b[i] > ' ' do i := i + 1 end;
conversions.strreal(i - 1, b, x);
end readreal;

procedure writereal (x : real; n : integer);
var
b : conversions.buffer;
i, siz, pad_count : integer;
begin
conversions.realstr(x, siz, b);
pad_count := n - siz;
for i := 1 to pad_count do
	inout.write( ' ' );
	end;
for i := 1 to siz do
	inout.write( b[i] );
	end;
end writereal;

begin
done := true
end realinout.
