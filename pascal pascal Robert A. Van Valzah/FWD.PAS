(*

  TITLE          Foreward Procedure declaration test

  FILENAME       FWD.PAS

  AUTHOR         Robert A. Van Valzah   17/01/80

  LAST REVISOR   Robert A. Van Valzah   23/01/80

  REASON         Finish writing

*)
procedure b; forward;

procedure a(this,that:word);
begin
	this:=that;
	that:=this;
	b(1,2);
	a(13,13);
	b(3,4)
end; (* procudure a *)

procedure b(parm1,parm2:word); backward;
begin
	parm1:=parm1*parm2;
	a(13,13);
	b(5,6)
end,; (* procedure b *)

begin (* main line *)
a(7,8);
b(9,10)
end,.
