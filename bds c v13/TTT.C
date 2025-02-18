#define true 1
#define false 0

#define ScoreWin 6
#define ScoreTie 5
#define ScoreLose  4
#define ScoreMax 9
#define ScoreMin 2
#define DefaultIterations 1

#define PieceX 1
#define PieceO 2
#define PieceBlank 0

#define ttype char

ttype g_board[ 9 ];
int g_moves;

ttype winner2( move ) ttype move;
{
    int x;  /* faster than ttype x on the stack */

    switch( move ) /* msc v3 from 1985 generates a jump table! */
    {
        case 0:
        {
            x = g_board[ 0 ];
            if ( ( ( x == g_board[1] ) && ( x == g_board[2] ) ) ||
                 ( ( x == g_board[3] ) && ( x == g_board[6] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[8] ) ) )
               return x;
            break;
        }
        case 1:
        {
            x = g_board[ 1 ];
            if ( ( ( x == g_board[0] ) && ( x == g_board[2] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[7] ) ) )
                return x;
            break;
        }
        case 2:
        {
            x = g_board[ 2 ];
            if ( ( ( x == g_board[0] ) && ( x == g_board[1] ) ) ||
                 ( ( x == g_board[5] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[6] ) ) )
                return x;
            break;
        }
        case 3:
        {
            x = g_board[ 3 ];
            if ( ( ( x == g_board[4] ) && ( x == g_board[5] ) ) ||
                 ( ( x == g_board[0] ) && ( x == g_board[6] ) ) )
                return x;
            break;
        }
        case 4:
        {
            x = g_board[ 4 ];
            if ( ( ( x == g_board[0] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[2] ) && ( x == g_board[6] ) ) ||
                 ( ( x == g_board[1] ) && ( x == g_board[7] ) ) ||
                 ( ( x == g_board[3] ) && ( x == g_board[5] ) ) )
                return x;
            break;
        }
        case 5:
        {
            x = g_board[ 5 ];
            if ( ( ( x == g_board[3] ) && ( x == g_board[4] ) ) ||
                 ( ( x == g_board[2] ) && ( x == g_board[8] ) ) )
                return x;
            break;
        }
        case 6:
        {
            x = g_board[ 6 ];
            if ( ( ( x == g_board[7] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[0] ) && ( x == g_board[3] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[2] ) ) )
                return x;
            break;
        }
        case 7:
        {
            x = g_board[ 7 ];
            if ( ( ( x == g_board[6] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[1] ) && ( x == g_board[4] ) ) )
                return x;
            break;
        }
        case 8:
        {
            x = g_board[ 8 ];
            if ( ( ( x == g_board[6] ) && ( x == g_board[7] ) ) ||
                 ( ( x == g_board[2] ) && ( x == g_board[5] ) ) ||
                 ( ( x == g_board[0] ) && ( x == g_board[4] ) ) )
                return x;
            break;
         }
    }

    return PieceBlank;
} /*winner2*/

ttype LookForWinner()
{
    int p;
    p = g_board[0]; /* faster as int than ttype on 8086 and Z80 */
    if ( PieceBlank != p )
    {
        if ( p == g_board[1] && p == g_board[2] )
            return p;

        if ( p == g_board[3] && p == g_board[6] )
            return p;
    }

    p = g_board[3];
    if ( PieceBlank != p && p == g_board[4] && p == g_board[5] )
        return p;

    p = g_board[6];
    if ( PieceBlank != p && p == g_board[7] && p == g_board[8] )
        return p;

    p = g_board[1];
    if ( PieceBlank != p && p == g_board[4] && p == g_board[7] )
        return p;

    p = g_board[2];
    if ( PieceBlank != p && p == g_board[5] && p == g_board[8] )
        return p;

    p = g_board[4];
    if ( PieceBlank != p )
    {
        if ( ( p == g_board[0] ) && ( p == g_board[8] ) )
            return p;

        if ( ( p == g_board[2] ) && ( p == g_board[6] ) )
            return p;
    }

    return PieceBlank;
} /*LookForWinner*/

ttype pos0func()
{
    char x;
    x = g_board[0];
    
    if ( ( x == g_board[1] && x == g_board[2] ) ||
         ( x == g_board[3] && x == g_board[6] ) ||
         ( x == g_board[4] && x == g_board[8] ) )
        return x;
    return PieceBlank;
}

ttype pos1func()
{
    char x;
    x = g_board[1];
    
    if ( ( x == g_board[0] && x == g_board[2] ) ||
         ( x == g_board[4] && x == g_board[7] ) )
        return x;
    return PieceBlank;
} 

ttype pos2func()
{
    char x;
    x = g_board[2];
    
    if ( ( x == g_board[0] && x == g_board[1] ) ||
         ( x == g_board[5] && x == g_board[8] ) ||
         ( x == g_board[4] && x == g_board[6] ) )
        return x;
    return PieceBlank;
} 

ttype pos3func()
{
    char x;
    x = g_board[3];
    
    if ( ( x == g_board[4] && x == g_board[5] ) ||
         ( x == g_board[0] && x == g_board[6] ) )
        return x;
    return PieceBlank;
} 

ttype pos4func()
{
    char x;
    x = g_board[4];
    
    if ( ( x == g_board[0] && x == g_board[8] ) ||
         ( x == g_board[2] && x == g_board[6] ) ||
         ( x == g_board[1] && x == g_board[7] ) ||
         ( x == g_board[3] && x == g_board[5] ) )
        return x;
    return PieceBlank;
} 

ttype pos5func()
{
    char x;
    x = g_board[5];
    
    if ( ( x == g_board[3] && x == g_board[4] ) ||
         ( x == g_board[2] && x == g_board[8] ) )
        return x;
    return PieceBlank;
} 

ttype pos6func()
{
    char x;
    x = g_board[6];
    
    if ( ( x == g_board[7] && x == g_board[8] ) ||
         ( x == g_board[0] && x == g_board[3] ) ||
         ( x == g_board[4] && x == g_board[2] ) )
        return x;
    return PieceBlank;
} 

ttype pos7func()
{
    char x;
    x = g_board[7];
    
    if ( ( x == g_board[6] && x == g_board[8] ) ||
         ( x == g_board[1] && x == g_board[4] ) )
        return x;
    return PieceBlank;
} 

ttype pos8func()
{
    char x;
    x = g_board[8];
    
    if ( ( x == g_board[6] && x == g_board[7] ) ||
         ( x == g_board[2] && x == g_board[5] ) ||
         ( x == g_board[0] && x == g_board[4] ) )
        return x;
    return PieceBlank;
} 

int * winner_functions[9];

ttype MinMax( alpha, beta, depth, move ) ttype alpha; ttype beta; ttype depth; ttype move;
{
    ttype pieceMove, score;   /* better perf with char than int. out of registers so use stack */
    int p, value;    /* better perf with these as an int on Z80, 8080, and 8086 */
    ttype (*winfunc)();

    g_moves++;

    if ( depth >= 4 )
    {
        /* winner_functions is faster than winner2() and LookForWinner() */
        winfunc = winner_functions[ move ];
        p = ( * winfunc )();

        if ( PieceBlank != p )
        {
            if ( PieceX == p )
                return ScoreWin;

            return ScoreLose;
        }

        if ( 8 == depth )
            return ScoreTie;
    }

    if ( depth & 1 ) 
    {
        value = ScoreMin;
        pieceMove = PieceX;
    }
    else
    {
        value = ScoreMax;
        pieceMove = PieceO;
    }

    for ( p = 0; p < 9; p++ )
    {
        if ( PieceBlank == g_board[ p ] )
        {
            g_board[p] = pieceMove;
            score = MinMax( alpha, beta, depth + 1, p );
            g_board[p] = PieceBlank;

            if ( depth & 1 ) 
            {
                if ( ScoreWin == score )
                    return ScoreWin;

                if ( score > value )
                {
                    value = score;

                    if ( value >= beta )
                        return value;
                    if ( value > alpha )
                        alpha = value;
                }
            }
            else
            {
                if ( ScoreLose == score )
                    return ScoreLose;

                if ( score < value )
                {
                    value = score;

                    if ( value <= alpha )
                        return value;
                    if ( value < beta )
                        beta = value;
                }
            }
        }
    }

    return value;
}  /*MinMax*/

int FindSolution( position ) ttype position;
{
    g_board[ position ] = PieceX;
    MinMax( ScoreMin, ScoreMax, 0, position );
    g_board[ position ] = PieceBlank;
} /*FindSolution*/

int main( argc, argv ) int argc; char * argv[];
{
    int i, iterations;

    for ( i = 0; i < 9; i++ )
        g_board[ i ] = PieceBlank;

    winner_functions[ 0 ] = &pos0func;
    winner_functions[ 1 ] = &pos1func;
    winner_functions[ 2 ] = &pos2func;
    winner_functions[ 3 ] = &pos3func;
    winner_functions[ 4 ] = &pos4func;
    winner_functions[ 5 ] = &pos5func;
    winner_functions[ 6 ] = &pos6func;
    winner_functions[ 7 ] = &pos7func;
    winner_functions[ 8 ] = &pos8func;

    if ( 2 == argc )
        sscanf( argv[ 1 ], "%d", &iterations ); /* no atoi in MS C 1.0 */
    else
        iterations = 10;

    for ( i = 0; i < iterations; i++ )
    {
        g_moves = 0;
        FindSolution( 0 );
        FindSolution( 1 );
        FindSolution( 4 );
    }

    printf( "move count:      %d\n", g_moves ); /* 6493 */
    printf( "iteration count: %d\n", iterations );
    return 0;
} /*main*/

