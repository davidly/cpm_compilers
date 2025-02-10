
/*
	"LIFE"

	The game invented by John Conway

	This version written by Leor Zolman to exemplify
	PROPER use of"goto" statements in C programs!

	Note that the Universe is a toroid;
	The left extreme is adjacent to the right extreme,
	the top is adjacent to the bottom, and each corner
	is adjacent to each other corner.
	In other words, there ARE NO EXTREMES !!
	Or, in a more physical illustration: If you could
	look straight ahead through an infinitely powerful
	telescope, you'd eventually see the back of your
	head....

*/

#define CLEARS 0x1a	/* character to clear your screen */
			/* If no single character does this
			   on your terminal, make this a
			   newline ('\n')		*/
#define TWIDTH 64	 /* # of columns on your terminal */
#define XSIZE 60	/* length of cell array  */
#define YSIZE 65	/* width of cell array */
			/* To see how the toroid works,
			   try reducing XSIZE and YSIZE to
			   around 10 or 20.		*/
#define BOREDOM_THRESHOLD 5  /* This is how many generations
				are allowed to pass without a
				population change */

char *gets();		/* routine to accept a line of input */
char cell[XSIZE][YSIZE]; /* the universe matrix */
int minx, maxx, miny, maxy, pop, gen;	/* misc. variables */
char doneflag;	   /* This goes true when we want to stop */
int boring;		/* keeps count of how many generations
			   go by without a population change */
char center;		/* 1 = center display; 0 = left
						   justify */

main()
{
	char c;
	printf("\n\t *** BDS Life ***\n");
	printf("\nDo you wish to have the display centered\n");
	printf(" (and thereby slowed down a bit) (y/n) ?");
	center = toupper(getchar()) == 'Y';
	for (;;) {
	  clear();
	  setup();
	  if (!pop) break;
	  adjust();
	  display();
	  while (pop) {
		adjust();
		dogen();
		display();
		if (boring == BOREDOM_THRESHOLD) {
		  boring++;
		  printf("\nNo change in population for");
		  printf(" %d ",BOREDOM_THRESHOLD);
		  printf("generations. Abort (y/n) ");
		  c = toupper(getchar());
		  putchar('\n');
		  if (c == 'Y') break;
		 }
		if (kbhit()) {getchar(); break;}
		if (doneflag) break;
	   }
	 }
 }

/* initialize the cell matrix to all dead */
clear()
{
	setmem(cell,(XSIZE*YSIZE),0);
}

/* get initial set-up from user */
setup()
{
	char c,y;
	char string[YSIZE], *ptr;
	y = pop = gen = minx = maxx = miny= maxy = 0;
	boring = 0;
	printf("\nEnter initial configuration (null line to end):\n");

	while (*gets(string)) {
		ptr = string;
		while (*ptr) {
			if ( *ptr++ != ' ') {
				cell[maxx][y] = 10;
				++pop;
			 }
			++y;
			if (y==YSIZE) {
			 printf("Truncated to %d chars\n",
				 YSIZE); break;
			 }
		 }
		--y;
		++maxx;
		if (y>maxy) maxy = y;
		if (maxx==XSIZE) break;
		y = 0;
	 }
	--maxx;
}

/* display the current generation */
display()
{
	int i,j,k,l,j9;
	char c;

	if (!pop) {
		printf("\nLife ends at %d\n",gen);
		return;
	 }
	if(minx && prow(minx-1)) minx--;
	if(miny && pcol(miny-1)) miny--;
	if ((maxx < (XSIZE-1)) && prow(maxx+1)) maxx++;
	if((maxy<(YSIZE-1)) && pcol(maxy+1))maxy++;
	
	while (!prow(minx)) minx++;
	while (!prow(maxx)) maxx--;
	while (!pcol(miny)) miny++;
	while (!pcol(maxy)) maxy--;

	putchar(CLEARS);
	if (center) {
		i = (TWIDTH-33)/2;
		for (j = 0; j<i; j++) putchar(' ');
	}
	printf("generation = %1d   population = %1d\n",
		gen,pop);
	++gen;

	j9 = maxy - miny + 1;
	for (i = minx; i<=maxx; i++) {
		if (center && j9<TWIDTH) {
			l = (TWIDTH-j9)/2;
			for (k = 0; k<l; k++) putchar(' ');
		 }
		for (j=miny; j<=maxy; j++)
			putchar(cell[i][j] ? '*' : ' ');
		if (i != maxx) putchar('\n');
	}
}

/* test if given column is populated */
pcol(n)
{
	int i,hi;
	hi = (maxx == (XSIZE-1)) ? maxx : maxx+1;
	for (i = minx ? minx-1 : minx; i<=hi; ++i)
		if (cell[i][n]) return 1;
	return 0;
}

/* test if given row is populated */
prow(n)
{
	int i,hi;
	hi = (maxy == (YSIZE-1)) ? maxy : maxy+1;
	for (i = miny ? miny-1 : miny; i<=hi; ++i)
		if (cell[n][i]) return 1;
	return 0;
}



/* compute next generation */
dogen()
{
	int i,j,i2,j2;
	int bigflag;
	int k,l;
	int oldpop;
	char c;
	int pass;
	doneflag = 1;
	oldpop = pop;
	bigflag =  (minx<2 || maxx>(XSIZE-3) ||
		miny<2 || maxy>(YSIZE-3)) ;
	i2 = (maxx==(XSIZE-1)) ? maxx : maxx+1;
	j2 = (maxy==(YSIZE-1)) ? maxy : maxy+1;
	for (pass = 0; pass < 2; pass++)
	for (i=minx ? minx-1 : minx; i<=i2; ++i)
	  for (j=miny ? miny-1 : miny; j<=j2; ++j) {
	   c = cell[i][j];
	   if (!pass) {
	     if (c >= 10)
		if (bigflag)
		  for (k = -1; k <= 1; k++)
		   for (l = -1; l <= 1; l++)
		    cell[mod(i+k,XSIZE)][mod(j+l,YSIZE)]++;
		else
		  for (k = -1; k<=1; k++)
		   for (l = -1; l <= 1; l++)
		    cell[i+k][j+l]++;
	    }
	   else
	     if (c > 10)
		if (c < 13 || c > 14) {
			cell[i][j] = 0;
			pop--;
			doneflag = 0;
		 }
		else cell[i][j] = 10;
	     else
		if (c == 3) {
			cell[i][j] = 10;
			pop++;
			doneflag = 0;
		 }
		else cell[i][j] = 0;
	 }
	if (pop == oldpop) boring++;
	  else boring = 0;
}


int mod(a,b)
{
	if (a<0) return b+a;
	if (a<b) return a;
	return a-b;
}


/* If we're about to run off the matrix, adjust accordingly (if possible) */
adjust()
{
	adjx();
	adjy();
}

/* Adjust vertical position */
adjx()
{
	int delta, i,j;
	int savdelta;
	if (maxx - minx + 1 > XSIZE-2) return;
	if (minx==0) {
		delta = (XSIZE-maxx)/2+maxx;
		savdelta = delta;
		for (i=maxx; i >= 0; --i) {
			for (j=miny; j<=maxy; ++j) {
				cell[delta][j] = cell[i][j];
				cell[i][j] = 0;
			 }
		--delta;
		}
		minx = delta+1;
		maxx = savdelta;
	}

	if (maxx == (XSIZE-1)) {
		delta = minx/2;
		savdelta = delta;
		for (i=minx; i<XSIZE; ++i) {
			for (j=miny; j<=maxy; ++j) {
				cell[delta][j] = cell[i][j];
				cell[i][j] = 0;
			}
		++delta;
		}
		maxx = delta-1;
		minx = savdelta;
	}
}


/* Adjust horizontal position */
adjy()
{
	int delta, i, j;
	int savdelta;
	if (maxy - miny + 1 > YSIZE -2) return;
	if (miny == 0) {
		delta = (YSIZE-maxy)/2+maxy;
		savdelta = delta;
		for (i=maxy; i>=0; --i) {
			for (j=minx; j<=maxx; ++j) {
				cell[j][delta] = cell[j][i];
				cell[j][i] = 0;
			}
		--delta;
		}
		miny = delta+1;
		maxy = savdelta;
	}

	if (maxy == (YSIZE-1)) {
		delta = miny/2;
		savdelta = delta;
		for (i=miny; i<YSIZE; ++i) {
			for (j=minx; j<=maxx; ++j) {
				cell[j][delta] = cell[j][i];
				cell[j][i] = 0;
			}
		++delta;
		}
		maxy = delta -1;
		miny = savdelta;
	}
}
