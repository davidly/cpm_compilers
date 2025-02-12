procedure STAR_TREK is

energy : integer := 4000;
torpedoes : integer := 10;
star_date : integer := 3421;
klingons : integer;
total_klingons : integer;			-- # klingons in galaxy
star_bases : integer;				-- # starbases in galaxy
x_sector,y_sector : integer;			-- position of Enterprise
x_quadrant,y_quadrant : integer;		-- position of Enterprise
condition : string(1..6) := "Green ";
damage : array(1..6) of integer;
x,y : integer;
max_klingons : constant integer := 4;
x_klingon, y_klingon, power_klingon : array(1..max_klingons) of integer;
sectors : array(0..7,0..7) of character;
quadrants : array(0..7,0..7) of integer;
command : integer;
moved, docked : boolean := false;

function rand(A : integer) return integer is
    function truncate(A : float) return integer is
	b : integer := integer(A);
	begin
	    if real(b) < a then return b; else return b-1; end if;
	end truncate;
begin
	return truncate(rnd(0.0) * real(a));
end rand;

function distance(i,j,x,y : integer) return integer is
a,b : integer;

function sqrt(a : integer) return integer is
begin
	if a=0 then return 0;
	elsif a=1 then return 1;
	else
		for guess in 2..256 loop
			if guess**2 = a or (guess+1)**2 > a then
				return guess;
			end if;
		end loop;
	end if;
end sqrt;

begin					-- distance
	a := i - x;
	b := j - y;
	return sqrt(a ** 2 + b ** 2) + 1;
end distance;

procedure get_blank_sector is
begin
	x := rand(7);
	y := rand(7);
	if sectors(x,y) /= '.' then
		get_blank_sector;
	end if;
end get_blank_sector;

procedure reset is	-- reset all enterprise variables
begin
	newline;
	energy := 4000;
	torpedoes := 10;
	for i in 1..6 loop
		damage(i) := 0;
	end loop;
	condition := "Green ";
end reset;

procedure dock is	-- dock the enterprise at a starbase
begin
	reset;
	docked := true;
	condition := "Docked";
end dock;

function unexplored(A,B : integer) return boolean is
begin
	if quadrants(a,b) < 0 then
		return true;
	else
		return false;
	end if;
end unexplored;

procedure initialize is
begin
	put("Please wait while I create the universe");newline;
	put("(Even God took seven days...)");newline;
	reset;
	x_quadrant := rand(7);
	y_quadrant := rand(7);
	star_date := 3421;
	total_klingons := 0;
	star_bases := 0;
	for i in 0..7 loop
		for j in 0..7 loop
			declare
				n : integer := 1;
				o : integer;
			begin
			      o := rand(max_klingons+1);   -- get rand # klingons
				total_klingons := total_klingons + o;
				n := n + o * 100;
				n := n + rand(8);-- get rand # stars
				if rand(8)=1 then
					n := n + 10;
					star_bases := star_bases + 1;
				end if;
				quadrants(i,j) := -n;
			end;
		end loop;
	end loop;
end initialize;

procedure set_up_quadrant is
begin
	for i in 0..7 loop
		for j in 0..7 loop
			sectors(i,j) := '.';
		end loop;
	end loop;

	x_sector := rand(7);
	y_sector := rand(7);
	sectors(x_sector,y_sector) := 'E';

	if abs(quadrants(x_quadrant,y_quadrant)) mod 100 > 9 then
		get_blank_sector;
		sectors(x,y) := 'B';
	end if;

	if abs(quadrants(x_quadrant,y_quadrant)) >= 100 then
		declare
			i : integer :=
				     abs(quadrants(x_quadrant,y_quadrant))/100;
		begin
			for j in 1..i loop
				get_blank_sector;
				sectors(x,y) := 'K';
				x_klingon(j) := x;
				y_klingon(j) := y;
				power_klingon(j) := rand(20) * 10 + rand(20) + 5;
			end loop;
			klingons := i;
		end;
	else
		klingons := 0;
	end if;

	if abs(quadrants(x_quadrant,y_quadrant)) mod 10 > 0 then
		declare
			i : integer :=
				  abs(quadrants(x_quadrant,y_quadrant)) mod 10;
		begin
			for j in 1..i loop
				get_blank_sector;
				sectors(x,y) := '*';
			end loop;
		end;
	end if;
end set_up_quadrant;

procedure attacked is
begin
	if klingons /= 0 then
		for i in 1..klingons loop
			declare
				j : integer;
			begin
				j := power_klingon(i) / 
			 distance(x_klingon(i),y_klingon(i),x_sector,y_sector);
				put(j);
				put(character(9));
				put("unit hit from Klingon at ");
				put(x_klingon(i)+1);
				put(',');
				put(y_klingon(i)+1);
				put(" (");
				put(power_klingon(i));
				put(')');
				newline;
				energy := energy - j;
			end;
		end loop;
	end if;
end attacked;

procedure commands is

procedure short_range_scan is
begin

-- set starship condition

	if klingons > 0 then
		condition := "Red   ";
	elsif docked then
		dock;
	elsif energy < 300 then
		condition := "Yellow";
	else
		condition := "Green ";
	end if;

-- print quadrant map

	for i in 0..7 loop
		for j in 0..7 loop	-- print a row of quadrant
			put(sectors(i,j)); put(' ');
		end loop;
		put("    ");

-- print a line of starship information

	    case i is
		when 1 =>
			put("Stardate=");put(star_date);newline;
		when 2 =>
			put("Condition: ");
			put(condition);
			newline;
		when 3 =>
			put("Quadrant=");
			put(x_quadrant+1);put(",");
			put(y_quadrant+1);newline;
		when 4 =>
			put("Sector=");
			put(x_sector+1);put(",");
			put(y_sector+1);newline;
		when 5 =>
			put("Energy=");put(energy);newline;
		when 7 =>
			put("Klingons left=");put(total_klingons);newline;
		when others =>
			newline;
	    end case;
	end loop;
end short_range_scan;

procedure long_range_scan is

procedure display(number : integer) is

procedure dispnum(number : integer) is
begin
	if number = 0 then
		put('-');
	else
		put(number);
	end if;
end dispnum;

begin
	dispnum(number/100);
	dispnum((number/10) rem 10);
	dispnum(number rem 10);
end display;

begin
	put("            Long range scan");
	newline;
	for i in 0..7 loop
		for j in 0..7 loop
		      if abs(i-x_quadrant) =< 1 and abs(j-y_quadrant) =< 1 then
				quadrants(i,j) := abs(quadrants(i,j));
			end if;
			if unexplored(i,j) then
				put("***");
			elsif i = x_quadrant and j = y_quadrant then
				put(" E ");
			else
				display(quadrants(i,j));
			end if;
			put(' ');
		end loop;
		newline;
	end loop;
end long_range_scan;

procedure phasors is
units : integer;
aux : integer;
length : integer;
begin
	put("Number of units to fire? ");
	get(units);
	energy := energy - units;
	while units > 0 and klingons /= 0 loop
		aux := power_klingon(klingons);
		length := distance(x_klingon(klingons),y_klingon(klingons),
			     x_sector,y_sector);
		if length /= 0 then
			aux := aux * length;
		end if;

	-- aux has relative power needed to destroy klingon

		if units >= aux then		-- more than enough to kill
			units := units - aux;
			put("Klingon at ");
			put(x_klingon(klingons)+1);
			put(',');
			put(y_klingon(klingons)+1);
			put(" destroyed!!!");
			sectors(x_klingon(klingons),y_klingon(klingons)) := '.';			klingons := klingons - 1;
			quadrants(x_quadrant,y_quadrant) :=
					quadrants(x_quadrant,y_quadrant) - 100;
			total_klingons := total_klingons - 1;
			newline;
		else			-- subtract what we threw at it...
			power_klingon(klingons) :=power_klingon(klingons) - 
				units / length;
			put(units / length);
			put(" unit hit on Klingon at ");
			put(x_klingon(klingons)+1);
			put(',');
			put(y_klingon(klingons)+1);
			newline;
			units := 0;
		end if;
	end loop;
end phasors;

procedure navigate is
type_of_propulsion : character;
x, y : integer;

procedure get_x_y is
begin
	put("New x co-ordinate: ");
	get(x);
	put("New y co-ordinate: ");
	get(y);
	if x<1 or x>8 or y<1 or y>8 then
		put("Invalid co-ordinates, try again!");newline;
		get_x_y;
	end if;
	x := x - 1; y := y -1;
end get_x_y;

procedure new_sector is
begin
	get_x_y;
	if sectors(x,y) = '.' then
		sectors(x,y) := 'E';
		sectors(x_sector,y_sector) := '.';
		energy := energy - distance(x,y,x_sector,y_sector);
		x_sector := x;
		y_sector := y;
	else
		put("That sector is not empty, try again!");newline;
		new_sector;
	end if;
end new_sector;

procedure check_docked is
begin
	docked := false;
	for i in x_sector-1..x_sector+1 loop
		for j in y_sector-1..y_sector+1 loop
			if sectors(i,j) = 'B' then
				docked := true;
			end if;
		end loop;
	end loop;
	if docked then dock; end if;
end check_docked;

begin
	put("Impulse (I) or Warp (W) power? ");
	get(type_of_propulsion);newline;
	docked := false;

	if type_of_propulsion = 'W' or type_of_propulsion = 'w' then
		get_x_y;
		moved := true;
		energy := energy - distance(x_quadrant,y_quadrant,x,y) * 100;
		x_quadrant := x;
		y_quadrant := y;
	else
		new_sector;
		short_range_scan;
	end if;
	check_docked;
end navigate;

begin			-- commands
	command := 0;
	attacked;		-- Enterprise is attacked immediately
	short_range_scan;	-- show the captain what he is up against

	while not moved and energy > 0 and total_klingons /= 0 loop
	    put("Command? ");
	    get(command);
	    case command is
		when 0 =>
			long_range_scan;
		when 1 =>
			short_range_scan;
		when 2 =>
			phasors;
			attacked;
			short_range_scan;
		when 3 =>
			navigate;
		when others =>			-- menu if bad command
			put("0 - long range scan");newline;
			put("1 - short range scan");newline;
			put("2 - phasors");newline;
			put("3 - navigate");newline;
	    end case;
	end loop;
end commands;

begin					-- main startrek program
	initialize;
	while energy > 0 loop
		moved := false; 	-- say we haven't moved out yet
		set_up_quadrant;	-- initialize the quadrant
		commands;
	end loop;

	if total_klingons = 0 then
		if energy > 0 then
			put("Congratulations, you have saved the Federation");
			newline;
			put("and have been promoted to Admiral.");newline;
		else
			put("You have destroyed the klingon manace and have");
			newline;
			put("killed yourself in the process.  A statue will");
			newline;
			put("erected in your honor.  Rest in peace and try");
			newline;
			put("not to think of the pidgeons.");
			newline;
		end if;
	elsif energy <= 0 then
		put("You have been destroyed and the empire has been");
		newline;
		put("taken over by Klingons.  Better luck next time.");
		newline;
	else
		put("Time has run out.  The Klingons have invaded");
		newline;
		put("en masse and wiped out the Federation.");
	end if;

end STAR_TREK;
 out.  The Klingons have invaded");
		newline;
		put("en masse and wiped out the Federation.");
	end if;

end STAR_TREK;