C Eratosthenes Sieve from BYTE magazine, all 8191 flags.
C INTEGER arrays can't hold 8191 flags in the memory available, so each
C flag is one bit: the BIT routine works on the 48 bits of a REAL. Flag n
C is bit B of word W, where n = 48 * ( W - 1 ) + B. A set bit means composite.
C Word and bit are advanced by addition rather than computed by division.
      REAL FLAGS( 171 )
      INTEGER I, PRIME, COUNT, ITER, W, B, F, KW, KB, PW, PB
      DO 96 ITER = 1, 10
      COUNT = 0
      DO 10 I = 1, 171
      FLAGS( I ) = 0.0
  10  CONTINUE
      W = 1
      B = 0
      DO 95 I = 0, 8190
      CALL BIT( FLAGS( W ), B, 'T', F )
      IF ( F .NE. 0 ) GOTO 90
      PRIME = I + I + 3
      PW = PRIME / 48
      PB = PRIME - PW * 48
C K = I + PRIME, as word KW and bit KB
      KW = W + PW
      KB = B + PB
      IF ( KB .LT. 48 ) GOTO 20
      KB = KB - 48
      KW = KW + 1
  20  IF ( 48 * ( KW - 1 ) + KB .GT. 8190 ) GOTO 85
      CALL BIT( FLAGS( KW ), KB, 'S' )
      KW = KW + PW
      KB = KB + PB
      IF ( KB .LT. 48 ) GOTO 20
      KB = KB - 48
      KW = KW + 1
      GOTO 20
  85  COUNT = COUNT + 1
  90  B = B + 1
      IF ( B .LT. 48 ) GOTO 95
      B = 0
      W = W + 1
  95  CONTINUE
  96  CONTINUE
      WRITE (1, 100) COUNT
      STOP
 100  FORMAT( I6 )
      END

