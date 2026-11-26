{ BYTE MAGAZINE OCTOBER 1982. JERRY POURNELLE. }
{ VARIOUS BUGS NOT FOUND BECAUSE DIMENSIONS ARE SQUARE FIXED BY DAVID LEE }
{ INTEGER VERSION: EACH C ELEMENT FITS IN 16 BITS; SUM KEPT IN BASE 10000 }
{ EXPECTED RESULT: 465880 }

PROGRAM MATRIX;

CONST
    L = 20; { ROWS IN A AND RESULTING MATRIX C }
    M = 20; { COLUMNS IN A AND ROWS IN B (MUST BE IDENTICAL) }
    N = 20; { COLUMNS IN B AND RESULTING MATRIX C }

VAR
    A : ARRAY [ 1 .. L, 1 .. M ] OF INTEGER; { [ROW,COL] }
    B : ARRAY [ 1 .. M, 1 .. N ] OF INTEGER;
    C : ARRAY [ 1 .. L, 1 .. N ] OF INTEGER;

    SUMMHI, SUMMLO : INTEGER;

PROCEDURE FILLA;
VAR
    I, J : INTEGER;
BEGIN { FILLA }
    FOR I := 1 TO L DO
        FOR J := 1 TO M DO
            A[ I, J ] := I + J;
END; { FILLA }

PROCEDURE FILLB;
VAR
    I, J : INTEGER;
BEGIN { FILLB }
    FOR I := 1 TO M DO
        FOR J := 1 TO N DO
            B[ I, J ] := ( I + J ) DIV J;
END; { FILLB }

PROCEDURE FILLC;
VAR
    I, J : INTEGER;
BEGIN { FILLC }
    FOR I := 1 TO L DO
        FOR J := 1 TO N DO
            C[ I, J ] := 0;
END; { FILLC }

PROCEDURE MATMULT;
VAR
    I, J, K : INTEGER;
BEGIN { MATMULT }
    FOR I := 1 TO L DO
        FOR J := 1 TO N DO
            FOR K := 1 TO M DO
                C[ I, J ] := C[ I, J ] + A[ I, K ] * B[ K, J ];
END; { MATMULT }

PROCEDURE SUMMIT;
VAR
    I, J : INTEGER;
BEGIN { SUMMIT }
    FOR I := 1 TO L DO
        FOR J := 1 TO N DO
            BEGIN
                SUMMLO := SUMMLO + C[ I, J ];
                WHILE SUMMLO >= 10000 DO
                BEGIN
                    SUMMLO := SUMMLO - 10000;
                    SUMMHI := SUMMHI + 1;
                END;
            END;
END; { SUMMIT }

BEGIN { MATRIX }
    SUMMHI := 0;
    SUMMLO := 0;

    FILLA;
    FILLB;
    FILLC;
    MATMULT;
    SUMMIT;

    WRITE( 'summ is : ', SUMMHI:1 );
    IF SUMMLO < 1000 THEN WRITE( '0' );
    IF SUMMLO < 100 THEN WRITE( '0' );
    IF SUMMLO < 10 THEN WRITE( '0' );
    WRITELN( SUMMLO:1 );
END. { MATRIX }
