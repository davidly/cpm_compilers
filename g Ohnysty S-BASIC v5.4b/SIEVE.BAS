VAR PRIME, COUNT, X, I, K = INTEGER
$CONSTANT MAX = 8190
DIM BYTE FLAGS(MAX + 1)

    PRINT "10 iterations"
    FOR X = 1 TO 10
        COUNT = 0
        FOR I = 0 TO MAX
            FLAGS(I) = 1
        NEXT I

        FOR I = 0 TO MAX
            IF FLAGS(I) = 0 THEN 18
            PRIME = I + I + 3
            K = I + PRIME
13          IF K > MAX THEN 17
            FLAGS(K) = 0
            K = K + PRIME
            GOTO 13
17          COUNT = COUNT + 1
18      NEXT I
    NEXT X

    PRINT COUNT," PRIMES"
    END

