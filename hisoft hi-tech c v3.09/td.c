#include <stdio.h>

int puterr_() {}

/* without these prototypes the compiler assumes an int return type and nothing works */
double sqrt();
double sin();
double cos();
double tan();
double atof();
double atan();
double atan2();
double acos();
double asin();
double tanh();
double log();
double log10();
double frexp();

int main()
{
    double pi = 3.1415927;
    float f;
    double r, sq, s, radians, c, t, d, at, b, a, mantissa, tmp;
    int exponent, i, loops;
    char ac[100];

    sprintf( ac, "sprintf double %.20f\n", pi );
    printf( ac );

    printf( "double from printf: %.20f\n", pi );

    f = 1.2020569;
    printf( "float from printf: %f\n", f );

    r = -f * pi;
    printf( "double from printf r: %lf\n", r );

    sq = sqrt( pi );
    printf( "sqrt of pi: %lf\n", sq );

    radians = ( 30.0 * pi ) / 180.0;
    printf( "pi in radians: %lf\n", radians );

    s = sin( radians );
    printf( "sin of 30 degress is %lf\n", s );

    c = cos( radians );
    printf( "cos of 30 degrees is %lf\n", c );

    t = tan( radians );
    printf( "tan of 30 degrees is %lf\n", t );

    d = atof( "1.0" );
    at = atan( d );
    printf( "atan of %lf is %lf\n", d, at );

    at = atan2( 0.3, 0.2 );
    printf( "atan2 of 0.3, 0.2 is %lf\n", at );

    c = acos( 0.3 );
    printf( "acos of 0.3 is %lf\n", c );

    s = asin( 0.3 );
    printf( "asin of 0.3 is %lf\n", s );

    d = tanh( 2.2 );
    printf( "tanh of 2.2 is %lf\n", s );
    
    d = log( 0.3 );
    printf( "log of 0.3: %lf\n", d );

    d = log10( 300.0 );
    printf( "log10 of 300: %lf\n", d );
    
    b = 2.7;
    for ( a = 2.0; a < 3.0; a += 0.1 )
    {
        if ( a > b )
            printf( "g," );
        if ( a >= b )
            printf( "ge," );
        if ( a == b )
            printf( "eq," );
        if ( a < b )
            printf( "l," );
        if ( a <= b )
            printf( "le," );
    }
    printf( "\n" );

    mantissa = frexp( pi, &exponent );
    printf( "pi has mantissa: %lf, exponent %d\n", mantissa, exponent );
    
    loops = 1000;
    for ( i = 0, r = 1.0; i < loops; i++ )
        r *= 1.14157222;

    t = r;
    for ( i = 0; i < loops; i++ )
        r /= 1.14157222;

    printf( "r should be 1.0: %lf\n", r );
    printf( "  r high point %lf\n", t );
    
    printf( "stop\n" );
    return 0;
}
