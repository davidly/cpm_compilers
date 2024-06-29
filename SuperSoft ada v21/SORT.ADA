procedure sort_demo is

	n : integer;

	type sort_array is array(integer range <>) of float;

	procedure sort is

		a : sort_array(1..n);
		which_sort : character;

		procedure swap(a,b : in out float) is
			temp : float;
		begin
			temp := a;
			a := b;
			b := temp;
		end swap;

		procedure print(ary : sort_array) is
		begin
			new_line;
			for i in ary'first..ary'last loop
				put(ary(i)); put(' ');
				if i rem 4 = 0 then
					new_line;
				else
					put("    ");
				end if;
			end loop;
		end print;

		procedure randomize(ary : in out sort_array) is
		begin
			for i in ary'first..ary'last loop
				ary(i) := rnd(0.0);
			end loop;
		end randomize;

		procedure bubble_sort(a : in out sort_array) is
			done : boolean;
		begin
			loop
				done := true;
				for i in a'first..a'last-1 loop
					if a(i) > a(i+1) then
						swap(a(i),a(i+1));
						done := false;
					end if;
				end loop;
				exit when done;
			end loop;
		end bubble_sort;

		procedure shell_sort(a : in out sort_array) is
			done : boolean;
			jump : integer;
		begin
			jump := a'length;
			while jump > a'first loop
				jump := jump/2;
				loop
					done := true;
					for j in a'first..a'length-jump loop
						declare
							i : integer := j+jump;
						begin
							if a(j)>a(i) then
								swap(a(j),a(i));
								done := false;
							end if;
						end;
					end loop;
					exit when done;
				end loop;
			end loop;
		end shell_sort;

	procedure quick_sort(a : in out sort_array; m,n: integer) is

		x,y : integer;

		procedure part_array    (a : in out sort_array;
					 i,j: in out integer;
					 left,right : integer) is
			pivot : float := a((left+right)/2);
		begin
			i := left;
			j := right;
			while i <= j loop
				while a(i) < pivot loop
					i := i+1;
				end loop;
				while pivot < a(j) loop
					j := j-1;
				end loop;
				if i <= j then
					swap(a(i),a(j));
					i := i+1;
					j := j-1;
				end if;
			end loop;
		end part_array;
	begin
		if m < n then
			part_array(a,x,y,m,n);
			quick_sort(a,m,y);
			quick_sort(a,x,n);
		end if;
	end quick_sort;

	begin
		randomize(a);
		put("Unsorted array:");
		print(a);
		put("Bubble, Shell, Quick: ");
		get(which_sort); new_line;
		put(character'val(7)); put("Start ");
		case which_sort is
			when 'B' ! 'b' =>
				put("bubble sort...");
				bubble_sort(a);
			when 'S' ! 's' =>
				put("shell-metzner sort...");
				shell_sort(a);
			when others =>
				put("quicksort...");
				quick_sort(a,a'first,a'last);
		end case;
		put(character'val(7));
		put("Done."); new_line;
		put("Sorted array:");
		print(a);
	end sort;

begin
	loop
		put("Number of points (0 to exit): ");
		get(n);
		exit when n = 0;
		sort;
	end loop;
end sort_demo;
