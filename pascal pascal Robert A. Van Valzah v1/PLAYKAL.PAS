const
   (* 'CONSTANT' VARIABLES USED TO REFERENCE COLS OF BOARD *)
   RLEFT  = 0; (* STONES IN RED'S LEFT PIT *)
   RRIGHT = 1; (* STONES IN RED'S RIGHT PIT *)
   RKAL   = 2; (* STONES IN RED'S KALAH *)
   BLEFT  = 3; (* STONES IN BLUE'S LEFT PIT *)
   BRIGHT = 4; (* STONES IN BLUE'S RIGHT PIT *)
   BKAL   = 5; (* STONES IN BLUE'S KALAH *)
   TURN   = 6; (* -1 MEANS RED'S TURN, 1 MEANS BLUE'S TURN *)
   LSON   = 7; (* ROW NUMBER OF LEFT SON *)
   RSON   = 8; (* ROW NUMBER OF RIGHT SON *)
   BESPAT = 9; (* 1 MEANS ON BEST PATH, 0 IF NOT *)
   OUTCOM = 10; (* 0 MEANS blue WIN, 1 MEANS DRAW, 2 MEANS red WIN *)
   ncols  = 11; (* number of columns in bd matrix *)
   rwin   = 2;  (* outcom value for red  win *)
   draw   = 1;  (* outcom value for draw *)
   bwin   = 0;  (* outcom value for blue win *)
   rturn  = 0;  (* turn value for red's  turn *)
   bturn  = 1;  (* turn value for blue's turn *)
   left   = 0;  (* move from left  pit *)
   right  = 1;  (* move from right pit *)
   offbespat = 0; (* bespat value if node is off best path *)
   onbespat  = 1; (* bespat value if node is on  best path *)


type
   ary = array[0..1000] of integer;
   boolean = (false, true);

var
   ch : integer;
   bd : ary;
   next : integer; (* row number of next "free" row in array board *)

function board(row, col : integer);

   begin
   board := bd[row*ncols + col]
   end; (* function board *)

procedure setbd(row, col, val : integer);

   begin
   bd[row*ncols + col] := val
   end; (* procedure setbd *)

function min(x, y : integer);

   begin
   if (x<y)
   then
      min:=x
   else
      min:=y
   end; (* function min *)

function max(x, y : integer);

   begin
   if (x>y)
   then
      max:=x
   else
      max:=y
   end; (* function max *)

procedure getroot;

   begin
   get#0(ch); setbd(1, rleft  ,ch-'0');
   get#0(ch); setbd(1, rright ,ch-'0');
   get#0(ch); setbd(1, rkal   ,ch-'0');
   get#0(ch); setbd(1, bleft  ,ch-'0');
   get#0(ch); setbd(1, bright ,ch-'0');
   get#0(ch); setbd(1, bkal   ,ch-'0');
   get#0(ch); setbd(1, turn   ,ch-'0');
   setbd(1, outcom , draw);
   setbd(1, bespat , offbespat)
   end; (* procedure getroot *)

procedure prtrow(row : integer);

   begin
   put#0(13,10);
   put#0(' ', ' ', board(row, bright)#,
         ' ', ' ', board(row, bleft )#, 13,10);

   put#0(board(row, bkal)#, ' ');
   if board(row, outcom)=rwin
      then put#0('r', 'e', 'd', ' ')
      else if board(row, outcom)=draw
              then put#0('d', 'r', 'a', 'w')
              else put#0('b', 'l', 'u', 'e');
   put#0(' ', board(row, rkal)#, ' ');

   if (board(row, bespat)=onbespat)
   then
      put#0('this boa',
            'rd is on',
            ' the bes',
            't possib',
            'le path.');
   put#0(13,10);

   put#0(' ', ' ', board(row, rleft )#,
         ' ', ' ', board(row, rright)#, 13,10)
   end; (* procedure prtrow *)

procedure compconf(father, son, sourcpit : integer);

   var
      sowopp,
      moving : boolean;
      frompit,
      topit,
      sowston,
      pturn,  (* rturn if red players turn, bturn otherwise *)
      i      : integer;

   begin
   pturn:=board(father, turn);
   if (pturn=bturn) then
      if (sourcpit=left) then
         frompit:=bleft
      else
         frompit:=bright
   else  (* must be red's turn *)
      if (sourcpit=left) then
         frompit:=rleft
      else
         frompit:=rright;
(* put#0('frompit=',frompit#,13,10);
*)
   for i:=rleft to outcom do  (* copy father board to son *)
      setbd(son, i, board(father, i));

   (* test if able to move *)
   if (board(father, frompit)=0) (* if frompit has no stones *)
   or (board(father, bkal)>6)    (* or blue has won *)
   or (board(father, rkal)>6)    (* or red has won *)
   then                       (* unable to move *)
      setbd(son, turn, board(father, turn))
   else                       (* still have move left *)
      if (board(father, turn)=rturn)
      then setbd(son, turn, bturn)
      else setbd(son, turn, rturn);

   moving:=true;
   while (moving=true) do begin
      sowston:=board(son, frompit);
(*    put#0('sowston=',sowston#,13,10);
*)    setbd(son, frompit, 0);
      topit:=frompit;
      sowopp:=false;

      while (sowston>0) do begin
         topit:=topit+1;
(*       put#0('topit= ',topit#,13,10);
*)       if (topit>bkal) then
            topit:=rleft;
         if (topit=rkal) and (pturn=bturn) then
            topit:=bleft;
         if (topit=bkal) and (pturn=rturn) then
            topit:=rleft;

(*       put#0('topit= ',topit#,13,10);
*)
         (* set sowopp to true if sowing into opponents pits *)
         if (pturn=bturn) then
            if (topit=rleft) or (topit=rright) then
               sowopp:=true;
         if (pturn=rturn) then
            if (topit=bleft) or (topit=bright) then
               sowopp:=true;

         setbd(son, topit, board(son,topit)+1); (* sow a stone *)
         sowston:=sowston-1  (* number to sow is one less now *)
         end; (* while sowston>0 *)

      (* check for go again, set moving *)
      if (sowopp=true) and (board(son, topit) > 1) then
         if ( (pturn=bturn) and ((topit=bleft) or (topit=bright)) )
         or ( (pturn=rturn) and ((topit=rleft) or (topit=rright)) )
            then (*  a go again move *)
               begin
                  moving:=true;
                  frompit:=topit
               end
            else
               moving:=false (* not a go again move *)
         else (* not a go again move *)
            moving:=false;

      (* check for capture *)
      if (board(son, topit)=2) or (board(son ,topit)=3)
      then  (* capture possible *)
         begin
         if (pturn=bturn) and ((topit=rleft) or (topit=rright))
         then
            begin
            setbd(son, bkal, board(son, bkal)+board(son, topit));
            setbd(son, topit, 0);
            if (topit=rright) and
               ((board(son, rleft)=2) or (board(son, rleft)=3))
            then
               begin
               setbd(son, bkal, board(son, bkal)+board(son, rleft));
               setbd(son, rleft, 0)
               end
            end;
         if (pturn=rturn) and ((topit=bleft) or (topit=bright))
         then
            begin
            setbd(son, rkal, board(son, rkal)+board(son, topit));
            setbd(son, topit, 0);
            if (topit=bright) and
               ((board(son, bleft)=2) or (board(son, bleft)=3))
            then
               begin
               setbd(son, rkal, board(son, rkal)+board(son, bleft));
               setbd(son, bleft, 0)
               end
            end
         end
      end (* while moving=true *)
   end; (* procedure compconf *)

procedure growtree(root : integer);

   begin
(* put#0('growtree',root#,13,10);
*) compconf(root, next, left); (* attempt to grow left son *)
   if (board(root, turn)<>board(next, turn))
   then (* there is a left son *)
      begin
(*    put#0('leftson ',13,10);
      prtrow(next);
*)    setbd(root, lson, next); (* link son to father *)
      next:=next+1;
      growtree(next-1)
      end
   else (* there is not left son *)
      setbd(root, lson, 0);

   compconf(root, next, right); (* attempt to grow right son *)
   if (board(root, turn)<>board(next, turn))
   then (* there is a right son *)
      begin
(*    put#0('rightson',13,10);
      prtrow(next);
*)    setbd(root, rson, next); (* link son to father *)
      next:=next+1;
      growtree(next-1)
      end
   else (* there is no right son *)
      setbd(root, rson, 0)
   end; (* procedure growtree *)

procedure prttree(root : integer);

   begin
   if (root<>0)
   then
      begin
      prttree(board(root, lson)); (* print left  subtree *)
      prtrow (root); (* print the node *)
      prttree(board(root, rson))  (* print right subtree *)
      end
   end; (* procedure prttree *)

procedure findout(root : integer);

   begin
   if (root<>0)
   then
      begin

      (* init all nodes to "off best path" *)
      setbd(root, outcom, offbespat);

      findout(board(root, lson)); (* find outcome of left  subtree *)
      findout(board(root, rson)); (* find outcome of right subtree *)

      (* determine outcome of father *)
      (* first, see if he has any sons *)
      if (board(root, lson)=0) and (board(root, rson)=0)
      then                   (* he has no sons *)
                             (* determine outcome from pits *)
         if (board(root, bkal)>6)
         then                (* blue has won *)
            setbd(root, outcom, bwin)
         else (* either red win or draw *)
            if (board(root, rkal)>6)
            then              (* red has won *)
               setbd(root, outcom, rwin)
            else              (* neither won, therefore draw *)
               setbd(root, outcom, draw)

      else                    (* he has at least one son *)
                              (* determine outcome from sons *)
         if (board(root, lson)=0)  (* if no left son *)
         then                 (* outcome is from right son *)
            setbd(root, outcom,
               board( board(root, rson), outcom)
                 )
         else                      (* he has a left son *)
            if (board(root, rson)=0) (* if no right son *)
            then            (* outcome is from left son *)
               setbd(root, outcom,
                  board( board(root, lson), outcom)
                    )
            else                   (* he has both sons *)
               if (board(root, turn)=bturn)
               then    (* outcome is minimum of sons' outcomes *)
                  setbd(root, outcom,
                     min(board( board(root, lson), outcom),
                         board( board(root, rson), outcom)
                        )
                       )
               else    (* outcome is maximum of sons' outcomes *)
                  setbd(root, outcom,
                     max(board (board(root, lson), outcom),
                         board (board(root, rson), outcom)
                        )
                       )
      end (* if root<>0 *)
   end; (* procedure findout *)

procedure findbespat;

   var
      p : integer;  (* work pointer used to traverse tree *)

   begin
   p:=1;
   (* loop unitl leaf is found *)
   while (board(p, lson)<>0) or (board(p, rson)<>0) do
      begin
      setbd(p, bespat, onbespat);
      if (board(p, lson)=0)
      then (* root has no left son *)
         p:=board(p, rson)    (* move on right son *)
      else
         if (board(p, rson)=0)
         then (* root has no right son *)
            p:=board(p, lson)   (* move on to left son *)
         else (* root has both sons *)
            if (board(p, turn)=bturn)  (* if blue's turn *)
            then (* see if left outcom is better than right *)
               if (    board( board(p, lson), outcom)
                    <= board( board(p, rson), outcom)
                  )
               then                 (* left  is better or = *)
                  p:=board(p, lson) (* go left              *)
               else                 (* right is better      *)
                  p:=board(p, rson) (* go right             *)
            else (* it must be red's turn *)
               if (    board( board(p, lson), outcom)
                    >= board( board(p, rson), outcom)
                  )
               then                 (* left  is better or = *)
                  p:=board(p, lson) (* go left              *)
               else                 (* right is better ro = *)
                  p:=board(p, rson) (* go right             *)
      end; (* while not a leaf *)
   setbd(p, bespat, onbespat)  (* final leaf is on best path *)
   end; (* procedure findbespat *)

begin (* main line *)
getroot;
while (ch-'0'<>2) do  (* do while not eof *)

   begin
   put#0(13,10,13,10);
   put#0('root boa',
         'rd is   ');
   prtrow(1);

   next:=2; (* row 2 is first free row *)
   growtree(1);
   findout(1);
   findbespat;
   put#0(13,10,13,10);
   put#0('output t',
         'ree     ');
   prttree(1);
   getroot
   end

end.
