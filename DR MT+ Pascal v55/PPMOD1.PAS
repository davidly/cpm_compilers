(*  VERSION 0032 *)

(* 5.5 STARTS WITH VERSION 32 *)

MODULE PPMOD1;

(*$I PPTYPES*)

(*$I PPEXTS*)


PROCEDURE GETCHAR;
VAR
  CH : CHAR;
  EOLCURSOR : INTEGER;
  CH2 : ARRAY [1..2] OF CHAR;

BEGIN
  CUR := NXT;
  IF CURSOR <= BUFSZ THEN
    CH := BUF[CURSOR]
  ELSE
     CH := ' ';
 
    WITH NXT DO
      BEGIN
        IF CURSOR > ENDFILE THEN
          NAME := FILEMARK
        ELSE IF CH = CHR(CR) THEN
          BEGIN
            CURSOR := CURSOR + 2;
            WRITE('.');
            EOLCURSOR := CURSOR;
            NAME := END_OF_LINE;
            (* CURSOR NOW POINTS TO CHAR AFTER LF *)
            WHILE BUF[CURSOR] = ' ' DO
              CURSOR := CURSOR + 1;
            MOVE(BUF[CURSOR],CH2,2);
            {IF (CH2= '(*') OR (BUF[CURSOR]='{') THEN
              CURSOR := EOLCURSOR;}
            CURSOR := CURSOR - 1
          END
        ELSE IF ((CH >='@') AND (CH <='Z')) OR
                ((CH >='a') AND (CH <='z')) OR
                ( CH = '_') THEN
          NAME := LETTER
        ELSE IF ((CH >= '0') AND (CH <= '9')) THEN
          NAME := DIGIT
        ELSE IF CH = '''' THEN
          NAME := QUOTE
        ELSE IF CH = SPACE THEN
          NAME := BLANK
        ELSE NAME := OTHERCHAR;
        
        IF (NAME=FILEMARK) OR (NAME=END_OF_LINE) THEN
          VALUE := SPACE
        ELSE
          VALUE := CH; {no longer convert to uppercase as of 5.5 }
          
        IF NAME <> FILEMARK THEN
          CURSOR := CURSOR + 1
      END
END;

(*$P*)

PROCEDURE STORENXT(VAR LENGTH:INTEGER;
                   VAR VALUE : STRING);
                        
BEGIN
  GETCHAR;
  IF LENGTH < MAXSYMSIZE THEN
    BEGIN
      LENGTH := LENGTH + 1;
      VALUE[LENGTH] := CUR.VALUE
    END
END;

(*$P*)

PROCEDURE SKIPSPACES(VAR SPACESBEFORE,CRSBEFORE : INTEGER);
                     
BEGIN
  SPACESBEFORE := 0;
  CRSBEFORE := 0;
  WHILE (NXT.NAME = BLANK) OR (NXT.NAME = ENDOFLINE) DO
    BEGIN
      GETCHAR;
      CASE CUR.NAME OF
        BLANK : SPACESBEFORE := SPACESBEFORE + 1;
        ENDOFLINE : BEGIN
                      CRSBEFORE := CRSBEFORE + 1;
                      SPACESBEFORE := 0
                    END
     END
   END
END;

(*$P*)

PROCEDURE GETCOMMENT(VAR NAME : KEYSYMBOL;
                     VAR VALUE : STRING;
                     VAR LENGTH : INTEGER;
                         BRACE : BOOLEAN);
 
BEGIN
  BRACE := NEXTSYM.VALUE[1] = '{';
  NAME := OPENCOMMENT;
  IF NOT BRACE THEN
    WHILE NOT(((CUR.VALUE = '*') AND (NXT.VALUE=')'))
          OR   (NXT.NAME = ENDOFLINE)
          OR   (NXT.NAME = FILEMARK)) DO
      STORENXT(LENGTH,VALUE)
  ELSE
    WHILE NOT((NXT.VALUE='}')
          OR  (NXT.NAME = ENDOFLINE)
          OR  (NXT.NAME = FILEMARK)) DO
      STORENXT(LENGTH,VALUE);
    
  IF (CUR.VALUE = '*') AND (NXT.VALUE = ')') THEN
    BEGIN
      STORENXT(LENGTH,VALUE);
      NAME := CLOSECOMMENT
    END
  ELSE IF (NXT.VALUE = '}') THEN
         NAME := CLOSECOMMENT
END;

(*$P*)

FUNCTION IDTYPE(VALUE:STRING;
                LENGTH:INTEGER):KEYSYMBOL;
                
VAR
  I : INTEGER;
  KEYVALUE : KEY;
  HIT : BOOLEAN;
  THISKEY : KEYSYMBOL;
  
BEGIN
  IDTYPE := OTHERSY;
  IF LENGTH <= MAXKEYLEN THEN
    BEGIN
      FOR I := 1 TO LENGTH DO
        KEYVALUE[I] := CHR(VALUE[I] & $DF);
      FOR I := LENGTH+1 TO MAXKEYLENGTH DO
        KEYVALUE[I] := SPACE;
      THISKEY := PROGSY;
      HIT := FALSE;
      
      WHILE NOT(HIT OR (PRED(THISKEY) = UNTILSY)) DO
        IF KEYVALUE = KEYWORD[THISKEY] THEN
          HIT := TRUE
        ELSE
          THISKEY := SUCC(THISKEY);
          
      IF HIT THEN
        IDTYPE := THISKEY
    END
END;

(*$P*)

PROCEDURE GETIDENTIFIER(VAR NAME : KEYSYMBOL;
                        VAR VALUE : STRING;
                        VAR LENGTH : INTEGER);
                        
BEGIN
  WHILE (NXT.NAME = LETTER) OR (NXT.NAME = DIGIT) DO
    STORENXT(LENGTH,VALUE);
  NAME := IDTYPE(VALUE,LENGTH);
  CASE NAME OF
    RECORDSY : RECORDSEEN := TRUE;
    EXTSY    : IF COLONSEEN THEN
		 NAME := ANOTHERSY
	       ELSE
		 EXTSEEN := TRUE;
    PROCSY,
    FUNCSY   : IF EXTSEEN THEN
	         NAME := ANOTHERSY;
    CASESY   : IF RECORDSEEN THEN
                  NAME := CASEVARSY;
    ENDSY    : RECORDSEEN := FALSE
    
  END
END;

MODEND.

