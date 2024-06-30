#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void swap( char & a, char & b )
{
    char c = a;
    a = b;
    b = c;
} //swap

void reverse( char str[], int length )
{
    int start = 0;
    int end = length - 1;
    while ( start < end )
    {
        swap( * ( str + start ), * ( str + end ) );
        start++;
        end--;
    }
} //reverse
 
char * i64toa( int64_t num, char * str, int base )
{
    int i = 0;
    bool isNegative = false;
 
    if ( 0 == num )
    {
        str[i++] = '0';
        str[i] = '\0';
        return str;
    }
 
    if ( num < 0 && 10 == base )
    {
        isNegative = true;
        num = -num;
    }
 
    while ( 0 != num )
    {
        int rem = num % base;
        str[i++] = (rem > 9)? (rem-10) + 'a' : rem + '0';
        num = num/base;
    }
 
    if (isNegative)
        str[i++] = '-';
 
    str[i] = '\0';
 
    reverse( str, i );
 
    return str;
} //i64toa

template <class T> T myabs( T x )
{
    if ( x < 0 )
        return -x;
    return x;
} //myabs

#pragma GCC optimize ("O0")
template <class T> T test( T & min, T & max )
{
    T a[ 340 ];

    for ( uint64_t i = 0; i < sizeof( a ) / sizeof( a[0] ); i++ )
        a[ i ] = i;

    for ( size_t zz = 0; zz < 10; zz++ )
    {
        for ( T i = min; i < max; i++ )
        {
            T j = 13 - i;
            int x = (int) j;
            int y = x * 2;
            a[ myabs( i ) ] = (T) y;
            a[ myabs( i + 1 ) ] = a[ myabs( i ) + 2 ] | a[ myabs( i ) + 3 ];
            a[ myabs( i + 2 ) ] = a[ myabs( i ) + 3 ] & a[ myabs( i ) + 4 ];
            a[ myabs( i + 3 ) ] = a[ myabs( i ) + 4 ] + a[ myabs( i ) + 5 ];
            a[ myabs( i + 4 ) ] = a[ myabs( i ) + 5 ] - a[ myabs( i ) + 6 ];
            a[ myabs( i + 5 ) ] = a[ myabs( i ) + 6 ] * a[ myabs( i ) + 7 ];
            if ( 0 != a[ myabs( i ) + 8 ] )
                a[ myabs( i + 6 ) ] = a[ myabs( i ) + 7 ] / a[ myabs( i ) + 8 ];
            a[ myabs( i + 7 ) ] = a[ myabs( i ) + 8 ] ^ a[ myabs( i ) + 9 ];
            if ( 0 != a[ myabs( i ) + 10 ] )
                a[ myabs( i + 8 ) ] = a[ myabs( i ) + 9 ] % a[ myabs( i ) + 10 ];
            a[ myabs( i + 9 ) ] = a[ myabs( i ) + 8 ] << a[ myabs( i ) + 11 ];
            a[ myabs( i + 10 ) ] = a[ myabs( i ) + 8 ] >> a[ myabs( i ) + 12 ];
            a[ myabs( i + 11 ) ] = ( a[ myabs( i ) + 8 ] << 3 );
            a[ myabs( i + 12 ) ] = ( a[ myabs( i ) + 8 ] >> 4 );

            if ( a[ myabs( i + 12 ) ] > a[ myabs( i + 13 ) ] )
                a[ myabs( i + 14 ) ] += 3;

            if ( a[ myabs( i + 12 ) ] < a[ myabs( i + 13 ) ] )
                a[ myabs( i + 14 ) ] += 7;

            if ( a[ myabs( i + 12 ) ] >= a[ myabs( i + 13 ) ] )
                a[ myabs( i + 14 ) ] += 3;

            if ( a[ myabs( i + 12 ) ] <= a[ myabs( i + 13 ) ] )
                a[ myabs( i + 14 ) ] += 7;

            if ( a[ myabs( i + 12 ) ] == a[ myabs( i + 13 ) ] )
                a[ myabs( i + 14 ) ] += 9;

            a[ myabs( i + 12 ) ] &= 0x10;
            a[ myabs( i + 13 ) ] |= 0x10;
            a[ myabs( i + 14 ) ] ^= 0x10;
            a[ myabs( i + 12 ) ] += 7;
            a[ myabs( i + 13 ) ] -= 6;
            a[ myabs( i + 14 ) ] *= 5;
            a[ myabs( i + 14 ) ] /= 4;
        }
    }

    return a[ 10 ];
} //template

void validate_128mul()
{
    // the gnu compiler generates mulhu for each of these, not mulh or mulhsu

    __int128 a = 0x4000000000000000;
    printf( "a: %llx %llx\n", (uint64_t) ( a >> 64) , (uint64_t) a );
    a <<= 4;
    printf( "a: %llx %llx\n", (uint64_t) ( a >> 64) , (uint64_t) a );

    __int128 b = 2;
    __int128 c = a * b;

    if ( 0 != ( 0xffffffff & c ) )
        printf( "failure 1: lower part of multiply isn't 0\n" );

    if ( ( c >> 64 ) != 0x8 )
        printf( "failure 2: upper part of multiply isn't 0x8: %llx\n", (uint64_t) ( c >> 64 ) );

    unsigned __int128 ua = 0x4000000000000000;
    printf( "ua: %llx %llx\n", (uint64_t) ( ua >> 64) , (uint64_t) ua );
    ua <<= 4;
    printf( "ua: %llx %llx\n", (uint64_t) ( ua >> 64) , (uint64_t) ua );

    unsigned __int128 ub = 2;
    unsigned __int128 uc = ua * ub;

    if ( 0 != ( 0xffffffff & uc ) )
        printf( "failure 3: lower part of multiply isn't 0\n" );

    if ( ( uc >> 64 ) != 0x8 )
        printf( "failure 4: upper part of multiply isn't 0x8: %llx\n", (uint64_t) ( uc >> 64 ) );

    a = -1;
    printf( "a: %llx %llx\n", (uint64_t) ( a >> 64) , (uint64_t) a );

    a = -33;
    printf( "a: %llx %llx = %lld\n", (uint64_t) ( a >> 64) , (uint64_t) a, (int64_t) a );

    c = a * b;
    if ( -66 != c )
        printf( "failure 5: c: %llx %llx = %lld\n", (uint64_t) ( c >> 64) , (uint64_t) c, (int64_t) c );

    c = a * ub;
    if ( -66 != c )
        printf( "failure 6: c: %llx %llx = %lld\n", (uint64_t) ( c >> 64) , (uint64_t) c, (int64_t) c );

    a = -7;
    b = -3;
    c = a * b;
    if ( 21 != c )
        printf( "failure 7: c: %llx %llx = %lld\n", (uint64_t) ( c >> 64) , (uint64_t) c, (int64_t) c );
} // validate_128mul

template <class T> void show_result( const char *text, T x )
{
    printf( "%s result: %ld\n", text, x );
} //show_result

extern "C" int main()
{
    validate_128mul();

    int8_t i8min = -127, i8max = 127;
    int8_t i8 = test( i8min, i8max );
    show_result( "int8_t", (int64_t) i8 );

    uint8_t ui8min = 0, ui8max = 255;
    uint8_t u8 = test( ui8min, ui8max );
    show_result( "uint8_t", (uint64_t) i8 );

    int16_t i16min = -228, i16max = 227;
    int16_t i16 = test( i16min, i16max );
    show_result( "int16_t", (int64_t) i16 );

    uint16_t ui16min = 0, ui16max = 300;
    uint16_t u16 = test( ui16min, ui16max );
    show_result( "uint16_t", (uint64_t) u16 );

    int32_t i32min = -228, i32max = 227;
    int32_t i32 = test( i32min, i32max );
    show_result( "int32_t", (int64_t) i32 );

    uint32_t ui32min = 0, ui32max = 300;
    uint32_t u32 = test( ui32min, ui32max );
    show_result( "uint32_t", (uint64_t) u32 );

    int64_t i64min = -228, i64max = 227;
    int64_t i64 = test( i64min, i64max );
    show_result( "int64_t", (int64_t) i64 );

    uint64_t ui64min = 0, ui64max = 300;
    uint64_t u64 = test( ui64min, ui64max );
    show_result( "uint64_t", (uint64_t) u64 );

    __int128 i128min = -228, i128max = 227;
    __int128 i128 = test( i128min, i128max );
    show_result( "int128_t", (int64_t) i128 );

    unsigned __int128 ui128min = 0, ui128max = 300;
    unsigned __int128 u128 = test( ui128min, ui128max );
    show_result( "uint128_t", (uint64_t) u128 );

    printf( "end of the app\n" );
    return 0;
} //main


