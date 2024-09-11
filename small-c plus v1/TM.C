#include <stdio.h>

#ifdef powerc
#define allocs 50
#else
#ifdef HISOFTC
#define allocs 66 /* not enough RAM with hisoft to go higher */
#else
/* most c runtimes work up to 69, but use 66 to have a consistent benchmark */
#define allocs 66
#endif
#endif

#define free mfree

int logging;

/* copy malloc and free from Small-C/Plus v1.00's malloc.c -- remove main and test code from that file */

#define NULL 0

/*
 * _slack is the headroom which malloc() always allows for
 * further growth of the stack
 */
int _slack = 1024 ;

/*
 * _heap contains pointer to first element in allocation chain
 * the chain is initialised so that the first element is
 * allocated (it can never be freed)
 * the next element immediately follows the first and is NULL
 */
int *_heap ;

initmalloc()
{
        char *ptr1, *ptr2, *ptr3, *ptr4 ;

#asm
        ld hl,_end                      ;chain starts at an even address
        inc hl
        res 0,l
;
        ld (q_heap),hl          ;start of chain in _heap
;
        ld d,h                          ;first pointer is start of chain + 2
        ld e,l
        inc de
        inc de
;
        ld (hl),e                       ;set up first pointer
        inc hl
        ld (hl),d
        inc hl
;
        xor a                           ;set up second pointer (NULL)
        ld (hl),a
        inc hl
        ld (hl),a
#endasm
}

malloc(len)
int len ;                                       /* length of block required */
{
        int n ;
        int cell ;                              /* current allocation chain cell */
        char *p ;                               /* pointer to cell */
        char *np ;                              /* pointer in cell */
        int *ip, *wp ;                  /* for casting */

        /* make length even */
        if ( (len=(len+1)&~1) == 0 ) {
                return NULL ;
        }
        for ( ip=p=*_heap ; np=(cell=*ip) & ~1 ; ip = p = np ) {

                if ( cell & 1 ) {                       /* low bit == 1 means free */
                        if ( (n=np-p-2) > len+2 ) {
                                /* new block fits in gap in chain with */
                                /* room to spare for another block */
                                wp = p + len + 2 ;
                                *wp = cell ;
                                *ip = wp ;
                        }
                        else if ( n >= len ) {
                                /* new block fits exactly in gap or */
                                /* leaves only room for pointer, not block */
                                *ip = np ;
                        }
                        else
                                continue ;
                        return p+2 ;
                }

        }

        /* new block goes at end of chain (if there's room) */
        if ( (wp=p+len+2) > &n-_slack )
                return NULL ;
        *ip = wp ;
        *wp = NULL ;
        return p+2 ;
}

mfree(fp)
int *fp ;
{
        int *p, *np ;

        --fp ;
        for ( p = _heap; np = *p & ~1; p = np ) {
                if ( np == fp ) {
                        np = *fp ;
                        if ( np & 1 || np == NULL )
                                break ;
                        if ( *p & 1 ) {
                                if ( *np & 1 )
                                        *p = *np ;
                                else if ( *np == NULL )
                                        *p = NULL ;
                                else
                                        *p = np | 1 ;
                        }
                        else {
                                if ( *np & 1 )
                                        *fp = *np ;
                                else if ( *np == NULL )
                                        *fp = NULL ;
                                else
                                        *fp |= 1 ;
                        }
                        return ;
                }
        }
        err("free botch") ;
        exit() ;
}

memsetx( p, v, c ) char * p; int v; int c;
{
    char * pc;
    char val;
    int i;

    pc = p;
    val = v;

    if ( 0 == p )
    {
        printf( "request to memset a null pointer\n" );
        exit( 1 );
    }

    if ( logging )
        printf( "  memset p %u, v %u, val %u, c %u\n", p, v, val, c );

    i = 0;
    while ( i < c )
    {
        *pc++ = val;
        i++;
    }
    return p;
}

chkmem( p, v, c ) char * p; int v; int c;
{
    char * pc;
    char val;
    int i;

    pc = p;
    val = v;

    if ( 0 == p )
    {
        printf( "request to chkmem a null pointer\n" );
        exit( 1 );
    }

    i = 0;
    while ( i < c )
    {
        if ( *pc != val )
        {
            printf( "memory isn't as expected! p %u, expected %u, buffer size %u, found value *pc %u\n", p, v, c, 255 & *pc );
            exit( 1 );
        }
        pc++;
        i++;
    }
}

calloc( x, y ) int x; int y;
{
    char * p;
    int len;

    len = x * y;
    p = malloc( len );
    memsetx( p, 0, len );
    return p;
}

main( argc, argv ) int argc; char * argv;
{
    int i, cb, c_cb, j;
    char * pc;
    int ap[ allocs ];

    initmalloc();

    logging = ( argc > 1 );
    pc = argv[ 0 ]; /* evade compiler warning */

    j = 0;
    while ( j < 10 )
    {
        if ( logging )
            printf( "in alloc mode\n" );
    
        i = 0;
        while ( i < allocs )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 5;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );

            pc = calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memsetx( pc, 204, c_cb );
    
            ap[ i ] = malloc( cb );
            memsetx( ap[ i ], 170, cb );
    
            chkmem( pc, 204, c_cb );
            free( pc );
            i++;
        }
    
        if ( logging )
            printf( "in free mode, even first\n" );

        i = 0;
        while ( i < allocs )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 3;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );
    
            pc = calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memsetx( pc, 204, c_cb );
    
            if ( logging )
                printf( "  after calloc\n" );

            chkmem( ap[ i ], 170, cb );
            memsetx( ap[ i ], 255, cb );
            free( ap[ i ] );
    
            if ( logging )
                printf( "  after first free\n" );

            chkmem( pc, 204, c_cb );
            free( pc );

            if ( logging )
                printf( "  after second free\n" );

            i += 2;
        }
    
        if ( logging )
            printf( "in free mode, now odd\n" );

        i = 1;
        while ( i < allocs )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 7;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );
    
            pc = calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memsetx( pc, 204, c_cb );
    
            chkmem( ap[ i ], 170, cb );
            memsetx( ap[ i ], 255, cb );
            free( ap[ i ] );
    
            chkmem( pc, 204, c_cb );
            free( pc );
            i += 2;
        }

        j++;
    }

    printf( "success\n" );
    return 0;
}
