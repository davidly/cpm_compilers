{Program 11.7
test side effect}

Program sideffect;		{ * (output ) is implicit in Pascal/Z * }

var	a, z : integer;

function sneaky( x : integer ) : integer;
begin
	z := z - x;		{side effect on z}
	sneaky := sqr( x );
end;	{ * sneaky * }

begin
	z := 10; a := sneaky( z ); writeln( a, z );
	z := 10; a := sneaky( 10 ) * sneaky( z ); writeln( a, z );
	z := 10; a := sneaky( z ) * sneaky( 10 ); writeln( a, z );
end.
                                                                             