implementation module disk;

from inout import write, writeln, writeint, writestring;
from realinout import writereal;

type
registers = record
	case integer of
	1 : flag, a, c, b, e, d, l, h : char |
	2 : psw, bc, de, hl : integer
	end
	end;


procedure open (var fv : file_variable; name_type : char16;
	bufsize : integer; delete, create : boolean);
var
i, fcb_address : integer;
r : registers;
begin
fv.open_flag := 4567h;
fv.file_pos := 0.0;
fv.ascii_eof_pos := 0.0;
fv.absolute_eof_pos := 0.0;
fv.buffer_pos := 1.0e50;

(* buffer_size must be a multiple of 128 (the disk sector size) *)
bufsize := bufsize + (bufsize mod 128);
if bufsize < 256 then bufsize := 256 end;	(* minimum is 256 *)
new( fv.buffer : bufsize );	(* allocate i/o buffer *)
fv.buffer_size := bufsize;

fv.record_size := 1;
fv.buffer_equals_disk := true;
fv.ascii_eof := false;
fv.absolute_eof := false;
fv.status := file_ok;

parse_filename(name_type, fv);

(* clear out fcb *)
fv.fcb_extent := chr(0);
fv.fcb_s1 := chr(0);
fv.fcb_s2 := chr(0);
fv.fcb_record_count := chr(0);
for i := 1 to 16 do fv.fcb_blocks[i] := chr(0) end;
fv.fcb_current_record := chr(0);
fv.fcb_random_record := 0;
fv.fcb_x := chr(0);


fcb_address := abs(fv.fcb_disk);
if delete then
	r.c := chr(13h);
	r.de := fcb_address;
	call(5,r,r)
	end;

(* open the file *)
r.c := chr(0fh);	(* open *)
r.de := fcb_address;
call(5,r,r);

(* check return code *)
if r.a = chr(0ffh) then		(* not found *)
	if create then
		r.c := chr(16h);	(* create *)
		r.de := fcb_address;
		call(5,r,r);
		if r.a = chr(0ffh) then
			fv.open_flag := 0;
			fv.status := no_directory_space
		else
			fv.status := file_ok
		end
	else
		fv.open_flag := 0;
		fv.status := not_found
	end;
end;
end open;




procedure update_buffer (var fv : file_variable; pos : real);
var
x, start : real;
r : registers;
i, dma_addr, sector : integer;
begin
(* if current buffer was modified, write it to disk *)
if not fv.buffer_equals_disk then
	if fv.file_pos = 0.0 then sector := 0
	else sector := trunc( fv.buffer_pos/128.0 )
	end;
	fv.fcb_random_record := sector;
	dma_addr := abs(fv.buffer^);
	for i := 1 to (fv.buffer_size div 128) do
		r.c := chr(1ah);	(* set dma address *)
		r.de := dma_addr;
		call(5,r,r);
		r.c := chr(22h);	(* random write *)
		r.de := abs(fv.fcb_disk);
		call(5,r,r);
		dma_addr := dma_addr + 128;
		fv.fcb_random_record := fv.fcb_random_record + 1;
		end;
end;

(* compute file_pos from which to load *)
if pos = 0.0 then x := 0.0 else x := pos / 128.0 end;
start := float( trunc(x) ) * 128.0;	(* previous sector boundary *)
fv.buffer_pos := start;
if start = 0.0 then sector := 0
else sector := trunc( start/128.0 )
end;

dma_addr := abs(fv.buffer^);
fv.fcb_random_record := sector;
for i := 1 to (fv.buffer_size div 128) do
	r.c := chr(1ah);	(* set dma address *)
	r.de := dma_addr;
	call(5,r,r);
	r.c := chr(21h);	(* random read *)
	r.de := abs(fv.fcb_disk);
	call(5,r,r);
	dma_addr := dma_addr + 128;
	fv.fcb_random_record := fv.fcb_random_record + 1;
	end;
fv.buffer_equals_disk := true;
end update_buffer;




procedure close (var fv : file_variable);
var
r : registers;
begin
if not fv.buffer_equals_disk then
	update_buffer(fv,0.0);
	end;
r.c := chr(10h);
r.de := abs(fv.fcb_disk);
call(5,r,r);
if r.a = chr(0ffh) then
	fv.status := not_found
else
	fv.status := file_ok
end
end close;







procedure diskread (var fv : file_variable; pos : real;
	count : integer; var buf : char30000);
var
start_data, end_data, start_buffer, end_buffer : real;
ptr, i : integer;
begin
if pos = -1.0 then pos := fv.file_pos end;	(* sequential *)
fv.status := file_ok;
if (count <= 0) or (count > fv.buffer_size - 128) then
	fv.status := parameter_error;
	return
	end;
if (pos < 0.0) or (pos > 16777216.0) then
	fv.status := parameter_error;
	return
	end;
fv.file_pos := pos + float(count);
start_data := pos;
end_data := pos + float(count - 1);
start_buffer := fv.buffer_pos;
end_buffer := fv.buffer_pos + float(fv.buffer_size - 1);

if ((start_data < start_buffer) or (end_data > end_buffer)) then
		update_buffer(fv,pos);
		end;
ptr := trunc( pos - fv.buffer_pos );
for i := 0 to (count - 1) do
	buf[i] := fv.buffer^[ptr];
	ptr := ptr + 1
	end;

(* update eof flags *)
if fv.file_pos > fv.ascii_eof_pos then
	fv.ascii_eof := true
	end;
if fv.file_pos > fv.absolute_eof_pos then
	fv.absolute_eof := true
	end
end diskread;






procedure diskwrite (var fv : file_variable; pos : real;
	count : integer; var buf : char30000);
var
start_data, end_data, start_buffer, end_buffer : real;
ptr, i : integer;
begin
if pos = -1.0 then pos := fv.file_pos end;	(* sequential *)
fv.status := file_ok;
if (count <= 0) or (count > fv.buffer_size - 128) then
	fv.status := parameter_error;
	return
	end;
if (pos < 0.0) or (pos > 16777216.0) then
	fv.status := parameter_error;
	return
	end;
fv.file_pos := pos + float(count);
start_data := pos;
end_data := pos + float(count - 1);
start_buffer := fv.buffer_pos;
end_buffer := fv.buffer_pos + float(fv.buffer_size - 1);

if ((start_data < start_buffer) or (end_data > end_buffer)) then
		update_buffer(fv,pos);
		end;
ptr := trunc( pos - fv.buffer_pos );
for i := 0 to (count - 1) do
	fv.buffer^[ptr] := buf[i];
	ptr := ptr + 1
	end;

(* update eof flags *)
if fv.file_pos > fv.ascii_eof_pos then
	fv.ascii_eof := true
	end;
if fv.file_pos > fv.absolute_eof_pos then
	fv.absolute_eof := true
	end;

fv.buffer_equals_disk := false;
end diskwrite;



procedure display_file ( fv : file_variable );
var i : integer;
begin
writeln;
writestring('------ DISPLAY_FILE ------$');
writeln;
writestring('open flag =$'); writeint(fv.open_flag,0);
writeln;
writestring('file_pos =$'); writereal(fv.file_pos,0);
writeln;
writestring('status = $');
writestring( status_message(fv) );

writeln;
writestring('record size =$');	writeint( fv.record_size , 0 );
writeln;
writestring('buffer size =$');	writeint( fv.buffer_size , 0 );
writeln;
writestring('bufferpos =$'); writereal(fv.buffer_pos,0);
writeln;
writestring('filename = $');
write( chr( ord(fv.fcb_disk) + 40h));
write(':');
for i := 1 to 8 do write( fv.fcb_name[i] ) end;
write('.');
for i := 1 to 3 do write( fv.fcb_type[i] ) end;
writeln;
writestring('--------------------------$');
writeln;
writeln;
end display_file;


procedure parse_filename (x : char16; var fv : file_variable);
const
a = {'A'..'Z','0'..'9','$','/'};

var
i, j, ptr : integer;

begin
x := cap(x);
fv.fcb_name := ' ';
fv.fcb_type := ' ';

(* check for disk letter *)
if x[2] = ':' then
	fv.fcb_disk := chr( ord(x[1]) - 40h);
	i := 3;
else
	fv.fcb_disk := chr(0);
	i := 1;
	end;


(* search for start of filename *)
while not (x[i] in a) do i := i + 1 end;

(* move filename to work area y *)

ptr := 1;
repeat
	fv.fcb_name[ptr] := x[i];
	i := i + 1;
	ptr := ptr + 1;
until (not (x[i] in a)) or (ptr > 8);

(* search for start of filetype *)
while (not (x[i] in a)) and (i <> 15) do i := i + 1 end;

(* move filetype to work area y *)
ptr := 1;
repeat
	fv.fcb_type[ptr] := x[i];
	i := i + 1;
	ptr := ptr + 1;
until (not (x[i] in a)) or (ptr > 3);

end parse_filename;


procedure status_message ( var fv : file_variable ): char16;
begin
case fv.status of
file_ok			: return 'file_ok$'|
name_error		: return 'name_error$'|
not_found		: return 'not_found$'|
no_disk_space		: return 'no_disk_space$'|
no_directory_space	: return 'no_dir_space$'|
parameter_error		: return 'parameter_error$'
else			  return 'UNKNOWN STATUS$'
end;
end status_message;


end disk.
