

/*
	Floating point package support routines

	(see FLOAT.DOC for details...)
*/

#define NORM_CODE	0
#define ADD_CODE	1
#define SUB_CODE	2
#define MULT_CODE	3
#define DIV_CODE	4
#define FTOA_CODE	5

fpcomp(op1,op2)
	char *op1,*op2;
{
	char work[5];
	fpsub(work,op1,op2);
	if (work[3] > 127) return (-1);
	if (work[0]+work[1]+work[2]+work[3]) return (1);
	return (0);
}
fpnorm(op1) char *op1;
{	fp(NORM_CODE,op1,op1);return(op1);}

fpadd(result,op1,op2)
	char *result,*op1,*op2;
{	fp(ADD_CODE,result,op1,op2);return(result);}

fpsub(result,op2,op1)
	char *result,*op1,*op2;
	{fp(SUB_CODE,result,op1,op2);return(result);}

fpmult(result,op1,op2)
	char *result,*op1,*op2;
{	fp(MULT_CODE,result,op1,op2);return(result);}

fpdiv(result,op1,op2)
	char *result,*op1,*op2;
{	fp(DIV_CODE,result,op1,op2);return(result);}
atof(fpno,s)
	char fpno[5],*s;
{
	char *fpnorm(),work[5],ZERO[5],FP_10[5];
	int sign_boolean,power;

	initb(FP_10,"0,0,0,80,4");
	setmem(fpno,5,0);
	sign_boolean=power=0;

	while (*s==' ' || *s=='\t') ++s;
	if (*s=='-'){sign_boolean=1;++s;}
	for (;isdigit(*s);++s){
		fpmult(fpno,fpno,FP_10);
		work[0]=*s-'0';
		work[1]=work[2]=work[3]=0;work[4]=31;
		fpadd(fpno,fpno,fpnorm(work));
	}
	if (*s=='.'){
		++s;
		for (;isdigit(*s);--power,++s){
			fpmult(fpno,fpno,FP_10);
			work[0]=*s-'0';
			work[1]=work[2]=work[3]=0;work[4]=31;
			fpadd(fpno,fpno,fpnorm(work));
		}
	}
	if (toupper(*s) == 'E') {++s; power += atoi(s); }
	if (power>0)
		for (;power!=0;--power) fpmult(fpno,fpno,FP_10);
	else
	if (power<0)
		for (;power!=0;++power) fpdiv(fpno,fpno,FP_10);
	if (sign_boolean){
		setmem(ZERO,5,0);
		fpsub(fpno,ZERO,fpno);
	}
	return(fpno);
}
ftoa(result,op1)
	char *result,*op1;
{	fp(FTOA_CODE,result,op1);return(result);}

itof(op1,n)
char *op1;
int n;
{
	char temp[20];
	return atof(op1, itoa(temp,n));
}

itoa(str,n)
char *str;
{
	char *sptr;
	sptr = str;
	if (n<0) { *sptr++ = '-'; n = -n; }
	_uspr(&sptr, n, 10);
	*sptr = '\0';
	return str;
}

�|	=�t�~�^#V�)�_ {�oz�g�i`N#F�o�g�o& �o�g�<�>���
� ����