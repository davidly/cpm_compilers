(****************************************************************)
(*								*)
(* Ithaca InterSystems' Pascal/Z Fixed-Point Package            *)
(*								*)
(* Written by Robert Bedichek	  August 1980			*)
(*								*)
(****************************************************************)

procedure setlength( var y: string0; x: integer ); external;
function length( x: string255 ): integer; external;

(* The next two external functions are in LIB.REL and are automatically *)
(* linked in when the library is being linked in.  They add and 	*)
(* subtract two decimal digits packed into a byte using Z-80 decimal	*)
(* arithmetic.								*)
function addbyte( var carry: carrytyp; a, b: byte ):byte; external;
function subbyte( var carry: carrytyp; a, b: byte ):byte; external;

function add( a, b: fixed ): fixed;
(************************************************************************)
(* The value of this function is the signed sum of the two value	*)
(* parameters.	The global variable 'fixederror' is set if there was	*)
(* an overflow. 							*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	carry: 0..1;
	i: integer;
	res: fixed;

begin
  carry := 0;
  if a.sign = b.sign then   (* Like signs, just add	*)
    begin
      add.sign := a.sign;
      for i := 1 to bytes do
	add.digits[ i ] := addbyte( carry, a.digits[ i ], b.digits[ i ] );
      fixederror := (carry = 1)
    end
		     else   (* Unlike signs, subract negative op from pos.  *)
    begin
      fixederror := false;
      if a.sign = plus then
	for i := 1 to bytes do
	  res.digits[ i ] := subbyte(carry, a.digits[ i ], b.digits[ i ])
		       else
	for i := 1 to bytes do
	  res.digits[ i ] := subbyte(carry, b.digits[ i ], a.digits[ i ]);
      if carry = 0 then res.sign := plus
		   else
		     begin
		       res.sign := minus;
		       carry := 0;

(* Take nines complement of the result by subtracting it from zero.	*)
		       for i := 1 to bytes do
		res.digits[ i ] := subbyte( carry, 0, res.digits[ i ])
		     end;
      add := res
    end
end;

function sub( minuend, subtrahend: fixed ): fixed;
(************************************************************************)
(* The value of this function is the signed difference of the two	*)
(* value parameters.  The global variable 'fixederror' is set if the	*)
(* is an overflow.							*)
(*									*)
(*									*)
(*									*)
(************************************************************************)

begin

(* Just reverse the sign of the subtrahend and add.			*)
  if subtrahend.sign = plus then subtrahend.sign := minus
			    else subtrahend.sign := plus;
  sub := add( minuend, subtrahend )
end;

function greater( a,b: fixed ): boolean;
(************************************************************************)
(* This returns true if the first operand is greater than or equal to	*)
(* the second operand.							*)
(* Otherwise it returns false.	If the signs are like then we		*)
(* determine which is greater by subtracting and loking at the sign	*)
(* of the result.  If the signs are unlike we return true if the first	*)
(* operand is positive, otherwise we return false.  This is faster	*)
(* and it avoids the problem of arithmetic overflow.			*)
(************************************************************************)
begin
  if a.sign = b.sign then
    begin
      a := sub( a, b );
      greater := ( a.sign = plus )
    end
		     else
    if a.sign = plus then greater := true
		     else greater := false

end;

procedure shiftleft( var a: fixed );
(************************************************************************)
(* This procedure shifts all of the packed decimal digits in the	*)
(* passed parameter left one position.	A zero is shifted into the	*)
(* least significant position.	The digit shifted out is lost.		*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	i: integer;
	next: byte;

begin
  for i := bytes downto 1 do
    begin
      if i > 1 then next := (a.digits[ i - 1 ] div 16)
	       else next := 0;
      a.digits[ i ] := ((a.digits[ i ] * 16) + next) mod 256
    end
end;		(*	shiftleft	*)

procedure shiftright( var a: fixed );
(************************************************************************)
(* This procedure shifts all of the packed decimal digits in the passed *)
(* parameter right one position.  A zero is shifted into the most	*)
(* significant position.  The digits shifted out is lost.		*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	i: integer;
	next: byte;

begin
  for i := 1 to bytes do
    begin
      if i < bytes then next := (a.digits[ i + 1 ] mod 16) * 16
		   else next := 0;
      a.digits[ i ] := (a.digits[ i ] div 16) + next
    end
end;		(*	shiftright	*)

function $mult( multiplier, multplicand: fixed): fixed;
(************************************************************************)
(* This function returns the product of the two passed value parameters.*)
(*									*)
(*									*)
(*									*)
(* NOTE: the i is left out of multiplicand to make it unique in the	*)
(*	 first eight characters.					*)
(************************************************************************)
const
	double = bytes * 2;
var
	i, j, k: integer;
	next: byte;		(* Used for shifting 'multpl' left	*)
	multpl, 		(* Work array for the multiplicand	*)
	result: array[ 1..double ] of byte;
	carry: carrytyp;

begin
  carry := 0;

(* Result is positive if operands have like signs, otherwise negative.	*)
  if multiplier.sign = multplicand.sign then $mult.sign := plus
					else $mult.sign := minus;

  for i := 1 to double do result[ i ] := 0;

(* Put the multiplicand into the double-sized work array 'multpl'.	*)
(* And extend it in 'multpl' by filling it with zeros.			*)
  for i := 1 to bytes do multpl[ i ] := multplicand.digits[ i ];
  for i := bytes + 1 to double do multpl[ i ] := 0;

  for i := 1 to left + right do
    begin
      for j := 1 to (multiplier.digits[ 1 ] mod 16) do
	for k := 1 to double do
	  result[ k ] := addbyte( carry, result[ k ], multpl[ k ] );

      shiftright( multiplier );

(* Shift the double-size array 'multpl' left one position		*)
      for j := double downto 1 do
	begin
	  if j > 1 then next := (multpl[ j - 1 ] div 16)
		   else next := 0;
	  multpl[ j ] := ((multpl[ j ] * 16) + next) mod 256
	end
    end;

(* Shift 'result' right one digit if 'right' is odd.			*)
  if odd( right ) then
    for i := 1 to double do
      begin
	if i < double then next := (result[ i + 1 ] mod 16) * 16
		      else next := 0;
	result[ i ] := (result[ i ] div 16) + next
      end;

(* Put the result in the return value and shift it while doing it.	*)
  for i := 1 to bytes do $mult.digits[ i ] := result[ i + (right div 2) ];

  fixederror := false;

(* If there are any non-zero digits above the ones that we just moved	*)
(* into the function array then we have an overflow.			*)
  for i := bytes + (right div 2) + 1 to double do
    if result[ i ] > 0 then fixederror := true
end;		(*	$mult	*)

function $divd( dividend, divisor: fixed ): fixed;
(************************************************************************)
(* The value of this function is the quotient of the first paramter	*)
(* by the second.  If the divisor is zero the function will return	*)
(* a zero and the 'fixederror' flag will be set.			*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	zero: boolean;		(* Gets set true if the divisor is zero *)
	i, j, shiftcount: integer;
	result: fixed;
	shift: integer;

begin
  for i := 1 to bytes do result.digits[ i ] := 0;
  zero := true;
  for i := 1 to bytes do zero := zero and (divisor.digits[ i ] = 0);
  fixederror := zero;
  if not zero then
    begin
      if dividend.sign = divisor.sign then $divd.sign := plus
				      else $divd.sign := minus;
      dividend.sign := plus;
      divisor.sign := plus;
      result.sign := plus;

(* Shift the divisor left until the most significant digit of the number
   is in the most significant nibble of the variable 'divisor'. 	*)
      shiftcount := 0;
      while (divisor.digits[ bytes ] div 16) = 0 do
	begin
	  shiftleft( divisor );
	  shiftcount := shiftcount + 1
	end;

(* Do the same thing to the dividend that we did to the divisor.
   Shiftcount's value is the relative position of the divisor and the
   dividend.  That is, shiftcount is the number of places that the divisor
   was shifted left minus the number of places the dividend was shifted left.
 *)
      while (dividend.digits[ bytes ] div 16) = 0 do
	begin
	  shiftleft( dividend );
	  shiftcount := shiftcount - 1
	end;


      for i := 1 to left + right do
	begin
	  shiftleft( result );

(* Keep subtracting the divisor from the dividend until the dividend goes
   negative.	*)
	  repeat
	    dividend := sub( dividend, divisor );
	    result.digits[ 1 ] := result.digits[ 1 ] + 1
	  until dividend.sign = minus;

(* Add the divisor back to the dividend to make it positive again.	*)
	  dividend := add( dividend, divisor );
	  result.digits[ 1 ] := result.digits[ 1 ] - 1;

	  shiftright( divisor )
	end;

(* Now that we've finished the divide, we must shift the result left or
   right to compensate for the preshifting of the divisor and the
   dividend that we did.	*)
      shift := shiftcount - left + 1;
      if shift > 0 then
	for i := 1 to shift do
	  begin
	    if ((result.digits[ bytes ] div 16) > 0) then fixederror := true;
	    shiftleft( result )
	  end
		   else
	for i := -1 downto shift do shiftright( result )
    end;
  $divd.digits := result.digits
end;		(*	$divd	*)

function fixtoreal( a: fixed): real;
(************************************************************************)
(* This function converts a fixed point number to a real one.		*)
(*									*)
(*									*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	multiplier: real;
	i: integer;
	result: real;

begin
  fixederror := false;
  result := 0;
  multiplier := 1;
  for i := 1 to right - 1 do multiplier := multiplier / 10;

  for i := 1 to left + right do
    begin
      shiftright( a );
      result := result + multiplier * (a.digits[ 1 ] mod 16);
      multiplier := multiplier * 10
    end;
  if a.sign = minus then result := -1 * result;
  fixtoreal := result
end;		(*	fixtoreal	*)

function realtofix( a: real ): fixed;
(************************************************************************)
(* This function converts a real number to a fixed point number.	*)
(*									*)
(*									*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	i: integer;
	multiplier: real;
	result: fixed;

begin
  fixederror := false;
  if a >= 0 then result.sign := plus
	   else
	     begin
	       result.sign := minus;
	       a := abs( a )
	     end;
  for i := 1 to bytes do result.digits[ i ] := 0;
  multiplier := 1;
  for i := 1 to left - 1 do multiplier := multiplier * 10;

  for i := 1 to left + right do
    begin
      if (result.digits[ bytes ] div 16) > 0 then fixederror := true;
      shiftleft( result );
      result.digits[ 1 ] := result.digits[ 1 ]+(trunc( a/multiplier ) mod 10);
      multiplier := multiplier / 10
    end;
  realtofix := result
end;		(*	realtofix	*)

function fixtostr( a: fixed; mode: modetyp; trailing: byte ): fixstr;
(************************************************************************)
(* This function returns a formatted string.  The 'mode' parameter	*)
(* specifies which formatting operation is to take place.  The		*)
(* 'trailing' parameter specifies the maximum number of digits to the	*)
(* right of the decimal point that are to appear.			*)
(*									*)
(*									*)
(************************************************************************)
var
	i, j: byte;
	result: fixstr;

begin
  if trailing > right then trailing := right;

(* Make the 'result' string have 'maxchars' spaces		*)
  setlength( result, 0 );
  for i := 1 to maxchars do append( result, ' ' );

  result[ maxchars - right ] := '.';

(* Put the digits to the right of the dp into the string	 *)
  for i := maxchars downto maxchars - (right - 1) do
    begin
      result[ i ] := chr((a.digits[ 1 ] mod 16) + ord('0'));
      shiftright( a )
    end;

(* Leave 'trailing' digits to the right of the decimal point	*)
  for i := maxchars downto (maxchars - (right - trailing)) + 1 do
    result[ i ] := ' ';

(* Put the digits to the left of the dp into the string 	*)
  j := maxchars - right - 1;
  for i := maxchars - right - 1 downto maxchars - left - right do
    begin

(* Put a comma between every third digit if 'mode' tells us to	*)
      if ((((maxchars - right - 1) - i) mod 3) = 0) and
	 (i < (maxchars - right - 1)) and
	 (mode >= wcomma) then
			    begin
			      result[ j ] := ',';
			      j := j - 1
			    end;
      result[ j ] := chr((a.digits[ 1 ] mod 16) + ord('0'));
      j := j - 1;
      shiftright( a )
    end;


(* Suppress leading zeros if mode is anything other than 'none' *)
  j := j + 1;
  if mode > none then
    while ((result[ j ] = '0') or (result[ j ] = ','))
	  and (j < maxchars - right - 1) do
      begin
	result[ j ] := ' ';
	j := j + 1
      end;

(* Put a dollar sign in front of the most significant digit if	*)
(* 'mode' is 'wdollar' or 'wboth'				*)
  j := j - 1;
  if (mode = wdollar) or (mode = wboth) then
    begin
      result[ j ] := '$';
      j := j - 1
    end;

(* If the number being converted is negative put a minus sign in	*)
(* front of the dollar sign or (if there is no dollar sign) the most	*)
(* most significant digit.						*)
  if a.sign = minus then result[ j ] := '-';

(* If we are supposed to suppress leading and trailing zeros	*)
(* (mode = supltzer), suppress the trailing ones here.		*)
  if mode = supltzer then
    begin
      j := maxchars - ( right - trailing );
      while result[ j ] = '0' do
	begin
	  result[ j ] := ' ';
	  j := j - 1
	end
    end;
  fixtostr := result
end;		(*	fixtostr	*)

function strtofix( a: fixstr ): fixed;
(************************************************************************)
(* This converts the passed string to fixed point.  All characters	*)
(* other than the minus sign (-), decimal point(.), and the decimal	*)
(* digits (0123456789) are skipped over and ignored.			*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	rightcount, i: byte;
	righthalf: boolean;	(* True when scanning digits to right of dp  *)
	result: fixed;

begin
  righthalf := false;
  rightcount := 0;
  for i := 1 to bytes do result.digits[ i ] := 0;
  result.sign := plus;
  for i := 1 to length( a ) do
    if a[ i ] = '.' then righthalf := true
		    else
      if a[ i ] = '-' then result.sign := minus
		      else
       if (rightcount < right) and (a[ i ] <= '9') and (a[ i ] >= '0')
	 then
	   begin
	     shiftleft( result );
	     result.digits[1] := result.digits[1] + ord(a[i]) - ord('0');
	     if righthalf then rightcount := rightcount + 1
	   end;
    for i := rightcount to right - 1 do shiftleft( result );
  strtofix := result
end;		(*	strtofix	*)



                                                                                                                    