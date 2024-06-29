/*      ECHO ARGUMENTS TO STDOUT
 *      copyright (c) 1980 by Whitesmiths, Ltd.
 */
#include <std.h>

/*      flags:
        -m              output newline between arguments
        -n              do not put newline at end of arguments
 */
BOOL mflag {NO};
BOOL nflag {NO};

TEXT *_pname {"echo"};

/*      output args separated by space or newline
 */
BOOL main(ac, av)
        BYTES ac;
        TEXT **av;
        {
        IMPORT BOOL mflag, nflag;
        FAST COUNT n, ns, nw;
        TEXT *q, between;

        getflags(&ac, &av, "m,n:F <args>", &mflag, &nflag);
        if (!ac)
                return (YES);
        between = mflag ? '\n' : ' ';
        for (nw = write(STDOUT, *av, (ns = lenstr(*av))), --ac, ++av; ac;
                --ac, ++av)
                {
                nw =+ write(STDOUT, &between, 1);
                nw =+ write(STDOUT, *av, (n = lenstr(*av)));
                ns =+ 1 + n;
                }
        nw =+ write(STDOUT, "\n", !nflag);
        return (nw == ns + !nflag);
        }
