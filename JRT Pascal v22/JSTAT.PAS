(*  JSTAT ver 1.0	JRT Systems		*)
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

extern

type
jstat_interface =
	record
	mean, standard_deviation,
	variance, skewness, kurtosis,
	m1, m2, m3, m4 : real;
	end;
jstat_array = array [1..1000] of real;

procedure jstat ( n : integer; var x : jstat_array;
		var r : jstat_interface );
var
i : integer;
total_x,total_x2,total_x3,total_x4 : real;

function cube ( x : real ): real;
begin
cube:= x * sqr(x);
end;

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
end; (* sqrt *)

procedure totals;
var
i : integer;
tx,tx2,tx3,tx4 : real;
sum_x, mean : real;
begin (* totals *)
total_x:=0; total_x2:=0; total_x3:=0; total_x4:=0;
sum_x:=0;
for i:=1 to n do sum_x:=sum_x + x[i];
mean:=sum_x / n;
r.mean:=mean;
for i:=1 to n do
	begin
	tx := x[i] - mean;
	tx2 := sqr(tx);
	tx3 := tx * tx2;
	tx4 := tx * tx3;
	total_x := total_x + tx;
	total_x2 := total_x2 + tx2;
	total_x3 := total_x3 + tx3;
	total_x4 := total_x4 + tx4;
	end;
end; (* totals *)

begin (* jstat *)
totals;
r.m1 := total_x / n;
r.m2 := total_x2 / n;
r.m3 := total_x3 / n;
r.m4 := total_x4 / n;

r.standard_deviation := sqrt(r.m2);
r.variance := r.m2;
r.kurtosis := r.m4 / sqr(r.m2);
r.skewness := r.m3 / sqrt( cube(r.m2));
end; (* jstat *).
