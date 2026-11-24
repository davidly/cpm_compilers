var n,k : integer;

function stirling(n,k : integer);

   begin
   if (k=1) or (n=k)
      then stirling:=1
      else stirling:=stirling(n-1,k-1)+k*stirling(n-1,k)
   end; (* function stirling *)

begin (* main line *)
put#1(9,9,9,9,9,'k',13,10); (* print centered "k" *)

put#1('n', 9);              (* print column headings *)
for n:=1 to 10 do
   put#1(n#,9);
put#1(13, 10);
put#1(9,'=',9,'=',9,'=',9,'=',9,'=',9,'=',9,'=',9,'=',9,'=',9,'=',13,10);

for n:=1 to 10 do begin     (* print body of table *)
   put#1(n#, ':', 9);
   for k:=1 to n do
      put#1(stirling(n,k)#, 9);
   put#1(13, 10) (* start new line *)
   end
end.
