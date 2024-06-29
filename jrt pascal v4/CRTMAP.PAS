
%TITLE('----- CRT Mapping Utility _____')
%PAGE(50)

{ This version setup for Televideo terminals.  To adapt to other
terminals modify PROCEDURE PART2 which generates the cursor
positioning (gotoxy) and clear screen (clear) codes. }


{=================================================================}
PROGRAM crtmap;
TYPE
char16 =  ARRAY [1..16] OF char;

VAR
ch : char;
alphameric : SET OF char;
end_of_file : boolean;
map_file_name : STRING[15];
word : char16;
exproc_name : char16;
include_name : char16;
record_name : char16;
f1, f2 : FILE OF char;


{=================================================================}
PROCEDURE error (msg : STRING[40]);
VAR
dummy : char16;

BEGIN
writeln;
writeln;
writeln(msg);
writeln;
{ abnormally terminate - return to CP/M }

call(0, dummy, dummy);
END;


{=================================================================}
PROCEDURE get_char;

BEGIN
read(f1; ch);
IF ch = chr(1ah) THEN
       error('Premature end of input file');
write(ch);
END;


{=================================================================}
PROCEDURE get_word;
LABEL 99;
VAR
i : integer;

BEGIN
word := ' ';
WHILE NOT (ch IN alphameric) DO
       BEGIN
       get_char;
       END;
word[1] := ch;
i := 2;
get_char;
WHILE (ch IN alphameric) DO
       BEGIN
       word[i] := ch;
       i := i + 1;
       get_char;
       END;
word := upcase(word);
END;  {get_word}


{=================================================================}
PROCEDURE init;

BEGIN
writeln('CRTMAP  ver 4.0');
writeln;
write('name of Map Description File : ');
readln(map_file_name);
writeln;
writeln;
reset(f1, map_file_name, binary, 256);
end_of_file := false;
ch := ' ';
alphameric := ['A'..'Z', 'a'..'z', '0'..'9', ':', '.', '_', '$'];
       
get_word;
IF word <> 'EXPROC' THEN
       error('EXPROC command expected');
get_word;
exproc_name := word;
rewrite(f2, exproc_name + '.pas', binary, 256);
get_word;
IF word <> 'INCLUDE' THEN
       error('INCLUDE command expected');
get_word;
include_name := word;
get_word;
IF word <> 'RECORD' THEN
       error('RECORD command expected');
get_word;
record_name := word;
END;  {init}


{=================================================================}
PROCEDURE part1;

BEGIN
writeln(f2; '{ CRTMAP generated external procedure }');
writeln(f2; 'extern');
writeln(f2);
writeln(f2; 'type');
writeln(f2; '%include (''', include_name, ''')');
writeln(f2);
writeln(f2; 'procedure ', exproc_name, '( var r : ', record_name, 
       ');');
writeln(f2);
END;  {part1}


{=================================================================}
PROCEDURE part2;

BEGIN
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
END;  {part2}


{=================================================================}
PROCEDURE part3;  {create DISPLAY procedure}


{=================================================================}
PROCEDURE process_coordinates;
VAR
x_coord, y_coord : char16;

BEGIN
get_word;
x_coord := word;
get_word;
y_coord := word;
writeln(f2; 'gotoxy( ', x_coord, ',', y_coord, ');');
END;


{=================================================================}
PROCEDURE process_string;

BEGIN
{find start of string}

WHILE NOT (ch IN ['''', chr(0dh), ' ', chr(9), chr(1ah)]) DO
       get_char;
IF ch <> '''' THEN
       error('Literal string expected');
write(f2; 'write(');
REPEAT
       write(f2; ch);
       get_char;
UNTIL ch = chr(0dh);
writeln(f2; ');');
END;

BEGIN  {part3}

writeln(f2; 'procedure display;');
writeln(f2; 'begin');
writeln(f2; 'clear;');
WHILE NOT end_of_file DO
       BEGIN
       get_word;
       CASE word OF
       'LITERAL' :
              BEGIN
              process_coordinates;
              process_string;
              END;
       'FIELD' :
              BEGIN
              process_coordinates;
              get_word;
              writeln(f2; 'write( r.', word, ');');
              END;
       'CURSOR' :
              process_coordinates;
       'END' :
              end_of_file := true;
       ELSE :
              error('LITERAL, FIELD, CURSOR or END command expected');
       END;
       END;
writeln(f2; 'end;');
writeln(f2);
END;  {part3}


{=================================================================}
PROCEDURE part9;

BEGIN
writeln(f2; 'begin');
writeln(f2; 'display;');
writeln(f2; 'end;.');
END;  {part9}

BEGIN  {crtmap}

init;
part1;
part2;
part3;
part9;
close(f1);
close(f2);
END  {crtmap}  .
