begin

procedure main;
begin
    integer array a[0:200];
    integer high, n, x, d;

    high := 200;
    x := 0;
    
    n := high - 1;
    while n > 0 do begin
        a[ n ] := 1;
        n := n - 1;
    end;
    
    a[ 1 ] := 2;
    a[ 0 ] := 0;
    
    while high > 9 do begin
        n := high;
        high := high - 1;
        while 0 <> n do begin
            d := x / n;
            a[ n ] := x - ( d * n );
            x := 10 * a[ n - 1 ] + d;
            n := n - 1;
        end;
        writeon( x );
    end;
    
    write( "done" );
end;

main;

end

