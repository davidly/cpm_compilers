/* Copyrighted (c) by SuperSoft, Inc., 1982 */

/*	stdio.c
 *
 *	This version has:
 *	User codes in file specs (eg b/6:file)
 *	Serial devices CON,RDR,PUN,LST may be opened and treated as files.
 *	Structures
 *	Fix for execl done on 6 July 1982  MQH
 *	Fix to fclose 1982 July 9 RB
 *	
 */

#define	STDIOEDIT	31

/* tell(fd)
 * seek(fd, offset, code)	code = 0,1,2,3,4,5
 * open(filename,mode) mode = 0,1,2
 * creat(filename)
 * close(fd)
 * fopen(filename,mode,buffer_size) mode = "r","w","a","rw"
 * write(fd,buffer,byte_count)
 * read(fd,buffer,byte_count)
 * cio(mode,fcb_pointer,buffer,byte_count)
 * cpmio(mode,fcb_pointer,buffer)
 * cpmver()
 */

#include 	"stdio.h"

int	Errno;			/* global error indicator */

cpmver()
{
	return bdos(CC_CPMVER,0);
}

seek(fd,offset,code)
 FILE *fd;
 int offset;
 char code;
{
	register int t;
	char tmp[3];

	if(isserial(fd))
		return seterr(BADDEV);
	if(code > 2) {
		code -= 3;
		offset *= 4;	/* 512/128 = 4 */
	}
	else {
		if(offset % 128)
			return seterr(INVSEEK);
		offset /= 128;
	}
	xselect(fd,tmp);
	t = cpmver() ? seek20(fd,offset,code)
	: seek14(fd,offset,code);
	xrestore(fd,tmp);
	return t;
}

seek20(fd,offset,code)
 FILE *fd;
 int	offset;
 char	code;
{

	switch(code)
	{
		case START:
			break;
		case CURRENT:
			offset += cpmtell(fd);
			break;
		case LAST:
			offset += filesize(fd);
			break;
		default:
			return seterr(INVSEEK);
	}
	fd->rrec = offset;
	bdos(SET_DMA,INIT_DMA);
	if(bdos(CC_RREAD,fd))
		return seterr(INVREC);
	return SUCCESS;
}


seek14(fd,offset,code)
 FILE *fd;
 int	offset;
 char	code;
{
	register int t3;
	int t1, t2;

	switch(code)
	{
	case CURRENT:
		t3 = fd->ex * EXT_SIZE;
		t1 = cc_ex(offset + fd->nr + t3);
		t2 = cc_nr(offset + fd->nr + t3);
		break;
	case START:
		t1 = cc_ex(offset);
		t2 = cc_nr(offset);
		break;
	case LAST:
		if(back_up(fd,offset) == ERROR)
			return ERROR;
		else
			return SUCCESS;
	default:
		return seterr(INVSEEK);
	}
	t3 = fd->ex;
	if(move_ex(fd,t1) == ERROR)
		return ERROR;
	if(move_nr(fd,t2) == ERROR) {
		move_ex(fd,t3);
		return ERROR;
	}
	return SUCCESS;
}

unlink(filename)
char	*filename;
{
	char tmp[3];
	FILE fd;

	if(fill_fcb(&fd,filename) == ERROR)
		return seterr(INVFD);
	if(isserial(fd))
		return seterr(BADDEV);
	xselect(&fd,tmp);
	if(bdos(CC_DELETE,&fd) == BDOSERR) {
		xrestore(&fd,tmp);
		return seterr(NOFILE);
	}
	return SUCCESS;
}

FILE *open(filename,mode)
 char	*filename, *mode;
{
	register FILE *fd;
	char tmp[3];
	int	t1;

	if(((fd = get_fd()) == ERROR) || (fill_fcb(fd,filename) == ERROR))
		return ERROR;
	if((fd->fm = mode) > FCB_R_W)
		return seterr(INVMODE);
	switch(fd->dc)
	{
	case CON:
		return fd;
	case RDR:
		if(mode == FCB_READ)
			return fd;
		else
			return seterr(BADDEV);
	case LST:
	case PUN:
		if(mode == FCB_WRITE)
			return fd;
		else
			return seterr(BADDEV);
	default:
		xselect(fd,tmp);
		bdos(SET_DMA,INIT_DMA);
		if(bdos(CC_OPEN,fd) == BDOSERR) {
			free(fd);
			xrestore(fd,tmp);
			return seterr(OPENERR);
		}
		xrestore(fd,tmp);
		return fd;
	}
}

FILE *creat(filename)
 char	*filename;
{
	register FILE *fd;
	char tmp[3];
	int	t1;

	if((fd = get_fd()) == ERROR || fill_fcb(fd,filename) == ERROR)
		return ERROR;

	fd->fm = FCB_WRITE;
	switch(fd->dc)
	{
	case RDR:
		return seterr(BADDEV);
	case CON:
	case LST:
	case PUN:
		return fd;
	default:
		xselect(fd,tmp);
		bdos(CC_DELETE,fd);
		if(bdos(CC_CREAT,fd) == BDOSERR) {
			free(fd);
			xrestore(fd,tmp);
			return seterr(CREATERR);
		}
		xrestore(fd,tmp);
		return fd;
	}
}


close(fd)
 FILE	*fd;
{
	char	tmp[3];
	int	t;

	if(fd==ERROR)
		return SUCCESS;

	switch(fd->fm)
	{
	case 0:
	case 1:
	case 2:
	case 'R':
	case 'W':
	case 'A':
	case 'X':
		break;
	default:
		return seterr(INVFD);
	}
	if(isserial(fd))
		t = SUCCESS;
	else {
		xselect(fd,tmp);
		if(bdos(CC_CLOSE,fd) == BDOSERR) {
			Errno = CLOSEERR;
			t = ERROR;
		}
		else
			t = SUCCESS;
		xrestore(fd,tmp);
	}
	if(fd->fm > 3)
		free(fd->ps);
	free(fd);
	return t;
}

fabort(fd)
 FILE	*fd;
{
	switch(fd->fm)
	{
	case 0:
	case 1:
	case 2:
	case 'R':
	case 'W':
	case 'A':
	case 'X':
		if(fd->fm > 3)
			free(fd->ps);
		free(fd);
		return SUCCESS;
	default:
		return seterr(INVFD);
	}
}

isserial(fd)
FILE *fd;
{
	switch(fd->dc)
	{
	case CON:
	case RDR:
	case LST:
	case PUN:
		return 1;
	default:
		return 0;
	}
}

unsigned tell(fd)		/* tell returns bytes. */
 FILE *fd;
{
	if(isserial(fd))
		return seterr(BADDEV);
	else
		return cpmtell(fd) * 128;
}

unsigned rtell(fd)		/* tell returns bytes / 512. */
 FILE *fd;
{
	if(isserial(fd))
		return seterr(BADDEV);
	else
		return cpmtell(fd) / 4;
}

unsigned otell(fd)		/* otell returns bytes % 512 */
 FILE *fd;
{
	if(isserial(fd))
		return seterr(BADDEV);
	else
		return (cpmtell(fd) % 4) * 128;
}

unsigned cpmtell(fd)			/* cpm tell returns bytes/128 */
 FILE *fd;
{
	register unsigned t;
	char tmp[3];

	if(isserial(fd))
		return seterr(BADDEV);
	xselect(fd,tmp);
	t = cpmver() ? tell20(fd) : tell14(fd);
	xrestore(fd,tmp);
	return t;
}

tell14(fd)	/* tell for CP/M's prior to 2.0 */
 FILE	*fd;
{
	return fd->nr + fd->ex * EXT_SIZE;
}

tell20(fd)	/* tell for CP/M's 2.0 and on	*/
 FILE *fd;
{
	FILE tfd;

	movmem(fd,&tfd,SIZE_FD);
	bdos(CC_SRR,&tfd);
	return tfd.rrec;
}

read(fd,buffer,byte_count)
 FILE *fd;
 char *buffer;
 int  byte_count;
{
	switch(fd->fm)
	{
	case FCB_READ:
	case FCB_R_W:
	case 'R':
	case 'X':
		return cio(CC_READ,fd,buffer,byte_count);
	}
	return seterr(INVMODE);
}

write(fd,buffer,byte_count)
 FILE *fd;
 char *buffer;
 int byte_count;
{
	register int	t1;

	switch(fd->fm)
	{
	case FCB_WRITE:
	case FCB_R_W:
	case 'W':
	case 'A':
	case 'X':
		t1 = cio(CC_WRITE,fd,buffer,byte_count);
		if(fd->me < fd->ex)
			fd->me = fd->ex;
		return t1;
	default:
		return seterr(INVMODE);
	}
}

cio(mode,fd,buffer,byte_count)
 FILE *fd;
 char	mode, *buffer;
 int	byte_count;
{
	register int records;
	int bytes;

	if(byte_count < REC_SIZE)
		return seterr(BCE);
	bytes = 0;
	switch(fd->dc)
	{
	case CON:
		if(mode == CC_READ) {
			*buffer = bdos(CC_CONIN ,0);
			bytes = 1;
		}
		else {
			for(; bytes < byte_count && *buffer != _EOF; ++bytes)
				bdos(CC_CONOUT , *buffer++);
		}
		break;
	case RDR:
		*buffer = bdos(CC_RDR ,0);
		bytes = 1;
		break;
	case LST:
		for(; bytes < byte_count && *buffer != _EOF; ++bytes)
			bdos(CC_LST , *buffer++);
		break;
	case PUN:
		for(; bytes < byte_count && *buffer != _EOF; ++bytes)
			bdos(CC_PUN , *buffer++);
		break;
	default:
		for(records = byte_count/REC_SIZE; records; --records) {
			if(!cpmio(mode,fd,buffer)) {
				Errno = mode+0x100;
				return bytes;
			}
			buffer += REC_SIZE;
			bytes += REC_SIZE;
		}
	}
	return bytes;
}

cpmio(mode,fd,buffer)
 char	mode, *buffer;
 FILE *fd;
{
	register char t1, tmp[3];

	xselect(fd,tmp);
	bdos(SET_DMA,buffer);
	t1 = (bdos(mode,fd) == 0);
	xrestore(fd,tmp);
	return t1;
}

/*	This function predates structures. It should be modified to access
 *	file descriptors by member names, yet, as it works properly, we shall
 *	let it kludge along a little longer.
 */
fspec(fps,fcb)		/* parse fspec. if valid return SUCCESS and set up */
char *fps, *fcb;	/* low 16 bytes of fcb, else return false.device*/
			/* codes CON..LST reserved for serial devices.	*/ 
{
	FILE *xfcb;
	register char *fp;
	int c;
	
	xfcb = fcb;
	fp = fps;
	if(*fp == 0)
		return seterr(FSPECERR);
	if((*fcb = chkserial(fp))==0) {
		if(fp[1] == ':' || fp[1] == '/') {
			if((*fcb = toupper(*fp++) - '@') > MAX_DRIVE)
				return seterr(FSPECERR);
		}
		else
			*fcb = 0;
		if(*fp == '/') {
			++fp;
			for(c=0;isdigit(*fp);)
				c = (10 * c) + *fp++ - '0';
			if(c > MAX_USER || *fp != ':')
				return seterr(FSPECERR);
			xfcb->user = c;
		}
		else
			xfcb->user = DEF_USER;
		if(*fp == ':')
			++fp;
	}
	++fcb;
	for(c=0; *fp && (*fp != '.'); ++c)
		*fcb++ = toupper(*fp++);
	if(c > 8 || c==0)
		return seterr(FSPECERR);
	for(;c<8;++c)
		*fcb++ = ' ';
	if(*fp=='.')
		++fp;
	for(c=0;*fp;++c)
		*fcb++ = toupper(*fp++);
	if(c > 3)
		return seterr(FSPECERR);
	for(;c++ < 3;)
		*fcb++ = ' ';
	return SUCCESS;
}

chkserial(fp)
char *fp;
{
	if(cmpu("CON:",fp))		return CON;
	else if(cmpu("RDR:",fp))	return RDR;
	else if(cmpu("LST:",fp))	return LST;
	else if(cmpu("PUN:",fp))	return PUN;
	else 				return 0;
}

cmpu(a0,b)
char *a0,*b;
{
	register char *a;

	a = a0;
	while(*a)
		if(*a++ != toupper(*b++))
			return 0;
	return 1;
}

/* This routine dumps a fd for debugging purposes */
/*
dump_fcb(fd)
 FILE	*fd;
{
	int i;

	printf("fcb @%x:\n",fd);
	printf("dc %x\n",fd->dc);
	puts("name.ext : ");
	for(i=0;i<8;++i)
		putchar(fd->name[i]);
	putchar('.');
	for(i=0;i<3;++i)
		putchar(fd->ext[i]);
	putchar('\n');
	printf("ex %x\n",fd->ex);
	printf("rc %x\n",fd->rc);
	printf("nr %x\n",fd->nr);
	printf("rrec %x\n",fd->rrec);
	printf("user %x\n",fd->user);
	printf("fm %x\n",fd->fm);
	printf("me %x\n",fd->me);
	printf("ps %x\n",fd->ps);
}
*/

back_up(fd,offset)
 FILE	*fd;
 int	offset;
{
	register FILE *fd_;
	int cur_ex;
	int cur_nr;

	cur_ex = (fd_ = fd)->ex;
	cur_nr = fd_->nr;
	if(fd_->me == BDOSERR) {
		to_end(fd_);
		fd_->me = fd_->ex;
	}
	else
		move_ex(fd_,fd_->me);

	fd_->nr = fd_->rc;
	if(seek(fd_,-offset,CURRENT) == ERROR) {
		move_ex(fd_,cur_ex);
		move_nr(fd_,cur_nr);
		return ERROR;
	}
	else
		return SUCCESS;
}

to_end(fd)
 FILE	*fd;
{
	FILE	tfd;

	setmem(&tfd,SIZE_FD,0);
	movmem(fd,&tfd,(&tfd.ex - &tfd));
	bdos(SET_DMA,INIT_DMA);
	for(tfd.ex++; bdos(CC_OPEN,&tfd) != BDOSERR; tfd.ex++)
		;
	if(--(tfd.ex) == fd->ex)
		return;
	bdos(CC_CLOSE,fd);
	fd->ex = tfd.ex;
	setmem(&fd->rc, &fd->rreco - &fd->rc, 0);
	bdos(CC_OPEN,fd);
}

move_ex(fd,where)
 FILE *fd;
 int	where;
{
	FILE	tfd;

	if(fd->ex == where)
		return SUCCESS;
	setmem(&tfd.ex,SIZE_FD,0);
	movmem(fd,&tfd,(&tfd.ex - &tfd));
	tfd.ex = where;
	bdos(SET_DMA,INIT_DMA);
	if(bdos(CC_OPEN,&tfd) != BDOSERR) {
		bdos(CC_CLOSE,fd);
		movmem(&tfd,fd,SIZE_FD);
		return SUCCESS;
	}
	return seterr(INVREC);
}

move_nr(fd,where)
 FILE	*fd;
 int	where;
{
	if(fd->nr == where)
		return SUCCESS;
	if(where <= fd->rc && (where >= 0 && where < REC_SIZE)) {
		fd->nr = where;
		return SUCCESS;
	}
	return seterr(INVREC);
}

cc_ex(where)
 int	where;
{
	return where / EXT_SIZE;
}

cc_nr(where)
 int	where;
{
	return where % EXT_SIZE;
}

fill_fcb(fd,filename)
 FILE	*fd;
 char	*filename;
{
	setmem(fd,SIZE_FD,0);
	fd->me = 255;
	return fspec(filename,fd);
}

get_fd()
{
	register FILE *p;

	if(p = alloc(SIZE_FD))
		return p;
	return seterr(NOMEM);
}

FILE *fopen(filename,mode,buffer_size)
 char	*filename, *mode;
 int	buffer_size;
{
	register FILE	*fd;
	struct seq_buf	*p;

	if((buffer_size % REC_SIZE) || buffer_size == 0)
		return seterr(INVBUF);
	switch(toupper(*mode))
	{
	case 'R':
		if((fd = open(filename,FCB_READ)) != ERROR)
			break;
		if(toupper(mode[1]) != 'W')
			return ERROR;
	case 'W':
		if((fd = creat(filename)) == ERROR)
			return ERROR;
		break;
	case 'A':
		if((fd = open(filename,FCB_WRITE)) == ERROR)
			return ERROR;
		if(seek(fd,0,LAST) == ERROR)
			return ERROR;
		break;
	default:
		return seterr(INVMODE);
	}
	if(!(p = fd->ps = alloc(buffer_size+SOVER)))
		return seterr(NOMEM);
	p->ap = &p->bu;
	p->ac = 0;
	p->bs = buffer_size;
	switch(toupper(*mode))
	{
	case 'A':
	case 'W':
		fd->fm = toupper(*mode);
		break;
	default:
		if(toupper(mode[1]) == 'W')
			fd->fm = 'X';
		else
			fd->fm = 'R';
	}
	return fd;
}

fclose(fd)
 FILE	*fd;
{
	if( (fd!=ERROR && fd->fm!='R' && fd->fm!=0) /* write attributes */
		&& (putc(_EOF,fd)==ERROR || fflush(fd)==ERROR))
			return ERROR;

	return close(fd);
}

pgetc(fd)
 FILE	*fd;
{
	register char	c;

	if((c = getc(fd)) == '\r') {
		if(getc(fd) == '\n')
			c = '\n';
		else
			ungetc(fd);
	}
	return c;
}

getc(fd)
 FILE *fd;
{
	register struct seq_buf	*p;

	if(fd->fm != 'R' && fd->fm != 'X')
		 return seterr(INVFD);
	p = fd->ps;
	if(p->ac <= 0 && fill_buf(fd) == ERROR)
		return ERROR;
	--(p->ac);
	return *p->ap++;
}

getw(fd)
 FILE	*fd;
{
	register int r1;
	int r2;

	if((r1 = getc(fd)) == ERROR ||
	   (r2 = getc(fd)) == ERROR)
		return ERROR;
	return ((r1<<8) & 0xff) | r2;
}

ungetc(c,fd)
 char	c;
 FILE *fd;
{
	struct seq_buf	*p;

	if(fd->fm != 'R' && fd->fm != 'X')
		return seterr(INVFD);

	p = fd->ps;
	++(p->ac);
	*--(p->ap) = c;
}

pputc(c,fd)
 char	c;
 FILE	*fd;
{
	if(c == '\n' && putc('\r',fd) == ERROR)
		return ERROR;
	return putc(c,fd);
}

putc(c,fd)
 char	c;
 FILE *fd;
{
	register struct seq_buf *p;

	switch(fd->fm)
	{
	case 'X':
	case 'W':
	case 'A':
		p = fd->ps;
		if(p->ac >= p->bs && write_buf(fd) == ERROR)
			return ERROR;
		++(p->ac);
		return *p->ap++ = c;
	default:
		return seterr(INVFD);
	}
}

putw(i,fd)
 int	i, fd;
{
	 return putc(i>>8,fd) == ERROR || putc(i,fd) == ERROR;
}

fflush(fd)
 FILE	*fd;
{
	register struct seq_buf	*p;

	switch(fd->fm)
	{
	case 'X':
	case 'W':
	case 'A':
		p = fd->ps;
		if(p->ac)
			return write_buf(fd);
		return SUCCESS;
	default:
		return seterr(INVFD);
	}
}

fill_buf(fd)
 FILE	*fd;
{
	register struct seq_buf	*p;

	p = fd->ps;
	if((p->ac = read(fd,&p->bu,p->bs)) <= 0)
		return seterr(EOFERR);
	p->ap = &p->bu;
	return SUCCESS;
}

write_buf(fd)
 FILE	*fd;
{
	register struct seq_buf	*p;

	p = fd->ps;
	if(write(fd,&p->bu,p->bs) != p->bs)
		return ERROR;
	p->ap = &p->bu;
	p->ac = 0;
	return SUCCESS;
}

filesize(fd)		/* should be called by seek20 only.	*/
 FILE *fd;		/* does not xselect			*/
{
	FILE tfd;

	bdos(SET_DMA,INIT_DMA);
	movmem(fd,&tfd,SIZE_FD);
	bdos(CC_CLOSE,&tfd);
	bdos(CC_CFS,&tfd);
	return tfd.rrec;
}

xselect(fd,tmp)		/* preserve user and drive code, and select	*/
 FILE *fd;		/* user & drive specified in fd			*/
 char *tmp;
{
	if(cpmver()==0) {
		tmp[0] = bdos(GET_DRIVE,0);
		bdos(SET_DRIVE,tmp[1] = fd->dc);
		fd->dc = 0;
	}
	else
		if(fd->user != DEF_USER) {
			tmp[2] = bdos(CC_USER,255);
			bdos(CC_USER,fd->user);
		}
}

xrestore(fd,tmp)
 FILE *fd;
 char *tmp;
{
	if(cpmver()==0) {
		fd->dc = tmp[1];
		bdos(SET_DRIVE,tmp[0]);
	}
	else
		if(fd->user != DEF_USER)
			bdos(CC_USER,tmp[2]);
}

seterr(err)
int err;
{
	Errno = err;
	return ERROR;
}

extern char xstart[];
extern char xfcb1[];
extern char xfcb2[];
extern char xend[];

#define FCB_SIZE	33
#define EXECAREA	(0x0080)
#define DEF_FCB		0x005c

exec(p)
 char *p;
{
	int execl(.);
	
	return execl(p, 0);
}

execl(nargs)	/* set up command line & default fcb just like cpm */
 int nargs;	/* then exec */
{
	int i,*ip;
	char *l,*p,prog[30],line[128];
	FILE fcb;

	if(nargs < 2)
		return ERROR;
	ip = &nargs;
	strcpy(prog,ip[nargs]);		/* get program name */

	 /* Construct default fcb at DEF_FCB from parms 2 & 3 */
	setmem(DEF_FCB,FCB_SIZE,0);
	if(nargs > 2) {
		fspec(ip[nargs - 1], &fcb);
		movmem(&fcb, DEF_FCB, 12);
		if(nargs > 3) {
			fspec(ip[nargs - 2], &fcb);
			movmem(fcb.name, DEF_FCB + 16, 11);
		}
		else
			setmem(DEF_FCB + 16, 11, ' ');
	}

	/* construct command line */
	for(l = EXECAREA + 1,--nargs; nargs > 1; --nargs) {
		p = ip[nargs];
		while(*p)
			*l++ = *p++;
		*l++ = ' ';
	}
	*l = 0;
	*(p=EXECAREA) = strlen(p+1);
	ccGo(prog);
}

ccGo(prog)			/* invoke file prog. default ext ".COM" */
 char *prog;
{
	FILE *fd;
	char *c,tfile[30],hold0x80[128];
	int (*fn)();

	movmem(EXECAREA,hold0x80,128);	/* squirrel away command line stuff */
	/* copy progname until nul or dot */
	for(c = tfile ;*prog && *prog != '.';)
		*c++ = *prog++;
	if(*prog=='.')			/* explicit extension given ? */
		strcpy(c,prog);		/* yes, use that ext. */
	else
		strcpy(c,".COM");	/* no, use default ext.	*/
	if((fd = open(tfile,0)) == ERROR || fd->dc >= CON)
		return ERROR;
	if(cpmver()) {
		if(fd->user != DEF_USER)
			bdos(CC_USER,fd->user);
	}
	else
		if(fd->dc)
			bdos(SET_DRIVE,fd->dc);
	movmem(fd,xfcb1,FCB_SIZE);
	if((fd = creat("$$$.$$$")) == ERROR || write(fd,hold0x80,128) != 128
	 || seek(fd,0,0) == ERROR)
		return ERROR;
	movmem(fd,xfcb2,FCB_SIZE);
	movmem(xstart,EXECAREA,xend-xstart);
	(*(fn=EXECAREA))();
}

#define CC_RENAME	23

rename(fname, fspec)
char *fname;
char *fspec;
{
	register int t;
	struct filedesc new;
	struct filedesc old;
	char tmp[3];

	if (fill_fcb(&old, fspec) == ERROR)
		return ERROR;

	if (fill_fcb(&new, fname) == ERROR)
		return ERROR;

	if (new.dc != old.dc)
		return ERROR;

	if (new.user != old.user)
		return ERROR;

	xselect(&old, tmp);

	movmem(&new.dc, &old._fcbr2[0], 16);

	t = bdos(CC_RENAME, &old);

	xrestore(&old, tmp);

	if (t == 0xFF)
		return (ERROR);
	else
		return (SUCCESS);
}
.COM");	/* no, use default ext.	*/
	if((fd = open(tfile,0))