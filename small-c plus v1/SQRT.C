#include <stdio.h>
#include <math.h>
#include "float.h"

sqrt(x)
double x;
{
	double extra;	/* current approximate root */
	char *px;		/* points to x */
	char *pextra;	/* points to extra */
	int i;			/* loop counter */

	if (x == 0.0) return 0.0 ;
	if (x < 0.0) {
		err("ill sqrt") ;
		return 0.0 ;
	}
	px = &x ;
	pextra = &extra ;			/* set the pointers */
	extra = 0.707 ;				/* initialize fraction at sqrt(.5) */
	pextra[5] = (px[5]>>1)^64 ;	/* answer exponent is half of "x" exponent */
	i = 5 ;						/* 5 iterations of Newton's algorithm */
	while (--i) {
		extra += x/extra ;
		--pextra[5] ;			/* /2 */
	}
	return extra ;
}
