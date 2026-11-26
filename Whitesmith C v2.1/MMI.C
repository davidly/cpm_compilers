/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* integer version: each C element fits in 16 bits; sum kept in base 10000 */
/* Whitesmith C needs initializers to allocate globals; v2.0 and v2.1 have putfmt, not printf */
/* putfmt prints ints with %i (%d printed garbage) */
/* expected result: 465880 */

#define l 20 /* rows in A and resulting matrix C */
#define m 20 /* columns in A and rows in B (must be identical) */
#define n 20 /* columns in B and resulting matrix C */

int SummHi {0};
int SummLo {0};
int A[ l ][ m ] {0};
int B[ m ][ n ] {0};
int C[ l ][ n ] {0};

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
    int i, j, k;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            for ( k = 0; k < m; k++ )
                C[ i ][ j ] += A[ i ][ k ] * B[ k ][ j ];
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

    putfmt( "summ is : %i", SummHi );
    if ( SummLo < 1000 )
        putfmt( "0" );
    if ( SummLo < 100 )
        putfmt( "0" );
    if ( SummLo < 10 )
        putfmt( "0" );
    putfmt( "%i\n", SummLo );
    return 0;
}
