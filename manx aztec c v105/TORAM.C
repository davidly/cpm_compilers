/************************************************************************/
/* This is a sample file	 					*/
/* Ver. 1.0								*/

#include "libc.h"
#define TRUE  1
#define FALSE 0
#define CTRL_Z 0x1a	/* WordStars end of file is a <CTRL/Z>		*/

main ()
{
/* this program converts S format readable assembly output to RAM 	*/
/*									*/
/* S format is 		<S1> 			(2 start bytes)		*/
/* 			<#of bytes in record> 	(2 bytes)		*/
/* 			<address of bytes> 	(4 bytes)		*/
/* 			<code> 			(# of RAM bytes * 2)	*/
/*			<Checksum>		(2 bytes)		*/
/*			<CR><LF>		(2 stop bytes)		*/
/* the last record contains S9 and final checksum but is ignored in 	*/
/* this program								*/


  FILE *fopen ();	/* function to open up file			*/
  FILE *input; 		/* input file					*/
  char  ptr[0x6000];	/* ptr to ram block 				*/
  char 	stringin[24];	/* string that contains the file to be read 	*/
  char 	answer[24];	/* string that contains answer to questions	*/
  char	c;		/* temporary char value				*/
  int	echoflag;	/* to see if the info should be echoed 		*/
  int	hi_nyb;		/* upper nybble flag for putting info into byte */
  int	i, j, k, l, m; 	/* counters					*/

  printf ("enter the file name to be transfered to RAM: ");
  gets (stringin);
  input = fopen (stringin, "r");
  while (input == NULL) 
    {
    printf ("file \"%s\" could not be opened\n\n", stringin);
    printf ("enter the file name to be transfered to RAM: ");
    gets (stringin);
    input = fopen (stringin, "r");
    }
  printf ("\n\ndo you wish to have the characters echoed ? <Y> or <N> : < >\b\b");
  gets (answer);
  if (toupper (answer[0]) == 'Y')
    echoflag = TRUE;
  else
    echoflag = FALSE;
  for (i = 0 ; ptr + i < 0x7000 ; ++i)
    ptr[i] = 0xff;
  k = i;
  m = 0;
  hi_nyb = TRUE;
  while (((c = getc (input)) != EOF) && (c != CTRL_Z))
    {
    if (c == 'S')
      for (j = 0 ; ((c = getc (input)) != EOF) && 
                    (c != CTRL_Z) && (j < 7) ; ++j)
        ;
    if (c == 0xd) 	/* if a <CR> get rid of previous checksum byte	*/
      {
      --k;
      --m;
      }
    if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F'))
      {
      if (c >= '0' && c <= '9')
        c -= '0';
      else
        c = c - 'A' + 0x0a;
      if (hi_nyb == TRUE)
        {
        ptr[k] = c;
        ptr[k] <<= 4;
        hi_nyb = FALSE;
        }
      else
        {
        ptr[k] |= c;
        ++k;
        ++m;
        hi_nyb = TRUE;
        }
      if ((echoflag == TRUE) && (hi_nyb == TRUE))
        printf ("%2x  ", ptr[k-1]);
      }
    }
  for (l = k ; ptr + l < 0x8000 ; ++l)
    ptr[l] = 0xff;
  printf ("\n\nthere were %d (%x hex) bytes read from file \"%s\"", m, m, stringin);
  printf ("\n\nthe information is at RAM location %xH on CP/M",0x8000,0x7000);
  fclose (input);
}
