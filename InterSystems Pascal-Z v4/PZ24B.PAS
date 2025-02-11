{Program 4.5
compute the cosine using the expansion:
cos( x ) = 1 - x**2/( 2 * 1 ) + x**4/( 4 * 3 * 2 * 1 ) - ...}

Program cosine;		{ * ( input, output ) is implicit in Pascal/Z * }

const	eps = 1E-14;
var	x, sx, s, t : real;
	i, k, n : integer;
{*}	infile : text;			{ * data input file variable  * }

begin	{ * set 'data24b' input file to beginning and open for read * }
{*}	reset( 'data24b', infile );
	{ * read from data input file * }
{*}	read( infile, n );
	for i := 1 to n	do
	begin
{*}		read( infile, x ); t := 1; k := 0; s := 1; sx := sqr( x );
		while abs( t ) > eps * abs( s ) do
		begin
			k := k + 2; t := -t * sx/( k * ( k-1 ) ); s := s + t
		end;
		writeln( x, s, k div 2 )
	end
end.
                                           