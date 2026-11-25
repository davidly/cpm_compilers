(* BYTE magazine October 1982. Jerry Pournelle. *)
(* various bugs not found because dimensions are square fixed by David Lee *)
(* integer version: Pascal Pascal has no real type or multi-dimensional arrays, *)
(* so the arrays are indexed by hand and the sum is kept in base 10000 *)
(* expected result: 465880 *)

const
    l = 20; (* rows in A and resulting matrix C *)
    m = 20; (* columns in A and rows in B (must be identical) *)
    n = 20; (* columns in B and resulting matrix C *)

type
    matrixType = array[ 0..399 ] of word;

var
    summHi, summLo : word;
    a : matrixType;
    b : matrixType;
    c : matrixType;

procedure filla;
var
    i, j : word;
begin
    i := 0;
    while i < l do begin
        j := 0;
        while j < m do begin
            a[ i * m + j ] := i + j + 2;
            j := j + 1;
        end;
        i := i + 1;
    end;
end;

procedure fillb;
var
    i, j : word;
begin
    i := 0;
    while i < m do begin
        j := 0;
        while j < n do begin
            b[ i * n + j ] := ( i + j + 2 ) / ( j + 1 );
            j := j + 1;
        end;
        i := i + 1;
    end;
end;

procedure fillc;
var
    i, j : word;
begin
    i := 0;
    while i < l do begin
        j := 0;
        while j < n do begin
            c[ i * n + j ] := 0;
            j := j + 1;
        end;
        i := i + 1;
    end;
end;

procedure matmult;
var
    i, j, k : word;
begin
    i := 0;
    while i < l do begin
        j := 0;
        while j < n do begin
            k := 0;
            while k < m do begin
                c[ i * n + j ] := c[ i * n + j ] + a[ i * m + k ] * b[ k * n + j ];
                k := k + 1;
            end;
            j := j + 1;
        end;
        i := i + 1;
    end;
end;

procedure summit;
var
    i, j : word;
begin
    i := 0;
    while i < l do begin
        j := 0;
        while j < n do begin
            summLo := summLo + c[ i * n + j ];
            while summLo >= 10000 do begin
                summLo := summLo - 10000;
                summHi := summHi + 1;
            end;
            j := j + 1;
        end;
        i := i + 1;
    end;
end;

begin
    summHi := 0;
    summLo := 0;

    filla;
    fillb;
    fillc;
    matmult;
    summit;

    put#1( 'summ is : ' );
    put#1( summHi# );
    if summLo < 1000 then put#1( '0' );
    if summLo < 100 then put#1( '0' );
    if summLo < 10 then put#1( '0' );
    put#1( summLo# );
    put#1( 13, 10 );
end.
