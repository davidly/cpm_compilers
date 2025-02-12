    DIM VALS( 200 )
    HIGH = 200
    X = 0
    N = HIGH - 1
150 IF N <= 0 THEN GOTO 200
    LET VALS( N ) = 1
    LET N = N - 1
    GOTO 150
200 LET VALS( 1 ) = 2
    LET VALS( 0 ) = 0
220 IF HIGH <= 9 THEN GOTO 400
    HIGH = HIGH - 1
    N = HIGH
240 IF N = 0 THEN 300
    LET D = INT( X / N )
    LET VALS( N ) = X - ( D * N )
    LET X = ( 10 * VALS( N - 1 ) ) + D
    LET N = N - 1
    GOTO 240
300 PRINT X;
    GOTO 220
400 PRINT ""
    PRINT "done"
    X = CALL( 0, 0 )
    END

