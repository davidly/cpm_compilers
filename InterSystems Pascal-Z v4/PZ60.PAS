{Program 9.1 -- frequency count of letters in input file}

Program fcount;		{ * ( input, output ) is implicit in Pascal/Z * }

var	ch : char;
	count : array[ 'a'..'z' ] of integer;
	letter : set of 'a'..'z';
{*}	infile : text;			{ * data input file variable * }

begin	{ * set 'data60' input file to beginning and open for read * }
{*}	reset( 'data60', infile );
	letter := [ 'a'..'z' ];
	for ch := 'a' to 'z' do count[ ch ] := 0;
{*}	while not eof( infile ) do
		begin		{ * read from data file * }
{*}			while not eoln( infile ) do
			begin
{*}				read( infile, ch ); write( ch );
				if ch in letter then
					count[ ch ] := count[ ch ] + 1
			end;
{*}			writeln; readln( infile )
		end
end.
                                                 