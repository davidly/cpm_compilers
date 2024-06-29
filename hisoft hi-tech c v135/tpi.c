#include <stdio.h>

/*
#include <stdint.h>
*/

#define HIGH_MARK  800
#define MAX_ITERATIONS 1
long r[HIGH_MARK + 1];

int main() {
    long i, k;
    long b, d, c, v;
    long iteration;

    printf( "sizeof int: %u\n", sizeof( int ) );
    printf( "sizeof long: %u\n", sizeof( long ) );

    for ( iteration = 0; iteration < MAX_ITERATIONS; iteration++ ) {
        c = 0;

        for (i = 0; i < HIGH_MARK; i++) {
            r[i] = 2000;
        }
    
        for (k = HIGH_MARK; k > 0; k -= 14) {
            d = 0;
    
            i = k;
            for (;;) {
                d += r[i] * 10000;
                b = 2 * i - 1;
    
                r[i] = d % b;
                d /= b;
                i--;
                if (i == 0) break;
                d *= i;
            }
            if ( iteration == ( MAX_ITERATIONS - 1 ) )
            {
                v = c + d / 10000;
                if ( v < 1000 )
                {
                    printf( "0" );
                    if ( v < 100 )
                    {
                        printf( "0" );
                        if ( v < 10 )
                            printf( "0" );
                    }
                }

                printf( "%ld", v );

/*              aztec C doesn't print leading 0s with the %.4ld format specifier */
/*                printf( "%.4ld", c + d / 10000 ); */

                fflush( stdout );
            }
            c = d % 10000;
        }
    }

    printf( "\n" );
    return 0;
}
