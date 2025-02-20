/*
    this is overall 25% faster for Whitesmith, but it's not the benchmark.
    #define FAST_WHITESMITH
*/

#define DIGITS_TO_FIND 200 /*9009;*/

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


int main()
{
#ifdef FAST_WHITESMITH
    static int N, x, n, l, d, t;
    static char ac[ 10 ];
    static int a[ DIGITS_TO_FIND ];
#else
    int N, x, n;
    char ac[ 10 ];
    int a[ DIGITS_TO_FIND ];
#endif

    N = DIGITS_TO_FIND;
    x = 0;

    for ( n = N - 1; n > 0; --n )
      a[ n ] = 1;

    a[ 1 ] = 2;
    a[ 0 ] = 0;

    while ( N > 9 )
    {
        n = N--;
        while ( --n )
        {
#ifdef FAST_WHITESMITH
            d = x / n;
            a[ n ] = x - ( d * n );
            t = a[ n - 1 ];
            x = ( t << 3 ) + ( t << 1 ) + d;
#else
            a[ n ] = x % n;
            x = 10 * a[ n - 1 ] + x / n;
#endif
        }

        n = utoa( ac, x );
        write( 0, ac, n );
    }

    write( 0, "\ndone\n", 6 );
    return 0;
}
