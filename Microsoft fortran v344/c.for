C     CONVERT FAHRENHEIT TO CENTIGRADE
      INTEGER F
      WRITE(5,5)
 5    FORMAT(33H        FAHRENHEIT     CENTIGRADE)
      DO 20 F=0,120,2
      C=5./9.*(F-32)
      WRITE(5,10)F,C
 10   FORMAT(15X,I3,7X,F8.2)
 20   CONTINUE
      END