program tmem;

procedure showsp;
var stack : integer;
begin
    stack := 666;
    inline (
        $26/0/ { mvi h, 0 }
        $2E/0/ { mvi l, 0 }
        $39/   { dad sp }
        $E5/   { push h }
        $D1/   { pop d }
        $21/stack/ { lxi h, stack }
        $7B/   { ld a,e }
        $77/   { ld (hl),a }
        $23/   { inc hl }
        $7A/   { ld a, d }
        $77    { ld (hl),a }
    );

    writeln( 'stack pointer: ', stack );
end;

var i : integer;
begin
    for i := 0 to 10 do
        writeln( 'byte ', i, ' is ', mem[i] );

    showsp;
end.