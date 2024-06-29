program bdosTest;

type
  timetype = record h, m, s, l : integer; end;

var
  timeA : timetype;

begin
  Bdos( 2, 65 );
  Bdos( 105, Addr( timeA ) );
  writeln;
  write( timeA.h, ':', timeA.m, ':', timeA.s, '.', timeA.l );
  writeln;
end.
