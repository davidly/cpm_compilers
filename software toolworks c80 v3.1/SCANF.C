/*#define FLONG 			     comment out to omit long & float */
/*
 * SCANF.C for C/80 Version 3.0
 * by Grant B. Gustafson, 1982-83
 *
 * Purpose: To provide formatted input as described on pages 147-149
 *	    of Kernighan & Ritchie, "The C Programming Language",
 *	    Prentice-Hall, Englewood Cliffs, 1978. Includes switchable
 *	    float and long support.
 *
 * Limitations:
 *
 *     1. A function ungetc() should be used on exit from scanff() to meet
 *	  the K & R (p 148) specification. Input terminated with a linefeed
 *	  will meet the standard with or without ungetc(). We do not supply
 *	  the function ungetc(), nor does C/80.
 *
 *     2. Under C/80, the coding n = (scanf(...)); returns the
 *	  number n of arguments processed. Double parentheses are required.
 *	  WARNING:  n = scanf(...); will fill n with a stack address.
 *
 * Portability:
 *
 * The %b binary conversion feature is not listed in the K & R standard.
 * However, it may be used in scanf() & printf() by many modern C-compilers.
 *
 * Short integers %h are taken to be the same as integers %d. This is
 * in keeping with the PDP-11 16-bit machine standard (K & R page 182).
 */

static index(str,c) char *str;		/* NOT the same as in stdlib.c */
{ static char *p; p = str;
  while(*p) { if(*p - c) ++p; else return p;}
  return 0;
}

static isspace(ch) char ch;		/* NOT the same as in stdlib.c */
{ return index("\40\t\r\n",ch);
}

static char toupper(ch)
{ static x; x = ch;
  return ( ('a' <= x && x <= 'z') ? (x - ' ') : x);
}

static int bufFLAG,method,chan,radix,hadany;
static union { char c; int i;
#ifdef FLONG
	long l; float f;
#endif
		} **STKtop;
static char *memory;

static nxtCHR() 			/* get buffered char from input */
{ static int keep;			/* return -1 for end of file */
  if(bufFLAG) return keep;		/* or next input stream char */
  bufFLAG = -1;
  switch(method)
	{ case 1: return (keep = getchar());
	  case 2: if( (keep = getc(chan)) != 26) return keep;
		  break;
	  case 3: if(*memory) return (keep = *memory++);
	} /* end switch */
return (keep = -1);
} /* end function nxtCHR() */

static advCHR() 			/* advance to next buffered char */
{ static i;
  if((i = nxtCHR()) != -1) { bufFLAG = 0;
		hadany = 1; }		/* tally to remember nr chars eaten */
  return i; }

static skipBL() 			/* skip over BLanks */
{ while( isspace(nxtCHR()) ) advCHR();
  hadany = 0; } 			/* remember no chars eaten */

static cvDIGIT(ch)			/* return value of digit or -1 */
{ static int z;
	if((z = ch) >= '0' && z <= '9') z -= '0';
  else	if((z &= 0137) >= 'A' && z <= 'F') z -= 'A' - 10;
  else	return (-1);
	if(z < radix) return z;
  return (-1);
} /* end function cvDIGIT() */

static kill0x() 			/* kill 0x from hex string */
{ skipBL();
  if(nxtCHR() != '0') return;
  advCHR();
  if(toupper(nxtCHR()) != 'X') advCHR();
} /* end function kill0x() */

int scanff(arg) 			/* called by scanf, sscanf, fscanf */
char *arg;
{ static int n,NOsupr,sign,value,width,x,cc,*STKlow;
  static char *p,*format;

#ifdef FLONG
  static long Lnum,Lx;
  char strBUF[21];
  float atof();
#endif
  bufFLAG = n = 0;
  STKlow = &arg;
  format = *--STKtop;
   while((cc = *format++) && nxtCHR() != -1)
	{ if(isspace(cc)) continue;
	  if(cc != '%')
	    { skipBL();
	      if(cc != nxtCHR() ) break; advCHR(); continue;}
	  sign = NOsupr = 1;
	  if(*format == '*') { NOsupr = 0; ++format;}
	  else if(--STKtop == STKlow) goto quit;
	  width = 0; radix = 10;
	  while((x = cvDIGIT(cc = *format++)) != -1) width = width*radix + x;
	  switch(toupper(cc))
	     { case 'X': kill0x(); radix = 16; goto loop;
	       case 'O': radix = 8; goto loop;
	       case 'B': radix = 2; goto loop;
	       case 'H':
	       case 'D': skipBL(); if(nxtCHR() != '-') goto loop;
			 sign = -1; advCHR();
  loop:        case 'U': value = 0; skipBL();
			 while((x = cvDIGIT(nxtCHR())) != -1)
			      { value = value*radix + x;
				advCHR();
				if(--width == 0) break;
			      } /* end while */
			 if (hadany == 0) goto quit;	/* If no chars eaten */
			 if(NOsupr) (*STKtop)->i = sign*value;
			 break;
	       case 'S': skipBL();
			 if(NOsupr) p = *STKtop;
			 while((x = nxtCHR()) != -1)
			      { if(isspace(x)) break;
				advCHR();
				if(NOsupr) *p++ = x;
				if(--width); else break;
			      } /* end while */
			 if(NOsupr) *p = '\0';
			 if (hadany == 0) goto quit;	/* If no chars eaten */
			 break;
	       case 'C': if (nxtCHR() == -1) goto quit;
			 if(NOsupr) (*STKtop)->c = nxtCHR();
			 advCHR(); break;
#ifdef FLONG	/* This is for float & long only */
	       case 'L': switch(toupper(*format++))
			   { case 'X': kill0x(); radix = 16;
				       goto loop1;
			     case 'O': radix = 8; goto loop1;
			     case 'B': radix = 2; goto loop1;
			     case 'D': skipBL();
				       if(nxtCHR() - '-');
				       else { sign = -1; advCHR();}
	  loop1:	     case 'U': skipBL();
				  Lnum = 0;
				  while((x = cvDIGIT(nxtCHR())) != -1)
				     { Lnum = Lnum * radix + x;
				       advCHR();
				       if(--width == 0) break;
				     } /* end while */
				  if(sign - 1) Lnum = -Lnum;
				  if (hadany == 0) goto quit;
				  if(NOsupr) (*STKtop)->l = Lnum;
				  break;
			     default:  goto quit;
			   } /* end switch */
			 break;
	       case 'E':
	       case 'F': skipBL(); p = strBUF;
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
 if(method == 3) return n;		/* no end of file for a string */
 while((x = nxtCHR()) != -1)
      { if(x == '\n') break;		/* normal with linefeed terminator */
	if(isspace(x)) advCHR();	/* delete trailing blanks */
	else {				/* put last char back on input */
					/* you supply ungetc() routine */
	       break;}	/* end else */
      } /* end while */
 return nxtCHR() != -1 ? n :		/* not at end of file */
			     -1;	/* return -1 for end of file */
} /* end function scanff() */

STK_pos(arg) int arg;
{ STKtop = &arg;}		/* find entry stack level */

scan_f()
{ method = 1; return scanff();} /* end function scanf() */

f_scan()
{ method = 2; chan = *--STKtop; return scanff();}

s_scan()
{ method = 3; memory = *--STKtop; return scanff();}

/* definitions for multiple args */
#undef scanf
#undef fscanf
#undef sscanf
#define scanf STK_pos(),scan_f
#define fscanf STK_pos(),f_scan
#define sscanf STK_pos(),s_scan

/* end file SCANF.C */
 TEST SCANF.C
		   Note use of symbol MATH to switch code */
puts(s