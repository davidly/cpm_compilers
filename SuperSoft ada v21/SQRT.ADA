procedure TEST_SQUARE_ROOT is

-- demonstrate overloaded function SQRT

function SQRT(A : integer) return integer is
c,s : integer;
begin
	s := 1;
	c := 3;
	while s <= A loop
		s := s + c;
		c := c + 2;
	end loop;
	return c / 2 - 1;
end SQRT;

function SQRT(A : float) return float is
guess, delt : float;
x1, x2, x3 :  float;
begin
	if A = 0.0 then
		return 0.0;	  -- sqrt(0)=0
	elsif A = 1.0 then
		return 1.0;	  -- sqrt(1)=1
	else
		guess := a / 2.0;
		delt := 1.0;
		while guess ** 2 > a loop
			guess := guess / 2.0;
		end loop;

		while abs(guess ** 2 - a) > 0.0001 loop
			while (guess + delt) ** 2 > a loop
			if delt < 0.000001 then
					return guess;
				end if;
				delt := delt / 2.0;
			end loop;
			guess := guess + delt;
		end loop;
		return guess;
	end if;
end SQRT;

-- this program demonstrates subprogram overloading (sqrt)

begin
	for i in 0..20 loop
		put("The square root of ");
		put(i);
		put(" is ");
		put(sqrt(i));
		put(", ");
		put(sqrt(float(i)));
		put(" in floating point.");
		new_line;
	end loop;
	new_line;
	put("End square root demo.");
end;
