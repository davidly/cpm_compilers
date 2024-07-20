/*
	NOBOOT.C	written by Leor Zolman
	v1.50 ONLY!		3/82, 9/82

	Given the name of a C-generated COM file linked with the standard
	distribution version of the v1.50 C.CCC run-time package using
	either the standard CLINK or optional "L2" linker), this program
	changes that COM file so that it does not perform a warm-boot after
	its execution is complete, but instead preserves the CCP (Console
	Command Processor) that is in memory when execution begins and
	returns to the CCP directly following execution.

	The versions of NOBOOT.C distributed with BDS C v1.46 will NOT
	work with files produced by v1.50.

	The CLINK option "-N" may be used instead of this program to the
	same effect. NOBOOT is basically intended for use with COM files
	produced by the L2 linker, as opposed to by CLINK.
*/

#include <bdscio.h>

#define JMP	0xC3	/* 8080 JMP instruction				*/
#define SNOBSP 0x0138	/* Location of Set NoBoot SP routine in C.CCC	*/
#define NOBRET 0x013B	/* Locatio of NoBoot RETurn routine in C.CCC	*/

main(argc,argv)
char **argv;
{
	int fd;
	int i;
	char c;
	char nambuf[30];
	char workbuf[0x500];

	if (argc != 2) {
		puts("Usage: noboot <C-generated COM file name>\n");
		exit();
	}

	for (i=0; (c = argv[1][i]) && c != '.'; i++)
		 nambuf[i] = c;
	nambuf[i] = '\0';
	strcat(nambuf,".COM");

	if ((fd = open(nambuf,2)) == ERROR) {
		puts("Can't open: ");
		puts(nambuf);
		exit();
	}

	i = read(fd,workbuf+0x100,8);
	if (i != 8) puts("Couldn't read in at least 8 sectors...\n");

	workbuf[0x100] = JMP;
	workbuf[0x101] = (SNOBSP & 0xFF);	/* Low byte of SNOBSP	*/
	workbuf[0x102] = (SNOBSP >> 8);		/*  Hi byte of SNOBSP	*/

	workbuf[0x109] = JMP;
	workbuf[0x10A] = (NOBRET & 0xFF);	/* Low byte of NOBRET	*/
	workbuf[0x10B] = (NOBRET >> 8);		/*  Hi byte of NOBRET	*/

	seek(fd,0,0);
	if (write(fd,workbuf+0x100,8) != 8) {
		puts("Write error.\n");
		exit();
	}

	if (close(fd) == ERROR) {
		puts("Close error\n");
	}
}
