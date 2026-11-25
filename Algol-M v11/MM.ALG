begin
comment BYTE magazine October 1982. Jerry Pournelle. Matrix multiply.
        various bugs not found because dimensions are square fixed by David Lee.
        Algol-M reals are BCD decimal. A and B hold small whole numbers,
        so the sum is exactly 465880;

decimal array a[1:20,1:20];
decimal array b[1:20,1:20];
decimal array c[1:20,1:20];
decimal summ;

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
        for j := 1 step 1 until 20 do
            summ := summ + c[ i, j ];
end;

summ := 0;
filla;
fillb;
fillc;
matmult;
summit;
write( "summ is : " );
writeon( summ );
if summ = 465880.0 then
    write( "summ is exactly 465880" );

end
