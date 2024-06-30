#include <stdio.h>
#include <setjmp.h>

static jmp_buf buf;

void second()
{
    printf( "second\n" );
    longjmp( buf, 1 );   
}

void first()
{
    second();
    printf( "first (if this prints there is a bug)\n" );
}

int main()
{   
    if ( ! setjmp( buf ) )
        first();         
    else                 
        printf( "back in main\n" );

    printf( "falling out of main\n" );
    return 0;
}
