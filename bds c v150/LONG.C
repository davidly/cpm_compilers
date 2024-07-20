/*	C-Source for Long (32-bit signed) Integer Package
 *	Rob Shostak
 *	August, 1982			
 */
        


char *itol(result,n)			/* integer to long */
char *result;
int n;
{
return(long(0,result,n));
}

int ltoi(l)				/* converts long to integer */
char l[];
{
return(l[3] + (l[2] << 8));
}

lcomp(op1,op2)				/* compares two longs */
char *op1,*op2;
{
return(long(1,op1,op2));
}

char *ladd(result,op1,op2)		/* adds two longs */
char *result,*op1,*op2;
{
return(long(2,result,op1,op2));
}

char *lsub(result,op1,op2)		/* subtracts two longs */
char *result,*op1,*op2;
{
return(long(3,result,op1,op2));
}

char *lmul(result,op1,op2)		/* multiplies two longs */
char *result,*op1,*op2;
{
return(long(4,result,op1,op2));
}

char *ldiv(result,op1,op2)		/* "long" division */
char *result,*op1,*op2;
{
return(long(5,result,op1,op2));
}

char *lmod(result,op1,op2)		/* long multiplication */
char *result,*op1,*op2;
{
return(long(6,result,op1,op2));
}


char *atol(result,s)			/* ascii to long */
char *result,*s;
{
char ten[4], temp[4], sign;

itol(ten,10); itol(result,0);

if(sign=(*s == '-')) s++;

while(isdigit(*s))
  ladd(result,lmul(result,result,ten),itol(temp,*s++ - '0'));

return(sign? lsub(result,itol(temp,0),result) : result);
}

char *ltoa(result,op1)				/* long to ascii string */
char *result,*op1;
{
char absval[4], temp[4];
char work[15], *workptr, sign;
char ten[4], zero[4], *rptr;

rptr = result;
itol(ten,10); itol(zero,0);			/* init these */

if(sign = *op1 & 0x80)				/* negative operand */
  {
  *rptr++ = '-';
  lsub(absval,zero,op1);
  }
else lassign(absval,op1);

*(workptr = work+14) = '\0';		/* generate digits in reverse order */
do					
  *(--workptr) = '0'+ *(lmod(temp,absval,ten) + 3);
while
  (lcomp(ldiv(absval,absval,ten),zero) > 0);

strcpy(rptr,workptr);
return(result);
}


/* lassign(ldest,lsource) assigns long lsource to ldest, returns
   ptr to ldest */

char *lassign(ldest,lsource)
unsigned *ldest, *lsource;
{
*ldest++ = *lsource++;	/* copy first two bytes */
*ldest = *lsource;	/* then last two */
return(ldest);
}

/* ltou(l) converts long l to an unsigned (by truncating) */

unsigned ltou(l)
char l[];
{
return(l[3] + (l[2] << 8));
}

/* utol(l,u) converts unsigned to long */

utol(l,u)
char l[];
unsigned u;
{
itol(l, u & 0x7FFF);			/* convert integer part */
if(u > 0x7FFF) l[2] += 0x80;		/* take care of leftmost bit */
return(l);
}
