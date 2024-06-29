procedure TOWERS_OF_HANOI is

number_of_disks : integer;

procedure writeln(A : string) is	-- output a string followed by crlf
	begin
		put(A);
		new_line;
	end writeln;

procedure MOVE (N : integer; source, auxiliary, destination : integer) is

	procedure move_a_disk_from_source_to_destination is

		procedure print_pole (P : integer) is
			begin
				put("pole ");
				put(P);
			end print_pole;

		begin
			put("Move a disk from ");
			print_pole(source);
			put(" to ");
			print_pole(destination);
			new_line;
		end move_a_disk_from_source_to_destination;

	begin
		if n=1 then
			move_a_disk_from_source_to_destination;
		else
			move(n-1, source, destination, auxiliary);
			move_a_disk_from_source_to_destination;
			move(n-1, auxiliary, source, destination);
		end if;
	end move;

begin

-- instructions

    writeln("This program solves the legendary ""Towers of Hanoi"" ");
    writeln("problem, given any number of disks.  You are given three");
    writeln("wooden poles.  A stack of n disks of decreasing size (such");
    writeln("that the largest disk is on the bottom) is held on the");
    writeln("first pole by holes in the center of each disk.  The");
    writeln("problem is to move all of the disks from the first pole");
    writeln("to the third pole, only moving one disk from pole to pole");
    writeln("at a time and ensuring that a larger disk is not placed on");
    writeln("top of a smaller one.");new_line;

-- input # of disks and solve

	put("How many disks on pole 1? ");
	get(number_of_disks);new_line;

	while number_of_disks > 10 or number_of_disks < 1 loop
		if number_of_disks > 10 then
			put("Too many disks, try again: ");
			else
			put("Must be positive number, try again: ");
			end if;
		get(number_of_disks);
		end loop;

	writeln("The required moves are:");
	move(number_of_disks,1,2,3);new_line;

	put("All disks are on pole 3.");

end TOWERS_OF_HANOI;
