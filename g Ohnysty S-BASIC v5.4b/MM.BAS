REM BYTE MAGAZINE OCTOBER 1982. JERRY POURNELLE. MATRIX MULTIPLY.
REM A AND B HOLD SMALL WHOLE NUMBERS, SO THE SUM IS EXACTLY 465880
VAR I, J, K = INTEGER
VAR SUM = REAL
DIM REAL A(20,20)
DIM REAL B(20,20)
DIM REAL C(20,20)

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
            B(I,J) = INT((I+J)/J)
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
            SUM = SUM + C(I,J)
        NEXT J
    NEXT I
END

    SUM = 0
    FILLA
    FILLB
    FILLC
    MATMULT
    SUMMIT
    PRINT "SUM = "; SUM
    END
