   10 PRINT "                       Graph of SIN": PRINT 
   20 LET P0=3.1415926
   30 LET P1=-P0
   40 LET Z=60/2
   50 FOR A=P1 TO P0 STEP .12
   60 LET W=SIN(A)*30+30
   70 LET I0=30
   80 IF W>30 THEN  LET I0=W
   90 IF W>30 THEN 210
  100 REM asterisks are on left side of center line
  110 IF W<1 THEN  LET W=2
  120 IF W<=2 THEN 160
  130 FOR I=1 TO W-1
  140 PRINT " ";
  150 NEXT I
  160 FOR I=W TO I0
  170 PRINT "*";
  180 NEXT I
  190 PRINT "+"
  200 GOTO 300
  210 REM asterisks are on right side of center line
  220 FOR I=1 TO Z-1
  230 PRINT " ";
  240 NEXT I
  250 PRINT "+";
  260 FOR I=Z+1 TO W
  270 PRINT "*";
  280 NEXT I
  290 PRINT 
  300 NEXT A
 PRINT " ";
  240 NEXT I
  250 PRINT "+";
  260 FOR I=Z+1 TO W
