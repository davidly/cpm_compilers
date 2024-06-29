/* printf.c: library file for format, fformat, and printf
 * compile: c -l32000
 * J. J. Gillogly, Apr 80
 * sprintf added J. J. Gillogly, Jul 80
 * Modified Jan 82 to work with #define kludge for multiple printf args
 * %u and unsigned octal and hex added WB Feb 82
 * long and floating descriptors added HT Apr 83
 * Split for float/nonfloat and long/nonlong versions WB 5/25/83.
 * Fix floating precision default, %3c, %% WB 11/15/83.
 */

#undef printf
#undef fprintf
#undef sprintf

static int *prnt_p;	/* Pointer into printf arglist */
static char *Pf = "",	/* current location in user's format */
	    Pfo,	/* Channel number for output */
	    *Pst;	/* current location in user's output string */
static int Width;	/* minimum field width */
static int Pr;		/* precision */
static int ch;		/* really char but int is more efficient */
static char Pad;
static int ljust;	/* left-adjust flag */
static char *nbp,*nbpe; /* pointer to ascii converted number */

/* define functions to reduce entry points */
static Ps(),Pc(),getnum(),putsi(),putui(),putfld(),putpad(),hexdig();
static char *ocvti();

#define int_typ int
#define uns_typ unsigned

#define NBS 80

/* prnt_1 is used to mark the position of
   the printf argument list on the stack.
   Visually, the arguments, starting with the format string, will
   be stacked right below the marked position (prnt_p). The
   stacked arguments are values !!! (16- or 32-bits)
*/
prnt_1(firstarg) { prnt_p = &firstarg; }	/* Record arglist start */

prnt_2(lastarg) {
	format (*--prnt_p);			/* Process arglist */

#asm
@prnt@: DS	0
#endasm

/* now we are going to print the values. Instead of passing to printf
   the value to print (of unknown type), we pass the current pointer
   to the argument list. It is the responsibility of "printf" to
   retrieve the value physically located at prnt_p - 2 (if 16-bit) or
   prnt_p - 4 (if 32-bit). "printf" must also update prnt_p accordingly.
*/
	while (prnt_p > &lastarg) printf(prnt_p); }

prnt_3(lastarg) {
	Pfo = *--prnt_p;	
	fformat(Pfo,*--prnt_p);

#asm
	JMP	@prnt@
#endasm
/*	while (prnt_p > &lastarg) printf(prnt_p);	*/
}

prnt_4(lastarg) {	
	Pst = *--prnt_p;
	sformat(Pst,*--prnt_p);

#asm
	JMP	@prnt@
#endasm
/*	while (prnt_p > &lastarg) printf(prnt_p);	*/
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

static Ps()    /* output format up to next % */
{	while (*Pf != 0 && *Pf != '%') Pc(*Pf++);
}

static Pc(c)
char c;
{	switch(Pfo)
	{   case 0: putchar(c); return;
	    case -2: *Pst++ = c;
		     *Pst = 0;	/* terminate each intermediate string */
		     return;
	    default: putc(c,Pfo);
	}
}

printf(arg)	/* print one arg using current format */
union {
	int *ival;
	} arg;
	{
		static int racine,realPr;
		static unsigned int uarg;
		static char *ptr,*end;

		arg.ival = prnt_p ;
		prnt_p -= 1;	/* update assuming a 16-bit value to print */
	again:	racine = Pr = 0;
		realPr = -1;

		if ((ch = *++Pf) == 0) return;
		Pad = ' ';
		if (ljust = (ch == '-')) ch = *Pf++;
		if (ch == '0') { Pad = '0'; ch = *Pf++; }
		Width = getnum();
		if (ch == '.') { ++Pf ; realPr = Pr = getnum(); }
		if ((ch = *Pf++) != 's' && Pr > 7) Pr = 7;
		switch (ch) {	/* decode the conversion type */

		case 'c':	ptr = --arg.ival;
				putfld(ptr,ptr+1); break;
		case 'd':	putsi((int_type)*--arg.ival,10); break;
		case 'o' :	racine = 8; goto p_ui;
		case 'u' :	racine = 10; goto p_ui;
		case 'x' :	racine = 16;
	p_ui:			uarg = *--arg.ival;
				putui((uns_type)uarg,racine);
				break;

		case 's' :	
				for (end = ptr = *--arg.ival; *end++; );
				if (--end - ptr > Pr && Pr) end = ptr + Pr;
				putfld(ptr,end);
				break;

		case 0	 :	return;
		default  :	Pc(ch); Ps(); goto again;
		}
		
	Ps();
}

static getnum () {
	int n;
	for (n=0; (ch = *Pf) >= '0' && ch <='9'; )
		n = 10*n + *Pf++ - '0';
	return n;
}

/* unsigned integer/long conversions to ascii. the number sn is
   converted in the specified radix sr. the ascii digits are
   generated in a buffer. the value returned is a pointer to
   the first character in the buffer.  The following routines use
   either longs or ints, depending on whether NOLONG is defined.
*/

static char *
ocvti (buflim, aln, alr)
char *buflim; uns_type aln;
	{
	static int lr;
	static uns_type ln;
	lr = alr; ln = aln;
	do {
		*--buflim = hexdig(lr == 10 ? ln % 10 : ln & (lr -1));
		ln = lr == 8 ? ln >>3 : lr == 10 ? ln/10 : ln>>4 ;
		}
	while (ln) ;
	return buflim;
}

/* Output a signed integer in the specified radix. */
static putsi(n,radix)
int_type n;	{
	char nbuf[NBS];  /* conversion buffer */
	static int_type dsn;
	dsn = n < 0 ? -n : n;
	nbp = ocvti ( nbpe = nbuf+NBS, dsn, radix);
	if (n < 0) {	if (Pad != ' ') { Pc('-'); --Width; }
			      else *--nbp = '-';
		   }
	putfld (nbp, nbpe);
}

static putui(ui,radix) /* output an unsigned integer in the specified radix */
uns_type ui;
	{
	char nbuf[NBS];  /* conversion buffer */

	nbp = ocvti (nbpe = nbuf + NBS, ui, radix);
	putfld (nbp, nbpe);
}
	
static putfld(string, end)/* output a field containing a specified string ending
			     at end. Takes care of justification and padding.
			  */
char *string,*end;
	{
	static int length;
	length = end - string;
	if (! ljust)
		putpad(Pad,length);
	while (length--) {
		Pc (*string++);
		--Width;
		}
	if (ljust) putpad(' ',0);
}

static putpad(ch,count) {
	while (Width > count) { Pc(ch); --Width; }
	}

static hexdig(c) {
	return c + (c <= 9 ? '0' : 'A' - 10); }

/* Definitions for printf and fprintf to allow multiple args. */

#define printf prnt_1(),prnt_2
#define fprintf prnt_1(),prnt_3
#define sprintf prnt_1(),prnt_4






















	if (n < 0) {	if (Pad != ' ') { Pc('-'); --Width; }
			      else