/* Copyrighted (c) by SuperSoft, Inc., 1982 */

#define	FAILURE		0
#define	INUSE		1
#define	SIZEOF		(sizeof allocs)
#define	UNITSIZE	(8 * SIZEOF)

int	*alloc1, *alloc2, *allocs;

alloc(nbytes)
 int	nbytes;
{
	register int *p;
	int i, nwords, *p2, *q;

	if(allocs == 0)
	{
		allocs = evnbrk(2*SIZEOF);
		allocs[0] = (&allocs[1])|INUSE;
		allocs[1] = (&allocs[0])|INUSE;
		alloc2 = alloc1 = &allocs[1];
	}


	nwords = (nbytes+(2*SIZEOF-1))/SIZEOF;
	for(p=alloc1;;)
	{
		do
		{
			if((*p & INUSE) == 0)
			{
				while((*(q = *p) & INUSE)==0)
					*p = *q;
				if(q >= &p[nwords])
				{
					alloc1 = &p[nwords];
					if(q > alloc1)
						*alloc1 = *p;
					*p = alloc1 | INUSE;
					return p+1;
				}
			}
			q = p;
			p = *p & ~INUSE;
		} while(q>=alloc1 || p<alloc1);

		i = (nwords+UNITSIZE)*SIZEOF;
		while((p2=evnbrk(i))==-1)
		{
			if(i<32)
				return FAILURE;
			i /= SIZEOF;
			i &= ~1;/* rounded by SIZEOF actually */
		}
		if(p2 != alloc2 + 1)
			*alloc2 = p2|INUSE;
		else
			*alloc2 = p2;
		*p2 = alloc2 = &p2[i/SIZEOF-1];
		*alloc2 = allocs|INUSE;
	}
}

free(p)
 int	*p;
{
	alloc1 = p-1;
	*alloc1 &= ~INUSE;
}

alloc2, *allocs;

alloc(nbytes)
 int	nbytes;
{
	register int *p;
	int i, nwords, *