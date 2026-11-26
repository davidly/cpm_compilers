/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* integer version: each C element fits in 16 bits; sum kept in base 10000 */
/* HI-TECH C v3.09 says "Expression too complicated" for the int += of a product, so the product goes in t */
/* expected result: 465880 */

#define l 20 /* rows in A and resulting matrix C */
#define m 20 /* columns in A and rows in B (must be identical) */
#define n 20 /* columns in B and resulting matrix C */

int SummHi, SummLo;
int A[ l ][ m ];
int B[ m ][ n ];
int C[ l ][ n ];

filla()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < m; j++ )
            A[ i ][ j ] = i + j + 2;
}

fillb()
{
    int i, j;
    for ( i = 0; i < m; i++ )
        for ( j = 0; j < n; j++ )
            B[ i ][ j ] = ( i + j + 2 ) / ( j + 1 );
}

fillc()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            C[ i ][ j ] = 0;
}

matmult()
{
    int i, j, k, t;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            for ( k = 0; k < m; k++ )
            {
                t = A[ i ][ k ] * B[ k ][ j ];
                C[ i ][ j ] += t;
            }
}

summit()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            {
                SummLo += C[ i ][ j ];
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
