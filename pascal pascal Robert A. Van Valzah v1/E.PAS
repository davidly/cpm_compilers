const
   DIGITS = 200;

type
    arrayType = array[ 0..DIGITS ] of byte;

var
    high, n, x, d : word;
    a : arrayType;

begin
    high := DIGITS;
    x := 0;

    n := high - 1;
    while n > 0 do begin
        a[ n ] := 1;
        n := n - 1;
    end;

    a[ 1 ] := 2;
    a[ 0 ] := 0;

    while high > 9 do begin
        high := high - 1;
        n := high;
        while 0 <> n do begin
            d := x / n;
            a[ n ] := x - ( d * n );
            x := 10 * a[ n - 1 ] + d;
            n := n - 1;
        end;

        put#1( x# );
    end;

    put#1(13,10,'done    ',13,10);
end.

