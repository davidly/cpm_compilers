(* pascal program to drive RENAME - an external routine which *)
(* allows pascal programs to rename files via cp/m's file     *)
(* system.                                                    *)

program rename_driver;

	type
		filename = string 14;
		$string0 = string 0;
		$string1 = string 1;
		$string255 = string 255;
	var
		i       : integer;
		oldfile : filename;
		newfile : filename;
		typefile :filename;
 
 


 
	function
		rename(oldfilen,newfilen:filename):boolean;external;

     (* main program driver *)
	begin
		while (true) do
		begin
		     (* old file name *)
			writeln('enter present filename');
			readln(oldfile);
		     
		     (* new file name *)
			writeln('enter new filename');
			readln(newfile);

			if rename(oldfile,newfile)
				then writeln('file renamed')
				else writeln('failed renaming')
		end
	end.
               