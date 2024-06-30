IMPLEMENTATION MODULE ScreenDummy;
IMPORT	ScreenIO;

PROCEDURE ClearScreen;
BEGIN
	ScreenIO.ScreenControl(ScreenIO.ClearScreen);
	END ClearScreen;
PROCEDURE Gotoxy(x,y:CARDINAL);
BEGIN
	ScreenIO.Gotoxy(x,y);
	END Gotoxy;
PROCEDURE RingBell;
BEGIN
	ScreenIO.ScreenControl(ScreenIO.RingBell);
	END RingBell;
PROCEDURE OutputToScreen(b:BOOLEAN);
BEGIN
	ScreenIO.OutputToScreen(b);
	END OutputToScreen;
PROCEDURE  DrawBox(x1,y1,x2,y2:CARDINAL);
BEGIN
	ScreenIO.DrawBox(x1,y1,x2,y2);
	END DrawBox;
END ScreenDummy.

