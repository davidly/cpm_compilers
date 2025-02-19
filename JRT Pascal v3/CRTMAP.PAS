%title('----- CRT Mapping Utility _____')
%page(50)

{ This version setup for Televideo terminals.  To adapt to other
terminals modify PROCEDURE PART2 which generates the cursor
positioning (gotoxy) and clear screen (clear) codes. }

program crtmap;

type
char16 = array [1..16] of char;

var
ch : char;
alphameric : set of char;
end_of_file : boolean;
map_file_name : string[15];
word : char16;
exproc_name : char16;
include_name : char16;
record_name : char16;
f1, f2 : file of char;


procedure error ( msg : string[40] );
var
dummy : char16;
begin
writeln;
writeln;
writeln(msg);
writeln;
{ abnormally terminate - return to CP/M }
call(0,dummy,dummy);
end;

procedure get_char;
begin
read(f1; ch);
if ch = chr(1ah) then error('Premature end of input file');
write(ch);
end;

procedure get_word;
label 99;
var
i : integer;
begin
word := ' ';
while not (ch in alphameric) do
	begin
	get_char;
	end;
word[1] := ch;
i := 2;
get_char;
while (ch in alphameric) do
	begin
	word[i] := ch;
	i := i + 1;
	get_char;
	end;
word := upcase(word);
end; {get_word}


procedure init;
begin
writeln('CRTMAP  ver 3.0');
writeln;
write('name of Map Description File : ');
readln(map_file_name);
writeln;
writeln;
reset(f1,map_file_name,binary,256);
end_of_file := false;
ch := ' ';
alphameric := ['A'..'Z','a'..'z','0'..'9',':','.','_','$'];
get_word;
if word <> 'EXPROC' then error('EXPROC command expected');
get_word;
exproc_name := word;
rewrite(f2, exproc_name + '.pas', binary, 256);
get_word;
if word <> 'INCLUDE' then error('INCLUDE command expected');
get_word;
include_name := word;
get_word;
if word <> 'RECORD' then error('RECORD command expected');
get_word;
record_name := word;
end; {init}


procedure part1;
begin
writeln(f2; '{ CRTMAP generated external procedure }');
writeln(f2; 'extern');
writeln(f2);
writeln(f2; 'type');
writeln(f2; '%include (''',include_name,''')');
writeln(f2);
writeln(f2; 'procedure ',exproc_name, '( var r : ', record_name,');');
writeln(f2);
end; {part1}


procedure part2;
begin
writeln(f2; 'procedure clear;');
writeln(f2; 'begin');
writeln(f2; 'write(chr(27),''*'');');
writeln(f2; 'end;');
writeln(f2);
writeln(f2; 'procedure gotoxy ( x,y : integer );');
writeln(f2; 'begin');
writeln(f2; 'write(chr(27),''='',chr(y+20h),chr(x+20h));');
writeln(f2; 'end;');
writeln(f2);
end; {part2}


procedure part3;	{create DISPLAY procedure}

procedure process_coordinates;
var
x_coord, y_coord : char16;
begin
get_word;
x_coord := word;
get_word;
y_coord := word;
writeln(f2; 'gotoxy( ',x_coord,',',y_coord,');');
end;

procedure process_string;
begin
{find start of string}
while not (ch in ['''',chr(0dh),' ',chr(9),chr(1ah)]) do
	get_char;
if ch <> '''' then error('Literal string expected');
write(f2; 'write(');
repeat
  write(f2; ch);
  get_char;
until ch = chr(0dh);
writeln(f2; ');');
end;


begin {part3}
writeln(f2; 'procedure display;');
writeln(f2; 'begin');
writeln(f2; 'clear;');
while not end_of_file do
	begin
	get_word;
	case word of
	'LITERAL' :
		begin
		process_coordinates;
		process_string;
		end;
	'FIELD' :
		begin
		process_coordinates;
		get_word;
		writeln(f2; 'write( r.',word,');');
		end;
	'CURSOR' : process_coordinates;
	'END' : end_of_file := true;
	else : error('LITERAL, FIELD, CURSOR or END command expected');
	end;
	end;
writeln(f2; 'end;' );
writeln(f2);
end; {part3}


procedure part9;
begin
writeln(f2; 'begin');
writeln(f2; 'display;');
writeln(f2; 'end;.');
end; {part9}


begin {crtmap}
init;
part1;
part2;
part3;
part9;
close(f1);
close(f2);
end {crtmap}.
