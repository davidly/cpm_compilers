procedure DUMP is		-- sample program using BDOS

address : integer := 0;
buffer : string (0..127);

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

begin	-- main dump program

	if bdos(15) = 255 then		-- open file
		put("File not found");
	else
		bdos(26,buffer'address);	-- specify DMA
		new_line;

-- fill buffer with characters and check for eof

		while bdos(20) = 0 loop
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

			end loop;
		end loop;
	end if;
end DUMP;
