C     should tend towards 1.61803398874989484820458683436563811772030
      program phi
      real*8 d, d1, d2
      real*4 r, r1, r1
      integer*4 prev2, prev1, next
      integer i

      write( 1, 1005 )
      prev2 = 1
      prev1 = 1

      do 10 i = 1, 40, 1
          next = prev1 + prev2
          prev2 = prev1
          prev1 = next

          d2 = prev2
          d1 = prev1
          d = d1 / d2

          r2 = prev2
          r1 = prev1
          r = r1 / r2

          write( 1, 1000 ) i, d, r
10    continue

      write( 1, 1003 )
1000  format( 5X, 'iteration ', I4, '  r8: ', F18.16, '  r4: ', F12.10 )
1003  format( ' complete' )
1005  format( ' should tend towards 1.61803398874989484820458683436563
     c811772030' )
      end

