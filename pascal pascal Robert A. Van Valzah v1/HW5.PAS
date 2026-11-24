
(*
title    message decoding by optimal binary search tree building
         using the hu-tucker algorithm
         cs 321 homework 5
author   robert a. van valzah   03/31/80


this  program will build an optimal binary search tree given
a set of characters and frequencies of occurance.  the  tree
is constructed using the hu-tucker algorithm (see knuth, the
art of computer programming, volume 3/sorting and searching,
pp.  439-446).  an input sequence of 1's and 0's is then de-
coded into a sequence of characters  using  this  tree.  the
resulting message is printed.
*)


const
   nmax     = 30; (* max number of characters *)
   rl       = 9;  (* record length in words *)
   dim      = 810;(* nmax * rl * 3 *)
   char     = 0;  (* character value offset *)
   freq     = 1;  (* character frequence offset *)
   lst      = 2;  (* pointer to left  subtree offset *)
   rst      = 3;  (* pointer to right subtree offset *)
   lforst   = 4;  (* pointer to left  brother offset *)
   rforst   = 5;  (* pointer to right brother offset *)
   lev      = 6;  (* node level number *)
   lexp     = 7;  (* pointer to lexicographic predecessor *)
   lexs     = 8;  (* pointer to lexicographic successor *)

   nil      = 0;  (* zeroth element never used *)
   sent     = '$';(* sentinal character *)
   maxint   = 32767; (* kludge cause not defined by compiler *)

type
   ary      = array[0..dim] of word;
   boolean  = (false, true); (* kludge till compiler is done *)
   
var         (* global variables *)
   h        : ary;  (* the heap *)
   hp       : word; (* the heap pointer *)
   lmost,
   rmost    : word; (* left and right most ends of the list *)
   lexfirst : word; (* pointer to first node in lex order *)

procedure new(var p:word);

   begin
   hp:=hp+1;
   p:=hp*rl;
   if (p>dim-rl)
      then put#1('heapover')
   end; (* procedure new *)


(*
read  a  sequence of characters and weights from the standard
input file and create a node for each  pair.  the  nodes  are
linked into a doubly linked list to form a forest as they are
read.
*)
procedure readtree;

   var
      ch  : word;  (* node value *)
      frq : word;  (* frequency *)
      p   : word;  (* pointer to new node *)
      prev: word;  (* pointer to previous node read (for linking) *)

   procedure readnode;

      var
         c : word;

      begin
      get#0(ch);    (* get node value character *)
      if (ch<>sent)
         then begin
            get#0(c);
            while (c=' ') do get#0(c);
            frq:=0;
            while (c>='0') and (c<='9') do begin
               frq:=frq*10+c-'0';
               get#0(c)
               end (* while *)
            end;
      repeat get#0(c) until (c=10) (* ignore till lf found *)
      end; (* readnode *)

   begin
   readnode;        (* readln(ch, frq); *)
   prev:=nil;       (* no left forest for first node *)
   repeat
      new(var p);
      if (prev=nil) then lmost:=p; (* record pointer to first node *)
      h[p+char  ]:=ch;
      h[p+freq  ]:=frq;
      h[p+lst   ]:=nil;  (* leaves have no subtrees *)
      h[p+rst   ]:=nil;
      h[p+lforst]:=prev; (* link to last node read created *)
      h[p+lexp  ]:=prev; (* predecessor is also last node created *)
      if (prev<>nil) then begin (* on all but first node . . . *)
         h[prev+rforst  ]:=p;   (* make previous right forest pointer and *)
         h[prev+lexs    ]:=p    (* lexicographic successor point to the new node *)
         end;
      prev:=p;
      readnode
   until (ch=sent);

   (* done reading nodes *)
   rmost:=p;          (* record pointer to right most node *)
   h[p+rforst]:=nil;  (* right most node has no right brother *)
   h[p+lexs  ]:=nil   (* right most node has no lexicographic successor *)
   end; (* procedure readtree *)


(*
given a forest of trees (all leaves when we start), build them
into  a  single tree using phase 1 of the hu-tucker algorithm.
the root of the resultant tree will be in lmost on exit.

the algorithm is implemented using two internal procedures.the
first (picklr) chooses two  trees  for  combination,  and  the
second  (combinelr)  combines the two chosen trees to form new
internal node in the final  tree.  this  process  is  repeated
unitl the forest contains only one tree.
*)
procedure build1tree;

   var left, rite : word; (* pointers to nodes to be combined *)


   (*
   pick  two  trees from the forest which satisfy the following
   rules:

   let i and j be pointers to the left and right trees

   i)   no external nodes occur between i and j.

   ii)  the  sum of the weights of i and j is minimal for all i
        and j satisfying rule (i).

   iii) the  index i is minimal for all i satisfying rules (i),
        (ii).

   iv)  the  index j is minimal for all j satisfying rules (i),
        (ii), (iii).

   pointers to the two trees chosen will be left  in  left  and
   rite (respectivly).

   one  internal  procedure  is used to compare the minimum sum
   found so far against the sum of the frequencies of the trees
   under consideration.
   *)
   procedure picklr;

      var i,j : word; (* pointers to left and right nodes which
                            are mininimum pair candidates *)
          minsum : word; (* mininimum sum found so far *)


      (*
      compare  the sum of the frequencies of nodes i and j.  if
      their sum is less than the minimum  found  so  far,  then
      record  the  new  minimum (in minsum) and the position of
      i and j as the two best candidates for combining.
      *)
      procedure takemin;

         begin
         if (h[i+freq]+h[j+freq]<minsum) then begin
            minsum:=h[i+freq]+h[j+freq];
            rite:=j; left:=i
            end
         end; (* procedure takemin *)


      begin (* procedure picklr *)
      i:=lmost;         (* start with leftmost tree in forest *)
      minsum:=maxint;
      while (h[i+rforst]<>nil) do begin (* more i's to test *)
         j:= h[i+rforst];

         (* compare to internal nodes till exeternal is found *)
         while (h[j+char]=sent) do begin
            takemin;
            j:=h[j+rforst] (* on to the next tree *)
            end;

         (* j now points to only external node candidate *)
         takemin;
         i:=h[i+rforst ]     (* move to next tree in forest *)
         end (* while not out of i's *)
      end; (* procedure picklr *)


   (*
   combine  the two trees pointed to by left and rite to form a
   new internal node in the final  tree.  link  this  new  node
   into  the  existing  forest  in place of the left tree.  the
   rite tree is  deleted  from  the  forest.  pointers  to  the
   leftmost  and  rightmost  (lmost and rmost, respectivly) are
   updated in the process.  the frequency of the new  new  node
   becomes the sum of the frequencies of its offspring.
   *)
   procedure combinelr;

      var newn : word; (* pointer to new node created *)

      begin
      new(var newn);  (* get pointer to new node on heap *)
      h[newn+char]:=sent;  (* init all internal nodes to sent char *)
      h[newn+freq]:=h[left+freq]+h[rite+freq];

      (* link to left and right subtrees (offspring) *)
      h[newn+lst]:=left;
      h[newn+rst]:=rite;

      (* link new node into the forest in place of old left *)
      (* first, make new node to point to its neighbors in the forest *)
      h[newn+lforst ]:=h[left+lforst];
      h[newn+rforst ]:=h[left+rforst];

      (* second, make neighbors point to new node *)
      if (h[left+lforst]<>nil)
         then h[h[left+lforst ]+rforst ]:=newn;
      h[h[left+rforst ]+lforst ]:=newn;

      (* delete rite node *)
      h[h[rite+lforst ]+rforst ]:=h[rite+rforst];
      if (h[rite+rforst]<>nil)       (* rite has a right neighbor *)
         then h[h[rite+rforst ]+lforst ]:=h[rite+lforst];

      (* update leftmost and rightmost pointers *)
      if (lmost=left) then lmost:=newn;
      if (rmost=rite) then rmost:=h[rite+lforst]
      end; (* procedure combinelr *)


   begin (* procedure build1tree *)
   repeat
      picklr;
      combinelr;
      put#1('.');      (* show progress on screen . . . *)
   until (lmost=rmost) (* only one node left *)
   end; (* procedure build1tree *)


(*
given the tree built in phase 1, traverse it (in order will do)
and  assign  a level to each node.  then return to the original
forest of trees (all leaves when we start), build them  into  a
single tree using phase 3 of the hu-tucker algorithm.  the root
of the resultant tree will be in lexfirst on exit.

the  algorithm  is  implemented  using two internal procedures.
the first (picklr) chooses two trees for combination,  and  the
second  (combinelr) combines the two chosen trees to form a new
internal node in the  final  tree.  this  process  is  repeated
unitl the forest contains only one tree.

the  procedure  used  is very similar to that used to build the
tree in phase 1.
*)
procedure build3tree;

   var maxlev : word; (* largest level in tree *)
       picklev: word; (* level of node now being picked *)
       left : word;   (* left most node to be replaced *)


   (*
   setlev  will  traverse  the  tree  generated  in phase 1 and
   assign levels to  each  of  the  nodes.  also,  the  deepest
   level reached will be recorded in maxlev on exit.
   *)
   procedure setlev;


      (*
      traverse  a  node  of  a  tree  pointed  to  by the first
      argument, assigning it the level  passed  in  the  second
      argument.
      *)
      procedure travinord(p : word  ;  curlev : word);

         begin
         if (p<>nil) then begin
            if (curlev>maxlev) then maxlev:=curlev;
            travinord(h[p+lst], curlev+1);
            h[p+lev]:=curlev;
            travinord(h[p+rst], curlev+1)
            end
         end; (* procedure travinord *)


      begin  (* procedure setlev *)
      maxlev:=0;
      travinord(lmost, 0) (* root is leftmost node *)
      end; (* procedure setlev *)


   (*
   pick  two  trees from the forest which satisfy the following
   rules:

   let i and j be pointers to the left and right trees:

   i')   the  trees  i  and  j  must be adjacent in the working
         sequence.

   ii')  the  levels  of  trees  i  and j must be maximal among
         all remaining levels.

   iii') the  index  i  is  minimal  for all i and j satisfying
         rules (i'), (ii').

   a pointer to the left most chosen will be left in left.  the
   right tree chosen is its lexicographic successor.
   *)
   procedure picklr;

      var picked  : boolean; (* true if one picked on this lev el *)
      begin
      picked:=false;
      while (picked=false) do begin
         left:=lexfirst; (* start with first node in lexicographic order *)
         while (left<>nil) and (picked<>true) do
            if (h[left+lev]=picklev)
                then picked:=true
                else left:=h[left+lexs];
         if (picked=false) then picklev:=picklev-1
         end (* while *)
      end; (* procedure picklr *)


   (*
   combine  the  tree  pointed to by left and its lexicographic
   successor to form a new internal node  in  the  final  tree.
   link  this new node into the existing lexicographic sequence
   in place of the left tree and its successor.  the pointer to
   the first node in the sequence (lexfirst), is updated in the
   process.
   *)
   procedure combinelr;

      var newn : word; (* pointer to new node created *)
          rite : word; (* pointer to right node being combined *)

      begin
      new(var newn);
      rite:=h[left+lexs]; (* right node is allways next in lex order *)
      h[newn+char]:=sent; (* init all internal nodes to sent char *)

      (* link left and right subtrees to new node *)
      h[newn+lst]:=left;
      h[newn+rst]:=rite;

      (* level of new node is one less than level of its offspring *)
      h[newn+lev]:=h[left+lev]-1;
      h[newn+lexs]:=h[rite+lexs];
      h[newn+lexp]:=h[left+lexp];

      (* link new node in place of left node from left *)
      if (h[left+lexp]<>nil) then (* left has a lex predecessor *)
         h[h[left+lexp]+lexs]:=newn;
      if (h[rite+lexs]<>nil) then (* right has a lex successor *)
         h[h[rite+lexs]+lexp]:=newn;

      if (left=lexfirst) then (* new node becomes lex first *)
         lexfirst:=newn
      end; (* procedure combinelr *)


   begin (* procedure build3tree *)
   setlev; (* compute node levels *)
   put#1(13,10);
   put#1('maxlev =',maxlev#,13,10);
   picklev:=maxlev;
   repeat
      picklr;
      combinelr;
      put#1('.')      (* show progress on screen . . . *)
   until (picklev<=1) (* true when all nodes have been picked *)
   end; (* procedure build3tree *)


(*
decode  a  sequence of 1's an 0's read from the standard input
file into a sequence of characters written to standard output.
this is done by starting at the root and taking a left  when a
zero  is  read, a right when a one is read.  this is continued
unitl a leaf is reached, when the character in  that  leaf  is
printed.  this process is repeated until end-of-file is found.
*)
procedure decode;

   var eof : boolean;
       ch  : word;   (* last one or zero read from input *)
       p   : word;   (* pointer used to traverse tree *)


   procedure getoz;

      begin
      get#0(ch);
      while (ch=13) or (ch=10) or (ch=' ') do
         get#0(ch);
      if (ch=26) then eof:=true
      end; (* procedure getoz *)


   begin (* prodecure decode *)
   put#1(13,10);
   put#1('decoded ', 'message  ',13,10);
   eof:=false;
   getoz;
   while (eof=false) do begin
      p:=lexfirst;      (* start at root of phase 3 tree *)
      while (h[p+char]=sent) do begin (* while at internal node *)
         if (ch='0')
            then p:=h[p+lst]  (* left  turn *)
            else p:=h[p+rst]; (* right turn *)
         getoz
         end; (* while at internal node *)
      put#1(h[p+char])
      end (* while not eof *)
   end; (* procedure decode *)

begin (* main line *)
   hp:=0; (* initialize heap pointer *)
   readtree;
   lexfirst:=lmost; (* first node in lex order is leftmost *)
   build1tree;
   build3tree;
   decode
end.
