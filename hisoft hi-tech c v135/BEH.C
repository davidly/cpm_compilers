/* This is the well-known Sieve of Erathostenes, as used in the	*/
/* BYTE Benchmarks (BYTE, june 1988). Only difference: Small C	*/
/* in my version does not accept for..next loops, so I changed	*/
/* them to whiles. 						*/

/* Performance measurements:					*/
/*	- a 386/40 running MYZ80 CP/M emulator: 284 seconds	*/
/*	- IBM PC, 4.77Mhz original, MS-DOS:	298 seconds :)	*/

/* I'd like your CP/M system's score! (No, I don't know	why	*/
/* either..) Send results to:					*/
/* Oscar Vermeulen, oscar@contrast.wlink.nl or 2:281/527.18	*/

#include stdio.h

#define size 8190
#define LOOP 100
#define TRUE 1
#define FALSE 0


char flags [8191];

main()
{
	int	i, prime, k, count, iter;

	printf("BYTE sieve Benchmark, %d iterations\n", LOOP);

/*	gtime	*/
	
	iter=1; while(iter<=LOOP)	
	{

		count = 0;

		i=0; while (i<=size)
		{	flags[i] = TRUE; i++;	}

		i=0; while (i<=size)
		{
			if (flags[i]==TRUE)
			{
				prime = i+i+3;
/*				printf("\n%d", prime);	*/
				
				k=i+prime; while (k<=size)
				{	flags[k] = FALSE;
					k=k+prime;
				}
			}
		i++; count++;
		}
	iter++;
	}

	printf("\nEND. %d primes found\n", count);
}
 = FALSE;
					k=k+prime;
				}
			}
		i++; count++;
		}
	iter++;
	}

	printf("\