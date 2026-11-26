{ BYTE magazine October 1982. Jerry Pournelle. }
{ various bugs not found because dimensions are square fixed by David Lee }
{ integer version: each C element fits in 16 bits; sum kept in base 10000 }
{ expected result: 465880 }

program matrix;

const
    l = 20; { rows in A and resulting matrix C }
    m = 20; { columns in A and rows in B (must be identical) }
    n = 20; { columns in B and resulting matrix C }

var
    A : array [ 1 .. l, 1 .. m ] of integer; { [row,col] }
    B : array [ 1 .. m, 1 .. n ] of integer;
    C : array [ 1 .. l, 1 .. n ] of integer;

    SummHi, SummLo : integer;

procedure filla;
var
    i, j : integer;
begin { filla }
    for i := 1 to l do
        for j := 1 to m do
            A[ i, j ] := i + j;
end; { filla }

procedure fillb;
var
    i, j : integer;
begin { fillb }
    for i := 1 to m do
        for j := 1 to n do
            B[ i, j ] := ( i + j ) div j;
end; { fillb }

procedure fillc;
var
    i, j : integer;
begin { fillc }
    for i := 1 to l do
        for j := 1 to n do
            C[ i, j ] := 0;
end; { fillc }

procedure matmult;
var
    i, j, k : integer;
begin { matmult }
    for i := 1 to l do
        for j := 1 to n do
            for k := 1 to m do
                C[ i, j ] := C[ i, j ] + A[ i, k ] * B[ k, j ];
end; { matmult }

procedure summit;
var
    i, j : integer;
begin { summit }
    for i := 1 to l do
        for j := 1 to n do
            begin
                SummLo := SummLo + C[ i, j ];
                while SummLo >= 10000 do
                begin
                    SummLo := SummLo - 10000;
                    SummHi := SummHi + 1;
                end;
            end;
end; { summit }

procedure putnum( v, w : integer );
{ JRT Pascal writes a blank before integers, so write the digits; at least w of them }
var
    p, d : integer;
begin { putnum }
    p := 1;
    d := 1;
    while ( v div p ) >= 10 do
    begin
        p := p * 10;
        d := d + 1;
    end;
    while d < w do
    begin
        write( '0' );
        d := d + 1;
    end;
    while p > 0 do
    begin
        write( chr( ord( '0' ) + ( v div p ) mod 10 ) );
        p := p div 10;
    end;
end; { putnum }

begin { matrix }
    SummHi := 0;
    SummLo := 0;

    filla;
    fillb;
    fillc;
    matmult;
    summit;

    write( 'summ is : ' );
    putnum( SummHi, 1 );
    putnum( SummLo, 4 );
    writeln;
end. { matrix }
