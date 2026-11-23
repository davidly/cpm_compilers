{ App to prove you can't win at Tic-Tac-Toe }

{ This flag turns off checking if the recursion stack and heap collide }
{$K-}

program ttt(output);

const
    scoreWin = 6;
    scoreTie = 5;
    scoreLose = 4;
    scoreMax = 9;
    scoreMin = 2;
    scoreInvalid = 0;

    pieceBlank = 0;
    pieceX = 1;
    pieceO = 2;

    iterations = 10;

var
    evaluated: integer;
    board: array[ 0..8 ] of integer;
    i, loops: integer;

procedure dumpBoard;
var
    i : integer;
begin
    Write( '{' );
    for i := 0 to 8 do
        Write( board[i] );
    Write( '}' );
end;

function lookForWinner : integer;
var
    t, p : integer;
begin
    {dumpBoard;}
    p := pieceBlank;
    t := board[ 0 ];
    if pieceBlank <> t then
    begin
        if ( ( ( t = board[1] ) and ( t = board[2] ) ) or
             ( ( t = board[3] ) and ( t = board[6] ) ) ) then
            p := t;
    end;

    if pieceBlank = p then
    begin
        t := board[1];
        if ( t = board[4] ) and ( t = board[7] ) then
            p := t
        else
        begin
            t := board[2];
            if ( t = board[5] ) and ( t = board[8] ) then
                p := t
            else
            begin
                t := board[3];
                if ( t = board[4] ) and ( t = board[5] ) then
                    p := t
                else
                begin
                    t := board[6];
                    if ( t = board[7] ) and ( t = board[8] ) then
                        p := t
                    else
                    begin
                      t := board[4];
                      if ( ( ( t = board[0] ) and ( t = board[8] ) ) or
                           ( ( t = board[2] ) and ( t = board[6] ) ) ) then
                          p := t
                    end;
                end;
            end;
        end;
    end;

    lookForWinner := p;
end;

{ If this flag isn't set, recursion doesn't work on CP/M }
{$A-}

function minmax( alpha: integer; beta: integer; depth: integer; move: integer ): integer;
var
    p, value, pieceMove, score : integer;
begin
    evaluated := evaluated + 1;
    value := scoreInvalid;
    if depth >= 4 then
    begin
        p := lookForWinner;  { this is much slower }
        { p := winner2( move ); }
        if p <> pieceBlank then
        begin
            if p = pieceX then
                value := scoreWin
            else
                value := scoreLose
        end
        else if depth = 8 then
            value := scoreTie;
    end;

    if value = scoreInvalid then
    begin
        if Odd( depth ) then
        begin
            value := scoreMin;
            pieceMove := pieceX;
        end
        else
        begin
            value := scoreMax;
            pieceMove := pieceO;
        end;

        p := 0;
        repeat
            if board[ p ] = pieceBlank then
            begin
                board[ p ] := pieceMove;
                score := minmax( alpha, beta, depth + 1, p );
                board[ p ] := pieceBlank;

                if Odd( depth ) then
                begin
                    if ( score > value ) then
                    begin
                        value := score;
                        if ( value = scoreWin ) or ( value >= beta ) then p := 10
                        else if ( value > alpha ) then alpha := value;
                    end;
                end
                else
                begin
                    if ( score < value ) then
                    begin
                        value := score;
                        if ( value = scoreLose ) or ( value <= alpha ) then p := 10
                        else if ( value < beta ) then beta := value;
                    end;
                end;
            end;
            p := p + 1;
        until p > 8;
    end;

    minmax := value;
end;

{$A+}

procedure runit( move : integer );
var
    score: integer;
begin
    board[move] := pieceX;
    score := minmax( scoreMin, scoreMax, 0, move );
    board[move] := pieceBlank;
end;

begin
    loops := iterations;

    if ( loops > 0 ) then
    begin
        for i := 0 to 8 do
            board[i] := pieceBlank;
    
        for i := 1 to loops do
        begin
            evaluated := 0;  { once per loop to prevent overflow }
            runit( 0 );
            runit( 1 );
            runit( 4 );
        end;
    
        WriteLn( 'moves evaluated: ', evaluated );
    end;
  
    WriteLn( 'iterations: ', loops );
end.
