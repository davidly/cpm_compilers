{Program 4.2
computer h( n ) = 1 + 1/2 + 1/3 + ... + 1/n}

Program egwhile;	{ * (input, output ) is implicit in Pascal/Z * }

var	n : integer;
	h : real;

begin
	read( n ); write( n );
	h := 0;
	while n > 0 do
		begin
			h := h + 1/n; n := n - 1
		end;
	writeln( h )
end.
                                                                                              