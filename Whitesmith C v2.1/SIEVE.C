/*  sieve.c */

/*
    this is overall 25% faster for Whitesmith, but it's not the benchmark.
    #define FAST_WHITESMITH
*/

/* Eratosthenes Sieve Prime Number Program in C from Byte Jan 1983
   to compare the speed. */

#define TRUE 1
#define FALSE 0
#define SIZE 8190
#define SIZEP1 8191

int reverse( p, len ) char * p; int len;
{
    int r, l;
    char t;

    r = len;
    if ( 0 == r )
        return 0;

    r--;
    l = 0;
    while ( l < r )
    {
        t = p[ l ];
        p[ l ] = p[ r ];
        p[ r ] = t;
        l++;
        r--;
    }

    return 0;
}

int utoa( p, i ) char * p; int i;
{
    int digit, len;

    len = 0;
    do
    {
        if ( i >= 10 )
        {
            digit = i % 10;
            i /= 10;
        }
        else
        {
            digit = i;
            i = 0;
        }

        p[ len ] = '0' + digit;
        len++;
    } while ( 0 != i );

    p[ len ] = 0;

    if ( len > 1 )
        reverse( p, len );

    return len;
}

char flags[ SIZEP1 ] {0};

int main()
        {
#ifdef FAST_WHITESMITH
        static int i, k;
        static int prime, count, iter;
        static char account[ 10 ];
#else
        int i, k;
        int prime, count, iter;
        char account[ 10 ];
#endif

        for (iter = 1; iter <= 10; iter++) {    /* do program 10 times */
                count = 0;                      /* initialize prime counter */
                for (i = 0; i <= SIZE; i++)     /* set all flags true */
                        flags[i] = TRUE;
                for (i = 0; i <= SIZE; i++) {
                        if (flags[i]) {         /* found a prime */
                                prime = i + i + 3;      /* twice index + 3 */
                                for (k = i + prime; k <= SIZE; k += prime)
                                        flags[k] = FALSE;       /* kill all multiples */
                                count++;                /* primes found */
                                }
                        }
                }
        i = utoa( account, count );
        write( 0, account, i );
        write( 0, " primes.\n", 9); 
        return 0;
        }
