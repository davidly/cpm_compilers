#include "func.c"
#include "crunt2.c"

/*Eratosthenes Sieve Prime Number Program in C*/
#define true 1
#define false 0
#define size 8190
#define sizepl 8191

char flags[sizepl];

main() {
	register int i;
        int prime,k,count,iter;

	puts("\n\nSample Program #3 : A prime number sieve\n");
	puts("10 iterations\n");
        for(iter = 1;iter <= 10;iter ++) {
            count=0;
            for(i = 0;i <= size;i ++)
                flags[i] = true;
            for(i = 0;i <= size;i ++) {
                if(flags[i]) {
                    prime = i + i + 3;
                    k = i + prime;
                        while(k <= size) {
                            flags[k] = false;
                            k += prime;
                            }
                        count = count + 1;
                    }
                }
              }
		putchar('\n');
		putdec(count);
		puts(" primes");
            }




