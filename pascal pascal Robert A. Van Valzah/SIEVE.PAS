const
    size = 8190;

type
    flagType = array[ 0..size ] of byte;

var
    i, k, prime, count, iter : word;
    flags : flagType;

begin
    for iter := 1 to 10 do begin
        count := 0;
        for i := 0 to size do flags[ i ] := 1;
        for i := 0 to size do begin
            if flags[ i ] = 1 then begin
                prime := i + i + 3;
                k := i + prime;
                while k <= size do begin
                    flags[ k ] := 0;
                    k := k + prime;
                end;
                count := count + 1;
            end;
        end;
    end;

    put#1( 'primes: ', count#, 13, 10 );
end.



