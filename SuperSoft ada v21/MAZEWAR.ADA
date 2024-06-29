procedure MAZE_WAR is

    clear_screen : constant integer := 26;
    maze : array (1..14) of string(1..55);	-- the maze itself
    user_symbol : constant character := '^';
    x_pos : integer;
    y_pos : integer;
    treasure : boolean;
    t_x_pos : integer;
    t_y_pos : integer;
    score : integer;
    timer : integer;
    timer2 : integer;
    guards : array(1..4,1..3) of integer;
    next_guard : integer := 1;
    game : boolean := true;

    procedure POSITION_CURSOR(x,y : integer) is
	begin
	    put(character'val(27)); 	-- escape
	    put('=');			-- =
	    put(character'val(y+31));	-- Y
	    put(character'val(x+31));	-- X
	end POSITION_CURSOR;

    function RAND(A : integer) return integer is
	function truncate(A : float) return integer is
	    B : integer := integer(A);
	    begin
		if float(B) > A then
		    return B - 1;
		else
		    return B;
		end if;
	    end truncate;
	begin
	    return truncate(rnd(0.0) * float(A)) + 1;
	end RAND;

    procedure WRITELN(input : string) is
	begin
	    put(input);
	    new_line;
	end WRITELN;

    procedure PRINT_MAZE is
	begin
	    put(character'val(clear_screen));
	    for i in 1..14 loop
		writeln(maze(i));
	    end loop;
		put("Score:                                      Time:      ");
	end PRINT_MAZE;

    procedure ADD_SCORE(delt : integer) is
	begin
	    score := score + delt;
	    position_cursor(8,15);
	    put(score);
	    position_cursor(1,16);
	end ADD_SCORE;

    procedure DISPLAY(symbol : character; x,y : integer) is
	begin
	    position_cursor(x,y);
	    put(symbol);
	    position_cursor(1,16);	-- return cursor to prompt input
	end DISPLAY;

    procedure LOSE_TREASURE is
	begin
	    maze(t_y_pos)(t_x_pos) := ' ';
	    display(' ',t_x_pos,t_y_pos);
	    t_x_pos := 2;
	    t_y_pos := 2;
	    treasure := false;
	end LOSE_TREASURE;

    procedure INITIALIZE is
	begin
	    maze(1):="*******************************************************";
	    maze(2):="*                                                     *";
	    maze(3):="*  +  +---+---+-+                    +-+---+---+  +   *";
	    maze(4):="*  |                                              |   *";
	    maze(5):="*  |                                              |   *";
	    maze(6):="*  +----+---+---+                    +---+---+----+   *";
	    maze(7):="*               |                    |                *";
	    maze(8):="*               |                    |                *";
	    maze(9):="*  +------+     |                    |     +------+   *";
	   maze(10):="*  |            |                    |            |   *";
	   maze(11):="*  |            |                    |            |   *";
	   maze(12):="*  +------+     +                    +     +------+   *";
	   maze(13):="*                                                     *";
	   maze(14):="*******************************************************";

	    guards(1,1) := 2;
	    guards(1,2) := 2;
	    guards(1,3) := 1;

	    guards(2,1) := 54;
	    guards(2,2) := 2;
	    guards(2,3) := 2;

	    guards(3,1) := 54;
	    guards(3,2) := 13;
	    guards(3,3) := 3;

	    guards(4,1) := 2;
	    guards(4,2) := 13;
	    guards(4,3) := 4;

	    x_pos := rand(55);
	    y_pos := rand(14);
	    while maze(y_pos)(x_pos) /= ' ' loop
		x_pos := rand(55);
		y_pos := rand(14);
	    end loop;

	    print_maze;
	    display(user_symbol,x_pos,y_pos);
	    score := 0;
	    timer := 0;
	    timer2 := 0;
	    treasure := false;
	    t_x_pos := 2;
	    t_y_pos := 2;
	    add_score(0);
	    position_cursor(51,15);
	    put(timer);

    end INITIALIZE;

    procedure END_GAME is
	ch : character;
	flag : boolean := true;
	begin
	    position_cursor(1,16);
	    put("The game has ended.  Do you want to play again? ");
	    while flag loop
		get(ch);
		if ch = 'Y' or ch = 'y' then
		    initialize;
		    flag := false;
		elsif ch = 'N' or ch = 'n' then
		    bdos(0);
		end if;
	    end loop;
	end END_GAME;

    procedure USER_INPUT is
	moved : boolean := false;
	x : integer := x_pos;
	y : integer := y_pos;
	input : character;
	begin
	    input := character'val(bdos(1));	-- obtain user keystroke
	    display(' ',1,16);			-- erase user input
	    timer2 := timer2 + 35;		-- compensate timer
	    case input is
		when 'U' | '8' =>
		    if y_pos /= 2 and maze(y_pos-1)(x_pos) = ' ' then
			    y_pos := y_pos - 1;
			    moved := true;
		    end if;
		when 'M' | '2' =>
		    if y_pos /= 13 and maze(y_pos+1)(x_pos) = ' ' then
			    y_pos := y_pos + 1;
			    moved := true;
		    end if;
		when 'H' | '4' =>
		    if x_pos /= 2 and maze(y_pos)(x_pos-1) = ' ' then
			    x_pos := x_pos - 1;
			    moved := true;
		    end if;
		when 'K' | '6' =>
		    if x_pos /= 54 and maze(y_pos)(x_pos+1) = ' ' then
			    x_pos := x_pos + 1;
			    moved := true;
		    end if;
		when character'val(3) | 'Q' | 'q' =>
		    end_game;
	    end case;
	    if moved then
		for i in y_pos-1..y_pos+1 loop
		    for j in x_pos-1..x_pos+1 loop
			if maze(i)(j) = '$' then
			    lose_treasure;
			    add_score(100);
			end if;
		    end loop;
		end loop;
		maze(y)(x) := ' ';
		display(' ',x,y);
		maze(y_pos)(x_pos) := user_symbol;
		display(user_symbol,x_pos,y_pos);
	    end if;
	end USER_INPUT;

    procedure MOVE_GUARDS is
	x,y,d : integer;
	begin
	    x := guards(next_guard,1);
	    y := guards(next_guard,2);
	    d := guards(next_guard,3);

	    timer2 := timer2 + 150;
	    display(' ',x,y);	-- erase this guard
	    maze(y)(x) := ' ';

	    case d is	  -- switch on direction of guard i
		when 1 =>
		    if x = 54 or (x > 17 and x < 38 and rand(9) = 1) then
			guards(next_guard,3) := 2;
		    else
			guards(next_guard,1) := x + 1;
		    end if;
		when 2 =>
		    if y = 13 then
			guards(next_guard,3) := 3;
		    else
			guards(next_guard,2) := y + 1;
		    end if;
		when 3 =>
		    if x = 2 or (x > 17 and x < 38 and rand(9) = 1) then
			guards(next_guard,3) := 4;
		    else
			guards(next_guard,1) := x - 1;
		    end if;
		when 4 =>
		    if y = 2 then
			guards(next_guard,3) := 1;
		    else
			guards(next_guard,2) := y - 1;
		    end if;
	    end case;
      if guards(next_guard,1) = t_x_pos and guards(next_guard,2) = t_y_pos then
		lose_treasure;
	    end if;
	  if guards(next_guard,1) = x_pos and guards(next_guard,2) = y_pos then
		end_game;
	    else
		maze(guards(next_guard,2))(guards(next_guard,1)) := 'X';
		display('X',guards(next_guard,1),guards(next_guard,2));
	    end if;
	    next_guard := (next_guard rem 4) + 1;
	end MOVE_GUARDS;

begin		-- MAZE WAR!

    initialize;

    while game loop
	timer2 := timer2 + 1;
	while timer2 > 800 loop
	    timer2 := timer2 - 800;
	    timer := timer + 1;
	    add_score(1);
	    if timer = 100 then
		end_game;
	    end if;
	    position_cursor(51,15);
	    put(timer);
	    position_cursor(1,16);
	end loop;
	if timer2 rem 2 = 0 then
	    move_guards;
	end if;
	if bdos(11) /= 0 then
	    user_input;
	    move_guards;
	end if;
	if rand(75) = 1 then
	    if not treasure then
		treasure := true;
		t_x_pos := rand(55);
		t_y_pos := rand(14);
		while maze(t_y_pos)(t_x_pos) /= ' ' loop
		    t_x_pos := rand(55);
		    t_y_pos := rand(14);
		end loop;
		maze(t_y_pos)(t_x_pos) := '$';
		display('$',t_x_pos,t_y_pos);
	    else
		if rand(25) = 1 then
		    lose_treasure;
		end if;
	    end if;
	end if;
    end loop;

end MAZE_WAR;
