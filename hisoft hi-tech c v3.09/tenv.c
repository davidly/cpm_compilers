#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


int main( int argc, char * argv[] )
{
    char ac[100];
    strcpy( ac, "MYVAL=toast!" );
    putenv( ac );

    char * pval = getenv( "MYVAL" );

    printf( "pval: %p\n", pval );

    if ( 0 != pval )
        printf( "value: %s\n", pval );

    return 0;
} //main
