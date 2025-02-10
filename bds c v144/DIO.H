/*
	External data used by DIO.C for directed I/O simulation:
	(BDSCIO.H must also be #included in the main file.)
*/

char _diflag, _doflag;			/* flag if directed I/O being used */
char _pipef, *_pipedest;		/* true if a pipe is being filled  */
char **_savei, **_nullpos;		/* used to remember position in
					   command line when piping 	   */
char _dibuf[BUFSIZ], _dobuf[BUFSIZ];	/* I/O buffers used for direction  */
