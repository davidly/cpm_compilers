%ltrace %ptrace
extern

type
char1000 = array [1..1000] of char;
char2000 = array [1..2000] of char;
char3000 = array [1..3000] of char;
char4000 = array [1..4000] of char;
char5000 = array [1..5000] of char;
char6000 = array [1..6000] of char;
char7000 = array [1..7000] of char;
char8000 = array [1..8000] of char;
char9000 = array [1..9000] of char;
jgraf_interface =
	record
	command, plot_char : char;
	x_grid, y_grid : boolean;
	rows, columns : integer;
	x_lower, x_upper, y_lower, y_upper : real;
	filename : array [1..14] of char;
	title : string;
	b : ^char9000;
	bufr_size, line_size, row_count : integer;
	x_spacing, y_spacing : real;
	end;

procedure jgraf ( var jg : jgraf_interface;
		x, y : real );
var
i : integer;
f1 : file of char;

procedure setup;
var
ai : integer;
axis_labels : array [1..50] of
	record
	axis : char;
	ptr : integer;
	end;

procedure allocate_buffer;
label 99;
var
x : integer;
b1 : ^char1000;	b2 : ^char2000;	b3 : ^char3000;
b4 : ^char4000;	b5 : ^char5000; b6 : ^char6000;
b7 : ^char7000; b8 : ^char8000; b9 : ^char9000;
begin
jg.line_size:=jg.columns+16;
jg.row_count:=jg.rows+5;
jg.bufr_size:=jg.line_size * jg.row_count + 8;
x := (jg.bufr_size div 1000) + 1;

if (x < 1) or (x > 9) then
	begin
	writeln('JGRAF - graph size error:',
		jg.bufr_size);
	goto 99;
	end;
case x of
1 : begin new(b1); jg.b:=b1 end;
2 : begin new(b2); jg.b:=b2 end;
3 : begin new(b3); jg.b:=b3 end;
4 : begin new(b4); jg.b:=b4 end;
5 : begin new(b5); jg.b:=b5 end;
6 : begin new(b6); jg.b:=b6 end;
7 : begin new(b7); jg.b:=b7 end;
8 : begin new(b8); jg.b:=b8 end;
9 : begin new(b9); jg.b:=b9 end;
end;
99: end; (* allocate_buffer *)

procedure crlfs; (* put crlfs in buffer *)
var
i, ptr : integer;
cr, lf : char;
begin
cr:=chr(0dh);
lf:=chr(0ah);
ptr:=jg.line_size - 1;
for i:=1 to jg.row_count-1 do
	begin
	jg.b^[ptr]:=cr;
	jg.b^[ptr+1]:=lf;
	ptr:=ptr + jg.line_size;
	end;
ptr := ptr + 8;
jg.b^[ptr]:=cr;
jg.b^[ptr+1]:=lf;
end; (* crlfs *)

procedure xgrid;
var x : integer;

procedure x_axes ( r : integer; main : boolean );
var
i,r1,ptr,count : integer;
ll,ss,rr,xx : real;
begin
r1 := jg.row_count - r;
ptr := (r1 * jg.line_size) + 13;
(* update axis labels array and file *)
axis_labels[ai].axis:='x';
axis_labels[ai].ptr:=ptr;
ai:=ai+1;
rr:=r;
ss:=jg.y_spacing;
ll:=jg.y_lower;
xx := ((rr - 3.0) * ss) + ll;
write(f1; xx);

if jg.x_grid or main then
	count := jg.columns
else count := 1;
for i:=0 to count do
	jg.b^[ptr+i] := '-';
end; (* x_axes *)

begin (* xgrid *)
x_axes(3,true);
x := 13;
while x <= jg.row_count-1 do
	begin
	x_axes(x,false);
	x := x + 10;
	end;
end; (* xgrid *)

procedure ygrid;
var y : integer;

procedure y_axes ( c : integer; main : boolean );
var
i, ptr : integer;
cc,ll,ss,yy : real;
begin
if jg.y_grid or main then
	begin
	ptr := (2 * jg.line_size) + c;
	for i:=1 to jg.rows + 1 do
		begin
		jg.b^[ptr]:='I';
		ptr:=ptr + jg.line_size;
		end;
	end
else
	begin	(* no ygrid *)
	ptr := (jg.line_size * (jg.rows+2)) + c;
	jg.b^[ptr]:='I';
	end;
(* update axis labels array and file *)
axis_labels[ai].axis:='y';
axis_labels[ai].ptr:=ptr;
ai:=ai+1;
cc:=c;
ss:=jg.x_spacing;
ll:=jg.x_lower;
yy := ((cc - 14.0) * ss) + ll;
write(f1; yy);

end; (* y_axes *)

begin (* ygrid *)
y_axes(14,true);
y := 24;
while y <= jg.columns + 14 do
	begin
	y_axes(y,false);
	y := y + 10;
	end;
end; (* ygrid *)

procedure clear_bufr;
type
buffer = array [1..20] of char1000;
var
a : char1000;
i : integer;
ptr : ^buffer;
begin
a:=' ';
map(ptr,addr(jg.b^));
for i:=1 to (jg.bufr_size div 1000) + 1 do
	ptr^[i]:=a;
end;

procedure move_title;
var
s : string[20];
x,i : integer;
begin
s := 'JGRAF ver 2.2';
for i:=1 to 13 do jg.b^[i]:=s[i];
x := (jg.line_size div 2) - (length(jg.title) div 2)
	+ 2;
for i:=1 to 4 do
	begin
	jg.b^[x] := '*';
	x:=x+1;
	end;
x:=x+1;		(* skip 1 space *)
for i:=1 to length(jg.title) do
	begin
	jg.b^[x] := jg.title[i];
	x:=x+1;
	end;
x:=x+1;		(* skip 1 space *)
for i:=1 to 4 do
	begin
	jg.b^[x] := '*';
	x:=x+1;
	end;
end; (* move_title *)

procedure process_axis_labels;
var
hold : array [1..30] of char;
i,j : integer;
ch : char;

procedure xlabels;
var
count,ptr,number_length,k : integer;
begin
number_length:=j-1;
ptr := axis_labels[i].ptr;
if number_length <= 8 then
	begin
	ptr := ptr - number_length;
	count:=number_length;
	end
else
	begin
	ptr:=ptr - 8;
	count:=8;
	end;
for k:=1 to count do
	begin
	jg.b^[ptr] := hold[k];
	ptr := ptr + 1;
	end;
end; (* xlabels *)

procedure ylabels;
var
count, ptr, number_length, k : integer;
begin
number_length:=j-1;
ptr:=axis_labels[i].ptr;
if number_length <= 8 then
	begin
	ptr := ptr + jg.line_size
		- (number_length div 2) + 1;
	count:=number_length;
	end
else
	begin
	ptr := ptr + jg.line_size - 4;
	count:=8;
	end;
for k:=1 to count do
	begin
	jg.b^[ptr]:= hold[k];
	ptr := ptr + 1;
	end;
end; (* ylabels *)


begin
reset(f1,'jgraf.$$$',binary,128);
read(f1; ch);	(* skip over leading blank *)
for i:=1 to ai-1 do
	begin
	hold:=' ';
	j:=1;
	repeat
	  read(f1; ch);
	  hold[j]:=ch;
	  j:=j+1;
	until ch = ' ';
	case axis_labels[i].axis of
	'x' : xlabels;
	'y' : ylabels;
	end;
	end;
close(f1);
end; (* process_axis_labels *)

begin (* setup *)
jg.x_spacing := (jg.x_upper - jg.x_lower) / jg.columns;
jg.y_spacing := (jg.y_upper - jg.y_lower) / jg.rows;
allocate_buffer;
clear_bufr;
crlfs;
ai := 1;	(* axis labels array index *)
rewrite(f1,'jgraf.$$$',text,128);
xgrid;
ygrid;
write(f1; ' ');
close(f1);
process_axis_labels;
move_title;
end; (* setup *)


procedure data;
label 99;
var
x1, y1 : integer;

procedure plot ( x,y : integer );
(* place char in graph area - origin 0 at lower left *)
var
ptr : integer;
begin
ptr := (jg.line_size * (jg.row_count - y - 3))
	+ (x + 14);
if ptr > jg.bufr_size then
	writeln('plot computation error')
else
	jg.b^[ptr] := jg.plot_char;
end; (* plot *)

begin
if not ((x >= jg.x_lower) and (x <= jg.x_upper) and
	(y >= jg.y_lower) and (y <= jg.y_upper)) then
	goto 99;
x1 := round((x - jg.x_lower) / jg.x_spacing);
y1 := round((y - jg.y_lower) / jg.y_spacing);
plot(x1,y1);
99: end;


procedure display ( mode : char );
var
bytes_remaining, len, start : integer;
begin
if mode = 'p' then system(list);
if mode = 's' then
	rewrite(f1,jg.filename,binary,1024);
bytes_remaining := jg.bufr_size;
start:=1;
repeat
  if bytes_remaining >= 1024 then len:=1024
  else len:=bytes_remaining;
  if mode = 's' then
	write(f1; copy(jg.b^,start,len))
  else  write( copy(jg.b^,start,len));
  start:=start+1024;
  bytes_remaining:=bytes_remaining-1024;
until bytes_remaining <= 0;
if mode = 'p' then system(nolist);
if mode = 's' then
	close(f1);
end; (* display *)


begin (* jgraf *)
case upcase(jg.command) of
'D' : data;
'I' : setup;
'S' : display('s');
'C' : display('c');
'P' : display('p');
'X' : dispose(jg.b);
else : writeln('JGRAF - unknown command: ',
		jg.command);
end; (* case *)

end; (* jgraf *).
