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

type
    boardType = array[ 0..8 ] of byte;

var
    i, evaluated: word;
    board: boardType;

function lookForWinner;
var
    t, p : word;
begin
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

function winner2( move: word );
var
    x : word;
begin
    case move of
        0:  begin
            x := board[ 0 ];
            if ( ( ( x <> board[1] ) or ( x <> board[2] ) ) and
                 ( ( x <> board[3] ) or ( x <> board[6] ) ) and
                 ( ( x <> board[4] ) or ( x <> board[8] ) ) )
                then x := PieceBlank;
            end;
        1:  begin
            x := board[ 1 ];
            if ( ( ( x <> board[0] ) or ( x <> board[2] ) ) and
                 ( ( x <> board[4] ) or ( x <> board[7] ) ) )
                then x := PieceBlank;
            end;
        2:  begin
            x := board[ 2 ];
            if ( ( ( x <> board[0] ) or ( x <> board[1] ) ) and
                 ( ( x <> board[5] ) or ( x <> board[8] ) ) and
                 ( ( x <> board[4] ) or ( x <> board[6] ) ) )
                then x := PieceBlank;
            end;
        3:  begin
            x := board[ 3 ];
            if ( ( ( x <> board[4] ) or ( x <> board[5] ) ) and
                 ( ( x <> board[0] ) or ( x <> board[6] ) ) )
                then x := PieceBlank;
            end;
        4:  begin
            x := board[ 4 ];
            if ( ( ( x <> board[0] ) or ( x <> board[8] ) ) and
                 ( ( x <> board[2] ) or ( x <> board[6] ) ) and
                 ( ( x <> board[1] ) or ( x <> board[7] ) ) and
                 ( ( x <> board[3] ) or ( x <> board[5] ) ) )
                then x := PieceBlank;
            end;
        5:  begin
            x := board[ 5 ];
            if ( ( ( x <> board[3] ) or ( x <> board[4] ) ) and
                 ( ( x <> board[2] ) or ( x <> board[8] ) ) )
                then x := PieceBlank;
            end;
        6:  begin
            x := board[ 6 ];
            if ( ( ( x <> board[7] ) or ( x <> board[8] ) ) and
                 ( ( x <> board[0] ) or ( x <> board[3] ) ) and
                 ( ( x <> board[4] ) or ( x <> board[2] ) ) )
                then x := PieceBlank;
            end;
        7:  begin
            x := board[ 7 ];
            if ( ( ( x <> board[6] ) or ( x <> board[8] ) ) and
                 ( ( x <> board[1] ) or ( x <> board[4] ) ) )
                then x := PieceBlank;
            end;
        8:  begin
            x := board[ 8 ];
            if ( ( ( x <> board[6] ) or ( x <> board[7] ) ) and
                 ( ( x <> board[2] ) or ( x <> board[5] ) ) and
                 ( ( x <> board[0] ) or ( x <> board[4] ) ) )
                then x := PieceBlank;
            end
    end;

    winner2 := x;
end;

function minmax( alpha: word; beta: word; depth: word; move: word );
var
    p, value, pieceMove, score : word;
begin
    evaluated := evaluated + 1;
    value := scoreInvalid;
    if depth >= 4 then
    begin
        (* slower: p := lookForWinner; *)
        p := winner2( move );
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
        if board[ move ] = pieceO then
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

                if pieceMove = pieceX then
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

procedure runit( move : word );
var
    score: word;
begin
    board[move] := pieceX;
    score := minmax( scoreMin, scoreMax, 0, move );
    board[move] := pieceBlank;
end;

begin
    for i := 0 to 8 do
        board[i] := pieceBlank;
    
    for i := 1 to iterations do
    begin
        evaluated := 0;
        runit( 0 );
        runit( 1 );
        runit( 4 );
    end;
    
    put#1('moves:  ',evaluated#);
end.
