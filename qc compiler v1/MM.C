/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* integer version for compilers without floating point or long: */
/* each element of C fits in 16 bits; the sum is kept in base 10000 */
/* expected result: 465880 */

/* Q/C v1.0 has no multi-dimensional arrays, so they are indexed by hand;
   the arrays are MA, MB, MC because A, B, C are register names to its assembler */

#include "qstdio.h"

#define l 20 /* rows in A and resulting matrix C */
#define m 20 /* columns in A and rows in B (must be identical) */
#define n 20 /* columns in B and resulting matrix C */

int SummHi, SummLo;
int MA[ 400 ];
int MB[ 400 ];
int MC[ 400 ];

/* Q/C v1.0 emits the program entry point only if main is the first function */

main()
{
    SummHi = 0;
    SummLo = 0;

    filla();
    fillb();
    fillc();
    matmult();
    summit();

    printf( "summ is : %d", SummHi, 2 );
    if ( SummLo < 1000 )
        printf( "0", 1 );
    if ( SummLo < 100 )
        printf( "0", 1 );
    if ( SummLo < 10 )
        printf( "0", 1 );
    printf( "%d\n", SummLo, 2 );
    return 0;
}

filla()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < m; j++ )
            MA[ i * m + j ] = i + j + 2;
}

fillb()
{
    int i, j;
    for ( i = 0; i < m; i++ )
        for ( j = 0; j < n; j++ )
            MB[ i * n + j ] = ( i + j + 2 ) / ( j + 1 );
}

fillc()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            MC[ i * n + j ] = 0;
}

matmult()
{
    int i, j, k;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            for ( k = 0; k < m; k++ )
                MC[ i * n + j ] += MA[ i * m + k ] * MB[ k * n + j ];
}

summit()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
        {
            SummLo += MC[ i * n + j ];
            while ( SummLo >= 10000 )
            {
                SummLo -= 10000;
                SummHi++;
            }
        }
}
