definition module realinout;

export qualified
	readreal, writereal;

var
done : boolean;

procedure readreal (var x : real);
procedure writereal (x : real; n : integer);

end realinout.
