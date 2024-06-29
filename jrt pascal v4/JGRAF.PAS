
EXTERN

TYPE
char1000 =  ARRAY [1..1000] OF char;
char2000 =  ARRAY [1..2000] OF char;
char3000 =  ARRAY [1..3000] OF char;
char4000 =  ARRAY [1..4000] OF char;
char5000 =  ARRAY [1..5000] OF char;
char6000 =  ARRAY [1..6000] OF char;
char7000 =  ARRAY [1..7000] OF char;
char8000 =  ARRAY [1..8000] OF char;
char9000 =  ARRAY [1..9000] OF char;
jgraf_interface = RECORD
       command, plot_char : char;
       x_grid, y_grid : boolean;
       rows, columns : integer;
       x_lower, x_upper, y_lower, y_upper : real;
       filename :  ARRAY [1..14] OF char;
       graf_title : STRING;
       b : ^char9000;
       bufr_size, line_size, row_count : integer;
       x_spacing, y_spacing : real;
       END;


{=================================================================}
PROCEDURE jgraf (VAR jg : jgraf_interface; x, y : real);
VAR
i : integer;
f1 : FILE OF char;


{=================================================================}
PROCEDURE setup;
VAR
ai : integer;
axis_labels :  ARRAY [1..50] OF RECORD
       axis : char;
       ptr : integer;
       END;


{=================================================================}
PROCEDURE allocate_buffer;
LABEL 99;
VAR
x : integer;
b1 : ^char1000;
b2 : ^char2000;
b3 : ^char3000;
b4 : ^char4000;
b5 : ^char5000;
b6 : ^char6000;
b7 : ^char7000;
b8 : ^char8000;
b9 : ^char9000;

BEGIN
jg.line_size := jg.columns + 16;
jg.row_count := jg.rows + 5;
jg.bufr_size := jg.line_size * jg.row_count + 8;
x := (jg.bufr_size DIV 1000) + 1;

IF (x < 1) OR (x > 9) THEN
       BEGIN
       writeln('JGRAF - graph size error:', jg.bufr_size);
       GOTO 99;
       END;
CASE x OF
1 :
       BEGIN
       new(b1);
       jg.b := b1
       END;
2 :
       BEGIN
       new(b2);
       jg.b := b2
       END;
3 :
       BEGIN
       new(b3);
       jg.b := b3
       END;
4 :
       BEGIN
       new(b4);
       jg.b := b4
       END;
5 :
       BEGIN
       new(b5);
       jg.b := b5
       END;
6 :
       BEGIN
       new(b6);
       jg.b := b6
       END;
7 :
       BEGIN
       new(b7);
       jg.b := b7
       END;
8 :
       BEGIN
       new(b8);
       jg.b := b8
       END;
9 :
       BEGIN
       new(b9);
       jg.b := b9
       END;
END;
99 : 
END;  (* allocate_buffer *)


{=================================================================}
PROCEDURE crlfs;  (* put crlfs in buffer *)
VAR
i, ptr : integer;
cr, lf : char;

BEGIN
cr := chr(0dh);
lf := chr(0ah);
ptr := jg.line_size - 1;
FOR i := 1 TO jg.row_count - 1 DO
       BEGIN
       jg.b^[ptr] := cr;
       jg.b^[ptr + 1] := lf;
       ptr := ptr + jg.line_size;
       END;
ptr := ptr + 8;
jg.b^[ptr] := cr;
jg.b^[ptr + 1] := lf;
END;  (* crlfs *)


{=================================================================}
PROCEDURE xgrid;
VAR
x : integer;


{=================================================================}
PROCEDURE x_axes (r : integer; main : boolean);
VAR
i, r1, ptr, count : integer;
ll, ss, rr, xx : real;

BEGIN
r1 := jg.row_count - r;
ptr := (r1 * jg.line_size) + 13;
(* update axis labels array and file *)

axis_labels[ai].axis := 'x';
axis_labels[ai].ptr := ptr;
ai := ai + 1;
rr := r;
ss := jg.y_spacing;
ll := jg.y_lower;
xx := ((rr - 3.0) * ss) + ll;
write(f1; xx);

IF jg.x_grid OR main THEN
       count := jg.columns
ELSE
       count := 1;
FOR i := 0 TO count DO
       jg.b^[ptr + i] := '-';
END;  (* x_axes *)

BEGIN  (* xgrid *)

x_axes(3, true);
x := 13;
WHILE x <= jg.row_count - 1 DO
       BEGIN
       x_axes(x, false);
       x := x + 10;
       END;
END;  (* xgrid *)


{=================================================================}
PROCEDURE ygrid;
VAR
y : integer;


{=================================================================}
PROCEDURE y_axes (c : integer; main : boolean);
VAR
i, ptr : integer;
cc, ll, ss, yy : real;

BEGIN
IF jg.y_grid OR main THEN
       BEGIN
       ptr := (2 * jg.line_size) + c;
       FOR i := 1 TO jg.rows + 1 DO
              BEGIN
              jg.b^[ptr] := 'I';
              ptr := ptr + jg.line_size;
              END;
       END
ELSE
       BEGIN  (* no ygrid *)
       
       ptr := (jg.line_size * (jg.rows + 2)) + c;
       jg.b^[ptr] := 'I';
       END;
(* update axis labels array and file *)

axis_labels[ai].axis := 'y';
axis_labels[ai].ptr := ptr;
ai := ai + 1;
cc := c;
ss := jg.x_spacing;
ll := jg.x_lower;
yy := ((cc - 14.0) * ss) + ll;
write(f1; yy);
END;  (* y_axes *)

BEGIN  (* ygrid *)

y_axes(14, true);
y := 24;
WHILE y <= jg.columns + 14 DO
       BEGIN
       y_axes(y, false);
       y := y + 10;
       END;
END;  (* ygrid *)


{=================================================================}
PROCEDURE clear_bufr;
TYPE
buffer =  ARRAY [1..20] OF char1000;
VAR
a : char1000;
i : integer;
ptr : ^buffer;

BEGIN
a := ' ';
map(ptr, addr(jg.b^));
FOR i := 1 TO (jg.bufr_size DIV 1000) + 1 DO
       ptr^[i] := a;
END;


{=================================================================}
PROCEDURE move_title;
VAR
s : STRING[20];
x, i : integer;

BEGIN
s := 'JGRAF ver 4.0';
FOR i := 1 TO 13 DO
       jg.b^[i] := s[i];
x := (jg.line_size DIV 2) - (length(jg.graf_title) DIV 2) + 2;
FOR i := 1 TO 4 DO
       BEGIN
       jg.b^[x] := '*';
       x := x + 1;
       END;
x := x + 1;  (* skip 1 space *)

FOR i := 1 TO length(jg.graf_title) DO
       BEGIN
       jg.b^[x] := jg.graf_title[i];
       x := x + 1;
       END;
x := x + 1;  (* skip 1 space *)

FOR i := 1 TO 4 DO
       BEGIN
       jg.b^[x] := '*';
       x := x + 1;
       END;
END;  (* move_title *)


{=================================================================}
PROCEDURE process_axis_labels;
VAR
hold :  ARRAY [1..30] OF char;
i, j : integer;
ch : char;


{=================================================================}
PROCEDURE xlabels;
VAR
count, ptr, number_length, k : integer;

BEGIN
number_length := j - 1;
ptr := axis_labels[i].ptr;
IF number_length <= 8 THEN
       BEGIN
       ptr := ptr - number_length;
       count := number_length;
       END
ELSE
       BEGIN
       ptr := ptr - 8;
       count := 8;
       END;
FOR k := 1 TO count DO
       BEGIN
       jg.b^[ptr] := hold[k];
       ptr := ptr + 1;
       END;
END;  (* xlabels *)


{=================================================================}
PROCEDURE ylabels;
VAR
count, ptr, number_length, k : integer;

BEGIN
number_length := j - 1;
ptr := axis_labels[i].ptr;
IF number_length <= 8 THEN
       BEGIN
       ptr := ptr + jg.line_size - (number_length DIV 2) + 1;
       count := number_length;
       END
ELSE
       BEGIN
       ptr := ptr + jg.line_size - 4;
       count := 8;
       END;
FOR k := 1 TO count DO
       BEGIN
       jg.b^[ptr] := hold[k];
       ptr := ptr + 1;
       END;
END;  (* ylabels *)

BEGIN
reset(f1, 'jgraf.$$$', binary, 128);
read(f1; ch);  (* skip over leading blank *)

FOR i := 1 TO ai - 1 DO
       BEGIN
       hold := ' ';
       j := 1;
       REPEAT
              read(f1; ch);
              hold[j] := ch;
              j := j + 1;
       UNTIL ch = ' ';
       CASE axis_labels[i].axis OF
       'x' :
              xlabels;
       'y' :
              ylabels;
       END;
       END;
close(f1);
END;  (* process_axis_labels *)

BEGIN  (* setup *)

jg.x_spacing := (jg.x_upper - jg.x_lower) / jg.columns;
jg.y_spacing := (jg.y_upper - jg.y_lower) / jg.rows;
allocate_buffer;
clear_bufr;
crlfs;
ai := 1;  (* axis labels array index *)

rewrite(f1, 'jgraf.$$$', text, 128);
xgrid;
ygrid;
write(f1; ' ');
close(f1);
process_axis_labels;
move_title;
END;  (* setup *)


{=================================================================}
PROCEDURE data;
LABEL 99;
VAR
x1, y1 : integer;


{=================================================================}
PROCEDURE plot (x, y : integer);
(* place char in graph area - origin 0 at lower left *)
VAR
ptr : integer;

BEGIN
ptr := (jg.line_size * (jg.row_count - y - 3)) + (x + 14);
IF ptr > jg.bufr_size THEN
       writeln('plot computation error')
ELSE
       jg.b^[ptr] := jg.plot_char;
END;  (* plot *)

BEGIN
IF NOT ((x >= jg.x_lower) AND (x <= jg.x_upper) AND (y >= jg.y_lower) 
       AND (y <= jg.y_upper)) THEN
       GOTO 99;
x1 := round((x - jg.x_lower) / jg.x_spacing);
y1 := round((y - jg.y_lower) / jg.y_spacing);
plot(x1, y1);
99 : 
END;


{=================================================================}
PROCEDURE display (mode : char);
VAR
bytes_remaining, len, start : integer;

BEGIN
IF mode = 'p' THEN
       system(list);
IF mode = 's' THEN
       rewrite(f1, jg.filename, binary, 1024);
bytes_remaining := jg.bufr_size;
start := 1;
REPEAT
       IF bytes_remaining >= 1024 THEN
              len := 1024
       ELSE
              len := bytes_remaining;
       IF mode = 's' THEN
              write(f1; copy(jg.b^, start, len))
       ELSE
              write(copy(jg.b^, start, len));
       start := start + 1024;
       bytes_remaining := bytes_remaining - 1024;
UNTIL bytes_remaining <= 0;
IF mode = 'p' THEN
       system(nolist);
IF mode = 's' THEN
       close(f1);
END;  (* display *)

BEGIN  (* jgraf *)

CASE upcase(jg.command) OF
'D' :
       data;
'I' :
       setup;
'S' :
       display('s');
'C' :
       display('c');
'P' :
       display('p');
'X' :
       dispose(jg.b);
ELSE :
       writeln('JGRAF - unknown command: ', jg.command);
END;  (* case *)
END;  (* jgraf *)  .
