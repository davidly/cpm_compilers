implementation module conversions;

type
registers = record
	case integer of
	1 : flag, a, c, b, e, d, l, h : char|
	2 : psw, bc, de, hl : integer
	end
	end;



procedure intstr ( i : integer; var s : integer; var str : buffer );
var
r : registers;
j : integer;
ptr : pointer to buffer;
begin
r.a := chr(20);
r.hl := i;
call(103h,r,r);
s := r.de;		(* string length *)
str := ' ';
new(ptr | r.hl);
for j := 1 to s do
	str[j] := ptr^[j];
	end;
dispose(ptr);
end intstr;



procedure strint ( s : integer; str : buffer; var i : integer );
var
r : registers;
begin
r.a := chr(21);
r.bc := s;		(* string length *)
r.hl := abs(str);
call(103h,r,r);
i := r.hl;
end strint;



procedure realstr ( r1 : real; var s : integer; var str : buffer );
var
r : registers;
ptr : pointer to buffer;
i : integer;
begin
r.a := chr(22);
r.bc := -1;		(* fraction length *)
r.de := 0;		(* minimum length  *)
r.hl := abs(r1);	(* address	   *)
call(103h,r,r);

s := r.de;		(* string length *)
new(ptr | r.hl);
for i := 1 to r.de do
	str[i] := ptr^[i];
	end;
dispose(ptr);
end realstr;


procedure strreal ( s : integer; str : buffer; var r1 : real );
var
r : registers;
ptr : pointer to buffer;
i : integer;
hold : record
	case integer of
	1 : c : array [1..8] of char|
	2 : r : real
	end
	end;
begin
r.a := chr(23);
r.bc := s;
r.hl := abs(str);
call(103h,r,r);

new(ptr | r.hl);
for i := 1 to 8 do
	hold.c[i] := ptr^[i];
	end;
dispose(ptr);
r1 := hold.r;
end strreal;


end conversions.
