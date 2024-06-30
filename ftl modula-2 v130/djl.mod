IMPLEMENTATION MODULE Djl;

FROM CPM IMPORT BDOS,rccfc,wccfc,rcbfc,rcsfc,diofc;

PROCEDURE Write(b:CHAR);
VAR     i:INTEGER;      (*needed to avoid conflict with global*)
BEGIN
        i:=BDOS(wccfc,SHORT(b))
        END Write;
PROCEDURE WriteLn;
BEGIN
        Write(0dx);
        Write(0ax);
        END WriteLn;
PROCEDURE OutString(VAR s:ARRAY OF CHAR);
BEGIN
        i:=0;
        LOOP
                IF i>HIGH(s) THEN EXIT END;
                IF s[i]=0c THEN EXIT END;
                Write(s[i]);
                i:=i+1;
                END; (*LOOP*)
        END OutString;
PROCEDURE WriteString(s:ARRAY OF CHAR);
BEGIN
        OutString(s);
        END WriteString;

BEGIN
        END Djl.

