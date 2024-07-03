/* Copyrighted (c) by SuperSoft, Inc., 1982 */

/*	stdio.h for stdio.c edit 25
 *
 *	This file should be included by all programs that use stdio.c
 *	This file generates no code.
 */

#define SUCCESS		0
#define	ERROR		(-1)
#define	BDOSERR		255

#define CON		0x80
#define RDR		0x81
#define PUN		0x82
#define LST		0x83

#define	BCE		1	/* Byte count error */
#define	NOFD		2	/* No open FD's */
#define NOFILE		3	/* File not found */
#define	INVFD		4	/* Invalid FD, unopened file */
#define	INVMODE		5	/* IO type mismatch */
#define	OPENERR		6	/* Error on CC_OPEN */
#define	CREATERR	7	/* Error on CC_CREAT */
#define	FSPECERR	8	/* Invalid filename */
#define	BADDEV		9	/* Device out of range */
#define	CLOSEERR	10	/* bdos error in close */
#define	INVREC		11	/* Invalid record in seek */
#define	INVSEEK		12
#define NOMEM		20	/* Memory allocation failure */
#define	INVBUF		21
#define	READERR		22
#define	EOFERR		23
#define	NOGETC		24

#define	REC_SIZE	128	/* Byte count of a CP/M record */
#define	EXT_SIZE	128	/* Records in a extent 1..EXT_SIZE */
#define	SOVER		6	/* Bytes to over allocate seq. buf. */
#define	FCB_READ	0
#define	FCB_WRITE	1
#define	FCB_R_W		2
#define	INIT_DMA	0x80	/* Each open sets dma here */
#define	START		0	/* Seek from beginning */
#define	CURRENT		1	/* Seek from current record */
#define	LAST		2	/* Seek from end */
#define MAX_DRIVE	15
#define MAX_USER	32
#define DEF_USER	255	/* Default user code */

#define _EOF		26

struct filedesc
{
	char	dc;		/* Drive Code of this file	*/
	char	name[8];	/* File's name			*/
	char	ext[3];		/* File's extension		*/
	char	ex;		/* Byte address of extent value	*/
	char	_fcbr1[2];	/* Reserved for CP/M		*/
	char	rc;		/* Record count in extent	*/
	char	_fcbr2[16];	/* Reserved for CP/M		*/
	char	nr;		/* Byte address of next record value */
	int	rrec;		/* random record# (CP/M 2.0 only)*/
	char	rreco;		/* rrec overflow, not yet used	*/
				/* End of CP/M FCB.		*/
	char	user;		/* User code of this file	*/
	char	fm;		/* File mode			*/
	char	me;		/* Maximum extent		*/
	char	*ps;		/* Pointer to seq buffer	*/
};

#define FILE		struct filedesc
#define	SIZE_FD		41	/* sizeof filedesc		*/
#define NULL		0

struct seq_buf
{
	char *ap;		/* Active pointer	*/
	int  ac;		/* Active count		*/
	int  bs;		/* Buffer size		*/
	char bu;		/* First byte of buffer	*/
				/* Buffer follows	*/
};


/* BDOS calling codes */

#define CC_CONIN	1
#define CC_CONOUT	2
#define CC_RDR		3
#define CC_PUN		4
#define CC_LST		5
#define CC_CPMVER	12	/* Return cpm version # */
#define	SET_DRIVE	14	/* Select disk drive */
#define	CC_OPEN		15
#define	CC_CLOSE	16
#define	CC_FIND		17	/* Find first occurence */
#define	CC_NEXT		18	/* Find next occurence */
#define	CC_DELETE	19
#define	CC_READ		20	/* Read next CP/M record */
#define	CC_WRITE	21	/* Write next CP/M record */
#define	CC_CREAT	22
#define	GET_DRIVE	25	/* Interrogate drive number */
#define	SET_DMA		26
#define CC_USER		32	/* Set/Get user code		*/
#define CC_RREAD	33	/* random read */
#define CC_CFS		35	/* Compute file size (CPM 2.0 only ) */
#define CC_SRR		36	/* set random record */

extern int Errno;		/* This line causes a non-fatal error	*/
				/* When compiling stdio.c		*/
#define ungetchar	ugetchar
