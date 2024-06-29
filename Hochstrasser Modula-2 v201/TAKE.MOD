MODULE Take;

  FROM InOut IMPORT
    	Read, ReadCard, Write, WriteCard, WriteLn, WriteString;

  
   VAR
     n, j: CARDINAL;
     ch: CHAR;
     wroteMsg: BOOLEAN;


PROCEDURE HeapStatus;
BEGIN
  WriteCard(n, 10); WriteString(' sticks left over'); WriteLn;
END HeapStatus;

BEGIN
  WriteString('          Take Game'); WriteLn;
  WriteString('          ---------'); WriteLn;
  WriteLn;
  REPEAT
    wroteMsg := FALSE;
    WriteLn;
    WriteString('You can tell me how many sticks you want'); WriteLn;
    WriteString('in the heap. Afterwards, one can take one,'); WriteLn;
    WriteString('two or three sticks.'); WriteLn; 
    WriteLn;
    WriteString('The one who has to take the last stick looses.'); WriteLn;
    WriteLn;

    WriteString('How many sticks: ');
    ReadCard(n); WriteLn;
  
    REPEAT  
      j := (n + 3) MOD 4;

      IF j = 0 THEN 
	j := 1; 
      ELSE 
	IF NOT wroteMsg THEN
	  WriteString("---- You don't stand a chance ...."); WriteLn;
	  wroteMsg := TRUE;
	END;
      END;

      WriteString('      I take '); WriteCard(j, 3); 
      n := n - j;
      HeapStatus;

      IF n = 1 THEN
	WriteString('---- You just lost the game.'); WriteLn;
        n := 0;
      ELSE
	LOOP
	  WriteString('    Your move: '); 
	  ReadCard(j); 
	  IF (j = 0) OR (j > 3) THEN
	    WriteLn;
	    WriteString('---- STOP CHEATING, Honey!'); WriteLn;
	    WriteString('               ');
	    HeapStatus;
	  ELSE
	    n := n - j;
	    HeapStatus;
	    EXIT;
	  END;
	END; (* LOOP *)
      END;
    UNTIL n <= 1;
    IF n = 1 THEN WriteString('Congratulations, you won!'); WriteLn; END;
    WriteString('Once again (Y/N)? ');
    REPEAT
      Read(ch);
      ch := CAP(ch);
    UNTIL (ch = 'N') OR (ch = 'Y');
    IF ch = 'N' THEN 
      WriteString('No');
    ELSE
      WriteString('Yes');
    END;
    FOR j := 1 TO 30000 DO (* wait *) END;
    FOR j := 1 TO 25 DO WriteLn; END; (* poor man's clear screen... *)
  UNTIL ch = 'N';
  WriteString('Bye Bye from your friendly computer....');
END Take.
