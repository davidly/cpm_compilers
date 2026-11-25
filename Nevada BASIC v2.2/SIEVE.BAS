1 S = 8190
2 DIM F$(8192)
3 PRINT "10 iterations"
4 FOR X = 1 TO 10
5 C = 0
6 F$ = "1"
7 IF LEN(F$) < S+1 THEN F$ = F$ + F$ : GOTO 7
10 FOR I = 0 TO S
11 IF F$(I+1,I+1) = "0" THEN GOTO 19
12 P = I + I + 3
13 FOR K = I + P TO S STEP P
15 F$(K+1,K+1) = "0"
16 NEXT K
18 C = C + 1
19 NEXT I
20 NEXT X
21 PRINT C;
22 PRINT " PRIMES"
23 BYE
24 REM Nevada BASIC has only floating-point numbers, and an array of 8191 of them
25 REM doesn't fit in memory, so each flag is one character of F$ ("1" prime,
26 REM "0" composite). F$ is filled by doubling it, as one character at a time
27 REM takes far longer. Multiples are marked with FOR/STEP, the fastest loop here.

