implementation module inout;

import terminal;
import disk;
import conversions;


var
disk_input, disk_output : boolean;
input_file, output_file : disk.file_variable;



procedure openinput ( deftext : buffer );
var
b : buffer;
i, j : integer;
save_disk_output : boolean;
begin
(* get filename from console *)
save_disk_output := disk_output;
disk_input := false;
disk_output := false;
writeln;
writestring('OpenInput, enter filename : $');
readstring(b);
writeln;

(* concatenate deftext if filename ends with '.' *)
i := 1;
while b[i] > ' ' do i := i + 1 end;
if b[i-1] = '.' then
	for j := 1 to 3 do
		b[i] := deftext[j];
		i := i + 1
		end
end;

(* open the file *)
disk.open(input_file, b, 256, false, false);

disk.display_file(input_file);
(* check status *)
if input_file.status = disk.file_ok then
	disk_input := true
else
	terminal.writestring('OpenInput failed: $');
	terminal.writestring( disk.status_message(input_file) );
	writeln;
end;

disk_output := save_disk_output;
end openinput;


procedure openoutput ( deftext : buffer );
var
b : buffer;
i, j : integer;
save_disk_input : boolean;
begin
(* get filename from console *)
save_disk_input := disk_input;
disk_input := false;
disk_output := false;
writeln;
writestring('OpenOutput, enter filename : $');
readstring(b);
writeln;

(* concatenate deftext if filename ends with '.' *)
i := 1;
while b[i] > ' ' do i := i + 1 end;
if b[i-1] = '.' then
	for j := 1 to 3 do
		b[i] := deftext[j];
		i := i + 1
		end
end;

(* open the file *)
disk.open(output_file, b, 256, true, true);

disk.display_file(output_file);
(* check status *)
if output_file.status = disk.file_ok then
	disk_output := true
else
	terminal.writestring('OpenOutput failed: $');
	terminal.writestring( disk.status_message(output_file) );
	writeln;
end;

disk_input := save_disk_input;
end openoutput;


procedure closeinput;
begin
disk.close(input_file);
disk_input := false;
end closeinput;


procedure closeoutput;
var
end_pos : real;
begin
end_pos := output_file.buffer_pos + float(output_file.buffer_size);
while output_file.file_pos < end_pos do
	write( chr(1ah) );	(* eof char *)
	end;
disk.close(output_file);
disk_output := false;
end closeoutput;



procedure read ( var ch : char );
begin
if disk_input then
	disk.diskread(input_file, -1.0, 1, ch)
else
	terminal.read(ch);
end
end read;

procedure readstring ( var s : buffer );
var
ch : char;
i : integer;
begin
s := ' ';
read(ch); while ch <= ' ' do read(ch) end;
s[1] := ch;
i := 2;
repeat
	read(ch);
	if ch > ' ' then s[i] := ch end;
	i := i + 1
until ch <= ' ';
termch := ch;
end readstring;


procedure readint ( var x : integer );
var
i : integer;
b : conversions.buffer;
begin
readstring(b);
i := 1;
while b[i] > ' ' do i := i + 1 end;
conversions.strint(i - 1, b, x);
end readint;



procedure write ( ch : char );
begin
if disk_output then
	disk.diskwrite(output_file, -1.0, 1, ch)
else
	terminal.write(ch);
end
end write;

procedure writeln;
begin
write( chr(0dh) );
write( chr(0ah) );
end writeln;

procedure writestring ( s : buffer );
var
i : integer;
begin
if disk_output then
	s[80] := '$';
	i := 1;
	while s[i] # '$' do i := i + 1 end;
	disk.diskwrite(output_file, -1.0, (i - 1), s);
else
	terminal.writestring(s);
end;
end writestring;


procedure writeint ( x, n : integer );
var
b : conversions.buffer;
i, siz, pad_count : integer;
begin
conversions.intstr(x,siz,b);
pad_count := n - siz;
for i := 1 to pad_count do write(' ') end;
for i := 1 to siz do write( b[i] ) end;
end writeint;


procedure writehex ( x, n : integer );
var
i, pad_count : integer;
b : array [1..4] of char;
begin
b := hex(x);
pad_count := n - 4;
for i := 1 to pad_count do write(' ') end;
write( b[3] );
write( b[4] );
write( b[1] );
write( b[2] );
end writehex;


begin
disk_input := false;
disk_output := false;
end inout.
