MODULE AnyCase;

(*  adapted from a program (unknown author) by Glenn Brooke
    12/29/86 for Turbo Modula-2 for the Z80.  Released to
    the public domain.  Last update 1/1/86
*)

(* obtain all the needed procedures from standard libraries *)
(* This program does use Turbo Modula-2 extensions of WRITE, WRITELN *)

   FROM STORAGE    IMPORT ALLOCATE, DEALLOCATE;
   FROM ComLine    IMPORT commandLine;
   FROM Texts      IMPORT TEXT, ReadChar, WriteChar, EOT, OpenText,
                          CreateText, CloseText;
   FROM Strings    IMPORT Length;

CONST
     maxidlength = 80;         (* you may want to shorten this to conserve
                                  memory space. *)
     maxfilenamelength = 14;

TYPE
    NodePtr = POINTER TO Node;
    ListPtr = POINTER TO ListNode;
    Node = RECORD
         List : ListPtr;
         Len : CARDINAL;
         left, right : NodePtr;
         END;
    ListNode = RECORD
         ch : ARRAY[0..1] OF CHAR;
         next : ListPtr;
         END;
    idtype = ARRAY[0..maxidlength-1] OF CHAR;
    leg = (LessThan, Equal, GreaterThan);
    filename = ARRAY[0..maxfilenamelength-1] OF CHAR;

VAR
   Root, where : NodePtr;
   j,k,c,i,d : CARDINAL;
   Nput, Output : TEXT;
   id : idtype;
   ch : CHAR;
   List : ListPtr;
   F : TEXT;
   infilename, outfilename : filename;

PROCEDURE RelativeSize(id : idtype; anode : NodePtr; VAR RelSize : leg);
VAR
   cell : ListPtr;
   a,b : CHAR;
   c,d : CARDINAL;

BEGIN
     d := 0;
     cell := anode^.List;
     FOR c := 0 TO anode^.Len + 1 DO
         a := CAP(cell^.ch[d]);
         b := CAP(id[c]);
         IF a = b THEN (*keep looking*)
            IF d=1 THEN
               d := 0;
               cell := cell^.next
            ELSE d := 1
            END;
         ELSIF a>b THEN
               RelSize := LessThan;
               RETURN
         ELSE
             RelSize := GreaterThan;
             RETURN
         END;
         END;
         RelSize := Equal;
END RelativeSize;

PROCEDURE addit(id : idtype; VAR anode : NodePtr);
VAR RelSize : leg;

      PROCEDURE addstring(List : ListPtr; VAR Len : CARDINAL; id : idtype);
      VAR d,c : CARDINAL;
      BEGIN (*addstring*)
        c := 0; d := 0;
        WHILE (c<maxidlength) & (id[c]#" ") DO
           List^.ch[d] := id[c];
           INC(c);
           IF d = 0 THEN d := 1
           ELSE
            d := 0;
            NEW(List^.next);
            List := List^.next;
            List^.next := NIL;
           END; (*if then *)
           List^.ch[d] := " ";
           IF c>maxidlength-1 THEN Len := maxidlength-1
             ELSE Len := c-1
           END; (* if then *)
        END; (* while *)
      END addstring;

BEGIN (*addit*)
  IF anode = NIL THEN (*not in tree insert it *)
     NEW(anode);
     WITH anode^ DO
        left := NIL;
        right := NIL;
        NEW(List);
        addstring(List, Len, id);
     END;
  ELSE
    RelativeSize(id, anode, RelSize);
    IF RelSize = LessThan THEN addit(id, anode^.left)
    ELSIF RelSize = GreaterThan THEN addit(id, anode^.right)
    (*ELSE id is already in spelling list, simply return*)
    END
  END;
END addit;


PROCEDURE InTree(id :idtype; VAR anode : NodePtr) : BOOLEAN;

(* Side effect is to set anode to point to place in tree id is located *)

VAR RelSize : leg;
BEGIN (*InTree*)
 LOOP
   IF anode=NIL THEN (* not in tree *) RETURN(FALSE)
   ELSE
     RelativeSize(id, anode, RelSize);
     IF RelSize=LessThan THEN (*create side effect *)
       anode := anode^.left;
     ELSIF RelSize = GreaterThan THEN (* create side effect *)
       anode := anode^.right
     ELSE (*its in the tree *) RETURN(TRUE);
     END
   END
 END;
END InTree;

PROCEDURE delit(id : idtype; VAR anode : NodePtr);
VAR
  qnode : NodePtr;
  mark, markhold : ListPtr;
  RelSize : leg;

   PROCEDURE del(VAR anode : NodePtr);
   BEGIN (* del *)
     IF anode^.right # NIL THEN del(anode^.right)
     ELSE
      qnode^.Len := anode^.Len;
      qnode^.List := anode^.List;
      qnode := anode;
      anode := anode^.left;
     END
   END del;

BEGIN (* delit *)
  IF anode = NIL THEN
     WRITELN("Can't delete ", id);
     WRITELN(" not in tree ");
     WRITELN;
 ELSE
     RelativeSize(id, anode, RelSize);
     IF RelSize = LessThan THEN delit(id, anode^.left)
     ELSIF RelSize = GreaterThan THEN delit(id,anode^.right)
     ELSE qnode := anode;
     IF qnode^.right = NIL THEN anode := qnode^.left
     ELSIF qnode^.left = NIL THEN anode := qnode^.right
     ELSE del(qnode^.left);  (* dispose of qnode *)
       mark := qnode^.List;
       WHILE mark#NIL DO
         markhold := mark;
         mark := mark^.next;
         DISPOSE(markhold)
       END;
    DISPOSE(qnode)
    END
  END
  END
END delit;

PROCEDURE copy;
BEGIN (* copy *)
 WriteChar(Output, ch);
 IF NOT EOT(Nput) THEN           (* make sure don;t read past end of file*)
   ReadChar(Nput, ch);
 END; (* if then *)
END copy;

PROCEDURE FinishComment;
(* this is a recursive procedure ! *)
BEGIN
 REPEAT
 REPEAT
   copy;
   IF ch = "(" THEN
      copy;
      IF ch = "*" THEN FinishComment
      END;
   END;
 UNTIL ch= "*";
 copy
UNTIL ch= ")";
copy
END FinishComment;



PROCEDURE GetId(Nput : TEXT; Adding, printing : BOOLEAN;
                     VAR ch : CHAR);
VAR j, k : CARDINAL;
BEGIN
  IF (CAP(ch)>="A") & (CAP(ch)<="Z") THEN
    k := 0;
    REPEAT
      id[k] := ch;
      k := k + 1;
      ReadChar(Nput, ch);
    UNTIL (((ch<"0") OR (ch>"9")) & ((CAP(ch)<="A") OR (CAP(ch)>"Z")))
           OR (k=maxidlength);
    IF k<maxidlength THEN id[k] := " " END;
    IF printing THEN
       FOR j := 0 TO k-1 DO WriteChar(Output, id[j]) END
    END;
    IF Adding THEN addit(id, Root); ELSE delit(id, Root) END;
 END;
END GetId;

PROCEDURE ProcessFile(Nput : TEXT; Adding : BOOLEAN);
VAR ch :CHAR;
BEGIN
  ReadChar(Nput, ch);
    IF NOT EOT(Nput) THEN
        REPEAT
        GetId(Nput, Adding, FALSE, ch);
        ReadChar(Nput, ch);
        UNTIL EOT(Nput);
    END;
END ProcessFile;



(* MAIN BODY OF ANYCASE MODULE  *)

BEGIN
 (* prepare for binary tree storage of keywords *)
 Root := NIL;

 (* display program identification *)
 WRITELN('    Turbo Modula-2 Case Converter ');
 WRITELN('    Glenn Brooke 1/1/86');
 WRITELN;

 (*  OK, let's open up the input and output files for the work *)
 (*  First read input, output filenames from command line*)

 READ(commandLine, infilename, outfilename);

 (* if one or both names missing, display syntax and halt *)
 IF (Length(infilename) = 0) OR (Length(outfilename) = 0) THEN
   WRITELN("  Syntax is :  CASE infilename outfilename ");
   WRITELN;
   HALT;
 END;  (* IF THEN *)

 (* load default spelling list from file MODULA2.KWD *)
 IF OpenText(Nput, "MODULA2.KWD") THEN
   (* file was found and opened properly, now process list *)
   WRITE("  now storing list of keywords in memory...");
   ProcessFile(Nput, TRUE);
   CloseText(Nput);
   WRITE("complete");
   WRITELN;
 ELSE
   WRITELN("  Sorry, couldn't open MODULA2.KWD (keyword file). ");
   WRITELN("  Case Converter terminated. ");
   HALT;
 END; (* if then else *)

 (* try to open input.  if can't, say so, and halt *)
 IF NOT OpenText(Nput, infilename) THEN
      WRITELN("  Sorry, couldn't open input file ", infilename);
      WRITELN(" Case Converter terminated. ");
      HALT;
 END; (* IF THEN *)
 (* open output file; overwrites if exists *)
 CreateText(Output, outfilename);


(* ok, now process input file char by char -- start of "state machine" *)
WRITE(" Now processing ",infilename,"...");

ReadChar(Nput, ch);
 IF NOT EOT(Nput) THEN
   REPEAT
   IF (CAP(ch)>="A") & (CAP(ch)<="Z") THEN
     k := 0;
     REPEAT
       id[k] := ch;
       k := k + 1;
       ReadChar(Nput, ch);
       (* do not copy to output until see if its in spelling table *)
     UNTIL (((ch<"0") OR (ch>"9") & ((CAP(ch)<"A")
               OR (CAP(ch)>"Z"))) OR (k=maxidlength));
     IF k<maxidlength THEN id[k] := " " END;
     (* look for identifier *)
     where := Root;
     IF InTree(id, where) THEN
        (* put spelling from tree to output *)
        d := 0;
        List := where^.List;
        FOR i := 0 TO where^.Len DO
           WriteChar(Output, List^.ch[d]);
           IF d=1 THEN
             d := 0;
             List := List^.next;
           ELSE d := 1
           END
        END
     ELSE
       (* not in tree, send to output as it came in *)
       FOR i := 0 TO k-1 DO
         WriteChar(Output, id[i]);
         END
     END;
     copy
  ELSIF ((ch>="0") & (ch<= "9")) THEN
     REPEAT copy UNTIL ((ch<"0") OR (ch > "9"))
  ELSIF ch="(" THEN
    copy;
    IF ch="*" THEN (* comment *)
      copy;
      FinishComment;
      END
    ELSIF ch = "'" THEN
       REPEAT
         copy
       UNTIL ch = "'";
       copy
    ELSIF ch = '"' THEN
       REPEAT
        copy
       UNTIL ch = "'";
       copy
    ELSE
     copy
   END
  UNTIL EOT(Nput)
END;

(* close up input and output files *)
CloseText(Nput);
CloseText(Output);

(* tell the user that all is finished *)
WRITELN("Job complete.");

END AnyCase.

                                                                                        