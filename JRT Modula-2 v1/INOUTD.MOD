definition module inout;

export qualified
	buffer,
	eol, done, termch,
	openinput, openoutput, closeinput, closeoutput,
	read, readstring, readint,
	write, writeln, writestring, writeint, writehex;

const
eol = 0dh;
var
done : boolean;
termch : char;

type
buffer = array [1..80] of char;

procedure openinput ( deftext : buffer );
procedure openoutput ( deftext : buffer );
procedure closeinput;
procedure closeoutput;
procedure read ( var ch : char );
procedure readstring ( var s : buffer );
procedure readint ( var x : integer );
procedure write( ch : char );
procedure writeln;
procedure writestring ( s : buffer );
procedure writeint ( x, n : integer );
procedure writehex ( x, n : integer );

end inout.
