MODULE ttt;

import terminal;
import inout;

CONST
    scoreWin = 6;
    scoreTie = 5;
    scoreLose = 4;
    scoreMax = 9;
    scoreMin = 2;
    scoreInvalid = 0;

    pieceBlank = 0;
    pieceX = 1;
    pieceO = 2;

    defaultIterations = 10;

TYPE
    boardType = ARRAY[ 0..8 ] OF integer;

VAR
    evaluated: integer;
    board: boardType;

PROCEDURE lookForWinner() : integer;
VAR t : integer;
BEGIN
    t := board[ 0 ];
    IF pieceBlank <> t THEN
        IF ( ( ( t = board[1] ) AND ( t = board[2] ) ) OR
           ( ( t = board[3] ) AND ( t = board[6] ) ) ) THEN
            RETURN t;
        END;
    END;

    t := board[1];
    IF ( pieceBlank <> t ) AND ( t = board[4] ) AND ( t = board[7] ) THEN RETURN t; END;

    t := board[2];
    IF ( pieceBlank <> t ) AND ( t = board[5] ) AND ( t = board[8] ) THEN RETURN t; END;

    t := board[3];
    IF ( pieceBlank <> t ) AND ( t = board[4] ) AND ( t = board[5] ) THEN RETURN t; END;

    t := board[6];
    IF ( pieceBlank <> t ) AND ( t = board[7] ) AND ( t = board[8] ) THEN RETURN t; END;

    t := board[4];
    IF pieceBlank <> t THEN
        IF ( ( ( t = board[0] ) AND ( t = board[8] ) ) OR
           ( ( t = board[2] ) AND ( t = board[6] ) ) ) THEN
                RETURN t;
        END;
    END;

    RETURN pieceBlank;
END lookForWinner;

PROCEDURE winner2( move: integer ) : integer;
VAR x : integer;
BEGIN
    x := board[ move ];
    CASE move OF
        0:  IF NOT ( ( ( x = board[1] ) AND ( x = board[2] ) ) OR
                     ( ( x = board[3] ) AND ( x = board[6] ) ) OR
                     ( ( x = board[4] ) AND ( x = board[8] ) ) )
                THEN RETURN pieceBlank; END; |
        1:  IF NOT ( ( ( x = board[0] ) AND ( x = board[2] ) ) OR
                     ( ( x = board[4] ) AND ( x = board[7] ) ) )
                THEN x := pieceBlank; END; |
        2:  IF NOT ( ( ( x = board[0] ) AND ( x = board[1] ) ) OR
                     ( ( x = board[5] ) AND ( x = board[8] ) ) OR
                     ( ( x = board[4] ) AND ( x = board[6] ) ) )
                THEN x := pieceBlank; END; |
        3:  IF NOT ( ( ( x = board[4] ) AND ( x = board[5] ) ) OR
                     ( ( x = board[0] ) AND ( x = board[6] ) ) )
                THEN x := pieceBlank; END; |
        4:  IF NOT ( ( ( x = board[0] ) AND ( x = board[8] ) ) OR
                     ( ( x = board[2] ) AND ( x = board[6] ) ) OR
                     ( ( x = board[1] ) AND ( x = board[7] ) ) OR
                     ( ( x = board[3] ) AND ( x = board[5] ) ) )
                THEN x := pieceBlank; END; |
        5:  IF NOT ( ( ( x = board[3] ) AND ( x = board[4] ) ) OR
                     ( ( x = board[2] ) AND ( x = board[8] ) ) )
                THEN x := pieceBlank; END; |
        6:  IF NOT ( ( ( x = board[7] ) AND ( x = board[8] ) ) OR
                     ( ( x = board[0] ) AND ( x = board[3] ) ) OR
                     ( ( x = board[4] ) AND ( x = board[2] ) ) )
                THEN x := pieceBlank; END; |
        7:  IF NOT ( ( ( x = board[6] ) AND ( x = board[8] ) ) OR
                     ( ( x = board[1] ) AND ( x = board[4] ) ) )
                THEN x := pieceBlank; END; |
        8:  IF NOT ( ( ( x = board[6] ) AND ( x = board[7] ) ) OR
                     ( ( x = board[2] ) AND ( x = board[5] ) ) OR
                     ( ( x = board[0] ) AND ( x = board[4] ) ) )
                THEN x := pieceBlank; END;
    END;

    RETURN x;
END winner2;

PROCEDURE minmax( alpha: integer; beta: integer; move: integer; depth: integer ): integer;
VAR p, value, pieceMove, score, i : integer;
BEGIN
    evaluated := evaluated + 1;
    value := scoreInvalid;
    IF depth >= 4 THEN
        p := lookForWinner();
        (* p := winner2( move ); *)

        IF p <> pieceBlank THEN
            IF p = pieceX THEN
                RETURN scoreWin;
            ELSE
                RETURN scoreLose;
            END;
        END;
        IF depth = 8 THEN
            RETURN scoreTie;
        END;
    END;

    IF pieceO = board[ move ] THEN
        value := scoreMin;
        pieceMove := pieceX;
    ELSE
        value := scoreMax;
        pieceMove := pieceO;
    END;

    p := 0;
    REPEAT
        IF board[ p ] = pieceBlank THEN
            board[ p ] := pieceMove;
            score := minmax( alpha, beta, p, depth + 1 );
            board[ p ] := pieceBlank;

            IF pieceX = pieceMove THEN
                IF ( score = scoreWin ) THEN RETURN scoreWin; END;
                IF ( score > value ) THEN
                    value := score;
                    IF ( value >= beta ) THEN RETURN value; END;
                    IF ( value > alpha ) THEN alpha := value; END;
                END;
            ELSE
                IF ( score = scoreLose ) THEN RETURN scoreLose; END;
                IF ( score < value ) THEN
                    value := score;
                    IF ( value <= alpha ) THEN RETURN value; END;
                    IF ( value < beta ) THEN beta := value; END;
                END;
            END;
        END;
        p := p + 1
    UNTIL p > 8;

    RETURN value;
END minmax;

PROCEDURE runit( move : integer );
VAR score : integer;
BEGIN
    board[move] := pieceX;
    score := minmax( scoreMin, scoreMax, move, 0 );
    board[move] := pieceBlank;
END runit;

VAR
    i, loops : integer;
    result : BOOLEAN;
    cmd : ARRAY[0..127] OF CHAR;
BEGIN
    loops := defaultIterations;

    FOR i := 0 TO 8 DO
        board[i] := pieceBlank;
    END;

    FOR i := 1 TO loops DO
        evaluated := 0;  (* once per loop to prevent overflow *)
        runit( 0 );
        runit( 1 );
        runit( 4 );
    END;

    terminal.writeln;
    terminal.writestring( 'moves evaluated: $' );
    inout.writeint( evaluated, 7 );
    terminal.writeln;
    terminal.writestring( 'iterations:      $' );
    inout.writeint( loops, 7 );
    terminal.writeln;
END ttt.

