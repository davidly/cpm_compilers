
/*
	BDS Telnet Version 2  (the first version was worthless)

	written by Leor Zolman and Leo Kenen
		   (mainly between the hours of 1am and 3am
		    over the phone)
		   December 1979

	See the write up by Leo for more details than are
	presented here.

	******************************************
	* Telnet assumes that your CP/M console  *
	* I/O device is much faster than your	 *
	* modem. On a 2MHz 8080, the modem can	 *
	* be receiving at up to 300 baud as long *
	* as your console whips along (at the	 *
	* very least) at about 1200. 4 MHz mach- *
	* ines might be able to get away with	 *
	* slower terminals, but not much slower. *
	******************************************

"Telnet" is a program which interacts with a modem to turn
 your microcomputer into a very versatile terminal. Special
 commands are entered to the program by typing the character
 you designate as "SPECIAL", i.e, some character (such as the
 null or ^A ) which you wouldn't be likely to need transmitted,
 and then entering the appropriate command letter. Incoming
 data may be buffered up in RAM memory and dumped to disk
 whenever you desire (via the "o", "d", "c" and "k" commands),
 data may be transmitted from disk to modem (via "t" and "a"),
 or files can be formally transferred in an alternate
 "checksum" mode which handles handshaking and buffering
 automatically when interacting with the same program on
 the other end of the line. During file transfers, you
 may temporarily pause and later resume the transmission
 (via the "p" and "r" commands.) There are also various
 options you can control (see "n", "7", "h" and "l") to
 adapt operation toward the type of file you wish to
 transfer. The "q" command closes the output file (if open)
 and quits to CP/M. The "s" command displays the status of
 the program. "z" clears the console screen. Any other
 command letter (such as, for example, "?") causes a list
 of legal commands to be displayed.

In order to transmit or receive files in the checksum
mode, both parties must make sure that their modems are
operating in FULL-DUPLEX. When you are in full duplex,
then what you type will NOT come right back at you from the
modem; the only input you see from the modem is the data
transmitted by the machine on the OTHER end of the line.

This program considers "half duplex" to be any situation
in which the data you transmit comes right back at you;
whether it is your modem that is performing the ehoing
or a computer system far away doesn't really matter. In any
case, checksumming and handshaking is not allowed under half-
duplex operation, since erroneous characters would be received.
When you run telnet, it will ask you whether
or not you are in half-duplex, and perform accordingly. If
you switch from half to full or vice-versa while running the
program, use the "h" option to inform telnet of the fact.

To perform checksummed file transfer, a connection must
first be established between the two parties. If both
parties are operating in full duplex, one originating and the
other answering, then telnet will both display what each
types to the console and send it to the modem. If a file
then needs to be transferred, then one user would give the
"t" command (to transmit) and the other would give the "o"
command (to open an output file.) If both users indicate
checksum mode (rather than only one specifing checksum mode
which will abort almost immediatly), then telnet will take
it from there and perform the transfer. If the sender
(transmitter) wants to suspend the transfer temporarily and
continue later, he can use the "p" command. When the receiver
sees that transmission has been suspended (when no data has
been sent for a long time), then HE gives the "p" command also,
and both users may type to each other. When ready to resume,
the "r" command must be given by the RECEIVER first, and
then the sender, to prevent data from being lost.



 Before using this program for the first time, you must
 make sure that all the "#define"s are set in accordance with
 your hardware. The program is set up to handle any status
 driven keyboard and modem devices. All you do is enter the
 vital information on port numbers, relevent bits, whether
 active high or low, etc.

Here is a description of the internal handshaking protocol for
checksummed file transfer (you don't have to read this to
use checksum mode):


1. Establishing a connection:

The transmitting system will send out a null byte every few
seconds until an acknowledging null is received from the
receiver, whereupon connection is established and data begins
to be transmitted. If no acknowledging null is ever received,
the transmitting user may abort by typing a SPECIAL on his
keyboard. When the acknowledging null is revieved both the
receiver and transmitter will be in sync with one another.
If this sync goes "out of sync" at any time during the tranfer,
then the process will be automaticlly aborted.

The receiver, analogously, will sit and wait for a null to
come in before beginning to buffer up data. As soon as a
null comes in, the receiver will send out a null of his own
and begin to buffer up data. Typing SPECIAL will abort the
attempt to establish a connection.

2. Transmission of data, sector by sector:

The transmitter sends out 128 bytes of data, and then waits
for a two byte checksum to come back from the receiver.

If the checksum is OK, then:
	if there is no more data, an EOT (^D) byte is sent and
		we're all done.
	else, an ACK (^F) byte is sent and we go back to send
		the next sector.
else there was an error, so we send a NAK (^U) byte and resend
the sector until we get it RIGHT.
If the transmitter whishes to abort, an ETX (^C) will be sent
to the receiver (so both can terminate the transfer).
After all checksumming has "checked out", an FDH is traded
between machines to insure (almost) that both systems are in
sync.

The receiver gobbles up 128 bytes of data, then sends out
2 bytes worth of checksum, and waits for a response. If
the response is NAK, the sector must be re-received.
If the response is ACK, all is well and we go get another
sector. If the response is EOT, we is FINISHED!!!
The only other possibility is that an ETX (^C) is received,
informing the receiver that the transmitter has aborted the
transfer. When this happens the file will be closed and
all of the valid data which has been received will be saved.

If the receiver wishes to abort a transfer prematurely, the
SPECIAL 'a' will both close the open file and send out an
ETX to inform the transmitter of the abortion.


*/

#define SPECIAL 0x00	/* The character you type to
			   signal a Telnet command (should
			   be obscure...I use a null)	*/
#define CPMSIZE 48	/* Amount of RAM used by CP/M in
			   your system (in K)		*/
#define CLEARS "\032"	/* string which, when output to
			   your CP/M console output, will
			   clear the screen (assuming you
			   have a video console...if not,
			   just make this "\n" or some-
			   thing)			*/

#define KBSTAT	0x00	/* Keyboard status port 	*/
#define KBIMASK 0x01	/* Keyboard status input mask	*/
#define KBAHI	0	/* 1 if kb status is active hi	*/
#define KBDATA	0x02	/* Keyboard data port		*/
#define KBRESET 0	/* 1 if status port needs to be
			   reset after sampling data from
			   keyboard			*/
#define KBRVAL 0x00	/* value to send to KB status port
			   (needed only if KBRESET = 1) */


#define MSTAT	0x00	/* Modem status port		*/
#define MIMASK	0x40	/* Modem input status mask	*/
#define MOMASK	0x80	/* Modem output status mask	*/
#define MAHI	1	/* 1 if modem status active hi	*/
#define MDATA	0x01	/* Modem data port		*/
#define MRESET 0	/* 1 if modem status port needs
			   to be reset after sampling
			   modem data port		*/
#define MRVAL 0		/* value to send to modem status
			   port to reset (only needed if
			   MRESET is 1)			*/

/*
	The following #defines need not be changed by the user
*/

#define BUFSIZ ((CPMSIZE-25)*1024)
#define	ACK	0x06	/* Ascii ACK for handshaking */
#define	NAK	0x15
#define	EOT	0x04	/* End of transmission */
#define	ETX	0x03	/* Abort Transmission */
#define CPMEOF	0x1a	/* CP/M end of text file byte */


/*
	External variable declarations:
*/

char rflag;		/* receiving file open flag	*/
char tflag;		/* transmitting file open flag	*/
char chflag;		/* checksumming enabled flag	*/
char cflag;		/* text-collection enabled flag */
char pflag;		/* pausing flag 		*/
char spflag;		/* stripping parity bit flag	*/
char lflag;		/* list device enabled flag	*/
char nflag;		/* recognizing nulls flag	*/
char fflag;		/* true if changing CR-LF's into
			    just CR when transmitting	*/
char lastc;		/* last char xmitted		*/
char dodflag;		/* true if displaying outging
			   data				*/
char didflag;		/* true if displaying incoming
			   data				*/
char hdflag;		/* true if effectively working
			   in half-duplex		*/
char abortf;		/* true when file I/O aborted	*/
char rbuf[134]; 	/* file I/O buffer for incoming
			   data file			*/
char tbuf[128]; 	/* file buffer for file being
			   transmitted			*/
char rname[20]; 	/* name of receiving file	*/
char tname[20]; 	/* name of transmitting file	*/

int rfd, tfd;		/* file descriptors		*/

char buf[BUFSIZ];	/* text collection buffer	*/
char *cptr;		/* pointer to free space in buf */
unsigned free;		/* number of bytes free in buf	*/
int bcount;		/* counts bytes in current block
			   when checksumming		*/
int scount;		/* Number of sectors sent/received */
int checksum;		/* the checksum value itself	*/
char *i;		/* odd-job char pointer 	*/

char toupper();		/* This makes for better code than
			   if we let it default to "int" */

/*
	Routine to return true if input is present on
	the modem:
*/

miready()
{
	return (inp(MSTAT) & MIMASK) == (MAHI ? MIMASK : 0);
}


/*
	Routine to return true if modem is ready to output
	a byte:
*/

moready()
{
	return (inp(MSTAT) & MOMASK) == (MAHI ? MOMASK : 0);
}


/*
	Routine to return true if keyboard has data
	available:
*/

kbready()
{
	return (inp(KBSTAT) & KBIMASK)==(KBAHI ? KBIMASK : 0);
}


main ()
{
	char c, c2;
	int n;
	int dod_sav, did_sav;
	printf("BDS Telnet version 2  (Dec. 79)\n");
	cflag = nflag = lflag = pflag = abortf = fflag = 0;
	spflag = 1;
	lastc = 0;
	printf("\nAnswer `y' if either your modem is set to half-duplex,\n");
	printf("or you expect an echo from the system on the");
	printf(" other end\n");
	printf("of the line; else answer `n':\n");
	hdflag = ask("Do you expect an echo");
	reset();
	printf("OK; you're on line...\n\n");

	outp(0,4);	/* Any hardware-dependent modem
			   port initailization should go
			   here.			*/

  loop:	if (abortf) {
		if (rflag) rclose();
		if (tflag) tabort();
		abortf = 0;
	}

	if (tflag && xmit()) {
			printf("\nTransmission complete.\n");
			close(tfd);
			reset();
		    }
	if (abortf) goto loop;
	if (miready()) {
	  c = c2 = getmod();
	  if (spflag) c &= 0x7f;
	  if (tflag && (c == ETX)) {
		printf("Reciever has aborted;\n");
		abortf = 1;
		goto loop;
		}
	  if (didflag && (c || nflag) && (c != CPMEOF))
			display(c);
	  if (cflag && !pflag) {
	    if (c || nflag)
	      if (!free) printf("**BUFFER FULL**\007\007");
	      else { *cptr++ = c; free--; }
	    if (chflag) {
		checksum += c2;
		bcount++;
		if (bcount == 128) {
		  bcount = 0;
		  outmod(checksum >> 8);
		  outmod(checksum);
		  checksum = 0;
		  c = getmod();
		  if ( c == NAK) {
		    cptr -= 128;
		    free += 128;
		    printf("\nChecksum error. Retrying <%d>\n",scount);
		    outmod(0xFD);
		  }
		  else {
		    if (cptr > buf+1000) rdump(0);
		    if (c == EOT) {
			rclose();
			printf("\n%s recieved OK\n",rname);
		    }
		    else if (c == ACK){
			if (!didflag) printf("Good sector  <%d>\n",scount);
			outmod(0xFD);
			scount++;
		    }
		    else { 
			   printf("Aborted, after %d",scount);
			   printf(" good sectors;\n");
			   cptr -= 128;
			   abortf = 1;
			}
		  }
		}
	      }
	  }
	}
	
	if (kbready()) {
	  c = getch2();
	  if (c != SPECIAL) {
	    if (pflag || (!tflag && !(rflag && chflag))) {
		outmod(c);
		if (dodflag) display(c);
	      }
	   }
	  else {
	    printf("\nSpecial: ");
	    putch (c = getch());
	    if (c != '\r') printf("  ");
	    switch (toupper(c)) {
		case '\r':  goto lf;
		case SPECIAL: outmod(SPECIAL);
			      printf("Special char sent\n");
			      break;
		case '7':  spflag = ask("Strip parity");
			   break;
		case 'N':  nflag = ask("Recognize incoming nulls");
			   break;
		case 'H':  if (rflag || tflag)  { printf(
			    "Must abort transfer first\n");
			    break;
			    }
			   printf("\nAre you either at half");
			   printf("-duplex or getting an ");
			   hdflag = ask ("echo");
			   reset();
			   break;
		case 'L':  lflag = ask("List incoming data");
			   break;
		case 'Z':  printf(CLEARS);
			   break;
		case 'P':  if (pflag) printf("Already pausing");
			   else {
				pflag = 1;
				dod_sav = dodflag;
				did_sav = didflag;
				dodflag = !hdflag;
				didflag = 1;
			   }
			   goto lf;
		case 'R':  if (!pflag) printf("Not pausing");
			   else {
				pflag = 0;
				dodflag = dod_sav;
				didflag = did_sav;
			   }
			   goto lf;
		case 'K':  printf("Text buffer !ZAPPED!");
			   free = BUFSIZ;
			   cptr = buf;
			   goto lf;
		case 'V':  if (rflag) {
				putch('\n');
				i = buf;
				while (i < cptr) putch(*i++);
				printf("\n%u bytes free",free);
			    }
			   else printf("No recieving file open");
			   goto lf;
		case 'O':  if (rflag) rclose();
			   if (tflag) tabort();
			   printf("\nOutput filename? ");
			   gets(rname);
			   rflag = 1;
			   if (!askstuff()) {
				rflag = 0;
				goto loop;
			   }
			   printf("Creating %s...",rname);
			   rfd = fcreat(rname,rbuf);
			   if (rfd == -1) {
				printf("Cannot create %s\n",rname);
				reset();
				break;
			    }
			   putch('\n');
			   cptr = buf;
			   free = BUFSIZ;
			   rflag = cflag = 1;
			   pflag = checksum = bcount = 0;
			   if (chflag) {
				printf("Trying to link...");
				do {
				  c = getmod();
				  if (abortf) {
				    printf("aborting...\n");
				    unlink(rname);
				    reset();
				    goto loop;
				  }
				} while (c & 0x7f);
				printf("linked.\n");
				outmod(0);
			    }
			   break;
		case 'D':  if (rflag) rdump(1);
			   else printf("No output file");
			   goto lf;
		case 'C':  if (rflag) rclose();
			   else printf("No output file");
			   goto lf;
		case 'Q':  if (tflag) tabort();
			   if (rflag) rclose();
			   outp(0,8);	/* hardware dependent port
					   fudging		*/
			   exit();
		case 'A':  if (tflag || rflag) {
  					 outmod(ETX);
					 abortf = 1;
 				         break;
				     }
			   printf("No transfer to abort.\n");
			   goto lf;
		case 'T':  if (tflag) tabort();
			   if (rflag) rclose();
			   printf("\nFile to transmit? ");
			   gets(tname);
			   tflag = 1;
			   if (!askstuff()) {
				tflag = 0;
				goto loop;
			   }
			   tfd = open(tname,0);
			   if (tfd == -1) {
				printf("Cannot open %s\n",tname);
				reset();
				goto lf;
			    }
			   pflag = checksum = bcount = 0;
			   if (read(tfd,tbuf,1) <=0) {
			    printf("Read error from %s\n",
					tname);
			    abortf = 1;
			    goto loop;
			   }
			   if (chflag) {
			    printf("Trying to link...");
			    while (1) {
			     outmod(0);
			     for (n=0; n<5000; n++)
				if (miready()) {
				 if( !(getmod() & 0x7f)) {
					printf("linked.\n");
					goto loop;
				  }
				 }
				else if (kbabort()) {
					printf("aborting.\n");
					goto loop;
				     }
			     }
			    }
			break;

		case 'S':  putch('\n');
			   if (rflag) {
				printf("Output file = %s\n",rname);
				printf("Text buffer has %u bytes free",
					free);
				printf("\nText collection %s\n",
					cflag ? "enabled" : "disabled");
			    }
			   else printf("No output file\n");
			   if (tflag) printf("Transmitting: %s\n",
						tname);
			   else printf("Not transmitting any file\n");
			   if (pflag) printf("Pausing\n");
			   printf("Incoming nulls are being %s\n",
				 nflag ?"collected" : "ignored");
			   printf("Parity bits are being %s\n",
				 spflag ?"stripped" : "preserved");
			   printf("Half-duplex mode: %s",
				hdflag ? "on" : "off");
			   goto lf;

	  default: printf("BDS Telnet commands are:\n");
		   printf("Double SPECIAL: send SPECIAL\n");
		   printf("o: open output file, start collection\n");
		   printf("p: pause (suspend collection or transmission)");
		   printf("  r: resume\n");
		   printf("d: dump (append) text buffer to output file\n");
		   printf("c: dump buffer and close output file\n");
		   printf("v: view contents of text buffer\n");
		   printf("k: kill (erase) contents of text buffer\n");
		   printf("t: transmit a file to modem\n");
		   printf("a: abort transfer of file\n");
		   printf("n: accept or ignore nulls\n");
		   printf("7: choose policy regarding parity bits\n");
		   printf("h: set half/full duplex mode\n");
		   printf("l: control CP/M list device\n");
		   printf("z: clear console terminal screen\n");
		   printf("s: display status of Telnet\n");
		   printf("q: dump & close output file (if open) and quit");
	  lf:	   putch('\n');
	  }}
	}
	goto loop;
}

/*
	Get all the info pertinent to a file transfer; i.e,
	whether or not the file is text (and needs parity
	stripped, nulls ignored, echoing to console, etc.),
	whether or not checksumming and handshaking are
	required (they always go together), and make sure
	the user is in full duplex mode.
*/

askstuff()
{
	printf("\n%s ",rflag ? "recieving" : "transmitting");
	if (ask("text (y) or binary data (n)  ")) {
		nflag = 0;
		spflag = didflag = 1;
		dodflag = !hdflag;
		printf("Stripping parity, ignoring nulls,\n");
		printf("  %sdisplaying %s data.\n",
		(rflag ? didflag : dodflag) ? "" : "not ",
			rflag ? "incoming" : "outgoing");
	}	
	else {
		spflag = didflag = dodflag = 0;
		nflag = 1;
		printf("%s all data verbatim, and not\n",
			rflag ? "Recieving" : "Sending");
		printf("displaying it on the console.\n");
	 }

	putch('\n');
	printf("Handshaking & checksumming can only happen\n");
	printf("if the other computer has this same program\n");
	printf("running. Do you want handshaking & checksumming");
	chflag = ask("");
	if (chflag && hdflag) {
		printf("Can't do it unless you can eliminate");
		printf(" the echo! Aborting.\n");
		return 0;
	}
	scount = 1;
	return ask("OK...type y to begin, n to abort:");
}

/*
	Routine to print out a string and return true
	if the user responds positively
*/

int ask(s)
char *s;
{
	char c;
	if (kbready()) getch2();
	printf("%s ",s);
	do {
	printf("(y/n)? ");
	putch (c = getch());
	putch('\n');
	} while ( (c = toupper(c)) != 'N' && c != 'Y');
	return ( c == 'Y');
}


/*
	Routine to dump contents of the memory text buffer
	to the output file and clear the buffer for more
	data:
	(Note that the "else putch('\0');" clause may not
	be necessary on your system; this is here only to
	make up for a strange "feature" of Lifeboat's 
	Northstar CBIOS where disk polling happens during
	console output, potentially causing bytes to be 
	missed from the modem.)
*/

rdump(n)
{
	for (i=buf; i<cptr; i++) putc(*i,rbuf);
	cptr = buf;
	free = BUFSIZ;
	if (n) printf("\nBuffer written\n");
	else putch('\0');
}


/*
	Routine to dump and close the output file:
*/

rclose()
{
	rdump(1);
	printf(" Closing %s ",rname);
	putc(CPMEOF,rbuf);
	fflush(rbuf);
	close(rfd);
	reset();
	putch('\n');
}

/*
	Routine to reset telnet
*/

reset()
{
	rflag = tflag = chflag = cflag = 0;
	scount = spflag = 1;
	dodflag = !hdflag;
	didflag = 1;
}


/*
	Get a byte from the modem:
	(If the user types anything on the keyboard before
	 the modem manages to come up with a byte, then all
	 file I/O is aborted.)
*/

getmod()
{
	char c;
	while (!miready())
	   if (kbabort()) return;
	c = inp(MDATA);
	if (MRESET) outp(MSTAT,MRVAL);
	return c;
}


/*
	Output a byte to the modem:
	(If the user types a SPECIAL on the keybard before
	 the modem becomes ready to transmit the character,
	 then the general alarm is sounded and all file I/O
	 is aborted.)
*/


outmod(c)
char c;
{
	while (!moready())
	    if (kbabort()) return;
	outp(MDATA,c);
}


/*
	Get a character from the keyboard:
*/

getch()
{
	while (!kbready());
	return getch2();
}

getch2()
{
	char c;
	c = inp(KBDATA) & 0x7f;
	if (KBRESET) outp(KBSTAT,KBRVAL);
	return c;
}

/*
	Return true if keyboard hit and SPECIAL
	typed:
*/

kbabort()
{
	if (kbready() && getch2() == SPECIAL) {
		abortf = 1;
		return 1;
	}
	return 0;
}


/*
	Abort transmission of file:
*/

tabort()
{
	if (chflag)  while (bcount++ != 133) outmod(ETX);
	printf("\nTransmission of %s aborted.\n",tname);
 	close(tfd);
	reset();
}


/*
	At first glance, the following function may not
	seem to do very much. Yet, it is necessary, for
	the following subtle reason: Should the normal
	"putchar" routine ever get called, there's the
	chance that it might intercept a control-C and
	abort to CP/M. We don't want this to happen; we'd 
	rather always call "putch" for console output. So,
	you say, just make sure there aren't any calls to
	putchar! Well, even if there aren't any EXPLICIT
	calls to putchar, there are plenty of calls to
	printf...and printf DOES call putchar! So, in order
	to fake out the printf function, we'll define
	putchar in terms of putch and make sure that the
	library version of putchar never gets yanked.
*/


putchar(c)
char c;
{
     putch(c);
}

/*
	transmit a character of the file being transmitted:
*/

xmit()
{
	int incheck;
	char c;
	if (pflag || !moready()) return 0;
	c = tbuf[bcount++];
	checksum += c;
	if (!(!chflag && c=='\n' && lastc=='\r' &&
	      !nflag && fflag)) outmod(c);
	lastc = c;
	if (dodflag) display(c);
	if (bcount != 128) return 0;
	bcount = 0;
	if (!chflag) return !read1();
	incheck = (getmod() << 8) + getmod();
	if (incheck != checksum) {
		printf("\nError. Resending sector %d...\n",scount);
		outmod(NAK);
	}
	else if (read1()) {
		if (!dodflag) printf("Good sector <%d>\n",scount);
		outmod(ACK);
		scount++;
	}
          else { outmod(EOT); return 1; }

	checksum = 0;
	if (getmod() != 0xFD) {
			printf("\nPhase error; aborting...");
			abortf = 1;
			}
	return 0;
}


/*
	Read a sector of the transmission file:
*/

read1()
{
	int i;
	i = read(tfd, tbuf, 1);
	if ( i == -1) {
		printf("\nRead error from %s; Aborting.\n",
			tname);
		tabort();
	 }
	return i;
}


/*
	Write character to console display, and also to
	system list device if that is enabled:
	(Note that "putch" is used instead of "putchar"
	because we don't want the console input sampled
	for control-C or anything else during output)
*/

display(c)
char c;
{
	if (c==CPMEOF) return;
	putch(c);
	if (lflag) bdos(5,c);
}

 TELNET  C     ÄÄÅÇÉÑÖÜáàâäãåçéè TELNET  C    9êëíìîïñó         TABIFY  C     òôö              CONVERT C     õúùû            