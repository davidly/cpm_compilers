/* Special Raw console I/O for BDSC			Steve Ward 1/81
 *
 * Provides a reasonably flexible, device-independent interface:
 *
 *	ch = getchar()		Read a character
 *
 *	putchar(ch)		write a character
 *
 *	kbhit()			true iff input character waiting
 *
 *	old = TTYMode(m)	Sets tty mode bits to m, returning old
 *				 value.  Mode bits:
 *		1	Echo mode: chars echoed as read.
 *		2	Quit: ^C causes an exit.
 *		4	Flow: ^S, ^Q flow control.
 *		8	Strip: input characters stripped to 7 bits.
 *		16	Expand: expand \n, \t on output.
 *
 * Hence for REALLY raw I/O, do TTYMode(0).
 *
 * NOTE: Program using CIO.C are NOT PORTABLE to systems lacking a C compiler!
 *	 If you really must use CIO, then compile this once (to get CIO.CRL)
 *	 and link your programs by saying:
 *
 *		A>clink main <other CRL files> DEFF CIO <cr>
 *
 */

#include "bdscio.h"			/* Make sure BDSCIO.H has been
					   customized for your system!   */

/* Device-specific definitions...	   Input status flag:		*/
#define	ISTAT	((CIMASK & inp(CSTAT)) == (CAHI ? CIMASK : 0))
					/* character output status:	*/
#define	OSTAT	((COMASK & inp(CSTAT)) == (CAHI ? COMASK : 0))

/* Internal static definitions.						*/
#define	Freeze	(static[1])		/* true if output frozen (^S) */
#define	Pending	(static[2])		/* true if input char waiting */
#define	PendCh	(static[3])		/* the pending input char     */
#define	Mode	(static[4])		/* input mode bits:	     */
#define	M_echo	1			/* echo mode bit		*/
#define	M_quit	2			/* ^C (quit) mode bit		*/
#define	M_flow	4			/* ^S/^Q flow control		*/
#define	M_strip	8			/* strip to 7-bits		*/
#define	M_expan	16			/* Expand \n on output.		*/

#define	QuitC	(static[5])


putchar(c) {  rawio(1, c); }

getchar() { return rawio(2); }

kbhit() { return rawio(3); }

TTYMode(mode) { return rawio(4, mode); } /* set mode bits, returns prev. */

rawio(key, arg)
 {	char ch, *static, mode;
	static = "Nonsense!";

	if (*static == 'N')		/* Initialization ...	*/
	 { *static = Freeze = Pending = 0;
	   Mode = M_echo | M_quit | M_flow | M_strip | M_expan;
	   QuitC = 3; }

Again:	if (ISTAT)		/* check for input pending.	*/
	 { ch = inp(CDATA);
	   if ((mode=Mode) & M_strip) ch &= 0x7F;
	   if ((mode & M_quit) && (ch == QuitC)) exit();
	   else if (mode & M_flow)
		{ if (ch == ('S'-64)) { Freeze=1; goto brk; }
		  if (ch == ('Q'-64)) { Freeze=0; goto brk; }}
	   if (!Pending)
		{ Pending = 1;
		  PendCh = ch;
		  if (mode & M_echo) outp(CDATA, ch); }}

brk:	switch(key)
	 { case 0:	return;
	   case 1:	if (Freeze || !OSTAT) goto Again;  /* putchar(arg) */
			outp(CDATA, arg);
			if ((arg == '\n') && (Mode & M_expan))
				putchar('\r');
			return arg;
	   case 2:	if (!Pending) goto Again;
			Pending = 0; return PendCh;
	   case 3:	return Pending;
	   case 4:	mode = Mode; Mode = arg;
			if (!(arg & M_flow)) Freeze = 0;
			return mode;
	   default:	return;
	 }
 }

