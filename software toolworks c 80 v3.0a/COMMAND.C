/* command: expand wild cards in the command line.  (7/25/83)
 * usage: command(&argc, &argv) modifies argc and argv as necessary
 * uses sbrk to create the new arg list
 * NOTE: requires makfcb() and bdos() from file stdlib.c.  When used
 *	with a linker and stdlib.rel, remove the #include stdlib.c.
 *
 * Written by Dr. Jim Gillogly; Modified for CP/M by Walt Bilofsky.
 */

#define MAXFILES 255	/* max number of expanded files */
#define FNSIZE 15	/* filename: 2(A:)+8+1+3+null */

int COMnf,*COMfn,COMc,*COMv;
char *COMarg,*COMs;
static expand();

command(argcp,argvp)
int *argcp,*argvp;
{
	int f_alloc[MAXFILES];

	COMfn = f_alloc;
	COMc = *argcp;
	COMv = *argvp;
	COMfn[0] = *COMv++;		     /* Don't expand first one */
	COMnf = 1;
	for (COMarg = *COMv; --COMc; COMarg = *++COMv)
	{	for (COMs = COMarg; *COMs; COMs++)
			if (*COMs == '?' || *COMs == '*')
			{	expand();
				goto contn;  /* expand each name at most once */
			}
		COMfn[COMnf++] = COMarg;     /* no expansion */
	    contn:;
	}
	*argcp = COMnf;
	COMfn[COMnf++] = -1;
	COMv = *argvp = sbrk(2 * COMnf);
	while (COMnf--) COMv[COMnf] = COMfn[COMnf];
}

static expand() {
	char fcb[36];
	static char *p,*q;
	static int i,flg;
	makfcb(COMarg,fcb);
	if (fcb[0] == -1) fcb[0] = '?'; 	/* Check for all users */
	for (i = flg = 1; i <= 11; ++i) {	/* Expand *'s */
		if (i == 9) flg = 1;
		if (fcb[i] == '*') flg = 0;
		if (flg == 0) fcb[i] = '?'; }
	flg = 17;
	bdos(26,0x80);				/* Make sure DMA address OK */
	while ((i = bdos(flg,fcb)) != -1) {
		COMfn[COMnf++] = q = sbrk(FNSIZE);
		if (COMnf >= MAXFILES-1) {
			for (p = "Too many file names.\n"; putchar(*p++); );
			exit(0); }
		p = 0x81 + i * 32;		/* Where to find dir. record */
		if (COMarg[1] == ':' && COMarg[0] != '?') {
			*q++ = COMarg[0]; *q++ = ':'; }
		for (i = 12; --i; ) {
			if (i == 3) *q++ = '.';
			if ((*q = *p++ & 0177) != ' ') ++q; }
		*q = 0;
		flg = 18;
	}	}

#include "stdlib.c"		/* Remove this if using linker and stdlib.rel */



8;