/*
 * This header file contains hardware-dependent definitions for C programs.
 * If the symbol "DIRECT_CURSOR" has been defined at the point this file
 * is included into the program, then the "gotoxy" function
 * and other advanced video-terminal functions will be compiled. THIS FILE
 * MUST BE CUSTOMIZED BY EACH INDIVIDUAL USER AT THE TIME BDS C IS BROUGHT UP.
 */

/*
 * Some console (video) terminal characteristics:
 */

#define TWIDTH	80	/* # of columns	*/
#define TLENGTH	24	/* # of lines	*/
#define CLEARS	"\033E"	/* String to clear screen on console	*/
#define INTOREV	"\033p"	/* String to switch console into reverse video	*/
#define OUTAREV "\033q"	/* String to switch console OUT of reverse video  */
#define CURSOROFF "\033x5"	/* String to turn cursor off	*/
#define CURSORON "\033y5"	/* String to turn cursor on	*/
#define ESC	'\033'	/* Standard ASCII 'escape' character	*/


#ifdef DIRECT_CURSOR		/* if user has enabled advanced	*/
				/* video-terminal functions: 	*/
gotoxy(x,y)
{
	bios(4,ESC);
	bios(4,'Y');
	bios(4, x + ' ');
	bios(4, y + ' ');
}

clear()
{
	bios(4,ESC);
	bios(4,'E');
}

#endif


/*
	The following definitions provide a portable low-level interface
	for direct I/O to the  console and modem devices. The values
	used here are only for example; be certain to go in and customize
	them for your system! Note that only one of the two sections
	(I/O port vs. memory mapped) will be needed for your system,
	so feel free to edit the unused section out of the file and remove
	the conditional compilation lines around the section you end up
	using.
*/

#define IO_PORTS	1	/* change to 0 if I/O is memory-mapped */

#if IO_PORTS			/* this section for status-driven I/O only */
#define CON_TBE		(inp(0x00) & 0x80)	/* Console: output ready? */
#define CON_RDA		(inp(0x00) & 0x40)	/*	    input ready?  */
#define CON_TDATA(byte)	(outp(0x01, byte))	/* 	    transmit data */
#define CON_RDATA	(inp(0x01))		/*	    read data	  */
#define CON_CTRL(byte)	(outp(0x00, byte))	/* write to control port  */

#define	MOD_TBE		(inp(0x08) & 0x80)	/* Modem */
#define MOD_RDA		(inp(0x08) & 0x40)
#define	MOD_TDATA(byte)	(outp(0x09, byte))
#define	MOD_RDATA	(inp(0x09))
#define MOD_CTRL(byte)	(outp(0x08, byte))

#else				/* this section for memory-mappped I/O only */
#define CON_TBE		(peek(FOO) & BAR)	/* Console */
#define CON_RDA		(peek(FOO) & BAR)
#define CON_TDATA(byte)	(poke(FOO, byte))
#define CON_RDATA	(peek(FOO))
#define CON_CTRL(byte)	(poke(FOO, byte))

#define	MOD_TBE		(peek(FOO) & BAR)	/* Modem */
#define	MOD_RDA		(peek(FOO) & BAR)
#define	MOD_TDATA(byte)	(poke(FOO, byte))
#define	MOD_RDATA	(peek(FOO))
#define MOD_CTRL(byte)	(poke(FOO, byte))
#endif
