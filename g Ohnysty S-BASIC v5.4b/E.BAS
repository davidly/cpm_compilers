VAR T, D, H, X, N = INTEGER
$CONSTANT MAX = 200
DIM INTEGER A( MAX )

    H = MAX
    X = 0
    N = H - 1
150 IF N <= 0 THEN GOTO 200
    A[ N ] = 1
    N = N - 1
    GOTO 150

200 A[ 1 ] = 2
    A[ 0 ] = 0

220 IF H <= 9 THEN GOTO 400
    H = H - 1
    N = H

240 IF N = 0 THEN GOTO 300
    D = X / N
    A[ N ] = X - D * N
    T = 10 * A[ N - 1 ]
    X = T + D
    N = N - 1
    GOTO 240

300 IF X >= 10 THEN GOTO 330
    PRINT USING "#"; X;
    GOTO 220
330 PRINT USING "##"; X;
    GOTO 220
400 PRINT ""
    PRINT "done"
    END


