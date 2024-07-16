1 S = 4095
2 DIM f(S+ 1)
3 PRINT "10 iterations"
4 FOR X = 1 TO 10
5 C = 0
6 FOR I = 1 TO S + 1
7 F( I ) = 1
8 NEXT I
9 FOR I = 0 TO S
10 IF f(I + 1) = 0 THEN GOTO 18
11 P = I + I + 3
12 K = I + P
13 IF K > S THEN GOTO 17
14 f(K + 1) = 0
15 K = K + P
16 GOTO 13
17 c = c + 1
18 NEXT I
19 NEXT X
20 PRINT c;
22 PRINT " PRIMES"
23 BYE

