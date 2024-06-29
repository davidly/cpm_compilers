procedure DUMP is		-- sample program using file calls

title : string(1..14);

procedure ascii(A : character) is
begin
	if A < ' ' or A > '~' then
		put('.');	 -- print a period for non-printable characters
	else
		put(A);
	end if;
end ascii;

procedure hex2(number : integer) is	-- print number as 2 hex digits

	procedure hexdigit(number : integer) is
	begin
		if number < 10 then
			put(number);
		else
			put(character'val(character'pos('A') +  number - 10));
		end if;
	end hexdigit;

begin
	hexdigit(number/16);
	hexdigit(number rem 16);
end hex2;

procedure hex4(number : integer) is	     -- print number as 4 hex digits
begin
	hex2(number/256);
	hex2(number rem 256);
end hex4;

procedure dumpit(title : string) is
	result : boolean := true;	-- for file I/O results
	buffer : string(0..127);	-- input buffer
	address : integer := 0;		-- address of output bytes
    begin
	open(ufcb,title,result);		-- open file
	if not result then
		put("File ");
		put(name(ufcb));
		put(" not found");
		new_line;
	else
		new_line;

    -- fill buffer with characters and check for eof

		read(ufcb,buffer,result);	-- get a record
		while result loop
			for i in 0..7 loop
				hex4(address);	-- write address in hex
				put("  ");

			-- print hex characters

				for j in 0..15 loop
					hex2(character'pos(buffer(i*16+j)));
					put(' ');
				end loop;
				put("   ");

			-- print ascii string

				for j in 0..15 loop
					ascii(buffer(i*16+j));
				end loop;

				new_line;
				address := address + 16;

			-- check for key depressed
				
				if bdos(11) /= 0 then
					bdos(0);	-- system reset if key
				end if;

			end loop;	-- end of this record

		read(ufcb,buffer,result); -- get another record
		end loop;
		close(ufcb,result);	-- ignore result
	end if; 
    end dumpit;

begin		-- main program

	dumpit(""); 	-- first dump program in ccp string
	loop
		put("Name of program to dump or cntl-C to exit: ");
		get(title);
		dumpit(title);
	end loop;	-- continue dumping programs

end DUMP;
