{Program 9.2 -- insert leading blank}

Program insert;		{ * ( input, output ) is implicit in Pascal/Z * }

var	ch : char;
{*}	infile : text;			{ * data input file variable * }

begin	{ * set 'data61' input file to the beginning and open for read * }
{*}	reset( 'data61', infile );
{*}	while not eof( infile ) do
	begin
		write( ' ' );
{*}		while not eoln( infile ) do
			{ * read from data file * }
			begin
{*}				read( infile, ch ); write( ch );
			end;
{*}		writeln; readln( infile )
	end
end.
                                                                                                                          