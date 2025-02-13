/*	seek.c - move to another position in an open file.  (7/23/83)
 *	Usage: seek(fdes,offset,type)
 *		  The read/write pointer for the file open on
 *		channel "fdes" is moved "offset" bytes forward
 *		or backward from:
 *			type =	0: beginning of file
 *				1: current location
 *				2: end of file
 *		If type = 3, 4 or 5, the pointer is moved "offset"
 *		records (256 bytes) instead.  Returns -1 for error, else 0.
 *		  The first version of this routine was written and
 *		contributed by Al Bolduc, 37 Catherine Av., Reading, MA.
 *
 *	Usage: ftell(fdes); ftellr(fdes);
 *		  Ftell returns the current offset of file fdes.  If the
 *		current position is more than 65K bytes down the file, the
 *		value returned will only be correct mod 256.  Ftellr returns
 *		the offset in records, for use on long files.
 *
 *	Change history:
 *		7/23/83:  Ftell wrong in last CP/M sector if odd.
 *		2/24/83:  Bug in ftellr (off by 1 at byte 0).
 *		2/5/82:   Bug in ftellr (off by 1).
 *		11/14/81: Don't try to read ahead on non-update files.
 *		10/21/81: Original release.
 */
#define CPM 0		/* Defined for CP/M version; comment out for HDOS */

extern	int	IObuf[],IOind[],IOsect[];
extern	char	IOmode[],IObin[],IOrw[];
int Sought[] = {0,0,0,0,0,0,0,0};	/* Have we done a seek on channel? */

#ifdef CPM
extern	int	IOfcb[];
#define BDOS 5
#define EOF 26		/* Ctrl-Z fills at end of file */
#define RECSIZ 128

#else
#define EOF 0		/* 0 fills at end of file */
#define RECSIZ 256
#endif

seek(fdes,offset,type)
int fdes,offset,type; {
	static int sector,byte,tmp,b,mode,rflag;
	static char *buf,*p;

	rflag = 0;
	if ((mode = IOmode[fdes]) != 'r') {
		skinit();	 /* Trap writes in putc */
		if (IOind[fdes] & 255) /* Write current record out */
			write(fdes,IObuf[fdes],256); }

	if (type > 2) { sector = offset; byte = 0; type =- 3; }
		else { sector = offset / 256; byte = offset % 256; }

	switch(type) {
		case 1: sector =+ ftellr(fdes);
			byte =+ 0377 & ftell(fdes);
		case 0: doit:
			if (byte < 0) { --sector; byte =+ 256; }
			sector =+ byte / 256;
			byte =% 256;
#ifdef CPM
			if (rflag == 0 || sector != tmp)
#endif
			 {  if (pos(sector,fdes)) return -1;
			    if (read(fdes,IObuf[fdes],256) <= 0) {
				    if (mode == 'r' || byte) return -1;
#ifndef CPM
				    for (p = 256 + (buf = IObuf[fdes]);
						p != buf; *--p = EOF);
#endif
			 }	    }
			if (byte == 0) { mode = byte = 256; }
			if (mode != 'r') {IOrw[fdes] = 0;
					  pos(sector,fdes);
#ifdef CPM
					  if (type == 2 && IObin[fdes] != 'b')
					     for (p = 256 + (buf = IObuf[fdes]),
						     rflag = 0; p != buf; buf++)
						if (rflag) *buf = EOF;
						else if (*buf == EOF) rflag = 1;
#endif
					 }
			IOind[fdes] = byte;
			Sought[fdes] = 1;
			return 0;
		case 2: if (offset > 0) return -1;
			b = 256;
#ifdef CPM
			tmp = pos(-1,fdes);
			if (tmp & 1) b = 128;
			tmp = (tmp + 1) >> 1;
#else
			tmp = -1 - pos(-1,fdes);
#endif
			if (IObin[fdes] != 'b') {
				/* ASCII file - find last byte */
				pos(--tmp,fdes);
				if (read(fdes,IObuf[fdes],256) <= 0) return -1;
				rflag = 1;
#ifdef CPM
				for (buf = IObuf[fdes];
						b-- && *buf != EOF; ++buf);
				b = buf - IObuf[fdes];
#else
				for (buf = IObuf[fdes] + b;
						     *--buf == EOF && b; --b);
#endif
				byte =+ b; }
			    else byte =- b & 255;
			sector =+ tmp; goto doit;
		default: return -1;
	}	}

ftell(fdes) int fdes; {
	return (RECSIZ * (IOsect[fdes] - IOrw[fdes]) + IOind[fdes]); }

ftellr(fdes) int fdes; {
	return (IOsect[fdes] - IOrw[fdes]) / (256/RECSIZ); }

/* pos - position over sector.	HDOS: returns 0, or nr. records to
	requested sector from EOF.  CP/M: returns 0, nonzero for error, or
	if sector == -1 returns length of file in 128-byte sectors. */

pos(sector,fdes) int sector,fdes; {
	static int *p,fcb;
	static char *q;
#ifdef CPM		/* CP/M version */
	q = p = 33 + (fcb = IOfcb[fdes-1]);
	if (sector == -1) {		/* Find end of file */
		fcb;
#asm
		XCHG
		MVI C,35	/* Compute file size */
		CALL BDOS
#endasm
		return *p; }
	*p = sector + sector;	/* CP/M sector numbers are double */
	q[2] = 0;		/* Zero high byte */
	IObuf[fdes];
#asm
	MVI C,26	/* Set DMA address */
	MOV M,C 	/* Put EOF there in case we have to write */
	XCHG
	CALL BDOS
#endasm
	fcb;
#asm
	XCHG		/* Read random to set file ptr */
	PUSH D
	MVI C,33
	CALL BDOS
	POP D
	ORA A
	JZ .pos1	/* No error */
	MVI C,34	/* Error: probably past EOF */
	CALL BDOS	/* So try writing next */
	LXI H,-1
	ORA A
	RNZ		/* If still can't, give up. */
.pos1:	DS 0
#endasm
	IOsect[fdes] = sector + sector;    /* If success, remember where */
#else
			/* HDOS version */
#asm
	POP D
	POP H		/* Get channel in H */
	POP B		/* Get sector in B */
	PUSH B
	PUSH H
	PUSH D
	MOV A,L
	DCR A
	DB 255,39	;SCALL 047Q
	MOV H,B
	MOV L,C
	RC
#endasm
	IOsect[fdes] = sector;		/* If success, remember where */
#endif
	return 0;
}

/* Plug putc to read next sector after writing, for file in update mode */
skinit() {
#asm
	LXI H,uputc
	SHLD .PC2+1
#ifdef CPM
	EXT .PC2	; *** Ignore this error. ***
#else
	IF 1		; True in MAC, false in ASM
	EXT .PC2	; *** Ignore this error. ***
	ENDIF
#endif
#endasm
}

/* This routine replaces write() from putc() when a file has been repositioned.
 *	It reads the next record after writing.
 */
uputc(fdes,buf,cnt) int fdes; char *buf; int cnt; {
	static int i;
	static char *p;

	i = write(fdes,buf,cnt);		/* Write it */
	if (IOmode[fdes] == 'u' && Sought[fdes] /* If channel had seek, update*/
	      && read(fdes,buf,cnt))		/* read next sector if there */
		pos(--IOsect[fdes],fdes);	/* and position to write it */
	else for (p = buf + 256; p > buf; *--p = EOF);	/* else erase buffer */
	return i;
	}
PUSH B
	PUSH H
	PUSH D