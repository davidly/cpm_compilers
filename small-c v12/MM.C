/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* Small-C v1.2: double (48-bit) floats; no multi-dimensional arrays, */
/* for loops, or += so arrays are indexed by hand and loops use while */
/* expected result: 465880 */

#include iolib.h
#include float.h

#define l 20 /* rows in A and resulting matrix C */
#define m 20 /* columns in A and rows in B (must be identical) */
#define n 20 /* columns in B and resulting matrix C */

double Summ;
double A[ 400 ];
double B[ 400 ];
double C[ 400 ];

filla()
{
    int i, j;
    i = 0;
    while ( i < l )
    {
        j = 0;
        while ( j < m )
        {
            A[ i * m + j ] = i + j + 2;
            j++;
        }
        i++;
    }
}

fillb()
{
    int i, j;
    i = 0;
    while ( i < m )
    {
        j = 0;
        while ( j < n )
        {
            B[ i * n + j ] = ( i + j + 2 ) / ( j + 1 );
            j++;
        }
        i++;
    }
}

fillc()
{
    int i, j;
    i = 0;
    while ( i < l )
    {
        j = 0;
        while ( j < n )
        {
            C[ i * n + j ] = 0;
            j++;
        }
        i++;
    }
}

matmult()
{
    int i, j, k;
    i = 0;
    while ( i < l )
    {
        j = 0;
        while ( j < n )
        {
            k = 0;
            while ( k < m )
            {
                C[ i * n + j ] = C[ i * n + j ] + A[ i * m + k ] * B[ k * n + j ];
                k++;
            }
            j++;
        }
        i++;
    }
}

summit()
{
    int i, j;
    i = 0;
    while ( i < l )
    {
        j = 0;
        while ( j < n )
        {
            Summ = Summ + C[ i * n + j ];
            j++;
        }
        i++;
    }
}

main()
{
    Summ = 0;

    filla();
    fillb();
    fillc();
    matmult();
    summit();

    printf( "summ is : %f\n", Summ );
}
