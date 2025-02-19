program convertm;

(* convert rel modules to exproc int modules *)


type
char2 = array [1..2] of char;
char4 = array [1..4] of char;
char8 = array [1..8] of char;
char14 = array [1..14] of char;
file_char = file of char;
control_record = record
	id : char4;
	name : char8;
	ept,ft : integer;
	version : char4;
	codtab, codtabr : integer;
	x : array [1..104] of char;
	end;

var
program_name, name : char8;
ept,ft,codtab,codtabr : integer;
rel_tab : array [1..500] of integer;
done : boolean;
ch, b : char;
byte_count, rel_ptr : integer;
i, bit_ptr : integer;
filename : string[20];
f1,f2 : file of char;

function testbit ( x : char; bit : integer ):
	boolean; extern;


function hexint ( x : integer ): char4;
var
a : char4;
begin
a:=hex$(x);
hexint[1]:=a[3];
hexint[2]:=a[4];
hexint[3]:=a[1];
hexint[4]:=a[2];
end;

%include 'reset.pas'

procedure init;
label 10;
var
i : integer;
c : array [1..128] of char;
begin
writeln('Convertm   ver 3.0');
10: writeln;
write('enter name of REL file : ');
readln(filename);
writeln;
if pos('.',filename) <> 0 then
	begin
	writeln('enter filename only, do not enter filetype');
	goto 10;
	end;
writeln;
reset(f1,filename+'.rel',binary,1024);
reset_check(f1);
rel_ptr:=1;
bit_ptr:=0;
read(f1; b);
byte_count:=0;
rewrite(f2,filename+'.int',binary,2048);
for i:=1 to 128 do c[i]:=chr(0);
write(f2; c);
done:=false;
end; (* init *)

procedure write_suffixes;
var
i : integer;
begin
ept:=byte_count;
ft:=byte_count+2;
codtab:=byte_count+4;
write(f2; 0ffffh, 0ffffh);

for i:=1 to rel_ptr-1 do write(f2; rel_tab[i]);
write(f2; 0ffffh);
codtabr:=codtab + (2 * (rel_ptr - 1)) + 2;
end; (* write_suffixes *)

procedure update_control_record;
var
c : control_record;
begin
open(f2, filename+'.int',binary);
read(f2,rba,0; c);
c.name:=program_name;
c.ept:=ept;
c.ft:=ft;
c.codtab:=codtab;
c.codtabr:=codtabr;
c.version:='0300';
c.id[1]:=chr(0a0h);
c.id[2]:=chr(04dh);
c.id[3]:=chr(001h);
write(f2,rba,0; c);
close(f2);
end; (* update_control_record *)

function bit : char;
var
x : boolean;
begin
if bit_ptr >= 8 then
	begin
	read(f1; b);
	bit_ptr:=0;
	end;
x:=testbit(b,bit_ptr);
if x then bit:='1' else bit:='0';
bit_ptr:=bit_ptr+1;
end; (* bit *)

function two_bit : char2;
var
x : char2;
begin
x[1]:=bit;
x[2]:=bit;
two_bit:=x;
end; (* two_bit *)

function four_bit : char4;
var
x : record a,b : char2 end;
begin
x.a:=two_bit;
x.b:=two_bit;
four_bit:=x;
end; (* four_bit *)

function byte : char;
var
a,i,m : integer;
begin
a:=0;
m:=128;
for i:=1 to 8 do
	begin
	if bit = '1' then a:=a + m;
	m:= m div 2;
	end;
byte:=chr(a);
end; (* byte *)

function name_count : integer;
var
x : integer;
begin
x:=0;
if bit = '1' then x:=x+4;
if bit = '1' then x:=x+2;
if bit = '1' then x:=x+1;
name_count:=x;
end; (* name_count *)


function address_field : integer;
var
low, hi : char;
begin
low:=byte;
hi:=byte;
address_field:= ord(low) + 256 * ord(hi);
end;

procedure byte_data;
begin
write(f2; byte);
byte_count:=byte_count+1;
end;

procedure value_field;
var
x : integer;
pgm_relative : boolean;
begin
pgm_relative:=false;
case two_bit of
'00' : write('absolute ');
'01' : write('program relative ');
'10' : write('data relative ');
'11' : write('common relative ');
end;
x:=address_field;
writeln(' = ',x);
end; (* value_field *)

procedure name_field;
var
i, n : integer;
begin
write('name field ');
n:=name_count;
write(' len =',n);
name:=' ';
for i:=1 to n do name[i]:=byte;
writeln(' = ',name);
end; (* name_field *)

procedure special_link;
begin
writeln('-- special link item');
case four_bit of
'0000' : begin
	write(' entry symbol ');
	name_field;
	end;
'0001' : begin
	write('select common block ');
	name_field;
	end;
'0010' : begin
	write('program name ');
	name_field;
	program_name:=name;
	end;
'0101' : begin
	write('define common size ');
	value_field;
	name_field;
	end;
'0110' : begin
	write('chain external ');
	value_field;
	name_field;
	end;
'0111' : begin
	write('define entry point ');
	value_field;
	name_field;
	end;
'1001' : begin
	write('external plus offset ');
	value_field;
	end;
'1010' : begin
	write('define data size ');
	value_field;
	end;
'1011' : begin
	write('set location counter');
	value_field;
	end;
'1100' : begin
	write('chain address ');
	value_field;
	end;
'1101' : begin
	write('define program size ');
	value_field;
	end;
'1110' : begin
	write('end module ');
	value_field;
	while bit_ptr <> 8 do ch:=bit;
	end;
'1111' : begin
	write('end file ');
	done:=true;
	end;
else :	begin
	writeln('*** error - unknown special item');
	read(i);
	end;
end; (* case *)
writeln;
end; (* special_item *)

procedure program_relative;
var
relocatable_field : integer;
begin
relocatable_field := address_field;
writeln('program relative = ',
	hexint(relocatable_field));
write(f2; relocatable_field);
rel_tab[rel_ptr]:=byte_count;
rel_ptr:=rel_ptr+1;
byte_count:=byte_count+2;
end;

procedure data_relative;
begin
writeln('data relative = ',
	hexint(address_field));
end;

procedure common_relative;
begin
writeln('common relative = ',
	hexint(address_field));
end;

procedure process_one_field;
begin
case bit of
'0' : byte_data;
'1' :	case two_bit of
	'00' : special_link;
	'01' : program_relative;
	'10' : data_relative;
	'11' : common_relative;
	end;
end;
end; (* process_one_field *)

begin (* convertm *)
init;

while not done do process_one_field;

write_suffixes;

close(f1);
close(f2);
update_control_record;

writeln('byte count =',byte_count);
writeln;
writeln('Convertm processing complete');
end (* convertm *).
