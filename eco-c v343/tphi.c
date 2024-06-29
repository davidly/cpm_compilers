#include <stdio.h>

#define limit 15

int main()
{
    long prev2 = 1;
    long prev1 = 1;
    long i;
    long next;
    double v;

    printf( "should tend towards 1.61803398874989484820458683436563811772030\n" );

    for ( i = 1; i <= limit; i++ )
    {
        next = prev1 + prev2;
        prev2 = prev1;
        prev1 = next;

        v = (double) prev1 / (double) prev2;
        printf( "  at %ld iterations: %f\n", i, v );
    }

    printf( "done\n" );
    return 0;
}
