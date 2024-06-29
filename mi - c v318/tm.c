#include <stdio.h>

#define allocs 10 /* can't allocate too much because free() isn't implemented */

int logging;

char * xmemset( p, v, c ) char * p; int v; int c;
{
    char * pc;
    char val;
    int i;

    pc = p;
    val = ( v & 0xff );

    if ( 0 == p )
    {
        printf( "request to memset a null pointer\n" );
        exit( 1 );
    }

    if ( logging )
        printf( "  memset p %u, v %d, val %x, c %d\n", p, v, val, c );

    for ( i = 0; i < c; i++ )
        *pc++ = val;
    return p;
}

int chkmem( p, v, c ) char * p; int v; int c;
{
    char * pc;
    char val;
    int i;

    pc = p;
    val = ( v & 0xff );

    if ( 0 == p )
    {
        printf( "request to chkmem a null pointer\n" );
        exit( 1 );
    }

    for ( i = 0; i < c; i++ )
    {
        if ( *pc != val )
        {
            printf( "memory isn't as expected! p %u, v %d, c %d, *pc %d\n",p, v, c, *pc );
            exit( 1 );
        }
        pc++;
    }
}

int free( char * p )
{
    /* MI -C doesn't have free!?! */
}

int main( argc, argv ) int argc; char * argv[];
{
    int i, cb, c_cb, j;
    char * pc;
    char * ap[ allocs ];

    logging = ( argc > 1 );
    pc = argv[ 0 ]; /* evade compiler warning */

    for ( j = 0; j < 10; j++ )
    {
        if ( logging )
            printf( "in alloc mode\n" );
    
        for ( i = 0; i < allocs; i++ )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 5;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );

            pc = (char *) calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            xmemset( pc, 0xcc, c_cb );
    
            ap[ i ] = (char *) malloc( cb );
            xmemset( ap[ i ], 0xaa, cb );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    
        if ( logging )
            printf( "in free mode, even first\n" );
    
        for ( i = 0; i < allocs; i += 2 )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 3;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );
    
            pc = (char *) calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            xmemset( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            xmemset( ap[ i ], 0xff, cb );
            free( ap[ i ] );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    
        if ( logging )
            printf( "in free mode, now odd\n" );
    
        for ( i = 1; i < allocs; i += 2 )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 7;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );
    
            pc = (char *) calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            xmemset( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            xmemset( ap[ i ], 0xff, cb );
            free( ap[ i ] );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    }

    printf( "success\n" );
    return 0;
}
