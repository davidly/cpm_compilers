MODULE e;

import terminal;
import inout;

VAR
    hi, n, x : integer;
    a : array [ 0..200 ] of integer;

BEGIN
    hi := 200;
    x := 0;

    n := hi - 1;
    WHILE n > 0 DO
        a[ n ] := 1;
        n := n - 1;
    END;

    a[ 1 ] := 2;
    a[ 0 ] := 0;

    WHILE hi > 9 DO
        hi := hi - 1;
        n := hi;
        WHILE 0 <> n DO
            a[ n ] := x MOD n;
            x := 10 * a[ n - 1 ] + x DIV n;
            n := n - 1;
        END;
        if n >= 10 then
            inout.writeint( x, 2 );
        else
            inout.writeint( x, 1 );
        end;

    END;

    terminal.writeln;
    terminal.writestring( 'done$' );
    terminal.writeln;
END e.

