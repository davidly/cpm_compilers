IMPLEMENTATION MODULE ResetDisc;
FROM	CPM IMPORT BDOS,rsdfc;
PROCEDURE ResetAllDiscs;
VAR	c:CARDINAL;
BEGIN
	c:=BDOS(rsdfc,03fh);
	END ResetAllDiscs;
END ResetDisc.
