      program test
      integer*1 b(9)
      integer*4 X
      integer*4 I
      integer*1 J

      write( 1, 1001 )
      X = 1
      I = 2**8 + 2**9 + 2**10

      do 20 J=1,5
          I = I * 2
          b(j) = j * 2
          write(1,1000) I, X
 20   continue

      do 40 j = 1, 9
          write( 1, 1000 ) j, b(j)
 40   continue

 1000 FORMAT(11X,I7,11X,I5)
 1001 FORMAT('         dog cat')
      END
