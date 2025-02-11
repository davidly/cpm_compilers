{ Program 11.4
conversion to postfix form}

Program postfix;	{ * ( input, output ) is implicit in Pascal/Z * }

var	ch : char;
{*}	infile : text;		{ * data input file variable * }

procedure find;
begin
{*}	repeat read( infile, ch )	{ * read from data file * }
{*}	until ( ch <> ' ' ) and not eoln( infile );
end;

procedure expression;
	var	op : char;

	procedure term;

	procedure factor;
	begin
		if ch = '(' then
		begin
			find; expression;		{ch = )}
		end else write( ch );
		find
	end;					{factor}

	begin
		factor;
		while ch = '*' do
		begin
			find; factor; write( '*' )
		end
	end;					{term}

begin
	term;
	while ( ch = '+' ) or ( ch = '-' ) do
		begin
			op := ch; find; term; write( op )
		end
end;						{expression}

begin	{ * set 'data75' input file to the beginning and open for read * }
{*}	reset( 'data75', infile );
	find;
	repeat write(' ');
		expression;
		writeln
	until ch = '.'
end.
                                                              