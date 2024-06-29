procedure FACT is

number : integer;

function FACTORIAL (A : in integer) return integer is
	begin					--compute factorial of A
		if A = 0 or A = 1 then
			return 1;		-- 0! = 1! = 1
		else
			return A*FACTORIAL(A-1);     -- n! = n * (n-1)!
		end if;
	end FACTORIAL;

function FACTORIAL (A : in integer) return float is
	begin
		if A = 0 or A = 0 then
			return 1.0;
		else
			return float(A) * FACTORIAL(A-1);
		end if;
	end FACTORIAL;

begin
	fact_loop:
	loop
		new_line;
		put("Input an integer (control-c to exit) : ");
		get(number);
		if number >= 0 and number < 8 then
			put(number);put("! = ");
			put(factorial(number));
		elsif number < 0 then
			put("Factorial of negative number is undefined");
		elsif number < 35 then
			put(number);put("! = ");
			put(float'(factorial(number)));
		else
			put("Number is too large for factorial");
		end if;
		new_line;
	end loop fact_loop;
end FACT;
