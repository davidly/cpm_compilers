pragma print(a_code);
procedure FOR_LOOP_CHECK is

test_string : string(1..45) := "This demonstrates a few string manipulations!";

procedure wait is
begin
	for i in 1..3 loop
		null;			--waste some time....
	end loop;
end wait;

begin

-- first print the line out character at a time, bouncing the
-- cursor back and forth from column 50.

	for i in 1..45 loop		--length of test_string

-- move cursor out to column 50

		for j in 1..50-i loop
			put(' ');
			wait;
		end loop;

-- move cursor back to column i

		for j in 1..50-i loop
			put(character'val(8));
			wait;
		end loop;

-- print a character from the test string

		put(test_string(i));

	end loop;		-- end of this line

	new_line;

-- now print the line backwards

	for i in reverse 45..1 loop
		put(test_string(i));
	end loop;
	new_line;

end;
