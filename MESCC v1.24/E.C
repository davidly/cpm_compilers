#include <mescc.h>
#include <printf.h>
#include <fileio.h>
#include <string.h>

#define DIGITS_TO_FIND 200 /*9009;*/
main() {
  int N;
  int x ;
  int a[ DIGITS_TO_FIND ];
  int n;

  x = 0;
  N = DIGITS_TO_FIND;

  for (n = N - 1; n > 0; --n) {
      a[n] = 1;
  }

  a[1] = 2;
  a[0] = 0;
  while (N > 9) {
      n = N--;
      while (--n) {
          a[n] = x % n;

          x = 10 * a[n-1] + x/n;
      }
      printf("%d", x);
  }

  printf( "\ndone\n" );

  return 0;
}
