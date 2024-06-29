/*	>>>>>>> start of cc5 <<<<<<<	*/
/*
	history...
		14 Jul 84  When profiling, not generating ':'
	after label equated to zero.
		27 Jun 84  No longer generating ENDDATA label
	at end of program (duty taken over by ZLINK).
		25 Jun 84  When profiling, the equate has
	the ZMAC syntax. '\l' added.
		10 Oct 83  Converted DB, DW, and DS to DEFB,
	DEFW, and DEFS.  Added colon after ENDDATA.
		1 Sept 83  calling nl() before outputting
	call to ccalls().
		26 Aug 83  added code to link call counts
	(header, trailer)
		29 Jun 83  addim() now calls outasm
	rather than ot to print the literal.
		7 Mar 83  prefix "&" no longer accepts function
	name.
		1 Feb 83  Declaring "enddata" at the end
	of the allocated memory (=top of heap).
		29 Jan 83  prefix "&" can return address of
	function.
		27 Oct 82  Generating no extra nl() after
	"dstore", updating Zsp in same routines that generate
	calls to floating point routines.
		23 Oct 82  rewrote value-returning expr
	in "fnumber".
		10 Oct 82  Corrected Zsp accounting.
	Moved type coersion to a subroutine. Checking operand
	types for integer operations.
		9 Oct 82  Automatically widening before:
	+ - * / < <= == != >= >.  Short-circuit evaluation of
	DOUBLE tests.
		6 Oct 82  Generating calls to "qfloat" rather
	than "qqfloat".
		11 Sept 82  Generating no POP DE instructions
	for most operators.
		5 Sept 82  "constant" doing explicit "dload"
	for floating constants.
		3 Sep 82  Accepting floating constants.
		31 Aug 82  Performing monadic "-" on
	floating point variables.
		30 Aug 82  Automatic conversions to and
	from DOUBLE on assignments. Adjusting stack after
	double precision comparisons. Comparisons now yield
	integers.
		29 Aug 82  monadic "&" now generates
	a correct variable name.
		12 Aug 82 Corrected "number" to return
	type correctly.
		11 Aug 82 Rewrote dbltest.
		9 Aug 82  Started installing floating
	point comparisons.
		7 Aug 82  Modified for floating point
	expressions.
		5 Aug 82  Converted JZ to JP Z,
	Converted several calls to ot() to outasm() to
	eliminate unwanted tabs.  Added some comments.
		3 Aug 82  Corrected immed(), removed two
	unnecessary tests for >0, removed one unnecessary
	8-bit mask.
		1 Aug 82  generating Zilog mnemonic
	output rather than Intel.
		18 Jul 82  Corrected expression analyzer
	per J. E. Hendrix (ddj n62 p41);
		1 Jul 82   Replaced calls to "ccpchar" with
	inline code, per Ron Cain, DDJ n48 p6.
		Implemented backslash escape sequences for
	character and string literals, per J. E. Hendrix,
	DDJ n56 p6.
		18 Apr 81	Preceding names by Q rather
	than QZ, to shorten them.
*/

/*
** lval[0] - symbol table address, else 0 for constant
** lval[1] - type of indirect object to fetch, else 0
		for static object
** lval[2] - type of pointer or array, else 0
** lval[3] - type of value calculated  jrvz 8/7/82
*/
expression()
{
	int lval[4];	/* jrvz 8/7/82 */
	if(heir1(lval))rvalue(lval);
	return lval[3];  /* return type  jrvz 8/7/82 */
}
heir1(lval)
	int lval[];
{
	int k,lval2[4];
	k=heir2(lval);
	if (match("="))
		{if(k==0){needlval();return 0;
		}
		if (lval[1])zpush();
		if(heir1(lval2))rvalue(lval2);
		force(lval[3],lval2[3]); /* jrvz 10/10/82 */
		store(lval);
		return 0;
		}
	else return k;
}
heir2(lval)
	int lval[];
{	int k,lval2[4];
	k=heir3(lval);
	blanks();
	if(ch()!='|')return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("|"))
			{zpush();
			if(heir3(lval2)) rvalue(lval2);
			intcheck(lval,lval2);
				/* jrvz 10/10/82 */
			zor();
			}
		else return 0;
		}
}
heir3(lval)
	int lval[];
{	int k,lval2[4];
	k=heir4(lval);
	blanks();
	if(ch()!='^')return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("^"))
			{zpush();
			if(heir4(lval2))rvalue(lval2);
			intcheck(lval,lval2);
				/* jrvz 10/10/82 */
			zxor();
			}
		else return 0;
		}
}
heir4(lval)
	int lval[];
{	int k,lval2[4];
	k=heir5(lval);
	blanks();
	if(ch()!='&')return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("&"))
			{zpush();
			if(heir5(lval2))rvalue(lval2);
			intcheck(lval,lval2);
				/* jrvz 10/10/82 */
			zand();
			}
		else return 0;
		}
}
heir5(lval)
	int lval[];
{
	int k,lval2[4];
	k=heir6(lval);
	blanks();
	if((streq(line+lptr,"==")==0)&
		(streq(line+lptr,"!=")==0))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("=="))
			{if(lval[3]==DOUBLE)dpush();
					/* jrvz 8/9/82 */
			else zpush();
			if(heir6(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{deq();
				lval[3]=cint;
				}	/* jrvz 8/9/82 */
			else zeq();
			}
		else if (match("!="))
			{if(lval[3]==DOUBLE)dpush();
					/* jrvz 8/9/82 */
			else zpush();
			if(heir6(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dne();
				lval[3]=cint;
				}	/* jrvz 8/9/82 */
			else zne();
			}
		else return 0;
		}
}
heir6(lval)
	int lval[];
{
	int k,lval2[4];
	k=heir7(lval);
	blanks();
	if((streq(line+lptr,"<")==0)&
		(streq(line+lptr,">")==0)&
		(streq(line+lptr,"<=")==0)&
		(streq(line+lptr,">=")==0))return k;
		if(streq(line+lptr,">>"))return k;
		if(streq(line+lptr,"<<"))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("<="))
			{if(lval[3]==DOUBLE)dpush();
			else zpush();	/* jrvz 8/9/82 */
			if(heir7(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dle();
				lval[3]=cint; continue;
				}
			if(lval[2]|lval2[2])
				{ule();
				continue;
				}
			if(cptr=lval2[0])
				if(cptr[ident]==pointer)
				{ule();
				continue;
				}
			zle();
			}
		else if (match(">="))
			{if(lval[3]==DOUBLE)dpush();
			else zpush();	/* jrvz 8/9/82 */
			if(heir7(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dge();
				lval[3]=cint; continue;
				}
			if(lval[2]|lval2[2])
				{uge();
				continue;
				}
			if(cptr=lval2[0])
				if(cptr[ident]==pointer)
				{uge();
				continue;
				}
			zge();
			}
		else if((streq(line+lptr,"<"))&
			(streq(line+lptr,"<<")==0))
			{inbyte();
			if(lval[3]==DOUBLE)dpush();
			else zpush();  /* jrvz 8/10/82 */
			if(heir7(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dlt();
				lval[3]=cint; continue;
				}
			if(lval[2]|lval2[2])
				{ult();
				continue;
				}
			if(cptr=lval2[0])
			    if(cptr[ident]==pointer)
				{ult();
				continue;
				}
			zlt();
			}
		else if((streq(line+lptr,">"))&
			(streq(line+lptr,">>")==0))
			{inbyte();
			if(lval[3]==DOUBLE)dpush();
			else zpush();  /* jrvz 8/10/82 */
			if(heir7(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dgt();
				lval[3]=cint; continue;
				}
			if(lval[2]|lval2[2])
				{ugt();
				continue;
				}
			if(cptr=lval2[0])
			    if(cptr[ident]==pointer)
				{ugt();
				continue;
				}
			zgt();
			}
		else return 0;
		}
}
/*	>>>>>> start of cc6 <<<<<<	*/

heir7(lval)
	int lval[];
{
	int k,lval2[4];
	k=heir8(lval);
	blanks();
	if((streq(line+lptr,">>")==0)&
		(streq(line+lptr,"<<")==0))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match(">>"))
			{zpush();
			if(heir8(lval2))rvalue(lval2);
			zpop();
			intcheck(lval,lval2);
				/* jrvz 10/10/82 */
			asr();
			}
		else if (match("<<"))
			{zpush();
			if(heir8(lval2))rvalue(lval2);
			intcheck(lval,lval2);
				/* jrvz 10/10/82 */
			asl();
			}
		else return 0;
		}
}
heir8(lval)
	int lval[];
{
	int k,lval2[4];
	k=heir9(lval);
	blanks();
	if((ch()!='+')&(ch()!='-'))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("+"))
			{if(lval[3]==DOUBLE)dpush();
					/* jrvz 8/7/82 */
			else zpush();
			if(heir9(lval2))rvalue(lval2);
			if(dbltest(lval,lval2))
			    scale(lval[2]);  /* jrvz 8/7/82 */
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dadd();
				}
			else	/* jrvz 8/8/82 */
			    {zpop();if(dbltest(lval2,lval))
				{if(lval2[2]!=cchar)
				    {swap();scale(lval2[2]);
				    }
				}
			    zadd();
			    result(lval,lval2);
			    }
			}
		else if (match("-"))
			{if(lval[3]==DOUBLE)dpush();
			else zpush();
			if(heir9(lval2))rvalue(lval2);
			if(dbltest(lval,lval2))
			    scale(lval[2]); /* jrvz 8/7/82 */
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dsub();
				}
			else
				{if(dbltest(lval2,lval))
				    {swapstk();
				    scale(lval2[2]);
					/* jrvz 8/8/82 */
				    swapstk();
				    }
				zsub();
				if((lval[2]==cint)
				&(lval2[2]==cint))
					{swap();
					immed(); ol("1");
					asr(); /*  div by 2  */
					}
				else if((lval[2]==DOUBLE)
				&(lval2[2]==DOUBLE))
					{swap();
					immed(); ol("6");
					div(); /* div by 6 */
					} /* jrvz 8/8/82 */
				result(lval,lval2);
				}
			}
		else return 0;
		}
}
heir9(lval)
	int lval[];
{
	int k,lval2[4];
	k=heira(lval);
	blanks();
	if((ch()!='*')&(ch()!='/')&
		(ch()!='%'))return k;
	if(k)rvalue(lval);
	while(1)
		{if (match("*"))
			{if(lval[3]==DOUBLE) dpush();
					/* jrvz 8/7/82 */
			else zpush();
			if(heir9(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{dmul();
				}
			else mult();
			}
		else if (match("/"))
			{if(lval[3]==DOUBLE) dpush();
					/* jrvz 8/7/82 */
			else zpush();
			if(heira(lval2))rvalue(lval2);
			if(widen(lval,lval2))
					/* jrvz 10/9/82 */
				{ddiv();
				}
					/* jrvz 8/7/82 */
			else
				{zpop(); div();
				}
			}
		else if (match("%"))
			{zpush();
			if(heira(lval2))rvalue(lval2);
			zpop();
			intcheck(lval,lval2);
				/* jrvz 10/10/82 */
			zmod();
			}
		else return 0;
		}
}
heira(lval)
	int lval[];
{
	int k;
	char *ptr;
	if(match("++"))
		{if((k=heira(lval))==0)
			{needlval();
			return 0;
			}
		if(lval[1])zpush();
		rvalue(lval);
		intcheck(lval,lval);	/* jrvz 10/10/82 */
		if(lval[2]==DOUBLE)  /* jrvz 8/7/82 */
			addimm("6");
		else
			{inc();
			if(lval[2]==cint) inc();
			}
		store(lval);
		return 0;
		}
	else if(match("--"))
		{if((k=heira(lval))==0)
			{needlval();
			return 0;
			}
		if(lval[1])zpush();
		rvalue(lval);
		intcheck(lval,lval);	/* jrvz 10/10/82 */
		if(lval[2]==DOUBLE)  /* jrvz 8/7/82 */
			addimm("0-6");
		else
			{dec();
			if(lval[2]==cint) dec();
			}
		store(lval);
		return 0;
		}
	else if (match("-"))
		{k=heira(lval);
		if (k) rvalue(lval);
		if(lval[3]==DOUBLE)dneg();
		else neg();
		return 0;
		}
	else if(match("*"))
		{k=heira(lval);
		if(k)rvalue(lval);
		if(ptr=lval[0])  /* get type from sym table */
			lval[3]=lval[1]=ptr[type];
					/* jrvz 8/7/82 */
		else lval[3]=lval[1]=cint;
			 /* ...else assume int  jrvz 8/7/82 */
		lval[2]=0;  /*  flag as not pointer or array */
		return 1;  /* dereferenced pointer is lvalue */
		}
	else if(match("&"))
		{k=heira(lval);
		ptr=lval[0];
		if(k==0)
			{error("illegal address");
			return 0;
			}
		ptr=lval[0];
		lval[2]=ptr[type];
		lval[3]=cint;	/* jrvz 8/7/82 */
		if(lval[1])return 0;
		/* global & non-array */
		immed();
		outname(ptr);
			/* formerly outsym   jrvz 8/29/82 */
		nl();
		lval[1]=ptr[type];
		return 0;
		}
	else 
		{k=heirb(lval);
		if(match("++"))
			{if(k==0)
				{needlval();
				return 0;
				}
			if(lval[1])zpush();
			rvalue(lval);
			intcheck(lval,lval);
					/* jrvz 10/10/82 */
			if(lval[2]==DOUBLE)  /* jrvz 8/7/82 */
				{zpush();
				addimm("6");
				store(lval);
				mainpop();
				}
			else
				{inc();
				if(lval[2]==cint) inc();
				store(lval);
				dec();
				if(lval[2]==cint) dec();
				}
			return 0;
			}
		else if(match("--"))
			{if(k==0)
				{needlval();
				return 0;
				}
			if(lval[1])zpush();
			rvalue(lval);
			intcheck(lval,lval);
				/* jrvz 10/10/82 */
			if(lval[2]==DOUBLE)  /* jrvz 8/7/82 */
				{zpush();
				addimm("0-6");
				store(lval);
				mainpop();
				}
			else
				{dec();
				if(lval[2]==cint) dec();
				store(lval);
				inc();
				if(lval[2]==cint) inc();
				}
			return 0;
			}
		else return k;
		}
	}
/*	>>>>>> start of cc7 <<<<<<	*/

heirb(lval)
	int *lval;
{	int k;char *ptr;
	k=primary(lval);
	ptr=lval[0];
	blanks();
	if((ch()=='[')|(ch()=='('))
	while(1)
		{if(match("["))
			{if(ptr==0)
				{error("can't subscript");
				junk();
				needbrack("]");
				return 0;
				}
			else if(ptr[ident]==pointer)rvalue(lval);
			else if(ptr[ident]!=array)
				{error("can't subscript");
				k=0;
				}
			zpush();
			expression();
			needbrack("]");
			scale(ptr[type]); /* jrvz 8/8/82 */
			zpop();
			zadd();
			lval[0]=lval[2]=0;
			lval[3]=lval[1]=ptr[type];
					/* jrvz 8/7/82 */
			k=1;
			}
		else if(match("("))
			{if(ptr==0)
				{callfunction(0);
				}
			else if(ptr[ident]!=function)
				{rvalue(lval);
				callfunction(0);
				}
			else callfunction(ptr);
			k=lval[0]=0;
			lval[3]=ptr[type]; /* jrvz 8/7/82 */
			}
		else return k;
		}
	if(ptr==0)return k;
	if(ptr[ident]==function)
		{immed();
		outname(ptr);
		nl();
		return 0;
		}
	return k;
}
primary(lval)
	int *lval;
{	char *ptr,sname[namesize];int num[1];
	int k;
	lval[2]=0;  /* clear pointer/array type */
	if(match("("))
		{k=heir1(lval);
		needbrack(")");
		return k;
		}
	if(symname(sname))
		{if(ptr=findloc(sname))
			{getloc(ptr);
			lval[0]=ptr;
			lval[3]=lval[1]=ptr[type];
					/* jrvz 8/7/82 */
			if(ptr[ident]==pointer)
				{lval[1]=cint;
				lval[2]=ptr[type];
				lval[3]=cint; /* jrvz 8/7/82 */
				}
			if(ptr[ident]==array)
				{lval[2]=ptr[type];
				lval[3]=cint; /* jrvz 8/7/82 */
				return 0;
				}
			else return 1;
			}
		if(ptr=findglb(sname))
			if(ptr[ident]!=function)
			{lval[0]=ptr;
			lval[1]=0;
			lval[3]=ptr[type];  /* jrvz 8/7/82 */
			if(ptr[ident]!=array)
				{if(ptr[ident]==pointer)
					{lval[2]=ptr[type];
					lval[3]=cint;
					/* jrvz 8/7/82 */
					}
				return 1;
				}
			if(ptr[ident]==array)
				lval[3]=cint; /* jrvz 8/30/82*/
			immed();
			outname(ptr);nl();
			lval[1]=lval[2]=ptr[type];
			return 0;
			}
		ptr=addglb(sname,function,cint,0);
		lval[0]=ptr;
		lval[1]=0;
		lval[3]=cint;  /* jrvz 8/7/82 */
		return 0;
		}
	if(constant(num,&lval[3]))  /* jrvz 8/7/82 */
		return(lval[0]=lval[1]=0);
	else
		{error("invalid expression");
		immed();outdec(0);nl();
		junk();
		return 0;
		}
}
/* Complains if an operand isn't int	  jrvz 10/10/82 */
intcheck(v1,v2)
int v1[],v2[];	/* pointers to operand dope arrays */
{	if((v1[3]==DOUBLE)|(v2[3]==DOUBLE))
		error("operands must be int");
}
/* Forces result, having type t2, to have type t1
					jrvz 10/10/82 */
force(t1,t2) int t1,t2;
{	if(t1==DOUBLE)
		{if(t2!=DOUBLE) callrts("qfloat");
		}
	else if (t2==DOUBLE)
		{if(t1!=DOUBLE) callrts("qifix");
		}
}
/* If only one operand is DOUBLE, converts the other one to
  DOUBLE.  Returns 1 if result will be DOUBLE.	jrvz 10/9/82 */
widen(v1,v2) int v1[],v2[];
{	if(v2[3]==DOUBLE)
		{if(v1[3]!=DOUBLE)
			{dpush2();
			    /* push 2nd operand UNDER 1st */
			mainpop();
			callrts("qfloat");
			callrts("dswap");
			v1[3]=DOUBLE; /* type of result */
			}
		return 1;
		}
	else
		{if(v1[3]==DOUBLE)
			{callrts("qfloat");
			return 1;
			}
		else return 0;
		}
}
/*
** true if val1 -> int pointer or int array and
**	val2 not ptr or array
*/
dbltest(val1,val2) int val1[], val2[];
{	if(val1[2])		/* rewritten	jrvz 8/11/82 */
		{if(val1[2]==cchar) return 0;
		if(val2[2])return 0;
		return 1;
		}
	else return 0;
}
/*
** determine type of binary operation
*/
result(lval,lval2) int lval[],lval2[];
{	if(lval[2] & lval2[2])
		lval[2]=0;  /* ptr-ptr => int */
	else if(lval2[2])  /* ptr +- int => ptr */
		{lval[0]=lval2[0];
		lval[1]=lval2[1];
		lval[2]=lval2[2];
		}
}
store(lval)
	int *lval;
{	if (lval[1]==0)putmem(lval[0]);
	else putstk(lval[1]);
}
rvalue(lval)
	int *lval;
{	if((lval[0] != 0) & (lval[1] == 0))
		getmem(lval[0]);
		else indirect(lval[1]);
}
test(label)
	int label;
{
	needbrack("(");
	expression();
	needbrack(")");
	testjump(label);
}
constant(val,t)
	int val[],
	*t;	/* type  jrvz 8/7/82 */
{	if (fnumber(val))	/* jrvz 9/3/82 */
		{t[0]=DOUBLE;
		immed();printlabel(litlab);outbyte('+');
		outdec(val[0]); nl();
		callrts("dload");
		return 1;
		}
	else if (number(val))
		{t[0]=cint; immed();	/* jrvz 8/30/82 */
		}
	else if (pstr(val))
		{t[0]=cint; immed();
		}
	else if (qstr(val))
		{t[0]=cint;
		immed();printlabel(litlab);outbyte('+');
		}
	else return 0;	
	outdec(val[0]);
	nl();
	return 1;
}
fnumber(val)
	int val[];
{	double *dp,	/* used to store the result */
	sum,		/* the partial result */
	scale;		/* scale factor for next digit */
	char *start,	/* copy of pointer to starting point */
	*s;		/* points into source code */
	int k,	/* flag and mask */
	minus;	/* negative if number is negative */
	start=s=line+lptr;	/* save starting point */
	k=minus=1;
	while(k)
		{k=0;
		if(*s=='+')
			{++s; k=1;
			}
		if(*s=='-')
			{++s; k=1; minus=(-minus);
			}
		}
	while(numeric(*s))++s;
	if(*s++!='.')return 0;	/* not floating point */
	while(numeric(*s))++s;
	lptr=(s--)-line;	/* save ending point */
	sum=0.;	/* initialize result */
	while(*s!='.')	/* handle digits to right of decimal */
		sum=(sum+float(*(s--)-'0'))/10.;
	scale=1.;	/* initialize scale factor */
	while(--s>=start)	/* handle remaining digits */
		{sum=sum+scale*float(*s-'0');
		scale=scale*10.;
		}
	if(match("e"))	/* interpret exponent */
		{int neg, /* nonzero if exp is negative */
		expon;		/* the exponent */
		if(number(&expon)==0)
			{error("bad exponent");
			expon=0;
			}
		if(expon<0)
			{neg=1; expon=-expon;
			}
		else neg=0;
		if(expon>38)
			{error("overflow");
			expon=0;
			}
		k=32;	/* set a bit in the mask */
		scale=1.;
		/* find 10**expon by repeated squaring */
		while(k)
			{scale=scale*scale;
			if(k&expon) scale=scale*10.;
			k=k>>1;
			}
		if(neg) sum=sum/scale;
		else    sum=sum*scale;
		}
	if(minus<0) sum=-sum;
	if(litptr+6>=litmax)
		{error("string space exhausted");
		return 0;
		}
		/* get location for result & bump litptr */
	val[0]=litptr;
	dp=litq+litptr;
	litptr=litptr+6;
	*dp=sum;	/* store result */
	return 1;	/* report success */
}
number(val)
	int val[];
{	int k,minus;char c;
	k=minus=1;
	while(k)
		{k=0;
		if (match("+")) k=1;
		if (match("-"))
			{minus=(-minus);k=1;
			}
		}
	if(numeric(ch())==0)return 0;
	while (numeric(ch()))
		{c=inbyte();
		k=k*10+(c-'0');
		}
	if (minus<0) k=(-k);
	val[0]=k;
	return 1;
}
pstr(val)
	int val[];
{	int k;char c;
	if (match("'"))
		{k=0;
		while((ch())!=39)
			k=(k&255)*256 + (litchar()&127);
		lptr++;		/*  jeh 11/10/82 */
		val[0]=k;
		return 1;
		}
	return 0;
}
qstr(val)
	int val[];
{	char c;
	if (match(quote)==0) return 0;
	val[0]=litptr;
	while (ch()!='"')
		{if(ch()==0)break;
		if(litptr>=litmax)
			{error("string space exhausted");
			while(match(quote)==0)
				if(gch()==0)break;
			return 1;
			}
		litq[litptr++]=litchar(); /* jeh  7/1/82 */
		}
	gch();
	litq[litptr++]=0;
	return 1;
}

/* Return current literal char & bump lptr	jeh 7/1/82 */
litchar()
{	int i,oct;
	if(ch()!=92)return gch();
	if(nch()==0)return gch();
	gch();
	if(ch()=='b'){++lptr; return  8;} /* BS */
	if(ch()=='t'){++lptr; return  9;} /* HT */
	if(ch()=='l'){++lptr; return 10;} /* LF */
	if(ch()=='f'){++lptr; return 12;} /* FF */
	if(ch()=='n'){++lptr; return 13;} /* CR */
	i=3; oct=0;
	while(((i--)>0)&(ch()>='0')&(ch()<='7'))
		oct=(oct<<3)+gch()-'0';
	if(i==2)return gch(); else return oct;
}
/*	>>>>>> start of cc8 <<<<<<<	*/

/* Begin a comment line for the assembler */
comment()
{	outbyte(';');
}

/* Put out assembler info before any code is generated */
header()
{	comment();	outstr(BANNER);		nl();
	comment();	outstr(AUTHOR);		nl();
	comment();	outstr(VERSION);	nl();
	comment();				nl();
	if(mainflg){		/* do stuff needed for first */
/*	 	ol("ORG 100h");	/* assembler file. NOT USED for ZMAC */
		ol("LD HL,(6)");   /* set up stack */
		ol("LD SP,HL");
		callrts("ccgo");
			/* set default drive for CP/M */
		zcall("main");
			 /* call code generated by small-c */
		if(profile)
			{ol("global ccregis"); /* using these */
			ol("global cccalls"); /* labels from */
			ol("global ccleavi"); /* profiling routine */
			immed(); printlabel(firstfct); nl();
			callrts("cccalls");
			}
		zcall("exit");
			/* do an exit		gtf 7/16/80 */
		}
}
/* Print any assembler stuff needed after all code */
trailer()
{	if(profile) {printlabel(lastfct); ol("= 0");}
	/* ol("END"); */	/*...note: commented out! */

	nl();
	/* 6 May 80 rj errsummary() now goes to console */
	comment();
	outstr(" --- End of Compilation ---");
	nl();
}
/* Print out a name such that it won't annoy the assembler */
/*	(by matching anything reserved, like opcodes.) */
/*	gtf 4/7/80 */
outname(sname)
char *sname;
{	int len, i,j;

	outasm("q");
		/* qz => q to shorten names (4/18/81, jrvz) */
	len = strlen(sname);
	if(len>(ASMPREF+ASMSUFF)){
		i = ASMPREF;
		len = len-ASMPREF-ASMSUFF;
		while(i--)	/* jrvz 8/3/82 */
			outbyte(raise(*sname++));
		while(len--)	/* jrvz 8/3/82 */
			++sname;
		while(*sname)
			outbyte(raise(*sname++));
		}
	else	outasm(sname);
/* end outname */}
/* Fetch a static memory cell into the primary register */
getmem(sym)
	char *sym;
{	if((sym[ident]!=pointer)&(sym[type]==cchar))
		{ot("LD A,("); outname(sym+name);
		outasm(")"); nl();
		callrts("ccsxt");
		}
	else if((sym[ident]!=pointer)&(sym[type]==DOUBLE))
		{immed(); outname(sym+name); nl();
		callrts("dload");
		}		/* jrvz 8/7/82 */
	else
		{ot("LD HL,("); outname(sym+name); outasm(")");
		nl();
		}
	}
/* Fetch the address of the specified symbol */
/*	into the primary register */
getloc(sym)
	char *sym;
{	immed();
	outdec(((sym[offset]&255)+
		((sym[offset+1])<<8))-
		Zsp);
		/* 2nd 8-bit mask removed  jrvz 8/3/82 */
	nl();
	ol("ADD HL,SP");
	}
/* Store the primary register into the specified */
/*	static memory cell */
putmem(sym)
	char *sym;
{	if((sym[ident]!=pointer)&(sym[type]==DOUBLE))
		{immed(); outname(sym+name); nl();
		callrts("dstore");
		}		/* jrvz 8/7/82 */
	else	{if((sym[ident]!=pointer)&(sym[type]==cchar))
			{ol("LD A,L");
			ot("LD (");
			outname(sym+name); outasm("),A");
			}
		else
			{ot("LD (");
			outname(sym+name); outasm("),HL");
			}
		nl();
		}
	}
/* Store the specified object type in the primary register */
/*	at the address on the top of the stack */
putstk(typeobj)
	char typeobj;
{	if(typeobj==DOUBLE)
		{mainpop();
		callrts("dstore");
		}
	else
		{if(typeobj==cchar)
			{zpop();
			ol("LD A,L"); ol("LD (DE),A");
			}	/* jrvz 7/1/82 */
		else
			{callrts("ccpint"); popped();
			}

		}
	}
/* Fetch the specified object type indirect through the */
/*	primary register into the primary register */
indirect(typeobj)
	char typeobj;
{	if(typeobj==cchar)callrts("ccgchar");
	else if(typeobj==DOUBLE)	/* jrvz 8/7/82 */
		callrts("dload");
	else callrts("ccgint");
}
/* Swap the primary and secondary registers */
swap()
{	ol("EX DE,HL");
}
/* Print partial instruction to get an immediate value */
/*	into the primary register */
immed()
{	ot("LD HL,");
}
/* Push the primary register onto the stack */
zpush()
{	ol("PUSH HL");
	Zsp=Zsp-2;
}
/* Push the primary floating point register onto the stack
						jrvz 8/7/82 */
dpush()
{	callrts("dpush");
	Zsp=Zsp-6;
}
/* Push the primary floating point register, preserving
	the top value  jrvz 8/7/82 */
dpush2()
{	callrts("dpush2");
	Zsp=Zsp-6;
}
/* Pop the top of the stack into the primary register
					jrvz 10/11/82 */
mainpop()
{	ol("POP HL");
	Zsp=Zsp+2;
}
/* Pop the top of the stack into the secondary register */
zpop()
{	ol("POP DE");
	Zsp=Zsp+2;
}
/* Adjust the stack counter for 2 bytes popped off stack */
popped()
{	Zsp=Zsp+2;
}
/* Swap the primary register and the top of the stack */
swapstk()
{	ol("EX (SP),HL");
}
/* Call the specified subroutine name */
zcall(sname)
	char *sname;
{	ot("CALL ");
	outname(sname);
	nl();
}
/* Call a run-time library routine */
callrts(sname)
char *sname;
{
	ot("CALL ");
	outasm(sname);
	nl();
/*end callrts*/}

/* Return from subroutine */
zret()
{	ol("RET");
}
/* Perform subroutine call to value on top of stack */
callstk()
{	immed();
	outasm("$+5");
	nl();
	swapstk();
	ol("JP (HL)");
	Zsp=Zsp-2;
	}
/* Jump to specified internal label number */
jump(label)
	int label;
{	ot("JP ");
	printlabel(label);
	nl();
	}
/* Test the primary register and jump if false to label */
testjump(label)
	int label;
{	ol("LD A,H");
	ol("OR L");
	ot("JP Z,");
	printlabel(label);
	nl();
	}
/* Print pseudo-op to define a byte */
defbyte()
{	ot("DEFB ");
}
/*Print pseudo-op to define storage */
defstorage()
{	ot("DEFS ");
}
/* Print pseudo-op to define a word */
defword()
{	ot("DEFW ");
}
/* Modify the stack pointer to the new value indicated */
modstk(newsp)
	int newsp;
 {	int k;
	k=newsp-Zsp;
	if(k==0)return newsp;
	if(k>=0)
		{if(k<7)
			{if(k&1)
				{ol("INC SP");
				--k;
				}
			while(k)
				{ol("POP BC");
				k=k-2;
				}
			return newsp;
			}
		}
	if(k<0)
		{if(k>-7)
			{if(k&1)
				{ol("DEC SP");
				++k;
				}
			while(k)
				{ol("PUSH BC");
				k=k+2;
				}
			return newsp;
			}
		}
	swap();
	immed();outdec(k);nl();
	ol("ADD HL,SP");
	ol("LD SP,HL");
	swap();
	return newsp;
}
/* Multiply the primary register by the length of
	some variable				jrvz 8/7/82 */
scale(t)
int t;	/* type */
{	if(t==cchar) return;
	if(t==DOUBLE) sixreg();
	else doublereg();
}
/* Double the primary register */
doublereg()
{	ol("ADD HL,HL");
}
/* Multiply the primary register by the length of a double
	(preserve DE)				jrvz 8/7/82 */
sixreg()
{	ol("LD B,H");
	ol("LD C,L");
	ol("ADD HL,BC");
	ol("ADD HL,BC");
	ol("ADD HL,HL");
}
/* Add a constant to the primary register  jrvz 10/11/82 */
addimm(x) char *x;
{	ot("LD DE,"); outasm(x); nl(); zadd();
}
/* Add the primary and secondary registers
	(result in primary) */
zadd()
{	ol("ADD HL,DE");
}
/* Add the primary floating point register to the
  value on the stack (under the return address)
  (result in primary)			  jrvz 8/8/82 */
dadd(){	callrts("dadd"); Zsp=Zsp+6;}
/* Subtract the primary register from the TOS */
/*	(TOS = value under the return address) */
/*	(results in primary) */
zsub()
{	callrts("ccsub"); popped();
}
/* Subtract the primary floating point register from the
  value on the stack (under the return address)
  (result in primary)				jrvz 8/8/82 */
dsub()
{	callrts("dsub"); Zsp=Zsp+6;}
/* Multiply the primary and TOS */
/*	(results in primary */
mult()
{	callrts("ccmult"); popped();
}
/* Multiply the primary floating point register by the value
  on the stack (under the return address)
  (result in primary)				jrvz 8/8/82 */
dmul()
{	callrts("dmul"); Zsp=Zsp+6;}
/* Divide the secondary register by the primary */
/*	(quotient in primary, remainder in secondary) */
div()
{	callrts("ccdiv");
}
/* Divide the value on the stack (under the return address)
  by the primary floating point register (quotient in primary)
						jrvz 8/8/82 */
ddiv()
{	callrts("ddiv"); Zsp=Zsp+6;}
/* Compute remainder (mod) of secondary register divided */
/*	by the primary */
/*	(remainder in primary, quotient in secondary) */
zmod()
{	div();
	swap();
	}
/* Inclusive 'or' the primary and the TOS */
/*	(results in primary) */
zor()
	{callrts("ccor"); popped();}
/* Exclusive 'or' the primary and TOS */
/*	(results in primary) */
zxor()
	{callrts("ccxor"); popped();}
/* 'And' the primary and TOS */
/*	(results in primary) */
zand()
	{callrts("ccand"); popped();}
/* Arithmetic shift right the secondary register number of */
/* 	times in primary (results in primary) */
asr()
	{callrts("ccasr");}
/* Arithmetic left shift the TOS number of */
/*	times in primary (results in primary) */
asl()
	{callrts("ccasl"); popped();}
/* Form two's complement of primary register */
neg()
	{callrts("ccneg");}
/* Negate the primary floating point register */
dneg()
	{callrts("minusfa");}
/* Form one's complement of primary register */
com()
	{callrts("cccom");}
/* Increment the primary register by one */
inc()
	{ol("INC HL");}
/* Decrement the primary register by one */
dec()
	{ol("DEC HL");}

/* Following are the conditional operators */
/* They compare the TOS against the primary */
/* and put a literal 1 in the primary if the condition is */
/* true, otherwise they clear the primary register */

/* Test for equal */
zeq()
	{callrts("cceq"); popped();}
/* Test for not equal */
zne()
	{callrts("ccne"); popped();}
/* Test for less than (signed) */
zlt()
	{callrts("cclt"); popped();}
/* Test for less than or equal to (signed) */
zle()
	{callrts("ccle"); popped();}
/* Test for greater than (signed) */
zgt()
	{callrts("ccgt"); popped();}
/* Test for greater than or equal to (signed) */
zge()
	{callrts("ccge"); popped();}
/* Test for less than (unsigned) */
ult()
	{callrts("ccult"); popped();}
/* Test for less than or equal to (unsigned) */
ule()
	{callrts("ccule"); popped();}
/* Test for greater than (unsigned) */
ugt()
	{callrts("ccugt"); popped();}
/* Test for greater than or equal to (unsigned) */
uge()
	{callrts("ccuge"); popped();}

/* The following conditional operations compare the
   top of the stack (TOS) against the primary floating point
   register (FA), resulting in 1 if true and 0 if false */

/* Test for floating equal */
deq()
	{callrts("deq"); Zsp=Zsp+6;}
/* Test for floating not equal */
dne()
	{callrts("dne"); Zsp=Zsp+6;}
/* Test for floating less than   (that is, TOS < FA)	*/
dlt()
	{callrts("dlt"); Zsp=Zsp+6;}
/* Test for floating less than or equal to */
dle()
	{callrts("dle"); Zsp=Zsp+6;}
/* Test for floating greater than */
dgt()
	{callrts("dgt"); Zsp=Zsp+6;}
/* Test for floating greater than or equal */
dge()
	{callrts("dge"); Zsp=Zsp+6;}

/*	<<<<<  End of small-c compiler  >>>>>	*/
                                                                                             