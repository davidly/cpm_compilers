{Program 13.1
alfa values}

Program egalfa;
{ * The type alfa is pre-defined by:				* }
{ *	type	alfa = packed array[ 1..10 ] of char;		* }
{ *								* }
{ *Since Pascal/Z does not have the pre-defined type		* }
{ *alfa, and all arrays in Pascal/Z are packed implicitly,	* }
{ *alfa must be re-defined as below				* }

{*}type	alfa = array[ 1..10 ] of char;
var	n1, n2 : alfa;

begin
	write( 'names : ' );
	n1 := 'raymond   '; n2 := 'debby     ';
	if n2 < n1 then writeln( n2, n1 )
		else writeln( n1, n2 )
end.
                                                                                                          