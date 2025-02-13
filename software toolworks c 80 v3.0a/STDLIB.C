/* stdlib.c - Standard C library - (c) 1983 The Software Toolworks.
   Some of these routines were provided by Jim and Gary Gilbreath.
   The fast str routines were donated by Dr. Jim Gillogly.

   If this file is #included at the end of a source program, routines
   will be compiled automatically as needed.

   In the following, s, t are strings terminated by a 0 byte, and c is
   a char or an int containing an ASCII character.  Other args are ints
   except where noted otherwise.

   abs(i)	Absolute value of i.
   alloc(i)	Returns pointer to i bytes of available memory.
   atoi(s)	Integer value of string s, optional leading +/-,
		stops at first non-digit.
   bdos(c,de)	Calls CP/M bdos with registers shown; returns contents of A,
		as a 16-bit sign-extended number.
   free(p)	Frees up memory at p.  P must have been value returned by alloc.
   getline(s,i) Reads a line from console into s, stopping at newline or i char-
		acters.  0-terminates string; returns length including 0 byte.
   index(s,t)	Position in string s of string t, or -1 if not there.
   isalpha(c)	1 if c is an alphabetic character A-Z or a-z.
   isdigit(c)	1 if c is an ASCII digit 0-9.
   islower(c)	1 if c is a lower case character a-z.
   isspace(c)	1 if c is a blank, tab or newline.
   isupper(c)	1 if c is an upper case character A-Z.
   itoa(i,s)	Converts i to an ASCII string in char s[7]; returns s.
   makfcb(s,fcb) Unpack file name s into char fcb[36] to make a CP/M fcb.
   max(i,j)	The greater of i and j.
   min(i,j)	The lesser of i and j.
   rename(s,t)	Renames the file named s to be called t.  Returns -1 for
		failure, a non-negative number for success.
   strcat(s,t)	Appends t to s.  No checking for overflow of s.
   strcmp(s,t)	-1, 0 or 1 if s < t, s == t, s > t respectively.
   strcpy(s,t)	Copies t into s.  No checking for overflow of s.
   strlen(s)	The number of bytes in s, exclusive of the 0 byte.
		(Note: it takes strlen(s)+1 bytes to hold s.)
   tolower(c)	c, but if upper case it is converted to lower case.
   toupper(c)	c, but if lower case it is converted to upper case.
   unlink(s)	Deletes the file s, if it exists.

   None of these routines calls any other functions, except that the file
   routines call bdos and makfcb. */

/*	*	*/

#ifneed abs
abs(i) { return i < 0 ? -i : i; }
#endif

/*	*	*/

#ifneed alloc,free
/* alloc and free - (c) 1983 Walt Bilofsky.

  Usage: alloc(n) returns pointer to n bytes of memory. 
	 free(p) returns memory at p to free pool; p must have
		been gotten from alloc.
	 Uses: sbrk(). */

static struct _block {
	unsigned _size;
	char *_next; }
    freelist = { 0, -1 };		/* -1 is largest unsigned */

#define PSIZE sizeof(unsigned)		/* Size of header word */
#define TRIFLE sizeof(struct _block)	/* Largest allowable wastage */

alloc(n) unsigned n; {
	static char *p,*pn;
	static int size;
	if ((n =+ PSIZE) < sizeof(struct _block))
				n = sizeof(struct _block);
	for (;;) {
		for (p = &freelist; (pn = p->_next) != -1; p = pn)
			if (n <= pn->_size) {
				/* Decide whether to fragment block */
				if (n + TRIFLE <= pn->_size) {
					p = p->_next = pn + n;
					p->_size = pn->_size - n;
					pn->_size = n; }
				p->_next = pn->_next;
				return pn + PSIZE; }
		if ((p = sbrk(size = n < 1024 ? 1024 : n)) == -1) return -1;
		p->_size = size;
		free(p + PSIZE);
	}	}

free(q) char *q; {
	static char *p, *pn;
	q =- PSIZE;
	for (p = &freelist; p != -1; p = pn)
	    if ((pn = p->_next) > q) {
		/* Merge with following block? */
		if (q + q->_size == pn) {
			q->_size =+ pn->_size;
			pn = pn->_next; }
		/* Merge with preceding block? */
		if (p + p->_size == q) {
			p->_size =+ q->_size;
			q = p; }
		p->_next = q;
		q->_next = pn;
		return; }
	}
#endif

/*	*	*/

#ifneed atoi
atoi(s)        /* convert string to integer */
char *s;
{
	static int n, sign;
	sign = 1;
	n = 0;
	switch (*s) {
		case '-': sign = -1;
		case '+': ++s;
		}
	while (*s >= '0' && *s <= '9') n = 10 * n + *s++ - '0';
	return(sign * n);
}
#endif

/*	*	*/

#ifneed getline
/* getline - get a string from the console.  Returns length of the string,
	0 terminated, without the newline at the end. */
getline(s,lim)
char *s;
{	static char *t;

	for (t = s; --lim > 0 && (*t = getchar()) != '\n' && *t != -1; ++t);
	*t = '\0';
	return t - s;
}
#endif

/*	*	*/

#ifneed index
index(s,t)	/* find string t in s, return index, or -1 if fail*/
char s[], t[];
{
	static int i,j,k;

	for (i = 0; s[i] != '\0'; i++) {
	   for (j=i,k=0; t[k] != '\0' && s[j]==t[k]; ++j, ++k)
		;
	   if (t[k] == '\0') return(i);
	}
	return(-1); /* no match*/
}
#endif

/*	*	*/

#ifneed isalpha
/* isalpha  -  is the input in [A..Z, a..z] ?
*/
isalpha(c) {
/*  return (('A' <= c && c <= 'Z') || ('a' <= c && c <= 'z')); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'A'
	RC
	CPI 'z'+1
	RNC
	INR L
	CPI 'a'
	RNC
	CPI 'Z'+1
	RC
	DCR L
#endasm
}
#endif

/*	*	*/

#ifneed isdigit
/* isdigit  -  is the input in [0..9] ?
*/
isdigit(c) {
/*  return ('0' <= c && c <= '9'); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI '0'
	RC
	CPI '9'+1
	RNC
	INR L
#endasm
}
#endif

/*	*	*/

#ifneed islower
/* islower  -  is the input in [a..z] ?
*/
islower(c) {
/*  return ('a' <= c && c <= 'z'); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'a'
	RC
	CPI 'z'+1
	RNC
	INR L
#endasm
}
#endif

/*	*	*/

#ifneed isspace
/* isspace  -  is the input blank ?
*/
isspace(c)
{   switch (c) {
	case ' ': case '\t': case '\n': return 1; }
    return 0;
}
#endif

/*	*	*/

#ifneed isupper
/* isupper  -  is the input in [A..Z] ?
*/
isupper(c) {
/*  return ('A' <= c && c <= 'Z'); */
#asm
	LXI H,2
	DAD SP
	MOV A,M
	LXI H,0
	CPI 'A'
	RC
	CPI 'Z'+1
	RNC
	INR L
#endasm
}
#endif

/*	*	*/

#ifneed itoa
/* itoa - convert n to characters in s. */
char *itoa(n, s)
char s[];
int n;
{
	static int c, k;
	static char *p, *q;

	if ((k = n) < 0)
		k = -k;
	q = p = s;
	do {
		*p++ = k % 10 + '0';
	} while (k /= 10);
	if (n < 0) *p++ = '-';
	*p = 0;
	while (q < --p) {
		c = *q; *q++ = *p; *p = c; }
	return (s);
}
#endif

/*	*	*/

#ifneed min
min(i,j) { return i < j ? i : j; }
#endif

/*	*	*/

#ifneed max
max(i,j) { return i > j ? i : j; }
#endif

/*	*	*/

#ifneed rename
/* rename - rename oldfile to be newfile  */

rename(old,new)
char *old,*new;
{
	char fcb[54];

	makfcb(new,fcb+16);	       /* enter new name */
	makfcb(old,fcb);	       /* and old one. */
	bdos(26, 0x80); 	       /* first, set dma addr to junk area */
	return bdos(23,fcb);	       /* rename it */
}
#endif

/*	*	*/

#ifneed strcat
/* Copy 0-terminated string tt onto end of 0-terminated string ss */
strcat(ss,tt)
char ss[], tt[];
{
	while (*ss) ++ss;		/* find end of string */
	while (*ss++ = *tt++);		/* copy til zero byte */
}
#endif

/*	*	*/

#ifneed strcmp
strcmp(str1, str2)
char *str1, *str2;
{
#asm
	POP	B	; return address
	POP	H	; get first string (str2)
	POP	D	; get second string (str1)
	PUSH	D	; restore stack for caller
	PUSH	H
	PUSH	B
SCLOOP: LDAX	D	; get next byte from second string
	CMP	M	; compare that with first string
	JNZ	SCDIFF	; they didn't compare
	INX	D	; increment both pointers
	INX	H
	ORA	A	; both the same.  see if both zero
	JNZ	SCLOOP	; nope.  get the next ones
	LXI	H,0	; yup.	they matched all the way to the null
	JMP	SCRET	; unified return for timing
SCDIFF: LXI	H,-1	;
	JC	SCRET	; first string < second string
	LXI	H,1	; first string > second string
SCRET:	DS	0	; unified return
#endasm
}
#endif

/*	*	*/

#ifneed strcpy
strcpy(to, from)
char *to, *from;
{
#asm
	POP	B	; return address
	POP	H	; get from arg
	POP	D	; get to arg
	PUSH	D	; restore stack for caller
	PUSH	H
	PUSH	B
	DCX	H	; back off for a running start
STLOOP: INX	H	; point at next FROM char
	MOV	A,M	; put it into accumulator
	STAX	D	; store it in TO string
	INX	D	; increment TO string
	ORA	A	; check for last char
	JNZ	STLOOP	; copied the 0 byte.  Go away.
#endasm
}
#endif

/*	*	*/

#ifneed strlen
strlen(string)
char *string;
{
#asm
	POP	B	; return address
	POP	D	; the string
	PUSH	D	; restore stack
	PUSH	B
	LXI	H,0	; initialize length
SLLOOP: LDAX	D	; get next char
	ORA	A	; test for zero
	JZ	SLDONE	; end of string
	INX	D	; point at next character
	INX	H	; increment counter
	JMP	SLLOOP	; and around again
SLDONE: DS	0	; fall through for timer
#endasm
}
#endif

/*	*	*/

#ifneed tolower
/* tolower  -  if the input is in [A..Z], convert to lower case
*/
tolower(c) {
/*  if ('A' <= c && c <= 'Z')
	return (c + 0x20);
    return c;		*/
#asm
	LXI H,2
	DAD SP
	MOV L,M
	MVI H,0
	MOV A,L
	CPI 'A'
	RC
	CPI 'Z'+1
	RNC
	XRI 20H
	MOV L,A
#endasm
}
#endif

/*	*	*/

#ifneed toupper
/* toupper - Convert character to upper case if in [a..z].  */
toupper(c) {
/*	if ('a' <= c && c <= 'z')
		return (c - 0x20);
	return (c);			*/
#asm
	LXI H,2
	DAD SP
	MOV L,M
	MVI H,0
	MOV A,L
	CPI 'a'
	RC
	CPI 'z'+1
	RNC
	XRI 20H
	MOV L,A
#endasm
}
#endif

/*	*	*/

#ifneed unlink
/* unlink - remove (erase) a file from the file directory  */

unlink(name)
char *name[];
{
	char fcb[36];

	makfcb(name,fcb);	       /* make fcb for name */
	bdos(26,0x80);		       /* first, set dma addr to junk area */
	bdos(19, fcb);		       /* erase the file */
}
#endif

/*	*	*/

#ifneed makfcb
/* makfcb(file,fcb) - unpack filename into char fcb[36]. */
makfcb(file,fcb) {
#asm
	POP B
	POP H
	POP D
	PUSH D
	PUSH H
	PUSH B
#endasm
	x_fcb();
}
#endif

/*	*	*/

#ifneed bdos
/* bdos(c,de) - call bdos with given values of c and de.
		return value from register a */
bdos() {
#asm
	POP H
	POP D		; Get arguments into d
	POP B		; and b.
	PUSH B		; Restore stack.
	PUSH D
	PUSH H
	CALL 5		; Call BDOS.
	MOV L,A 	; Return value from A.
	RLC
	SBB A		; Extend sign of value.
	MOV H,A
#endasm
}
#endif
*/
bdos() {
#asm
	POP H
	POP D		; Get arguments into d
	POP B		; and b.
	PUSH B		; Restore stack.
	PUSH D
	PUSH 