    REM can't use 8190 -- fails with a memory error
    REM for 6500, expect 1548, not 1899 as a result
    SIZE = 6500
    DIM FLAGS(6501)
    PRINT "10 iterations"
    FOR X = 1 TO 10
    COUNT = 0
    FOR I = 0 TO SIZE
    FLAGS(I) = 1
    NEXT I
    FOR I = 0 TO SIZE
    IF FLAGS(I) = 0 THEN GOTO 18
    PRIME = I + I + 3
    K = I + PRIME
13  IF K > SIZE THEN GOTO 17
    FLAGS(K) = 0
    K = K + PRIME
    GOTO 13
17 COUNT = COUNT + 1
18 NEXT I
   NEXT X
   PRINT COUNT," PRIMES"
   X = CALL( 0, 0 )

