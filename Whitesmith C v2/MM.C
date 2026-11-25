/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* integer version for compilers without floating point or long: */
/* each element of C fits in 16 bits; the sum is kept in base 10000 */
/* Whitesmith C v2.0: its float runtime hangs on this program, and it has no printf, */
/* so this is the integer version printing with write(); globals need initializers */
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

putnum( i, digits ) int i; int digits;
{
    char ac[ 6 ];
    int len;

    len = 0;
    do
    {
        ac[ 5 - len ] = '0' + ( i % 10 );
        i /= 10;
        len++;
    } while ( 0 != i || len < digits );

    write( 0, ac + 6 - len, len );
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

    write( 0, "summ is : ", 10 );
    putnum( SummHi, 1 );
    putnum( SummLo, 4 );
    write( 0, "\n", 1 );
    return 0;
}
