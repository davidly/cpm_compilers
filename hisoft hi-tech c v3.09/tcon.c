#include <stdio.h>


int main()
{
    char acin[ 100 ];
    int ch;
    char * result;

    printf( "enter a string and then ENTER please: " );
    fflush( stdout );

    result = fgets( acin, 50, stdin );
    printf( "result: %s\n", result );

    printf( "type characters then control-z to stop: " );
    fflush( stdout );

    while ( ( ch = getchar() ) != EOF )
        ;

    printf( "exiting the app\n" );
    fflush( stdout );
    return 0;
} /*main*/


