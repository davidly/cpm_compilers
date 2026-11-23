program PascalMem;

function BlsPascalVersion: integer; 
begin
   BlsPascalVersion := mem[$0100 + 5] * 10 + mem[$0100 + 6];
   (* return 10 for v1.0, 12 for v1.2, etc *)
end; 

function GetHiMem: integer;
var PMTP, p: integer; 
begin
   p := addr(PMTP);
   (* PMTP = $0c94-95 = Highest RAM address the WSP of running program can access *)
   mem[p+0] := mem[3220];
   mem[p+1] := mem[3221]; 
   GetHiMem := PMTP
end; 

function MemAvail: integer;
var WSP, p: integer; 
begin
   p := addr(WSP);
   (* WSP = $0c92-93 = Program WorkSpace Stack Pointer *)
   mem[p+0] := mem[3218];
   mem[p+1] := mem[3219]; 
   MemAvail := GetHiMem - WSP;
end; 

function StrHex(n, len: integer): string[4];
var d: integer; 
    ch: string[1];
    s: string[4];
begin
   s := '';
   while len > 0 do begin
      d := n and 15;
      n := n shift -4;
      if d <= 9 then ch := chr(48+d) 
                else ch := chr(ord('A')-10+d);
      s := concat(ch, s);
      len := len -1;
   end; 
   StrHex := s;
end;

procedure PasMem;
var m, m1, m2: integer; 
begin
   writeln('Memory avalilable for Running compiled Pascal Programs');
   writeln('BLS Pascal version: ', BlsPascalVersion);
   write('Into BLS Pascal environment?: ');
   if mem[$0C9C] = 0 then write('YES - Using RUN command') else write('NO - Stand alone .COM file') ;
   writeln;
   m := MemAvail;
   m2 := GetHiMem;
   m1 := m2 - m;
   write('BLS Pascal Working RAM: $',StrHex(m1, 4),' - $', StrHex(m2, 4));
   m := m shift -10;
   writeln(' (',m,' Kb)'); 
end;

begin
   PasMem;
end.

