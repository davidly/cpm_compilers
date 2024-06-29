#define allocs 22 /* this is all the ram that works given there is no free */

int logging = 1;

char * my_memset( p, v, c ) char * p; int v; int c;
{
    char * original;
    char val;
    int i;

    original = p;
    val = ( v & 0xff );

    if ( 0 == p )
    {
        printf( "request to memset a null pointer\n" );
        exit( 1 );
    }

    if ( logging )
        printf( "  memset p %u, v %d, val %x, c %d\n", p, v, val, c );

    for ( i = 0; i < c; i++ )
        *p++ = val;
    return original;
}

int chkmem( p, v, count ) char * p; int v; int count;
{
    char * original;
    char val;
    int iter;

    original = p;
    val = ( v & 0xff );

    if ( 0 == p )
    {
        printf( "request to chkmem a null pointer\n" );
        exit( 1 );
    }

    for ( iter = 0; iter < count; iter++ )
    {
        if ( *p != val )
        {
            printf( "memory isn't as expected! p %u, v %d, c %d, *pc %d\n", original, v, count, *p );
            exit( 1 );
        }
        p++;
    }
}

int free( mem ) char * mem;
{
    /* this compiler doesn't have free!?! */
}

char * my_calloc( n, x ) int n; int x;
{
    int s;
    char * p;

    s = n * x;
    p = malloc( s );
    if ( p  )
        my_memset( p, 0, s );
    return p;
}

char * ap[ allocs ];

int main( argc, argv ) int argc; char * argv[];
{
    int i, cb, c_cb, j;
    char * pc;

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

            pc = (char *) my_calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            my_memset( pc, 0xcc, c_cb );
    
            ap[ i ] = (char *) malloc( cb );
            my_memset( ap[ i ], 0xaa, cb );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    
        if ( logging )
            printf( "in free mode, even first\n" );

/*
    
        for ( i = 0; i < allocs; i += 2 )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 3;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );
    
            pc = (char *) my_calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            my_memset( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            my_memset( ap[ i ], 0xff, cb );
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
    
            pc = (char *) my_calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            my_memset( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            my_memset( ap[ i ], 0xff, cb );
            free( ap[ i ] );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
*/
    }

    printf( "success\n" );
    return 0;
}
