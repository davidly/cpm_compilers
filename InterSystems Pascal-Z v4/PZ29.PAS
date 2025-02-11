{Program 4.8
exponentiation with natural exponent}

Program exponentiation;	{ * ( input, output ) is implicit in Pascal/Z * }

var	e, y : integer;
	u, x, z : real;
{*}	infile : text;		{ * data input file variable * }

begin	{ * set 'data29' input file to beginning and open for read * }
{*}	reset( 'data29', infile );
	{ * read from data input file * }
{*}	read( infile, x, y ); write( x, y );
	z := 1; u := x; e := y;
	while e > 0 do
	begin				{z * u**e=x**y, e > 0}
		while not odd( e ) do
			begin
				e := e div 2; u := sqr( u );
			end;
		e := e-1; z := u * z
	end;
	writeln( z )			{z = x**y}
end.
            