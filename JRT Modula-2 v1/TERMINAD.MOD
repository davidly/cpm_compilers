definition module terminal;

export qualified
	console, tab, read, busyread, readagain,
	write, writeln, writestring, printer;

type
char256 = array [1..256] of char;
var
column : integer;
console, printer : boolean;

procedure read ( var ch : char );
procedure busyread ( var ch : char );
procedure readagain;
procedure write ( ch : char );
procedure writeln;
procedure writestring ( s : char256 );
procedure tab ( x : integer );

end terminal.
