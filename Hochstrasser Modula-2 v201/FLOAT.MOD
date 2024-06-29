MODULE floating;

IMPORT MathLib;

PROCEDURE testReal;

VAR
    r, a, b, c, d : REAL;
    i, x : INTEGER;
    car : CARDINAL;

BEGIN
    a := 1.1;
    b := 2.2;
    c := 3.3;
    d := FLOAT( 69 );

    FOR i := 1 TO 10 DO
        a := b * c;
        b := a * c;
        r := MathLib.arctan( a );
        r := MathLib.cos( a );
        r := MathLib.exp( c );
        IF a <= 32727.0 THEN car := CARD( a ); END;
        IF a <= 32727.0 THEN r := FLOAT( CARD( a ) ); END;
        r := MathLib.ln( a );
        r := MathLib.sin( a );
        r := a * a;
        r := MathLib.sqrt( a );
        IF a <= 32767.0 THEN x := CARD( a ); END;
    END;

(*    WRITELN( "real a, b, c, d, x, r: ", a, b, c, d, x, r ); *)
END testReal;

BEGIN
    testReal;
END floating.



