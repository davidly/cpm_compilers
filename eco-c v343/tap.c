#include <stdio.h>

#define __max( a, b ) (a) > (b) ? a : b
#define __min( a, b ) (a) < (b) ? a : b

/* unsigned only works on int with the eco compiler */

typedef /*unsigned */ char uint8_t;
typedef unsigned int uint16_t;
typedef /*unsigned*/ long uint32_t;

/*
   note: this bdos function 109 only exists on ntvcm -- not on real cp/m or any other emulator!
   it returns a 8-bit random number in register A
*/

uint8_t bdos_rand()
{
    uint8_t x = _bdos( 109, 0 );
    return x;
}

uint16_t bdos_16rand()
{
    uint16_t x = _bdos( 109, 0 );
    return x;
}

uint32_t gcd( m, n ) uint32_t m, n;
{
    uint32_t a = 0;
    uint32_t b = __max( m, n );
    uint32_t r = __min( m, n );

    while ( 0 != r )
    {
        a = b;
        b = r;
        r = a % b;
    }

    return b;
}

uint16_t rand16()
{
    int r = bdos_rand();
    r |= bdos_rand() << 8;
    return r;
}

uint32_t rand32()
{
    uint32_t ul = (uint32_t) bdos_16rand();
    ul |= ( (uint32_t) bdos_16rand() << 16 );

/*
    uint32_t ul = (uint32_t) rand16();
    ul |= ( (uint32_t) rand16() << 16 );
*/

    /* 32 bit unsigned isn't a thing with eco, so mask off top bit */
    return ul & 0x7fffffff;
}

static uint16_t last_rand = 0x100;

uint32_t badrand()
{
    uint32_t * pmem = (uint32_t *) last_rand;
    uint32_t x = *pmem;
    if ( 0 == ( last_rand % 7 ) )
        x <<= 1;
    x &= 0x7fffffff;

    last_rand++;
    if ( last_rand > 0x2a00 )
        last_rand = 0x100;
    return x;
}

/* https://en.wikipedia.org/wiki/Ap%C3%A9ry%27s_theorem */

void first_implementation()
{
    uint32_t total = 10000;
    uint32_t i;
    uint32_t update = 10;
    double sofar = 0.0;
    double dq;

    for ( i = 1; i <= total; i++ )
    {
        dq = (double) i;
        dq = dq * dq * dq;
        sofar += (double) 1.0 / dq;

        if ( i == update )
        {
            update = i * 10;
            printf( "  at %12lu iterations: %f\n", i, sofar );
            fflush( stdout );
        }
    }
} 

int main()
{
    uint32_t totalEntries = 1000; /* 10000 is too slow especially when emulated */
    uint32_t i, update, totalCoprimes, greatest, a, b, c;
    double v;

    printf( "starting, should tend towards 1.2020569031595942854...\n" );

    printf( "first implementation...\n" );
    first_implementation();

    printf( "second implementation...\n" );

    totalCoprimes = 0;
    update = 10;

    for ( i = 1; i <= totalEntries; i++ )
    {
        a = rand32();
        b = rand32();
        c = rand32();
/*
        a = badrand();
        b = badrand();
        c = badrand();
*/
        /* printf( "i: %ld, a %ld, b %ld, c %ld\n", i, a, b, c ); */

        greatest = gcd( a, gcd( b, c ) );
        if ( 1 == greatest )
            totalCoprimes++;

        if ( i == update )
        {
            update = i * 10;
            v = (double) i / (double) totalCoprimes;
            printf( "  at %12lu iterations: %f\n", i, v );
            fflush( stdout );
        }
    }

    printf( "done\n" );
    return 1202;
} 
