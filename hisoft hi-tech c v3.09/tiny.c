#include <stdio.h>

int puterr_() {}

double sqrt();

int main()
{
    double pi, square_root;
    pi = 400.0;
    square_root = sqrt( pi );
    printf( "pi: %lf\n", pi );
    printf( "sqrt of pi: %lf\n", square_root );
    printf( "stop\n" );
    return 0;
}
