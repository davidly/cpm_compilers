definition module conversions;

export qualified buffer,
	intstr, strint, realstr, strreal;

type
buffer = array [1..80] of char;

procedure intstr ( i : integer; var s : integer; var str : buffer );
procedure strint ( s : integer; str : buffer; var i : integer );
procedure realstr ( r1 : real; var s : integer; var str : buffer );
procedure strreal ( s : integer; str : buffer; var r1 : real );

end conversions.
