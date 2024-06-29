procedure ADA_CALCULATOR is

-- define terminal dependent features

    clear_screen : constant character := character'val(26);
    home_cursor : constant character := character'val(30);
    cr : constant character := character'val(13);
    back_space : constant character := character'val(8);
    beep : constant character := character'val(7);

    X, Y, Z, T : float := 0.0;		-- the calculator registers
    ch : character;
    roll_flag : boolean := false;
    error : boolean := false;
    decimal_point : boolean := false;
    power : float := 0.1;

    procedure display is
	begin
	    put(home_cursor);
	    put(T); put("    "); new_line;
	    put(Z); put("    "); new_line;
	    put(Y); put("    "); new_line;
	    put(X); put("    "); new_line;
	    new_line;
	end display;

    procedure roll_up is
	begin
	    t := z;
	    z := y;
	    y := x;
	end roll_up;

    function sqrt(A : float) return float is
	guess, delt : float;
	begin
	    if a = 0.0 then
		return 0.0;
	    elsif a = 1.0 then
		return 1.0;
	    else
		guess := a / 2.0;
		delt := 1.0;
		while guess ** 2 > a loop
		    guess := guess / 2.0;
		end loop;
		while abs(guess ** 2 - a) > 0.0001 loop
		    while (guess + delt) ** 2 > a loop
			if delt < 0.00001 then
			    return guess;
			else
			    delt := delt / 2.0;
			end if;
		    end loop;
		    guess := guess + delt;
		end loop;
		return guess;
	    end if;
	end sqrt;

    function sin(x : float) return float is
	n1 : float := 1.0;
	n2 : integer := -1;
	x1 : float := 0.0;
	x2 : float := 1.0;
	x3 : float := x * 0.017453;
	begin
	    for n in 1..15 loop
		n1 := n1 * float(n);
		x2 := x2 * x3;
		if n rem 2 = 1 then
		    n2 := -1 * n2;
		    x1 := x1 + ((x2 * float(n2)) / n1);
		end if;
	    end loop;
	    return x1;
	end sin;

    function cos(x : float) return float is
	n1 : float := 1.0;
	n2 : integer := 1;
	x1 : float := 1.0;
	x2 : float := x * 0.017453;
	x3 : float := x2;
	begin
	    for n in 2..16 loop
		n1 := n1 * float(n);
		x2 := x2 * x3;
		if n rem 2 = 0 then
		    n2 := -n2;
		    x1 := x1 + ((x2 * float(n2)) / n1);
		end if;
	    end loop;
	    return x1;
	end cos;

    function ln(a : float) return float is
	x1 : float := 0.0;
	x2 : float := 1.0;
	begin
	    for n in 1..51 loop
		x2 := x2 * ((x - 1.0) / (x + 1.0));
		if n rem 2 = 1 then
		    x1 := x1 + x2 / float(n);
		end if;
	    end loop;
	    return 2.0 * x1;
	end ln;

    function exp(a : float) return float is
	n1, x1, x2 : float := 1.0;
	begin
	    for n in 1..51 loop
		n1 := n1 * float(n);
		x2 := x2 * x;
		x1 := x1 + x2 / n1;
	    end loop;
	    return x1;
	end exp;

    procedure process(input : character) is
	    number : constant float := float(character'pos(input)-48);
	begin
	    case input is
		when '0'..'9' =>
		    if roll_flag then
			roll_up;		-- entering new number, roll
			roll_flag := false;
			x := number;
		    else
			if decimal_point then
			    x := x + number * power;
			    power := power / 10.0;
			else
			    x := x * 10.0 + number;
			end if;
		    end if;

		when '.' =>
		    if roll_flag then
			roll_up;
			roll_flag := false;
			x := 0.0;
		    end if;
		    decimal_point := true;

		when '+' =>
		    x := x + y;
		    y := z;
		    z := t;

		when '-' =>
		    x := y - x;
		    y := z;
		    z := t;

		when '*' =>
		    x := x * y;
		    y := z;
		    z := t;

		when '/' =>
		    x := y / x;
		    y := z;
		    z := t;

		when '@' =>
		    x := -x;

		when ' ' =>
		    x := 0.0;
		    y := 0.0;
		    z := 0.0;
		    t := 0.0;

		when 'R' | 'r' =>
		    if x < 0.0 then
			error := true;
		    else
			x := sqrt(x);
		    end if;

		when 'S' | 's' =>
		    if x < -180.0 or x > 180.0 then
			error := true;
		    else
			x := sin(x);
		    end if;

		when 'C' | 'c' =>
		    if x < -180.0 or x > 180.0 then
			error := true;
		    else
			x := cos(x);
		    end if;

		when 'L' | 'l' =>
		    if x < 0.1 or x > 10.0 then
			error := true;
		    else
			x := ln(x);
		    end if;

		when 'E' | 'e' =>
		    if x < -5.0 or x > 22.0 then
			error := true;
		    else
			x := exp(x);
		    end if;

		when cr =>
		    roll_up;
		    x := 0.0;

		when others =>
		    null;		-- ignore bad characters

	end case;
	if not ((input >= '0' and input <= '9') or input = '.') then
	    roll_flag := input /= cr;
	    decimal_point := false;
	    power := 0.1;
	end if;

    end process;

begin

    put(clear_screen);
    display;
    new_line;
    put("+ : add           - : subtract");  new_line;
    put("* : multiply      / : divide");    new_line;
    put("s : sine          c : cosine");    new_line;
    put("l : ln            e : e^x");	    new_line;
    put("r : square root  sp : clear registers"); new_line;
    put("@ : +/-          cr : enter");     new_line;
    put("q : quit");	  new_line;
    new_line;

    loop
	if error then
	    put(beep);
	    error := false;
	    x := 0.0;
	end if;
	get(ch);			-- get input character
	exit when ch = 'q' or ch = 'Q'; -- check for exit condition
	put(back_space);put(' ');	-- erase it
	process(ch);			-- process it
	display;			-- re-display results
    end loop;
    put(clear_screen);

end ADA_CALCULATOR;
