type

	(* The next two types are neccessary for 'length' and 'setlength' *)
	string255 = string 255;
	string0 = string 0;

	signtyp = (plus, minus);
	carrytyp = 0..1;

	(* The basic unit of a fixed-point number -- takes 1 byte of storage *)
	byte = 0..255;

	modetyp = (none, suplzer, supltzer, wdollar, wcomma, wboth);

(* This is the type around which this whole package is based.		*)
	fixed = record
		  sign: signtyp;
		  digits: array[1..bytes] of byte
		end;

(* This is a string type which can hold a fixed point number converted	*)
(* to ASCII.								*)
	fixstr = string maxchars;

