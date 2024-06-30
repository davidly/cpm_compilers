(*$l-*)
IMPLEMENTATION MODULE Pattern;

(*	This is a pattern matching module

	Dave Moore, FTL Modula-2

*)

FROM	STORAGE IMPORT ALLOCATE,DEALLOCATE;
FROM	Strings IMPORT Length;
FROM	SYSTEM	IMPORT TSIZE;
VAR	i,j:CARDINAL;

	Changed:BOOLEAN;
	Len:CARDINAL;

PROCEDURE CreateStringNode(s:ARRAY OF CHAR):PNode;
VAR	p:PNode;
BEGIN

(*This procedure is provided to allow the creation of nodes
  for strings easilly. Only the required amount of memory is allocated*)

	i:=Length(s);
	ALLOCATE(p,i+3*TSIZE(CARDINAL)+TSIZE(NodeType));
	WITH p^ DO
		FOR j:=0 TO i-1 DO 
			Text[j]:=s[j] 
			END;
		TextLen:=i;
		NType:=String;
		END;
	RETURN p;
	END CreateStringNode;
PROCEDURE CreateAltNode(m,q:PNode):PNode;
VAR	p:PNode;
BEGIN
	NEW(p);
	WITH p^ DO
		NType:=Alternatives;
		First:=m;
		Second:=q;
		END;
	RETURN p
	END CreateAltNode;
PROCEDURE CreateAnyOfNode(s:CharSet;min,max:CARDINAL;Longest:BOOLEAN):PNode;
VAR	p:PNode;
BEGIN
	NEW(p);
	WITH p^ DO
		NType:=AnyOf;
		MinCount:=min;
		MaxCount:=max;
		Fast:=Longest;
		Match:=s;
		END;
	RETURN p
	END CreateAnyOfNode;
PROCEDURE CreateConcatNode(m,q:PNode):PNode;
VAR	p:PNode;
BEGIN
	NEW(p);
	WITH p^ DO
		NType:=Concat;
		First:=m;
		Second:=q;
		END;
	RETURN p
	END CreateConcatNode;

PROCEDURE CreateLimitNode():PNode;
VAR	p:PNode;
BEGIN
	NEW(p);
	p^.NType:=RightLimit;
	RETURN p;
	END CreateLimitNode;
PROCEDURE Pattern(p:PNode;VAR s:ARRAY OF CHAR;VAR Pos:CARDINAL):PStatus;FORWARD;


PROCEDURE BackTrack(q:PStatus;VAR s:ARRAY OF CHAR;VAR Pos:CARDINAL):PStatus;

(*	perform backtracking after a failure

	Returns TRUE if a new match was found for node p

	On entry the first time, Changed must be false
	it will be set true by the first node which extends its match
	Hence, Changed must be true if backtrackimng is completely successful*)

VAR	count:CARDINAL;
	StartPos,LastPos:CARDINAL;
	p:PNode;
	SaveMatch:CARDINAL;
	MatchLeft,MatchRight:PStatus;
	temp:PStatus;
	MatchStatus:CARDINAL;
	SavePos:CARDINAL;
PROCEDURE P():BOOLEAN;
BEGIN
	(* Recursively match the pattern *)
	WITH p^ DO
 	    Pos:=q^.MatchedAt;
	    StartPos:=Pos;
	    temp:=NIL;
	    MatchStatus:=q^.Status;
	    CASE NType OF
		String,RightLimit:
			temp:=Pattern(p,s,Pos);
			RETURN temp<>NIL;
			| (*string etc*)
		AnyOf:
			Pos:=q^.MatchedTo;
			IF (MatchStatus<MaxCount) AND (s[Pos] IN Match) THEN
				INC(MatchStatus);
				Changed:=TRUE;
				RETURN TRUE;
				END;
			RETURN FALSE;
			|
		Alternatives:
			IF MatchStatus=1 THEN
				MatchLeft:=BackTrack(q^.Left,s,Pos);
				IF (MatchLeft<>NIL) AND Changed THEN 
					RETURN TRUE
				ELSE
					MatchStatus:=2;
					Changed:=TRUE;
					Pos:=StartPos;
					MatchLeft:=Pattern(Second,s,Pos);
					RETURN MatchLeft<>NIL;
					END;
			ELSE (*Status=2*)
				MatchLeft:=BackTrack(q^.Left,s,Pos);
				RETURN MatchLeft<>NIL;
				END;
			|
		Concat:

			(* see if we can backtrack on the second string*)

			Pos:=MatchStatus;
			MatchLeft:=q^.Left;
			MatchRight:=BackTrack(q^.Right,s,Pos);
			IF (MatchRight<>NIL) AND Changed THEN
				RETURN TRUE
				END;
			Pos:=q^.MatchedAt;
			
			(* if not, try to backtrack the first string
			   until the second string matches*)			
			Changed:=FALSE;
			SavePos:=Pos;
			LOOP
				Pos:=SavePos;
				MatchLeft:=BackTrack(q^.Left,s,Pos);
				IF (MatchLeft=NIL) OR NOT Changed THEN EXIT END;
				MatchRight:=Pattern(Second,s,Pos);
				IF MatchRight<>NIL THEN
					RETURN TRUE
					END;
				Changed:=FALSE;
				END;
			Pos:=StartPos;
			RETURN FALSE
			|			
			END (*CASE*)
		END (*WITH*)
	END P;
BEGIN
	p:=q^.PatternNode;
	IF P() THEN
		IF temp<>NIL THEN
			q^:=temp^;
			DISPOSE(temp);
		ELSE
 		    WITH q^ DO
 			Status:=MatchStatus;
			PatternNode:=p;
			MatchedAt:=StartPos;
			MatchedTo:=Pos;
			Left:=MatchLeft;
			Right:=MatchRight;
			END;
		    END;
	ELSE
		DISPOSE(q);
		Changed:=FALSE;
		END;
	RETURN q;
	END BackTrack;

PROCEDURE Pattern(p:PNode;VAR s:ARRAY OF CHAR;VAR Pos:CARDINAL):PStatus;

(*	This procedure matches forward *)
VAR	count:CARDINAL;
	StartPos,LastPos:CARDINAL;
	SaveMatch:CARDINAL;
	Q:PStatus;
	MatchStatus:CARDINAL;
	MatchLeft,MatchRight:PStatus;
	SavePos:CARDINAL;
PROCEDURE P():BOOLEAN;
BEGIN
	(* Recursively match the pattern *)
	WITH p^ DO
	    StartPos:=Pos;
	    CASE NType OF
		String:
			IF (Len-Pos)<TextLen THEN RETURN FALSE
			ELSE
				i:=0;
				WHILE (i<TextLen) AND (s[Pos]=Text[i]) DO
					INC(Pos);
					INC(i);
					END;
				IF i=TextLen THEN 
					RETURN TRUE
				ELSE
					Pos:=Pos-i;
					RETURN FALSE;
					END;
				END;(* long enough to match*)
			| (*string*)
		AnyOf:	MatchStatus:=0;
			WHILE (MatchStatus<MinCount) AND (s[Pos] IN Match) DO
				INC(Pos);
				INC(MatchStatus);
				END;
			IF Fast THEN
				WHILE (MatchStatus<MaxCount) AND (s[Pos] IN Match) DO
					INC(Pos);
					INC(MatchStatus);
					END;
				END;
			RETURN MatchStatus>=MinCount;
			|
		Alternatives:
				MatchLeft:=Pattern(First,s,Pos)
				IF  MatchLeft<>NIL THEN 
					MatchStatus:=1;
					RETURN TRUE
				ELSE
					
					MatchStatus:=2;
					MatchLeft:=Pattern(Second,s,Pos); 
					RETURN MatchLeft<>NIL
					END;
			|
		Concat:
			MatchLeft:=Pattern(First,s,Pos);
			IF MatchLeft<>NIL THEN
				MatchStatus:=Pos;
				MatchRight:=Pattern(Second,s,Pos);
				IF MatchRight<>NIL THEN
					RETURN TRUE
					END;
				Changed:=FALSE;
				SavePos:=Pos;
				LOOP
					Pos:=SavePos;
					MatchLeft:=BackTrack(MatchLeft,s,Pos);
					IF (MatchLeft=NIL) OR NOT Changed THEN
						EXIT
						END;
					MatchRight:=Pattern(Second,s,Pos)
					IF MatchRight<>NIL THEN
						RETURN TRUE
						END;
					Changed:=FALSE;
					END;
				END;
			Pos:=StartPos;
			RETURN FALSE
			|			
		RightLimit:
			RETURN Pos=Len
			END; (*CASE*)
		END (*WITH*)
	END P;
BEGIN
	IF P() THEN
		NEW(Q);
		WITH Q^ DO
			Status:=MatchStatus;
			PatternNode:=p;
			MatchedAt:=StartPos;
			MatchedTo:=Pos;
			Left:=MatchLeft;
			Right:=MatchRight;
			END;
	ELSE
		Q:=NIL;
		END;
	RETURN Q;
	END Pattern;


PROCEDURE MatchPattern(p:PNode;s:ARRAY OF CHAR):PStatus;

(*	Match a Pattern 
	p is the root of the pattern to match
	s is the text to match

	The function returns true only if the string matches
	completely.

	Of course, you can always used repeated sets of anything
	at the beginning and.or end of a string in order to
	match only part of a string*)

VAR	Pos:CARDINAL;
BEGIN
	Pos:=0;
	Len:=Length(s);
	RETURN Pattern(p,s,Pos);
	END MatchPattern;
END Pattern.
