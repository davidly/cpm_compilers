      real d, d1, d2
      rem using real instead of 2-byte integers means more range but drifting precision
      real prev2, prev1, n
      integer i

      print "should tend towards 1.61803398874989484820458683436563811772030"
      prev2 = 1.0
      prev1 = 1.0

      for i = 1 to 30
          n = prev1 + prev2
          prev2 = prev1
          prev1 = n

          d2 = prev2
          d1 = prev1
          d = d1 / d2

          print "iteration, r:  "; i; d
      next i

      print "complete"
      stop

