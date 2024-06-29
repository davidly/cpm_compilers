procedure getdir is

title : string(0..13);
result : boolean;

function ucase(inchar : character) return character is
begin
	if (inchar >= 'a') and (inchar <= 'z') then
		return character'val(character'pos(inchar) - 32);
	else
		return inchar;
	end if;
end ucase;

procedure gdir is
	eodir : constant integer := 255;
	ch : character;
	dirptr : integer;
	nmctr : integer;
	dircode : integer;
	dir_buffer : string(0..127);

	procedure printname is
	begin
		if nmctr = 1 then
			ch := title(0);
			put(ch);
		end if;
		put(" : ");
		for i in 1..8 loop	
			put(dir_buffer(dirptr+i));
		end loop;
		put(' ');
		for i in 9..11 loop
			put(dir_buffer(dirptr+i));
		end loop;
		if nmctr = 4 then
			new_line;
			nmctr := 0;
		end if;
	end printname;
begin
	nmctr := 0;

--	create used here to stuff phony file name "????????.???" into user file
--	control block at 16#5C#. Result ignored; file name remains parsed in
--	file control block and bdos calls used from now on.  Note that this is
--	an erroneous program as it depends on a side effect to accomplish its
--	results. Future versions of Ada will treat the file variable as a 
--	record with individually accessable components.  This call will create
--	the file "????????.???" on an empty disk.

	create(ufcb,title,result);
	bdos(26,dir_buffer'address);
	dircode := bdos(17);
	if dircode /= eodir then
		while dircode /= eodir loop
			nmctr := nmctr + 1;
			dirptr := dircode * 32;
			printname;
			dircode := bdos(18);
		end loop;
	else
		put("No file"); new_line;
	end if;
end gdir;

procedure list is
	ch : character;
begin
	title := "A:????????.???";
	put("List disk directory: Unit A or B? ");
	get(ch);
	if ch = character'val(3) then
		bdos(0);		-- exit on cntl-c
	end if;
	ch := ucase(ch);
	title(0) := ch;
	bdos(13);
	new_line;
	gdir;
	new_line;
end list;

begin		-- getdir
	loop
		list;
	end loop;
end getdir;
