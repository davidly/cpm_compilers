/*
 *	Q/C V3.1 Standard I/O Definitions
 *		05/19/83
 */

#define ERROR	-1
#define EOF	-1
#define NULL	0
#define TRUE	1
#define FALSE	0

/* define the "type" file pointer */

#define FILE	struct _iob

/* define the file I/0 control block */

struct _iob {
	char	_flag;
	char	*_pch;
	int	_cnt;
	char	*_buf;
	int	_bufsize;
	char	_fd;
	};

/* standard I/O device names for redirection */

extern FILE *stdin,
	    *stdout,
	    *stderr;
