(* Cross reference as above, but using a hash table instead
   of a binary tree to store the words encountered. *)

(***************************************************************************************)
(* MODULE crossref--This module is a cross reference generator.  A file which is       *)
(* specified by the user is read and a cross reference table of all the words is built.*)
(* A word consists of a letter and any combination of letters and digits thereafter    *)
(* until a separator, i.e. blanks, ends of lines, special characters, is read.  Quotes *)
(* and comments are ignored.  The cross reference table is a hash table which stores   *)
(* the words and the number of the line on which the word appeared.  When the table    *)
(* is generated, its contents are printed on the screen.  This program is the MODULA-2 *)
(* translation of the PASCAL program 11.2.                                             *)



MODULE crossref;

FROM InOut IMPORT                              (* get necessary i/o files             *)
     Read, WriteString, Write, WriteLn, WriteCard, OpenInput, CloseInput, Done;
FROM STORAGE IMPORT                            (* get NEW procedure                   *)
     ALLOCATE;

CONST  ff         = 14;                       (* clear the screen constant           *)
       eol        = 36c;                       (* end of line constant                *)
       quote      = 42c;                       (* double quote mark                   *)
       wordlen    = 10;                        (* maximum word length                 *)
       numperline = 8;                         (* no of line numbers per display line *)
       digpernum  = 6;                         (* maximum number of digits per number *)
       maxline    = 9999;                      (* maximum number of lines in file     *)
       prime      = 997;                       (* number of hash table entries        *)
       blank      = " ";                       (* blank character constant            *)
       filetype   = "TEXT";                    (* default filename extension          *)

TYPE   index    = [0..prime];                  (* range of hash table                 *)
       alfa     = ARRAY[1..wordlen] OF CHAR;   (* word string                         *)
       relation = (equal,less,greater);        (* used for string comparisons         *)
       itemref  = POINTER TO item;
       word     = RECORD                       (* hash table entries                  *)
                    key        : alfa;         (* word found in text                  *)
                    first, last: itemref;      (* pointer to cross reference list     *)
                    follow     : index         (* hash number of next entry           *)
                  END;
       item     = RECORD                       (* cross reference list                *)
                    lineno: [0..maxline];      (* line number word occurred on        *) 
                    next  : itemref            (* pointer to next item in list        *)
                  END;

VAR    i        : index;                       (* index to hash table                 *)
       top      : index;                       (* current hash table entry            *)
       idcntr   : INTEGER;                     (* index to id array                   *)
       id       : alfa;                        (* contains the current word           *)
       free     : alfa;                        (* blank word                          *)
       table    : ARRAY [0..prime] OF word;    (* hash table                          *)
       current  : CARDINAL;                    (* current line number                 *)
       ch       : CHAR;                        (* current character                   *)
       tablefull: BOOLEAN;                     (* flags if table gets full            *)
       

PROCEDURE compare(j,k:alfa):relation;
(**************************************************************************************)
(* This function compares the two strings j and k to see how they compare.  If j = k  *)
(* then the value of equal is returned.  If j < k then the value is less is returned  *)
(* and if j > k tthen the value greater is returned.                                  *)
(**************************************************************************************)


VAR compvalue : relation;                     (* function value                       *)
    through   : BOOLEAN;                      (* flags when through with loop         *)
    i         : INTEGER;                      (* array index                          *)

BEGIN 
  compvalue := equal;                         (* initializations                      *)
  i         := 1;  
  through   := FALSE;
  WHILE (NOT through) & (i <= 10) DO          (* compare the two strings              *)
    IF CAP(j[i]) = CAP(k[i]) THEN             
      INC(i)
    ELSE
      through := TRUE;
      IF CAP(j[i]) < CAP(k[i]) THEN 
        compvalue := less
      ELSE
        compvalue := greater
      END
    END
  END;
  RETURN compvalue
END compare;



PROCEDURE search():BOOLEAN; 
(**************************************************************************************)
(* This function searches the hash table to see if an entry for the current word      *)
(* already exists.  This is done by calculating the hash value of the current word.   *)
(* If no entry exists at the hash value slot in the table, then an entry is created   *)
(* for that word and an item list created.  If the entry already exists, then only a  *)
(* new item node is created and added to the item list.  If the hash slot is already  *)
(* occupied by a different word, then the hash table is searched for an empty slot.   *)
(* If one is found, then it is filled in with the current word, etc.  If no empty     *)
(* slot can be found, then a message is printed indicating table overflow and the     *)
(* procedure quits, returning the value of FALSE.                                     *)
(**************************************************************************************)

VAR  hash         : CARDINAL;                   (* contains hash value                *)
     addvalue     : index;                      (* contains search increment value    *)
     done         : BOOLEAN;                    (* flags when finished                *)
     full         : BOOLEAN;                    (* flags if table is full             *)
     x            : itemref;                    (* pointer to current item list       *)
     compvalue    : relation;                   (* contains result of compare         *)

     
BEGIN
  full     := FALSE;                            (* initialize                         *)
  hash     := 0;
  done     := FALSE;
  addvalue := 1;
  NEW(x);                                       (* get a new item list node           *)
  x^.lineno  := current;                        (* fill in current line number        *)
  x^.next := NIL;                               (* set next link to nil               *)
  FOR i := 1 TO wordlen                         (* calculate hash value               *)
    DO
     hash := (hash + ORD(id[i])) MOD prime
    END;
  REPEAT                                        (* continue searching until done      *)
    compvalue := compare(id, table[hash].key);  (* compare id to key to see if equal  *)
    IF compvalue = equal THEN                   (* if word entry already exists       *)
      done := TRUE;                             (* flag to end loop                   *)
      table[hash].last^.next := x;              (* link last item node to new node    *)
      table[hash].last := x                     (* link table pointer to new last node*)
    ELSE
      compvalue := compare(free,table[hash].key);
      IF compvalue = equal THEN                 (* if no entry exists                 *)
        WITH table[hash] DO
          key := id;                            (* fill in current word               *)
          first := x;                           (* link to item node                  *)
          last  := x;
          follow := top                         (* fill in last hash table entry      *)
        END;
        top  := hash;                           (* set to current hash table entry    *)
        done := TRUE
      ELSE                                      (* collision occurred                 *)
        hash := hash + addvalue;                (* incrmt hash to check next entry    *)
        addvalue := addvalue + 2;               (* increment displacement             *)
        IF  hash >= prime THEN 			(* if hash value greater than length  *)
	hash := hash - prime                    (* reset hash value                   *)
        END;
        IF addvalue = prime THEN                (* if table is full                   *)
          done := TRUE;                         (* flag that search is through        *)
          full := TRUE;                         (* flag that table is full            *)
          WriteString("Table Overflow");
          WriteLn
        END
      END
    END
  UNTIL done;
  RETURN full
END search;


PROCEDURE printtable;
(**************************************************************************************)
(* This procedure prints out the cross reference table.  It lists each word and the    *)
(* line numbers on which that word occurred.  Printtable has an internal procedure    *)
(* printword that handles printing the word and its line references.  The cross      *)
(* reference table is printed out in alphabetical order.                              *)
(**************************************************************************************)

VAR  hold      : index;                          (* contains the current entry index  *)
     least     : index;                          (* contains index to least word      *) 
     move      : index;                          (* used to search for least word     *)  
     compvalue : relation;                       (* contains compare result           *)

PROCEDURE printword(w: word);
 
   
  VAR numcnt: INTEGER;                           (* keeps track line nos on screen    *)
      x     : itemref;                           (* pointer to current item node      *)

  BEGIN
    Write(blank);
    WriteString(w.key); 
    x := w.first;
    numcnt := 0;
    REPEAT                                       (* do until all line numbers printed *)
      IF numcnt = numperline THEN                (* if need a new line for line nos   *)
        numcnt := 0;                             (* reset counter                     *)
        WriteLn;
        Write(blank);
        WriteString(free)
      END; 
      INC(numcnt);                               
      WriteCard(x^.lineno,digpernum);            (* write the line number             *)
      Write(blank);                              (* move to next item node            *)
      x := x^.next
    UNTIL x = NIL;
    WriteLn;
  END printword;

BEGIN
  hold := top;                                   (* start at last entry to be added   *)
  WHILE hold <> prime                            (* do for all of the table           *)
    DO
      least := hold;                             (* initialize for alphabetic search  *)
      move  := table[hold].follow;
      WHILE move <> prime                        (* search table for least entry      *)
        DO
          compvalue := compare(table[move].key,table[least].key);
          IF compvalue = less THEN
            least := move                   
          END;
          move := table[move].follow
        END;
      printword(table[least]);                    (* print the word and its line nos  *)  
      IF least <> hold THEN                       (* make sure entry won't get printed*)
        table[least].key   := table[hold].key;
        table[least].first := table[hold].first;
        table[least].last  := table[hold].last
      END;
      hold := table[hold].follow                  (* move to the next entry           *)  
     END
END printtable;


BEGIN                                              (* ***MAIN PROCEDURE***            *)

  current   := 0;                                  (* initialize                      *)
  top       := prime;
  tablefull := FALSE;
  FOR i := 1 TO wordlen DO 
    free[i] := blank
  END;
  OpenInput(filetype);                             (* request filename and open file  *)
  IF NOT Done THEN                                 (* if file does not exist quit     *)
    WriteString("Error--file DK.file.TEXT does not exist")
  ELSE                                             (* otherwise continue              *)
    FOR i := 1 TO prime DO                         (* more initialization             *)
      table[i].key := free
    END;
    Read(ch);                                      (* get the first character         *)
    WHILE NOT tablefull DO                         (* do while table is not full      *)
      WHILE Done DO                                (* do while end of file not reached*)
        IF current = maxline THEN                  (* counter exceeds allowed line no *)
          current := 0                             (* reset counter                   *)
        END;
        INC(current);
        WriteCard(current,digpernum);              (* write current line no to screen *)
        Write(blank);
        WHILE (ch <> eol) & (Done) DO              (* while not at end of file line   *)             id := free;
          IF (CAP(ch)>= "A") & (CAP(ch)<="Z") THEN (* see if alphabetic               *)
            idcntr    := 0;
            REPEAT                                 (* get the word and put in id      *)
              IF idcntr < wordlen THEN
                INC(idcntr);
                id[idcntr] := ch;
              END;
              Write(ch);
              Read(ch);
             UNTIL ((CAP(ch)<"A") OR (CAP(ch)>"Z")) & ((ch<"0") OR (ch>"9"));
            tablefull := search()                  (* call search to add to table     *)
          ELSE                                     (* if not a word                   *)
            IF ch = quote THEN                     (* if a quote ignore between quotes*)
              REPEAT 
                Write(ch);
                Read(ch)
              UNTIL ch = quote       
            ELSIF ch = "{" THEN                    (* if a brace ignore between braces*)
              REPEAT
                Write(ch);
                Read(ch)
              UNTIL ch = "}"
            END;
          Write(ch);
          Read(ch);
        END;                                       (* end if alphabetic statement     *)
      END;                                         (* end while not eol loop          *)
      WriteLn;
      Read(ch);
    END;                                           (* end while not eof loop          *)
    tablefull := TRUE;                             (* exit outer loop so can print tab*)
  END;
  CloseInput;                                      (* close the input file            *)
  (* Write(ff) *)
  printtable;                                      (* print the table                 *)
  END 
END crossref.
                                                                