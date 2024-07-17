program show;

(* This program prints the current memory size in kilobytes	*)
(* and the version number of CP/M on the console.		*)
(* Written by Robert Bedichek  September 1980			*)
(* NOTE: The external routines used herein are not in LIB.REL	*)
(*	 and thus must be explicitly linked in. 		*)

const
	cpm = 5;	(* BDOS entry point address.		*)
	vercode = 12;	(* CP/M code to return the version number *)

type
	byte = 0..255;
	registers = record
		      a: byte;
		      bc, de, hl: integer
		    end;

var
	reg: registers;
	BDOS: integer;
	kilobytes: byte;
	quarterK: byte;

procedure call( var x: registers; start: integer ); external;
function peek( address: integer ): integer; external;

begin
  writeln;
  writeln;
  reg.bc := vercode;
  call( reg, cpm );

  write( 'This is ' );

(* If register h is zero then we are under CP/M, else
   we are under MP/M.					*)
  if (reg.hl div 256) > 0 then write( 'MP/M' )
			  else write( 'CP/M' );

  writeln( ' version ', reg.hl div 16:1, '.', reg.hl mod 16:1 );

(* Now figure out how big the workspace is.  We look at the jump	*)
(* instruction at location 5.  It points to one past the end of the	*)
(* workspace.  Note the trickery involved because Pascal/Z can not have *)
(* an integer bigger than 32,767.					*)

(* I know this code could be shorter, but I thought that this was clearer *)
  BDOS := peek( cpm + 1 ) - 256;
  if BDOS < 0 then
		begin
		  kilobytes := (BDOS div 1024) + 64;
		  quarterK := 25 * (((BDOS div 256) mod 4) + 3)
		end
	      else
		begin
		  kilobytes := BDOS div 1024;
		  quarterK := 25 * ((BDOS div 256) mod 4)
		end;

  writeln( 'There are ', kilobytes:1, '.', quarterK:1,
		 ' kilobytes in the Transient Program Area' );

end.





