MODULE floating;

IMPORT MathLib;
IMPORT LongMath;

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
        r := MathLib.Arctan( a );
        r := MathLib.Cos( a );
        r := MathLib.Exp( c );
        IF a <= 32727.0 THEN car := CARD( a ); END;
        IF a <= 32727.0 THEN r := FLOAT( CARD( a ) ); END;
        r := MathLib.Ln( a );
        r := MathLib.Sin( a );
        r := a * a;
        r := MathLib.Sqrt( a );
        IF a <= 32767.0 THEN x := CARD( a ); END;
    END;

    WRITELN( "real a, b, c, d, x, r: ", a, b, c, d, x, r );
END testReal;

PROCEDURE testLongReal;

VAR
    r, a, b, c, d : LONGREAL;
    i, x : INTEGER;
    car : CARDINAL;

BEGIN
    a := 1.1D0;
    b := 2.2D0;
    c := 3.3D0;
    d := DOUBLE( 69 );

    FOR i := 1 TO 10 DO
        a := b * c;
        b := a * c;
        r := LongMath.Arctan( a );
        r := LongMath.Cos( a );
        r := LongMath.Exp( c );
        IF a <= 32727.0D0 THEN car := CARD( a ); END;
        IF a <= 32727.0D0 THEN r := DOUBLE( CARD( a ) ); END;
        r := LongMath.Ln( a );
        r := LongMath.Sin( a );
        r := a * a;
        r := LongMath.Sqrt( a );
        IF a <= 32767.0D0 THEN x := CARD( a ); END;
    END;

    WRITELN( "LongReal a, b, c, d, x, r: ", a, b, c, d, x, r );
END testLongReal;

BEGIN
    testReal;
    testLongReal;
END floating.



                                                                                  