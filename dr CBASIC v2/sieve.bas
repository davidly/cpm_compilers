1 SIZE% = 8190
2 DIM FLAGS%(8191)
3 PRINT "10 iterations"
4 FOR X% = 1 TO 10
5 COUNT% = 0
6 FOR I% = 0 TO SIZE%
7 FLAGS%(I%) = 1
8 NEXT I%
9 FOR I% = 0 TO SIZE%
10 IF FLAGS%(I%) = 0 THEN 18
11 PRIME% = I% + I% + 3
12 K% = I% + PRIME%
13 IF K% > SIZE% THEN 17
14 FLAGS%(K%) = 0
15 K% = K% + PRIME%
16 GOTO 13
17 COUNT% = COUNT% + 1
18 NEXT I%
19 NEXT X%
20 PRINT COUNT%," PRIMES"