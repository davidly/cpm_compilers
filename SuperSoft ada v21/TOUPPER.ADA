procedure TO_UPPER is

    error_flag : boolean;
    ch : character;
    eof : constant character := character'val(26);

    function up (A : character) return character is
	begin
	    if A < 'a' then
		return A;
	    elsif A > 'z' then
		return A;
	    else
		return character'val(character'pos(A)-32);
	    end if;
	end up;
begin

    open(ufcb,"",error_flag);

    if not error_flag then
	put(name(ufcb));
	put(" not found");
	bdos(0);
    else
	read(ufcb,ch,error_flag);
	while ch /= eof and error_flag loop
		put(up(ch));
		read(ufcb,ch,error_flag);
	end loop;

	if not error_flag then
	    new_line;
	    put("File error.");
	    new_line;
	end if;
    end if;

    close(ufcb,error_flag);
    new_line;

end TO_UPPER;
