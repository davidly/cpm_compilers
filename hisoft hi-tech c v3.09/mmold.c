/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* various bugs not found because dimensions are square fixed by David Lee */
/* expected result: 4.65880E+05 */

#define LINT_ARGS

#include <stdio.h>

#define l 20 /* rows in A and resulting matrix C */
#define m 20 /* columns in A and rows in B (must be identical) */
#define n 20 /* columns in B and resulting matrix C */

#define ftype float

ftype Summ;
ftype A[ l + 1 ] [ m + 1 ];
ftype B[ m + 1 ] [ n + 1 ];
ftype C[ l + 1 ] [ n + 1 ];

void filla()
{
    int i, j;
    for ( i = 1; i <= l; i++ )
        for ( j = 1; j <= m; j++ )
            A[ i ] [ j ] = i + j;
}

void fillb()
{
    int i, j;
    for ( i = 1; i <= m; i++ )
        for ( j = 1; j <= n; j++ )
            B[ i ] [ j ] = (ftype) (int) ( ( i + j ) / j );
}

void fillc()
{
    int i, j;
    for ( i = 1; i <= l; i++ )
        for ( j = 1; j <= n; j++ )
            C[ i ] [ j ] = 0;
}

void matmult()
{
    int i, j, k;
    for ( i = 1; i <= l; i++ )
        for ( j = 1; j <= n; j++ )
            for ( k = 1; k <= m; k++ )
                C[ i ] [ j ] += A[ i ] [ k ] * B[ k ] [ j ];
}

void summit()
{
    int i, j;
    for ( i = 1; i <= l; i++ )
        for ( j = 1; j <= n; j++ )
            Summ += C[ i ] [ j ];
}

int main( argc, argv ) int argc; char * argv[];
{
    Summ = 0;

    filla();
    fillb();
    fillc();
    matmult();
    summit();

    printf( "summ is : %f\n", Summ );
    return 0;
}



