MODULE Ackermann;

  FROM TERM1 IMPORT 
        Read,
        Write, WriteCard, WriteLn, WriteString;

  FROM ASCII IMPORT
        bel;

  VAR
    p1,p2: CARDINAL;
    ch: CHAR;


  PROCEDURE Acker(m, n: CARDINAL): CARDINAL;
  BEGIN
    IF m = 0 THEN
      RETURN n + 1;
    ELSIF n = 0 THEN
      RETURN Acker(m-1, 1);
    ELSE
      RETURN Acker(m-1, Acker(m, n-1));
    END;
  END Acker;

  PROCEDURE ReadNum(VAR c: CARDINAL);
  BEGIN
    LOOP 
      Read(ch);
      c := ORD(ch) - 30H; 
      IF c < 10 THEN EXIT; END;
      Write(bel);
    END;
    Write(ch);
  END ReadNum;

BEGIN
  WriteString( 'Ackermann Function Calculation' ); WriteLn;
  WriteString( '------------------------------' ); WriteLn;
  WriteLn;
  WriteString('Enter first parameter (1..4): ');
  ReadNum(p1);
  WriteLn;
  WriteString('Enter second parameter (1..7): ');
  ReadNum(p2);
  WriteLn; WriteString('Hit any key to start Ackermann(');
  WriteCard(p1,0); Write(','); WriteCard(p2,0); WriteString('): ');
  Read(ch);
  WriteLn; WriteCard(Acker(p1,p2), 10);
  Write(bel); 
END Ackermann.
