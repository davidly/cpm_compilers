/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* integer version for compilers without floating point or long: */
/* each element of C fits in 16 bits; the sum is kept in base 10000 */
/* HiSoft C v1.35 has no floating point. it compiles STDIO.LIB after the program, */
/* so the sizes are LL/MM/NN (#define n would rewrite library code) and the arrays MA/MB/MC */
/* expected result: 465880 */

#include stdio.h

#define LL 20 /* rows in A and resulting matrix C */
#define MM 20 /* columns in A and rows in B (must be identical) */
#define NN 20 /* columns in B and resulting matrix C */

int SummHi, SummLo;
int MA[ LL ][ MM ];
int MB[ MM ][ NN ];
int MC[ LL ][ NN ];

filla()
{
    int i, j;
    for ( i = 0; i < LL; i++ )
        for ( j = 0; j < MM; j++ )
            MA[ i ][ j ] = i + j + 2;
}

fillb()
{
    int i, j;
    for ( i = 0; i < MM; i++ )
        for ( j = 0; j < NN; j++ )
            MB[ i ][ j ] = ( i + j + 2 ) / ( j + 1 );
}

fillc()
{
    int i, j;
    for ( i = 0; i < LL; i++ )
        for ( j = 0; j < NN; j++ )
            MC[ i ][ j ] = 0;
}

matmult()
{
    int i, j, k;
    for ( i = 0; i < LL; i++ )
        for ( j = 0; j < NN; j++ )
            for ( k = 0; k < MM; k++ )
                MC[ i ][ j ] += MA[ i ][ k ] * MB[ k ][ j ];
}

summit()
{
    int i, j;
    for ( i = 0; i < LL; i++ )
        for ( j = 0; j < NN; j++ )
        {
            SummLo += MC[ i ][ j ];
            while ( SummLo >= 10000 )
            {
                SummLo -= 10000;
                SummHi++;
            }
        }
}

main()
{
    SummHi = 0;
    SummLo = 0;

    filla();
    fillb();
    fillc();
    matmult();
    summit();

    printf( "summ is : %d", SummHi );
    if ( SummLo < 1000 )
        printf( "0" );
    if ( SummLo < 100 )
        printf( "0" );
    if ( SummLo < 10 )
        printf( "0" );
    printf( "%d\n", SummLo );
    return 0;
}
