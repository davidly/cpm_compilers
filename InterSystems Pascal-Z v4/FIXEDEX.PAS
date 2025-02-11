Program checkbook;

{ This is a simple checkbook balancing program designed }
{ to demonstrate the use of the fixed point package     }

const	max_t = 100;

{ The following comment INCLUDES the fixed point constant }
{ declarations.  The FIXCONST.PAS file has already been   }
{ editted to remove the reserved word CONST.              }

{$ifixconst.pas }
type

{ The following comment INCLUDES the fixed point type  }
{ declarations.  The FIXTYPE.PAS file has already been }
{ modified to remove the reserved word TYPE.           }

 {$ifixtype.pas }

	transaction = ( inq, dep, chk, stmt, stop );
	daterec = record
		    month : ( jan, feb, mar, apr, may, jun, jul, aug,
					sep, oct, nov, dec );
		    day : 1..31;
		    year : integer;
		  end;
	transrec = record
			oldbal, newbal : fixed;
			date : daterec;
			t_type : transaction;
			amount : fixed;
		   end;
	sequence = 1..max_t;


var

{ The following comment INCLUDES the fixed point variable }
{ declarations.  The FIXVAR.PAS file has already been     }
{ editted to remove the reserved word VAR.                }

{$ifixvar.pas }

	number : string 20;	{ number to be read }
        dummy,			{ dummy variable for comparison }
	income,			{ present deposit }
	withdrawal,		{ present withdrawal }
	balance : fixed;	{ current balance }
	option : transaction;	{ current operation }
	done : boolean;		{ test for stop }
	today : daterec;        { date }

        { array to store individual transactions }
	history : array[ 1..max_t ] of transrec;
	t# : sequence;          { transaction number }
	i : sequence;           { index variable }


procedure print; forward;    { forward declaration of procedure print }

{$l-}  { turn off listing to eliminate fixed point }

{ The following comment INCLUDES the fixed point routines. }
{$ifixed.pas }

{$l+}  { turn the listing back on }

{ enter the date }
procedure getdate;
begin
  write( 'Enter date (E.G. JUN 17 1981) -- ' );
  with today do
    read( month, day, year );
end;

{ add deposits }
procedure increment;
begin
  write( 'Deposit -- ' );
  read ( number );
  { convert the string to a fixed point # }
  income := strtofix( number );
  { perform a fixed point addition }
  balance := add( balance, income );
  { store the current information in the array }
  with history[ t# ] do
  begin
    { perform a fixed point subtraction }
    oldbal := sub( balance, income );
    newbal := balance;
    date := today;
    amount := income;
    t_type := option;
  end;
    { convert the fixed point # to a string and write it out }
  writeln( fixtostr( balance, wboth, 2 ) );
  t# := t# + 1;
end;

{ decrement withdrawals }
procedure decrement;
begin
  write( 'Withdrawal amount -- ' );
  read( number );
  { convert the string to a fixed point # }
  withdrawal := strtofix( number );
  with history[ t# ] do
  begin
    oldbal := balance;
    newbal := sub( balance, withdrawal );
    date := today;
    t_type := option;
    amount := withdrawal;
  end;
  t# := t# + 1;
  { perform a fixed point subtraction }
  balance := sub( balance, withdrawal );
  history[ t# - 1 ].newbal := balance;
  { convert the fixed point # to a string and write it out }
  writeln( fixtostr( balance, wboth, 2 ) );
  { routine to check for overdrawn account }
  dummy := strtofix( '0' );
  if greater( dummy, balance ) then writeln( 'Oops! Overdrawn' )
end;

{ procedure to print out statement }
procedure print;
begin
  with history[ i ], date do
  begin
    { convert all fixed point #s to strings and write out }
    write( fixtostr( newbal, wboth, 2 ) );
    write( fixtostr( oldbal, wboth, 2 ) );
    write( month, day, year, t_type );
    writeln( fixtostr( amount, wboth, 2 ) )
  end;
end;


begin		{ main program }
  done := false;
  t# := 1;
  getdate;
  write( 'Starting balance -- ' );
  read( number );
  { convert the string to a fixed point # and assign it to balance }
  balance := strtofix( number );
  repeat
    write( 'Option ( inq, dep, chk, stmt, stop ) -- ' );
    read( option );
    case option of
      inq: writeln( fixtostr( balance, wboth, 2 ) );
      dep : increment;
      chk : decrement;
      stmt : for i := 1 to t# - 1 do print;
      stop : done := true
    end;
  until done;
end.
                                                                                                              