(***************************************************************************)
(*                                                                         *)
(*                      IMPLEMENTATION MODULE Strings			   *)
(*                                                                         *)
(*                                                                         *)
(*                     Modula-2 Standard Library Module			   *)
(*                                                                         *)
(*                                for the				   *)
(*                                                                         *)
(*                     Modula-2 System for Z80 / CP/M 			   *)
(*                                                                         *)
(*                                   by					   *)
(*                                                                         *)
(*                        Hochstrasser Computing AG			   *)
(*                           Leonhardshalde 21				   *)
(*                              8001 Zuerich				   *)
(*                              Switzerland				   *)
(*                                                                         *)
(*                                                                         *)
(* created	Aug - 14 - 1984 pwh                                        *)
(* updated	Aug - 23 - 1984 pwh                                        *)
(*		Mar -  7 - 1985 pwh -- Open Arrays.			   *)
(*              Mar - 26 - 1985 pwh -- Assign Parameter List Changed.      *)
(***************************************************************************)
IMPLEMENTATION MODULE Strings;
 

  FROM SYSTEM IMPORT
	ADR, ADDRESS, SIZE;

  FROM Moves IMPORT
	MoveLeft, MoveRight, Fill;

  FROM ASCII IMPORT
	nul;

  TYPE 
    CharPtr = POINTER TO CHAR;

  VAR
    i, j: CARDINAL;
    chp: CharPtr;


(*--------------------------------------------------------------*)
(* PROCEDURE Length -- find length of 'string'.                 *)
(*--------------------------------------------------------------*)
  PROCEDURE Length(VAR string: ARRAY OF CHAR): CARDINAL;
  BEGIN
    i := 0;
    chp := CharPtr(ADR(string));
    WHILE (i < SIZE(string)) & (chp^ # nul) DO i := i + 1; INC(chp); END;
    RETURN i;
  END Length;      

(*--------------------------------------------------------------*)
(* PROCEDURE Assign -- assign one string to another character   *)
(* by character up to nul. Fill rest with nul.			*)
(*--------------------------------------------------------------*)
  PROCEDURE Assign(source: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR);
  VAR
    ch: CHAR;
  BEGIN
    i := 0;
    j := Length(source) - 1; IF j > HIGH(dest) THEN j := HIGH(dest); END;
    MoveLeft(ADR(source), ADR(dest), j + 1);
    Fill(ADR(dest[j+1]), HIGH(dest) - j, nul);
  END Assign;


(*--------------------------------------------------------------*)
(* PROCEDURE Insert -- insert 'subString' beginning at 'inx'    *)
(* into 'string'. Adjusts length, clips if necessary.		*)
(* Tests also if 'string' ends before 'inx' and does no work in	*)
(* that case.							*)
(*--------------------------------------------------------------*)
  PROCEDURE Insert(               subString: ARRAY OF CHAR; 
		   (* into *) VAR string:    ARRAY OF CHAR; 
		   (* at   *)     inx:       CARDINAL);
  VAR
    ch, och: CHAR;
    stringEnd: STRING;
    insertStart: ADDRESS;
  BEGIN
    IF inx <= HIGH(string) THEN
      j := Length(subString);
      i := Length(string);		(* 'i' manipulated by Length *)
      IF (i + 1 < inx) OR (j = 0) THEN 
	RETURN; 		(* no show... *)
      END;

				(* save end of original string *)
      insertStart := ADR(string[inx]);
      MoveLeft(insertStart, ADR(stringEnd), HIGH(string) + 1 - inx);
				(* move 'subString' in *)
      MoveLeft(ADR(subString), insertStart, HIGH(string) + 1 - inx);

      i := inx;			(* this loop reads one character over the *)
      LOOP			(* end of the string to look at, but no   *)
        ch := string[i];	(* danger *)
        IF (ch = nul) OR (i > HIGH(string)) THEN EXIT; END;
        INC(i);
      END; (* LOOP *)
      IF i <= HIGH(string) THEN	(* insert string end *)
	MoveLeft(ADR(stringEnd[0]), ADR(string[i]), HIGH(string) + 1 - i);
      END;
    END;
  END Insert;


(*--------------------------------------------------------------*)
(* PROCEDURE Delete - delete 'len' characters starting at 'inx' *)
(* from 'string'. If the string end (nul) would be deleted, it 	*)
(* is set to 'inx'.						*)
(*--------------------------------------------------------------*)
  PROCEDURE Delete(VAR string: ARRAY OF CHAR; inx, len: CARDINAL); 
  BEGIN
    IF inx <= HIGH(string) THEN
				(* adjust length *)
      IF (inx + len) > HIGH(string) THEN
	len := HIGH(string) + 1 - inx;
      END;

      IF len = 0 THEN RETURN; END; (* no show *)

      i := inx;			(* test if end will be deleted *)
      WHILE i < (inx + len) DO
	IF string[i] = nul THEN 
	  string[inx] := nul; 
	  RETURN;		(* done *)
	END;
        i := i + 1;
      END; (* WHILE *)
				(* delete that part *)
      MoveLeft(ADR(string[inx+len]), ADR(string[inx]), 
	   HIGH(string) + 1 - inx - len);
    END;
  END Delete;


(*--------------------------------------------------------------*)
(* PROCEDURE Pos -- find position of the first occurence of     *)
(* 'subString' in 'string'. HIGH(string) + 1 is returned if no 	*)
(* match was detected or 'subString' was empty.			*)
(*--------------------------------------------------------------*)
  PROCEDURE Pos(subString, string: ARRAY OF CHAR): CARDINAL;
  VAR
    searched, ch: CHAR;
  BEGIN
    searched := subString[0];
    ch := string[0];
    j := 0;			(* 'subString' index *)
    i := 0;			(* 'string' index *)
    WHILE (searched # nul) & (ch # nul) & (i <= HIGH(string)) DO

      IF searched = ch THEN	(* character match; advance in 'subString' *)
	j := j + 1;
	searched := subString[j];
      ELSIF j > 0 THEN		(* no full match; reset to start *)
	i := i - j;		(* correction by 1 is done later *)
        j := 0;
	searched := subString[0];
      END;			(* if still at beginning of 'subString', *)
				(* no action has to be taken.		 *)
      i := i + 1;		(* test next character 			 *)
      ch := string[i];      

    END; (* WHILE *)

    IF (searched = nul) & (i # 0) THEN (* full match *)
      RETURN i - j; 
    ELSE
      RETURN HIGH(string) + 1;
    END;
  END Pos;


(*--------------------------------------------------------------*)
(* PROCEDURE Copy -- copy substring of 'string' starting at     *)
(* 'inx' of length 'len' to 'result'.				*)
(*--------------------------------------------------------------*)
  PROCEDURE Copy((* from *)     string:   ARRAY OF CHAR; 
		 (* part *)     inx, len: CARDINAL; 
		 (* to   *) VAR result:   ARRAY OF CHAR);
  BEGIN
    IF len > HIGH(result) THEN (* like graphics: do clipping... *)
      len := HIGH(result) + 1; (* could have used SIZE here *)
    END;
    MoveLeft(ADR(string[inx]), ADR(result[0]), len);
  END Copy;


(*--------------------------------------------------------------*)
(* PROCEDURE Concat -- concatenate 'string1' and 'string2' into *)
(* 'result'. Overflow is clipped off.				*)
(*--------------------------------------------------------------*)
  PROCEDURE Concat((* parts *)     string1, string2: ARRAY OF CHAR; 
		   (* into  *) VAR result:           ARRAY OF CHAR);
  VAR
    i,j,k: CARDINAL;
  BEGIN
    Assign(string1, result);
    i := Length(result);
    j := SIZE(result) - i;
    IF j # 0 THEN (* there is room. *)
      k := Length(string2);
      IF k > j THEN k := j; END;	(* clip *)
      MoveLeft(ADR(string2), ADR(result[i]), k);
      Fill(ADR(result[i+k]), j-k, nul);
    END;
  END Concat;


(*--------------------------------------------------------------*)
(* PROCEDURE CompareStr -- compare 'string1' and 'string2' and  *)
(* return 							*)
(*		0 if 'string1' = 'string2'			*)
(*		1 if 'string1' > 'string2'			*)
(*	       -1 if 'string1' < 'string2'			*)
(*--------------------------------------------------------------*)
  PROCEDURE CompareStr(string1, string2: ARRAY OF CHAR): INTEGER;
  BEGIN
    i := 0;
    WHILE (string1[i] = string2[i]) & 
	  (string1[i] # nul) & (i < HIGH(string1)) DO
      i := i + 1;
    END; (* WHILE *)
    (* little BOOLEAN expression: strain your brain. *)
    RETURN (1 - 2 * ORD(string1[i] < string2[i])) * 
	      ORD(string1[i] # string2[i]);
  END CompareStr;

END Strings.
