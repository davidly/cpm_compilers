
(*
	Prints solutions to the problem of placing eight queens on
	a chess board in such a way that no queen checks against
	any other queen.  See "Algorithms+Data Structures = Programs",
	Niklaus Wirth.
*)

type
   boolean = (false, true);
   aryi    = array[0.. 8] of integer;
   aryb    = array[0..16] of boolean;

var
   i : integer;
   a, b, c: aryb;
   x      : aryi;

procedure print;

   var
      k : integer;

   begin
   for k:=1 to 8 do put#0(x[k]#,' ');
   put#0(13,10)
   end; (* procedure print *)

procedure try(i : integer);

   var
      j : integer;

   begin
   for j:=1 to 8 do
      if (a[j]=true) and (b[i+j]=true) and (c[i-j+7]=true) then
         begin
         x[i]:=j;
         a[j]:=false; b[i+j]:=false; c[i-j+7]:=false;
         if i<8 then try(i+1) else print;
         a[j]:=true; b[i+j]:=true; c[i-j+7]:=true
         end
   end; (* procedure try *)

begin (* main line *)
for i:= 1   to 8  do a[i]   :=true;
for i:= 2   to 16 do b[i]   :=true;
for i:= 0-7 to 7  do c[i+7] :=true;

try(1)
end.
