begin
comment BYTE magazine October 1982. Jerry Pournelle. Matrix multiply.
        various bugs not found because dimensions are square fixed by David Lee.
        integer version: each element of C fits in 16 bits, the sum is kept in
        base 10000. Each element is under 10000, so one carry per add is enough;

integer array a[1:20,1:20];
integer array b[1:20,1:20];
integer array c[1:20,1:20];
integer summhi, summlo, p;
string(1) array dig[0:9];

procedure filla;
begin
    integer i, j;
    for i := 1 step 1 until 20 do
        for j := 1 step 1 until 20 do
            a[ i, j ] := i + j;
end;

procedure fillb;
begin
    integer i, j;
    for i := 1 step 1 until 20 do
        for j := 1 step 1 until 20 do
            b[ i, j ] := ( i + j ) / j;
end;

procedure fillc;
begin
    integer i, j;
    for i := 1 step 1 until 20 do
        for j := 1 step 1 until 20 do
            c[ i, j ] := 0;
end;

procedure matmult;
begin
    integer i, j, k;
    for i := 1 step 1 until 20 do
        for j := 1 step 1 until 20 do
            for k := 1 step 1 until 20 do
                c[ i, j ] := c[ i, j ] + a[ i, k ] * b[ k, j ];
end;

procedure summit;
begin
    integer i, j;
    for i := 1 step 1 until 20 do
        for j := 1 step 1 until 20 do begin
            summlo := summlo + c[ i, j ];
            if summlo >= 10000 then begin
                summlo := summlo - 10000;
                summhi := summhi + 1;
            end;
        end;
end;

summhi := 0;
summlo := 0;
filla;
fillb;
fillc;
matmult;
summit;
comment writeon pads numbers to 6 columns, so the digits are written as strings;
dig[0] := "0"; dig[1] := "1"; dig[2] := "2"; dig[3] := "3"; dig[4] := "4";
dig[5] := "5"; dig[6] := "6"; dig[7] := "7"; dig[8] := "8"; dig[9] := "9";
write( "summ is : " );
p := 1;
while summhi / ( p * 10 ) > 0 do
    p := p * 10;
while p > 0 do begin
    writeon( dig[ summhi / p - ( summhi / ( p * 10 ) ) * 10 ] );
    p := p / 10;
end;
p := 1000;
while p > 0 do begin
    writeon( dig[ summlo / p - ( summlo / ( p * 10 ) ) * 10 ] );
    p := p / 10;
end;

end
