REM BYTE MAGAZINE OCTOBER 1982. JERRY POURNELLE. MATRIX MULTIPLY.
REM INTEGER VERSION: EACH C ELEMENT FITS IN 16 BITS; SUM KEPT IN BASE 10000
REM / OF INTEGERS IS INTEGER DIVISION. THE SUM IS PRINTED A DIGIT AT A TIME
VAR I, J, K, SH, SL, P, D = INTEGER
DIM INTEGER A(20,20)
DIM INTEGER B(20,20)
DIM INTEGER C(20,20)

PROCEDURE FILLA
    FOR I = 1 TO 20
        FOR J = 1 TO 20
            A(I,J) = I + J
        NEXT J
    NEXT I
END

PROCEDURE FILLB
    FOR I = 1 TO 20
        FOR J = 1 TO 20
            B(I,J) = (I+J)/J
        NEXT J
    NEXT I
END

PROCEDURE FILLC
    FOR I = 1 TO 20
        FOR J = 1 TO 20
            C(I,J) = 0
        NEXT J
    NEXT I
END

PROCEDURE MATMULT
    FOR I = 1 TO 20
        FOR J = 1 TO 20
            FOR K = 1 TO 20
                C(I,J) = C(I,J) + A(I,K) * B(K,J)
            NEXT K
        NEXT J
    NEXT I
END

PROCEDURE SUMMIT
    FOR I = 1 TO 20
        FOR J = 1 TO 20
            SL = SL + C(I,J)
100         IF SL < 10000 THEN GOTO 110
            SL = SL - 10000
            SH = SH + 1
            GOTO 100
110     NEXT J
    NEXT I
END

    SH = 0
    SL = 0
    FILLA
    FILLB
    FILLC
    MATMULT
    SUMMIT
    PRINT "SUM = ";
    PRINT USING "##"; SH;
    P = 1000
200 D = (SL / P) - (SL / (P * 10)) * 10
    PRINT USING "#"; D;
    P = P / 10
    IF P > 0 THEN GOTO 200
    PRINT ""
    END
