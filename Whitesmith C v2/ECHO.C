#include <std.h>

/*	ECHO ARGUMENTS TO STDOUT
 *	copyright 1978 by Whitesmiths, Ltd.
 */
BOOL main(ac, av)
	COUNT ac;
	TEXT **av;
	{
	FAST COUNT n, ns, nw;

	if (++av, --ac <= 0)
		return (YES);
	else
		{
		ns = lenstr(*av);
		nw = write(STDOUT, *av, ns);
		while (++av, --ac)
			{
			n = lenstr(*av);
			ns =+ 1 + n;
			nw =+ write(STDOUT, " ", 1);
			nw =+ write(STDOUT, *av, n);
			}
		nw =+ write(STDOUT, "\n", 1);
		return (nw == ns + 1);
		}
	}
