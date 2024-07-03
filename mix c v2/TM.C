#define allocs 40 /* not much RAM is available due to less than great alloctor strategy */

int logging = 1;

char * memset( p, v, c ) char * p; int v; int c;
{
    char * pc = (char *) p;
    char val = (char) ( v & 0xff );
    int y;

    if ( 0 == p )
    {
        printf( "request to memset a null pointer\n" );
        exit( 1 );
    }

    if ( logging )
        printf( "  memset p %u, v %d, val %x, c %d\n", p, v, val, c );

    for ( y = 0; y < c; y++ )
        *pc++ = val;
    return p;
}

void chkmem( p, v, c ) char * p; int v; int c;
{
    char * pc = (char *) p;
    char val = (char) ( v & 0xff );
    int z;

    if ( 0 == p )
    {
        printf( "request to chkmem a null pointer\n" );
        exit( 1 );
    }

    for ( z = 0; z < c; z++ )
    {
        if ( *pc != val )
        {
            printf( "memory isn't as expected! p %u, v %x, c %d, *pc %x, nth: %u\n",p, v, c, *pc, z );
            exit( 1 );
        }
        pc++;
    }
}

char * my_calloc( i, n ) int i; int n;
{
    int s;
    char * r;

    s = i * n;
    r = malloc( s );
    if ( 0 == r )
    {
        printf( "malloc returned 0 for a request of %u bytes\n", s );
        exit( 1 );
    }

    memset( r, 0, s );
    return r;
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

            pc = (char *) my_calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memset( pc, 0xcc, c_cb );
    
            ap[ i ] = (char *) malloc( cb );
            memset( ap[ i ], 0xaa, cb );
    
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
    
            pc = (char *) my_calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memset( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            memset( ap[ i ], 0xff, cb );
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
            memset( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            memset( ap[ i ], 0xff, cb );
            free( ap[ i ] );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    }

    printf( "success\n" );
    return 0;
}
