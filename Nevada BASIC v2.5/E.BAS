100 D = 200
110 DIM A( 200 )
120 H = D
130 X = 0
140 N = H - 1
150 IF N <= 0 THEN GOTO 200
160 A( N + 1 ) = 1
170 N = N - 1
180 GOTO 150
200 A( 2 ) = 2
210 A( 1 ) = 0
220 IF H <= 9 then GOTO 400
230 H = H - 1
235 N = H
240 IF N = 0 then GOTO 300
245 Q = INT( X / N )
247 if 0 = X THEN R = 0 ELSE R = X - ( N * Q )
250 A( N + 1 ) = R
260 X = ( 10 * A( N ) ) + Q
270 N = N - 1
280 GOTO 240
300 print str(x);
340 GOTO 220
400 PRINT ""
410 PRINT "done"
420 BYE

