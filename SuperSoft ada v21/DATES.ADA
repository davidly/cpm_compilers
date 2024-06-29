procedure dates is

type month is  (January, February, March,
		April, May, June,
		July, August, September,
		October, November, December);

type date is
	record
		m : month;
		day : integer;
		year : integer;
	end record;

i : integer;
day : date;
days_in_month : integer;

procedure write_date(d : date) is
begin
	put(month'pos(d.m)+1); put('/');
	put(d.day);put('/');
	put(d.year);
end write_date;

begin
	put("Month: ");get(i);day.m := month'val(i-1);
	put("Day: ");get(day.day);
	put("Year: ");get(day.year);
	put("The day following ");write_date(day);put(" is ");

	case day.m is
		when February =>
			if day.year mod 4 = 0 and day.year /= 1900 then
				days_in_month := 29;
			else
				days_in_month := 28;
			end if;
		when March | June | September | November =>
			days_in_month := 30;
		when others =>
			days_in_month := 31;
	end case;

	if day.day = days_in_month then
		day.day := 1;
		if day.m = December then
			day.m := January;
			day.year := day.year+1;
		else
			day.m := month'val(month'pos(day.m) + 1);
		end if;
	else
		day.day := day.day + 1;
	end if;

	write_date(day); new_line;

end dates;
