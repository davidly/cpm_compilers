const
	left =	 5;  (* Number of digits to the left of the dp *)
	right =  5;    (*   "	  "    "    "	" right "  "  "  *)

   (* Number of bytes it takes to represent a fixed-point number *)
	bytes = (left + right + 1) div 2;

   (* Length of a fixed-point converted string *)
	maxchars = ((left * 4) div 3) + right + 3;

