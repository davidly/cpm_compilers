IMPLEMENTATION MODULE LongSets;         (* Feb - 1 - 1985 *)
 

  CONST
    LongIndex = (LongBits-1) DIV BitsPerSet; (* max index *)


  VAR
    i: CARDINAL;


  PROCEDURE Init(VAR set: LONGSET);
  BEGIN
    FOR i := 0 TO LongIndex DO
       set[i] := {};
    END;
  END Init;


  PROCEDURE Unite(s1, s2: LONGSET; VAR union: LONGSET);
  BEGIN
    FOR i := 0 TO LongIndex DO 
      union[i] := s1[i] + s2[i];
    END;
  END Unite;      


  PROCEDURE Diff(s1, s2: LONGSET; VAR difference: LONGSET);
  BEGIN
    FOR i := 0 TO LongIndex DO
      difference[i] := s1[i] - s2[i];
    END;  
  END Diff;


  PROCEDURE InterSect(s1, s2: LONGSET; VAR intersect: LONGSET);
  BEGIN
    FOR i := 0 TO LongIndex DO
      intersect[i] := s1[i] * s2[i]; 
    END;  
  END InterSect;


  PROCEDURE Xor(s1, s2: LONGSET; VAR symSetDiff: LONGSET);
  BEGIN
    FOR i := 0 TO LongIndex DO
      symSetDiff[i] := s1[i] / s2[i];
    END;  
  END Xor;


  PROCEDURE Include(VAR set: LONGSET; bit: CARDINAL);
  BEGIN
    INCL(set[bit DIV BitsPerSet], bit MOD BitsPerSet);
  END Include;


  PROCEDURE InclRange(VAR set: LONGSET; start, end: CARDINAL);
  VAR
    i: CARDINAL;
  BEGINŠ    FOR i := start TO end DO
      INCL(set[i DIV BitsPerSet], i MOD BitsPerSet);
    END; (* FOR *)
  END InclRange;


  PROCEDURE Exclude(VAR set: LONGSET; bit: CARDINAL);
  BEGIN
    EXCL(set[bit DIV BitsPerSet], bit MOD BitsPerSet);
  END Exclude;


  PROCEDURE Included(set: LONGSET; bit: CARDINAL): BOOLEAN;
  BEGIN
    RETURN (bit MOD BitsPerSet) IN set[bit DIV BitsPerSet];
  END Included;

END LongSets.
