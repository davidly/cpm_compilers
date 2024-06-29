/****************** some system definitions *****************/

		#define	NULL	0
		#define	FALSE	0
		#define TRUE	1
		#define EOF	(-1)
		#define CPMEOF	(0x1a)

/**************** the structure for allocations *************/

		typedef int	ALIGN;

		union	header	{
			struct	{
				union	header	*ptr;
				unsigned	size;
			}s;
			ALIGN	x;
		};

		typedef union header HEADER;


/******************* the iob structure **********************/

		struct	iobbuf{
			int	_cnt;
			char	*_ptr;
			char	*_base;
			int	_flag;
			int	_fd;
			};

		#define	_NFILE	6
						/* maximum number of files */

		extern	int	_nfile;		/* this variable yields the
						    number of files set in
						    the library */

		typedef	struct	iobbuf	FILE;

		extern	FILE	_iob[];

/*********************** the iob definitions ******************/

		#define	stdin	&_iob[0]
		#define	stdout	&_iob[1]
		#define	stderr	&_iob[2]
		#define	stdlst	&_iob[3]

		#define	_READ	01
						/* file open for reading */
		#define _WRITE	02
						/* file open for writing */
		#define _UNBUF	04
						/* file is unbuffered */
		#define _BBUF	010
						/* a big buffer was
						   allocated */
		#define _EOF	020
						/* EOF has occurred on this
						   file */
		#define _ERR	040
						/* error has occurred on this
						    file */
		#define _WFLAG	0100
						/* buffer has been written
						   to */
		#define	_BFLAG	0200
						/* if true then binary read/
						   write */
		#define	_BSIZE 512
						/* buffer size for files */
		#define SECSIZE 128
						/* size of a sector */

/******************* setjmp and longjmp defs **********************/

	struct	_env{
		char	*rtnadr;
		char	*oldstk;
		};

	typedef	struct	_env	*jmp_buf;
	typedef	struct	_env	jmp_env;


/******************************* **********************************/

