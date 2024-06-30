#include <stdio.h>

int puterr_() {}

int main()
{
    float f1 = 1.0;
    float f2 = 20.2;
    float fm1 = -1.342;
    float fr = f2 * fm1;
    float fd = 1000.0 / 3.0;
    float pi = 3.14159;
    float dpi = 3.14159;
    float radians = pi / 180.0 * 30.0;
    float dradians = dpi / 180.0 * 30.0;
    double d = (double) fr;
/*
    float fs = sqrtf( fd );
    float s = sinf( radians );
    float c = cosf( radians );
    float t = tanf( radians );
    float mantissa = frexpf( pi, &exponent );
*/
    int exponent;
    float a, b, at;

    printf( "hello from printf\n" );

    printf( "pi: %f\n", pi );
    printf( "radians: %f\n", radians );
    printf( "pi as double: %lf\n", dpi );
    printf( "radians as double: %lf\n", dradians );

#if false
    rvos_floattoa( ac, -1.234567, 8 );
    rvos_printf( "float converted by floattoa: %s\n", ac );
    rvos_floattoa( ac, 1.234567, 8 );
    rvos_printf( "float converted by floattoa: %s\n", ac );
    rvos_floattoa( ac, 34.567, 8 );
    rvos_printf( "float converted by floattoa: %s\n", ac );
#endif    

    printf( "float from printf: %f\n", 45.678 );
    printf( "division result: %f\n", fd );

#if 0
    printf( "square root: %f\n", fs );
    rvos_print_text( "calling floattoa\n" );
    rvos_floattoa( ac, fr, 6 );
    rvos_printf( "float converted with rvos_floattoa: %s\n", ac );
#endif    

    printf( "result of 20.2 * -1.342: %f\n", fr );

    printf( "result of 20.2 * -1.342 as a double: %lf\n", d );

/*
    printf( "sinf of 30 degress is %lf\n", s );

    printf( "cosf of 30 degrees is %lf\n", c );

    printf( "tanf of 30 degrees is %lf\n", t );
*/

/*
    at = atan2f( 0.3, 0.2 );
    printf( "atan2f of 0.3, 0.2 is %lf\n", at );

    c = acosf( 0.3 );
    printf( "acosf of 0.3 is %lf\n", c );

    s = asinf( 0.3 );
    printf( "asinf of 0.3 is %lf\n", s );

    f = tanhf( 2.2 );
    printf( "tanhf of 2.2 is %lf\n", s );
    
    f = logf( 0.3 );
    printf( "logf of 0.3: %lf\n", f );

    f = log10f( 300.0 );
    printf( "log10f of 300: %lf\n", f );
    printf( "pi has mantissa: %lf, exponent %d\n", mantissa, exponent );
*/

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

    printf( "stop\n" );
    exit( 0 );
} /*main*/


