/*#define NOLONG		  /* define to defeat long integer code */
/*#define NOFLOAT		  /* define to defeat float code */
/*
 * SCANF.C for C/80 Version 3.1
 * by Grant B. Gustafson, 1982-83
 * Version Date: 1/25/84
 *
 * Purpose: To provide formatted input as described on pages 147-149
 *	    of Kernighan & Ritchie, "The C Programming Language",
 *	    Prentice-Hall, Englewood Cliffs, 1978.
 *	    Switchable float and long support for the C/80 Mathpak.
 *
 * Returns: The number of successfully matched and assigned data items
 *	    A short count is returned for missing or illegal data items
 *	    EOF = -1 is returned for end-of-file
 *
 * Limitations:
 *
 *     1. The function ungetc() must be used on exit from scanff() to meet
 *	  the K & R (p 148) specification.  A very limited ungetc is included,
 *	  but it only affects reading with scanf.  If you mix scanf calls with
 *	  other functions using getc or getchar, strange things will happen.
 *
 *     2. Under C/80, the coding n = (scanf(...)); returns the
 *	  number n of arguments processed. Double parentheses are required.
 *	  WARNING:  n = scanf(...); will fill n with a stack address.
 *
 * Portability:
 *
 * Radix 2 conversion %b is not listed in the K&R standard, however
 * it is available in many modern compilers. Primary use is debugging.
 *
 * Short integers %h are taken to be the same as integers %d. This is
 * in keeping with the PDP-11 16-bit machine standard (K & R page 182).
 *
 * Unix conversion %[...]: Reference: S.R.Bourne, "The Unix System", p 306.
 * String input using a limited character set. At least 2 chars must
 * follow %[ and the last must be ]. Use %[^ to mean "all but", or the
 * complement of the allowed character set.
 *
 * Examples:  %[^\n] inputs a string until a newline is found.
 *	      %[0-9A-F] inputs a string using 0123456789ABCDEF only.
 *	      %[^\1\3\n\32] inputs until ctrl-A, crtl-C or ctrl-Z.
 *	      %[^]--] inputs until a ']' or '-' is found.
 *
 * The Unix conversions %hd, %hx, %ho, %D, %O, %X, %E, %F are not supported.
 *
 * Both getchar() and getc() are assumed to follow the K&R convention
 * of returning -1 for END-OF-FILE. We do not translate getc() = 26 (^Z).
 *
 * History:
 * 7/83 first release
 * kill0x() bug, NOLONG/NOFLOAT switches, data type & function coercion. GBG
 * %% bug fix, Unix string input %[...]. 8/83 GBG
 * tolower and simple ungetc 1/84 WB
 *
 */

/* See S.R.Bourne, "The Unix System", p 309. NOT the same as in stdlib.c */
static char *index(str,c) char *str;
{ static char *p; p = str;
  while(*p) { if(*p - c) ++p; else return p;}
  return 0;}

/* Define white space for binary mode.	NOT the same as in stdlib.c */
static int Isspace(ch) char ch;
{ return (index("\40\t\r\n",ch) ? 1:0);}

static tolower(c) char c; {
	if (c >= 'A' && c <= 'Z') c += 'a' - 'A';
	return c; }

static int bufFLAG = 0,chan,radix,hadany,_keep;
static char *memory;
static union { char c; int i;
#ifndef NOLONG
	long l;
#endif
#ifndef NOFLOAT
	float f;
#endif
		} **STKtop;

static int nxtCHR()			/* get buffered char from input */
{ static int _keep;			 /* return -1 for end of file */
  if(bufFLAG) return _keep;		 /* or next input stream char */
  bufFLAG = -1;
  if(chan) return (_keep = getc(chan));
  if(memory) return (_keep = (*memory ? *memory++ : -1));
  return (_keep = getchar());
}

static advCHR() 			/* advance to next buffered char */
{ static i;
  if((i = nxtCHR()) != -1) { bufFLAG = 0;
		hadany = 1; }		/* tally to remember nr chars eaten */
  return i; }

static skipBL() 			/* skip over BLanks */
{ while( Isspace(nxtCHR()) ) advCHR();
  hadany = 0; } 			/* remember no chars eaten */

static int cvDIGIT(ch)			/* return value of digit or -1 */
{ static int z;
	if((z = ch) >= '0' && z <= '9') z -= '0';
  else	if((z &= 0137) >= 'A' && z <= 'F') z -= 'A' - 10;
  else	return (-1);
	if(z < radix) return z;
  return (-1);
}

static kill0x() 			/* kill 0x from hex string */
{ skipBL();
  if(nxtCHR() != '0') return;
  advCHR();
  if(tolower(nxtCHR()) == 'x') advCHR();
}

static char unchars[11] = {0,0,0,0,0,0,0,0,0,0,0};

ungetc(c,chan) {
	unchars[chan < 32 ? chan : chan - 25] = c; }

static int scanff(arg)			/* called by scanf, sscanf, fscanf */
char *arg;
{ static int n,NOsupr,sign,value,width,x,cc,*STKlow;
  static char *p,*q,*format;
  auto char strBUF[81];

#ifndef NOLONG
  static long ln;
#endif
#ifndef NOFLOAT
  float atof();
#endif
  bufFLAG = _keep = unchars[n = chan < 32 ? chan : chan - 25];
  n = unchars[n] = 0;
  STKlow = &arg;
  format = *--STKtop;
   while((cc = *format++) && nxtCHR() != -1)
	{ if(Isspace(cc)) continue;
	  if(cc == '%')
	    if(*format != '%') goto start; else ++format;
	  skipBL(); if(cc != nxtCHR() ) break; advCHR(); continue;
start:	  sign = NOsupr = 1;
	  if(*format == '*') { NOsupr = 0; ++format;}
	  else if(--STKtop == STKlow) goto quit;
	  width = 0; radix = 10;
	  while((x = cvDIGIT(cc = *format++)) != -1) width = width*radix + x;
	  switch(tolower(cc))
	     { case 'x': kill0x(); radix = 16; goto loop;
	       case 'o': radix = 8; goto loop;
	       case 'b': radix = 2; goto loop;
	       case 'h':
	       case 'd': skipBL(); if(nxtCHR() != '-') goto loop;
			 sign = -1; advCHR();
  loop:        case 'u': value = 0; skipBL();
			 while((x = cvDIGIT(nxtCHR())) != -1)
			      { value = value*radix + x;
				advCHR();
				if(--width == 0) break;
			      } /* end while */
			 if (hadany == 0) goto quit;	/* If no chars eaten */
			 if(NOsupr) (*STKtop)->i = sign*value;
			 break;
	       case 's': skipBL();
			 if(NOsupr) p = *STKtop;
			 while((x = nxtCHR()) != -1)
			      { if(Isspace(x)) break;
				advCHR();
				if(NOsupr) *p++ = x;
				if(--width); else break;
			      } /* end while */
			 if(NOsupr) *p = '\0';
			 if (hadany == 0) goto quit;	/* If no chars eaten */
			 break;
	       case 'c': if (nxtCHR() == -1) goto quit;
			 if(NOsupr) (*STKtop)->c = nxtCHR();
			 advCHR(); break;
	       case '[': sign = cc = 0;
			 if((x = *format++) == '^') { cc = 1; x = *format++;}
			 if((q = index(format,']')) == 0) goto quit;
			 p = strBUF;
			 while(format <= q && ++sign < 80)
			      { *p++ = x;
				if(*format == '-')
				  { ++format;
				    while(x < *format && ++sign < 80)
					 *p++ = ++x;
				  }
				x = *format++;
			      }
			 format = q+1; *p = '\0';

			 p = *STKtop;
			 while((x = nxtCHR()) != -1)
			      { q = index(strBUF,x);
				if((cc && q == 0) || (q && cc == 0))
				  { if(NOsupr) *p++ = x; advCHR();}
				else break;
			      }
			 if(NOsupr) *p = '\0';
			 break;
/* long integer code */
#ifndef NOLONG
	       case 'l': switch(tolower(*format++))
			   { case 'x': kill0x(); radix = 16;
				       goto loop1;
			     case 'o': radix = 8; goto loop1;
			     case 'b': radix = 2; goto loop1;
			     case 'd': skipBL();
				       if(nxtCHR() - '-');
				       else { sign = -1; advCHR();}
	  loop1:	     case 'u': skipBL();
				  ln = 0;
				  while((x = cvDIGIT(nxtCHR())) != -1)
				     { ln = ln * radix + x;
				       advCHR();
				       if(--width == 0) break;
				     } /* end while */
				  if(sign - 1) ln = -ln;
				  if (hadany == 0) goto quit;
				  if(NOsupr) (*STKtop)->l = ln;
				  break;
			     case 'e':	/* double is an error */
			     case 'f':
			     default:  goto quit;
			   } /* end switch */
			 break;
#endif
/* float code */
#ifndef NOFLOAT
	       case 'e':
	       case 'f': skipBL(); p = strBUF;
			 if(width > 20) width = 20;
			 while((x = nxtCHR()) != -1)
			      { if(index("0123456789.-+Ee",x) )
				  { *p++ = x; advCHR();}
				else break;
				if(--width == 0) break;
			      } /* end while */
			 *p = '\0';
			 if (hadany == 0) goto quit;
			 if (NOsupr) (*STKtop)->f = atof(strBUF);
			 break;
#endif
	       default:  goto quit;
	     } /* end switch case */
	     n += NOsupr;
	} /* end while */
quit:
 if(memory) return n;			/* no end of file for a string */
 while((x = nxtCHR()) != -1)
      { if(x == '\n') break;		/* normal with linefeed terminator */
	if(Isspace(x)) advCHR();	/* delete trailing blanks */
	else { ungetc(x,chan);		/* put last char back on input */
	       break;}
      } /* end while */
 return nxtCHR() != -1 ? n :		/* not at end of file */
			     -1;	/* return -1 for end of file */
} /* end function scanff() */

STK_pos(arg) int arg;
{ chan=memory=0; STKtop = &arg;}	/* find entry stack level */

int scan_f()
{ return scanff();}

int f_scan()
{ chan = *--STKtop; return scanff();}

int s_scan()
{ memory = *--STKtop; return scanff();}

/* definitions for multiple args */
#undef scanf
#undef fscanf
#undef sscanf
#define scanf STK_pos(),scan_f
#define fscanf STK_pos(),f_scan
#define sscanf STK_pos(),s_scan

/* end file SCANF.C */
 */
C FA!  9Â! Â ∆A¡¡Õ‰å ÂÕ˙0¡ÕZ FA ÄÕD ⁄9^! " A!  9ÂÕ åÂÕ‰å *FAÕœíÂ É¡¡¡! .ob ! 9.nf åÂÕR_b µ¬x^ ‰åÂÕ∞a Õ„í…˜‚  