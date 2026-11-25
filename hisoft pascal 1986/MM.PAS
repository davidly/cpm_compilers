{ BYTE MAGAZINE OCTOBER 1982. JERRY POURNELLE. }
{ VARIOUS BUGS NOT FOUND BECAUSE DIMENSIONS ARE SQUARE FIXED BY DAVID LEE }
{ A AND B HOLD SMALL WHOLE NUMBERS, SO EVERY REAL FORMAT GETS EXACTLY 465880 }
{ EXPECTED RESULT: 465880 }

{$A-,O-,C-,S-  CHECKS OFF TO REDUCE CODE SIZE }

PROGRAM MATRIX;

CONST
    L = 20; { ROWS IN A AND RESULTING MATRIX C }
    M = 20; { COLUMNS IN A AND ROWS IN B (MUST BE IDENTICAL) }
    N = 20; { COLUMNS IN B AND RESULTING MATRIX C }

VAR
    A : ARRAY [ 1 .. L, 1 .. M ] OF REAL; { [ROW,COL] }
    B : ARRAY [ 1 .. M, 1 .. N ] OF REAL;
    C : ARRAY [ 1 .. L, 1 .. N ] OF REAL;

    SUMM: REAL;

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
            B[ I, J ] := TRUNC( ( I + J ) / J );
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
            SUMM := SUMM + C[ I, J ];
END; { SUMMIT }

BEGIN { MATRIX }
    SUMM := 0;

    FILLA;
    FILLB;
    FILLC;
    MATMULT;
    SUMMIT;

    WRITELN( 'summ is : ', SUMM:10:1 );
END. { MATRIX }
