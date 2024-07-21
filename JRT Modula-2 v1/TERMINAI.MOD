implementation module terminal;

type
registers = record
	case integer of
	1 : flag, a, c, b, e, d, l, h : char|
	2 : psw, bc, de, hl : integer
	end
	end;

var
last_ch : char;
again : boolean;

procedure read (var ch : char);
var
r : registers;
begin
if again then
	ch := last_ch;
	again := false
else
	r.c := chr(1);
	call(5,r,r);
	ch := r.a;
	last_ch := ch;
	end;
end read;



procedure busyread (var ch : char);
var
r : registers;
begin
(* check console status *)
r.c := chr(11);
call(5,r,r);

if r.a = chr(1) then
	r.c := chr(1);		(* get a char *)
	call(5,r,r);
	ch := r.a;
	last_ch := ch;
else
	ch := chr(0)		(* no char was typed in *)
end;
end busyread;


procedure write (ch : char);
var
r : registers;
begin
if console then
	r.c := chr(2);
	r.e := ch;
	call(5,r,r)
	end;
if printer then
	r.c := chr(5);
	r.e := ch;
	call(5,r,r)
	end;
column := column + 1;
end write;


procedure writeln;
begin
write( chr(0dh) );
write( chr(0ah) );
column := 1;
end writeln;


procedure writestring (s : char256);
var
i : integer;
begin
i := 1;
s[256] := '$';
while s[i] # '$' do
	write( s[i] );
	i := i + 1;
	end;
if i >= 256 then
	writeln;
	writestring('Error: non-terminated string$');
	writeln;
	end;
end writestring;


procedure tab (x : integer);
begin
while column < x do write(' ') end;
end tab;



procedure readagain;
begin
again := true
end readagain;

begin (* terminal *)
again := false;
printer := false;
console := true;
last_ch := ' ';
column := 1;
end terminal.
