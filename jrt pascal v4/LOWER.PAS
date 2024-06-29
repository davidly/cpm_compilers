{ this program takes an input textual file and converts all
 characters except those inside single quotes to lower case }


{=================================================================}
PROGRAM lower;
VAR
ch, ch_1a : char;
count : integer;
string_flag : boolean;
infile, outfile :  ARRAY [1..16] OF char;
upper_case : SET OF char;
f1, f2 : FILE OF char;


BEGIN

writeln;
string_flag := false;
ch_1a := chr(1ah);
upper_case := ['A'..'Z'];
WHILE true DO
       BEGIN
       count := 0;
       write('input filename (or ctl-c to end) : ');
       readln(infile);
       write('output filename : ');
       readln(outfile);
       reset(f1, infile, binary, 4096);
       rewrite(f2, outfile, binary, 4096);
       read(f1; ch);
       WHILE NOT (eof(f1)) AND (ch <> ch_1a) DO
              BEGIN
              IF ch = '''' THEN
                     IF string_flag THEN
                            string_flag := false
                     ELSE
                            string_flag := true;
              IF NOT string_flag THEN
                     IF ch IN upper_case THEN
                            ch := chr(ord(ch) + 20h);
              write(f2; ch);
              write(ch);
              count := count + 1;
              read(f1; ch);
              END;
       writeln;
       writeln('byte count =', count);
       writeln;
       writeln;
       close(f1);
       close(f2);
       END;
END.
