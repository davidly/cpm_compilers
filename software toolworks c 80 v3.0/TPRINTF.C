/* printf.c: library file for format, fformat, and printf
 * compile: c -l32000
 * J. J. Gillogly, Apr 80
 * sprintf added J. J. Gillogly, Jul 80
 * Modified Jan 82 to work with #define kludge for multiple printf args
 * %u and unsigned octal and hex added WB Feb 82
 */

#undef printf
#undef fprintf
#undef sprintf
static int *prnt_p;	/* Pointer into printf arglist */
static char *Pf = "",	/* current location in user's format */
	    Pfo,	/* Channel number for output */
	    *Pst;	/* current location in user's output string */
static int Pr; /* precision */
static char Pad;
static int Rad, Neg, Uns;

prnt_1(firstarg) { prnt_p = &firstarg; }	/* Record arglist start */

prnt_2(lastarg) {
	format(*--prnt_p);			/* Process arglist */
#asm
@prnt@: DS 0
#endasm
	while (prnt_p > &lastarg) printf(*--prnt_p); }

prnt_3(lastarg) {
	Pfo = *--prnt_p;
	fformat(Pfo,*--prnt_p);
#asm
	JMP @prnt@
#endasm
}

prnt_4(lastarg) {
	Pst = *--prnt_p;
	sformat(Pst,*--prnt_p);
#asm
	JMP @prnt@
#endasm
}

format(form)
char *form;
{	fformat(0,form);
}

fformat(chan,form)
char chan,*form;
{	Pfo = chan;
	Pf = form;
	Ps();
}

sformat(string,form)	/* user wants data to go to a string */
char *string,*form;
{	Pst = string;
	fformat(-2,form);/* illegal value for a channel */
}

Ps()	/* output format up to next % */
{	while (*Pf != 0 && *Pf != '%')
		Pc(*Pf++);
}

Pc(c)
char c;
{	switch(Pfo)
	{   case 0: putchar(c); break;
	    case -2: *Pst++ = c;
		     *Pst = 0;	/* terminate each intermediate string */
		     break;
	    default: putc(c,Pfo); break;
	}
}

printf(arg)	/* print one arg using current format */
char *arg;
{	if (*Pf++ == 0) return; /* otherwise next char is % */
	for (Pr = 0; *Pf >= '0' && *Pf <= '9';) /* precision */
		Pr = 10*Pr + *Pf++ - '0';
	Pad = ' '; Rad = Uns = 10; Neg = 0;
	switch(*Pf++)
	{   case 'd': Uns = 0;	      /* decimal */
	    case 'u': On(arg); break; /* unsigned decimal */
	    case 'o': Pad = '0'; Rad = 8; On(arg); break; /* octal */
	    case 'x': Pad = '0'; Rad = 16; On(arg); break; /* hex */
	    case 'c': Pc(arg); break; /* single char */
	    case 's': while (*arg) { Pc(*arg++); --Pr; }
		      Pd(' ');
		      break;	/* left-adjusted strings only */
	}
	Ps();
}

Od(n)	/* output digit: hex, octal, or decimal */
int n;
{	Pc(n < 10? n+'0' : 'A'+n-10);
}

Pd()
{	while (--Pr >= 0) Pc(Pad);
}

On(num)
register unsigned num;
{	Pr--;
	/* if negative, don't output the - yet, but save it for end */
	if (Uns == 0) if (num & 0100000) {Pr--; num = -num; Neg = 1; }
	if (num < Rad && num >= 0)
	{	Pd();
		if (Neg) Pc('-');
		Od(num);
	}
	else
	{	On(Rad==8?  num>>3:
		   Rad==10? num/10 :
			    num>>4);
		Od(Rad==10? num % 10 : num & (Rad-1));
	}
}
/* Definitions for printf and fprintf to allow multiple args. */

#define printf prnt_1(),prnt_2
#define fprintf prnt_1(),prnt_3
#define sprintf prnt_1(),prnt_4
