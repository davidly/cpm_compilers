

/*MI - C  v-3.183  (C) COPYRIGHT  G. KERSTING / H. ROSE, 1983*/

#INCLUDE IODEF.C

FWRITE(BUF, LAENGE, ZAHL, HFP)
FILE *HFP;
CHAR *BUF;
UNSIGNED LAENGE, ZAHL;
{
   STATIC FILE *FP;
   STATIC INT ZAEHLER, I;
   ZAEHLER = LAENGE * ZAHL;
   I = 0;
   FP = HFP;
   WHILE ( ZAEHLER-- )
	   IF ( PUTC ( BUF[I++], FP) == EOF )
		{
		--I;
		BREAK;
		}
   RETURN I / LAENGE ;
}

FREAD(BUF, LAENGE, ZAHL, HFP)
CHAR *BUF;
UNSIGNED LAENGE, ZAHL;
FILE *HFP;
{
   STATIC FILE * FP;
   STATIC INT ZAEHLER, C, I;
   FP = HFP;
   I = 0;
   ZAEHLER = LAENGE * ZAHL;
   WHILE ( ZAEHLER-- )
	{
	IF ( ( C = GETC (FP) ) == EOF )
	   BREAK;
	BUF[I++] = C;
	}
   RETURN I / LAENGE ;
}

/*		*/
/*
#INCLUDE IODEF.C
*/

FGETS(BUFF,COUNT,UNIT)
CHAR *BUFF;
FILE *UNIT; INT COUNT;
{	STATIC INT K, C;
	K=0;
	WHILE ((BUFF[K] = C = GETC(UNIT)) != '\N')
	   {IF (C == '\R') CONTINUE;
	   IF (C == EOF)
		{BUFF[K]=0; RETURN NULL;}
	   ELSE 
		{ K++;
		IF ((K + 1) >= COUNT) {BUFF[K]=0; RETURN BUFF;}
		}
	   }
	BUFF[K+1]=0;
	RETURN BUFF;
}

FPUTS(BUFFER,UNIT)
CHAR *BUFFER;
FILE *UNIT;
{	STATIC INT C;
	WHILE(C= *BUFFER++)
	   PUTC(C,UNIT);
	IF (UNIT > 0X10 && UNIT->FCBTAB.ART & ASCMOD) ;
	ELSE
	   PUTC('\R',UNIT);
	RETURN PUTC('\N',UNIT);
}

/*
#INCLUDE IODEF.C
*/
EXTERN INT CPVERS;
/*		*/
FSEEK(HFP, OFFSET, ORIGIN)
FILE *HFP;
LONG OFFSET;
INT ORIGIN;
{
   STATIC LONG LREC, HREC;
   STATIC INT J, F, HPOI;
   STATIC CHAR *IPOI;
   STATIC FILE *FP;
   IF ( CPVERS );
   ELSE
	RETURN EOF;
   IF ( ((FP = HFP) -> FCBTAB.ART & ~(KMASK & ~UNPUFF)) + (-KENN))
	RETURN EOF;
   HREC = *( (LONG *) &FP -> FREC);
   HPOI = FP -> POI - FP -> BUFF;
   IF ( FP -> FCBTAB.ART & GEAEN )
	{
	FP -> FCBTAB.ART &= ~VORSOLL;
	IF ( PUFPRO(FP) == EOF )
	   {
	   FP -> FCBTAB.ART |= VORSOLL;
	   RETURN EOF;
	   }
	}
   SWITCH (ORIGIN)
	{
	CASE 0:
 F0:		*((LONG *) &FP -> FCBTAB.FCB.RECORD) = 0;
		FP -> POI = FP -> BUFF;
		BREAK;
	CASE 1:
		FP -> POI = FP -> BUFF + (HPOI & (RECLAE - 1));
		*((LONG *) &FP -> FCBTAB.FCB.RECORD) = 
			HREC + (HPOI >> RECMASK);
		BREAK;
	CASE 2:
		FP -> POI = FP -> BUFF;
		IF ( FP -> FCBTAB.ART & ASCMOD)
		   {
		   IF ( FP -> FSIZE || FP -> FOSIZE )
			{
			FP -> FCBTAB.FCB.RECORD = FP -> FSIZE - 1;
			BDOS( FP -> BUFF, _DMA);
			IF ( BDOS( FP -> FCBTAB.FCB, _REARAN) )
			   RETURN EOF; /* FEHLER */
			J = RECLAE;
			WHILE ( J-- )
			   {
			   IF ( *FP -> POI == 0X1A )
				GOTO WEI;
			   ++ FP -> POI;
			   }
			++ *((LONG *)&FP -> FCBTAB.FCB.RECORD);
			FP -> POI = FP -> BUFF;
			}
		   ELSE
			GOTO F0;
		   }
		ELSE 
		   {
		   *((LONG *) &FP -> FCBTAB.FCB.RECORD) =
			*((LONG *) &FP -> FSIZE);
		   }
 WEI:		BREAK;
	DEFAULT:
		RETURN EOF;
	}
   FP -> FCBTAB.ART |= VORSOLL;
   FP -> EPOI = FP -> BUFF + RECLAE;
   LREC = ( OFFSET >> 7) + *((LONG *)&FP -> FCBTAB.FCB.RECORD);
   IF ((IPOI = FP -> POI + (OFFSET & 127)) >= FP->BUFF +RECLAE)
	{
	++ LREC;
	IPOI -= RECLAE;
	}
   IF ( LREC < 0 )
	{
	*((LONG *) &FP -> FREC) = 0;
	FP -> EPOI = FP -> POI = FP -> BUFF;
	RETURN 0;
	}
   IF ( LREC > 0X3FFFF )   
	{
	*((LONG *) &FP -> FREC) = 
		*((LONG *) &FP -> FCBTAB.FCB.RECORD);
	RETURN EOF;
	}
   *((LONG *) &FP -> FREC) = LREC;
   FP -> EPOI = FP -> BUFF;
   PUFPRO (FP);
   FP -> POI = IPOI;
   RETURN 0;
}

/*		*/
/*
#INCLUDE IODEF.C
*/
EXTERN FILE *XXXDAT;

EXIT(N)
INT N;
{
   CLOSAL();
   UNLINK("A:$$$.SUB");
   _EXIT();
}

CLOSAL()
{
   STATIC FILE *OPDAT;
   OPDAT = XXXDAT;
   WHILE ( OPDAT != NULL )
	{
	IF ( OPDAT -> FCBTAB.ART & UNPUFF )
	   CLOSE (OPDAT);
	ELSE
	   FCLOSE (OPDAT);
	OPDAT = OPDAT -> FCBTAB.NEXT;
	}
   XXXDAT = NULL;
}

/*		*/
/*
#INCLUDE IODEF.C
*/
EXTERN INT CPVERS;

FOPEN (NAME, TYP)
CHAR *NAME, *TYP;
{
   STATIC FILE *FP, *J;
   STATIC STRUCT SFCB HFCB;
   CPVERS = BDOS (0, _VERS) & 255;
   IF ( (FP = CALLOC (1, SIZEOF (FILE ))) == NULL )
	RETURN NULL;
   FP -> EPOI = FP -> BUFF + BUFFLAE;
   FP -> POI = FP -> BUFF;
   *((LONG *) &FP -> FREC) = *((LONG *) &FP -> FSIZE) = 0;
   FP -> FCBTAB.ART = (TYP[1] & 0X5F) == 'A' ? ASCMOD : 0;
   SWITCH (*TYP & 0X5F)
	{
	CASE 'R':
		IF (XOPEN( FP -> FCBTAB, NAME, 3) )
		   GOTO FOPFE;
		*((LONG *) &FP -> FSIZE) =
			*((LONG *) &FP -> FCBTAB.FCB.RECORD);
		FP -> FCBTAB.ART |= KENN | LESEN;
		FP -> EPOI = FP -> BUFF;
		BREAK;
	CASE 'W':
		IF ( XOPEN (FP -> FCBTAB, NAME, 2) )
		   GOTO FOPFE;
		FP -> FCBTAB.ART |= KENN | SCHREIBEN;
		BREAK;
	CASE 'A':
	   IF ( XOPEN (FP -> FCBTAB, NAME, 0 ))
		IF ( XOPEN (FP -> FCBTAB, NAME, 2 ))
		   GOTO FOPFE;
	   IF ( DATEND (FP) )
		GOTO FOPFE;
	   SWITCH (TYP[1] & 0X5F)
	   {
	   CASE 'A':
		IF ( TYP[2] == 'R' )
		   IF ( CPVERS )
		 	FP -> FCBTAB.ART |= LESEN | VORSOLL;
		BREAK;
	   DEFAULT:
		IF ( TYP[1] == 'R' )
		   IF ( CPVERS )
			FP -> FCBTAB.ART |= LESEN | VORSOLL;
	   }
	   BREAK;
	DEFAULT:
FOPFE:		{
		CFREE (FP);
		RETURN NULL;
		}
	}
   RETURN FP;
}

GETC(HFP)
FILE *HFP;
{
   STATIC INT C, HART, RECANZ;
   STATIC STRUCT SFCB HFCB;
   STATIC FILE *FP;
   STATIC CHAR *DMA;
   IF ( (FP = HFP) -> FCBTAB.ART == WSTDIN )
	RETURN AGETCHAR();
LAB:
   SWITCH (FP->FCBTAB.ART & ~ (KMASK & ~LESEN & ~UNPUFF & ~ASCMOD & ~VORIST) )
	{
	CASE LESEN | KENN | VORIST:
		IF ( FP -> POI < FP -> EPOI )
		   RETURN * FP -> POI ++;
		BREAK;
	CASE LESEN | KENN | ASCMOD | VORIST:
 CRNEU:		IF ( FP -> POI < FP -> EPOI )
		   {
		   IF ((C= *FP->POI++) + ( - '\R'))  ;
		   ELSE
			GOTO CRNEU;
		   IF ( C  + (-0X1A) )
			RETURN   C;
		   -- FP -> POI;
		   RETURN EOF;
		   }
		BREAK;
	CASE LESEN | KENN:
	CASE LESEN | KENN | ASCMOD:
		IF ( FP -> POI < FP -> EPOI )
		   RETURN EOF;
		BREAK;
DEFAULT:
		RETURN EOF;
	}
   IF (FP -> FCBTAB.ART & VORSOLL)
	   {
	   IF (PUFPRO (FP) )
		RETURN EOF;
	   IF ( FP -> FCBTAB.ART & VORIST );
	   ELSE
		{
		FP -> EPOI = FP -> BUFF;
		RETURN EOF;
		}
	   }
   ELSE
	  {
	   DMA = FP -> BUFF;
	   *((LONG *) &FP -> FREC) += 
		(FP->POI - FP->BUFF) / RECLAE;
	   RECANÚ = BUFFLAÅ / RECLAE;
	   WHILE (RECANZ -- )
		{
		BDOS (DMA, _DMA);
		IF (BDOS (FP -> FCBTAB.FCB, _REASEQ) & 255)
		   BREAK;
		DMA += RECLAE;
		}
	   IF ( (FP -> EPOI = DMA) == (FP -> POI = FP -> BUFF))
		RETURN EOF;
	   FP -> FCBTAB.ART |= VORIST;
	   }
   GOTO LAB;
}

UNGETC(C,HFP)
INT C;
FILE *HFP;
{
   STATIC FILE *FP;
   IF ( (FP = HFP)-> FCBTAB.ART == WSTDOUT )
	RETURN UNGETCHAR(C);
   IF ( (FP -> FCBTAB.ART & ~(KMASK & ~LESEN & ~UNPUFF & 
	~VORIST) ) != (KENN | LESEN | VORIST) )
	RETURN EOF;
   IF ( (FP -> POI <= FP -> BUFF) || C == EOF )
	RETURN EOF;
   IF ( FP -> FCBTAB.ART & SCHREIBEN )
	IF ( *(FP -> POI -1) != C)
	   FP -> FCBTAB.ART |= GEAEN;
   RETURN * --FP -> POI = C;
}

STATIC DATEND(HFD)
FILE *HFD;
{
   STATIC FILE *FD;
   STATIC INT NR;
   STATIC CHAR EX, RCEX;
   STATIC STRUCT SFCB HFCB;
   STATIC UNSIGNED J;
   STATIC STRUCT DATVER {
		   CHAR DRIVE,
			NAME[8],
			TYP[3],	
			EXT,
			RESV[2],
			RC,
			SYDX[16];
			} *FCPOI;
   STATIC STRUCT DATVER VIERFC[4];
   FD = HFD;
   FD->POI= FD -> BUFF;
   IF ( CPVERS )
	{
	BDOS ( &FD -> FCBTAB.FCB, _SIZFIL);
	FD -> EPOI  = FD -> BUFF;
	FD -> FCBTAB.ART |= KENN | LESEN | VORSOLL;
	*((LONG *) &FD -> FREC) = *((LONG *) &FD -> FSIZE) =
		*((LONG *) &FD -> FCBTAB.FCB.RECORD);
	IF ( FD ->FCBTAB.ART & ASCMOD && 
			(FD -> FREC || FD -> FOVER) )
	   {
	   -- *((LONG *) &FD -> FREC);
	   PUFPRO (FD);
	   IF ( FD -> FCBTAB.ART & VORIST )
		{
		WHILE ( *FD -> POI != 0X1A )
		   {
		   IF ( ++FD -> POI >= FD -> EPOI)
			BREAK;
		   }
		}
	   ELSE
		RETURN -1;
	   }
	ELSE
	   PUFPRO (FD);
	FD -> FCBTAB.ART = (FD -> FCBTAB.ART & ~LESEN) | SCHREIBEN;
	RETURN 0;
	}
   ELSE
	{
	BDOS ( VIERFC, _DMA );
	IF ((NR = (BDOS (&FD->FCBTAB.FCB, _SEAFIR) )&255)==255)
	   RETURN -1;
	FCPOI = VIERFC[NR];
	EX = FCPOI -> EXT;
	RCEX = FCPOI -> RC;
	WHILE ((NR = (BDOS(&FD->FCBTAB.FCB, _SEANEX))&255)!=255)
	   {
	   FCPOI = VIERFC[NR];
	   IF ( EX < FCPOI->EXT )
		{
		RCEX = FCPOI->RC;
		EX = FCPOI->EXT;
		}
	   }
	FD -> FCBTAB.ART |= KENN | SCHREIBEN;
	NR =1;
	IF ( RCEX )
	   --RCEX;
	ELSE
	   IF ( EX )
		{
		--EX;
		RCEX = RECLAE;
		}
	   ELSE
		NR = 0;
	FD -> FCBTAB.FCB.EXT = EX;
	BDOS ( FD -> FCBTAB.FCB, _OPFIL );
	FD -> FCBTAB.FCB.CR = RCEX;
	IF ( NR )
	   {
	   IF ( BDOS (& FD -> FCBTAB.FCB, _REASEQ) & 255 )
		RETURN -1;
	   IF ( FD -> FCBTAB.ART & ASCMOD ) ;
	   ELSE	
		RETURN 0;
	   WHILE ( *FD -> POI != 0X1A )	
		{
		IF ( ++FD -> POI >= FD -> BUFF + RECLAE )
		   {
		   FD -> POI = FD -> BUFF;
		   RETURN 0;
		   }
		}
	   IF ( FD -> FCBTAB.FCB.CR )
		-- FD -> FCBTAB.FCB.CR;
	   ELSE
		{
		-- FD -> FCBTAB.FCB.EXT;
		BDOS ( &FD -> FCBTAB.FCB, _OPFIL );
		FD -> FCBTAB.FCB.CR = REC_EXT;
		}
	   }
	RETURN 0;
   }
}

/*		*/
/*
#INCLUDE IODEF.C
*/
/* STATIC INT XXXMER = 0; */
EXTERN INT XXXMER;

EXTERN INT CPVERS;

FCLOSE(FP)
FILE *FP;
{
   STATIC INT RET;
   IF ( (FP -> FCBTAB.ART & ~(KMASK & ~UNPUFF)) + (-KENN) )
	RETURN EOF;
   RET = 0;
   IF ( FP -> FCBTAB.ART & GEAEN )
	{
	IF ( FP -> FCBTAB.ART & VORSOLL )
	   {
	   FP -> FCBTAB.ART &= ~VORSOLL;
		RET = PUFPRO ( FP );
	   }
	ELSE
	   {
	   WHILE ( (FP -> POI - FP -> BUFF ) & 127 )
		*FP -> POI ++ = 0X1A;
	   FP -> EPOI = FP -> POI;
	   RET =  PUTC ( 0X1A, FP );
	   }
	IF ( (BDOS ( &FP ->FCBTAB.FCB, _CLOSFIL) | ~255)+1  ) ;
	ELSE
	   RET = EOF;
	}
   FP -> FCBTAB.ART = 0;
   IF ( XCLOSE( &FP -> FCBTAB ) )
	RETURN EOF;
   RETURN RET;
}

PUTC(C, HFP)
INT C;
FILE *HFP;
{
   STATIC CHAR *DMA;
   STATIC INT RECANZ, R;
   STATIC FILE *FP;
   IF ( (FP = HFP) -> FCBTAB.ART == WSTDOUT)
	RETURN APUTCHAR (C);
   SWITCH (FP->FCBTAB.ART & ~(KMASK & ~SCHREIBEN & ~UNPUFF & ~ASCMOD))
	{
	CASE SCHREIBEN | KENN:
		IF (FP -> POI < FP ->EPOI)
		   {
		   FP -> FCBTAB.ART |= GEAEN;
		   RETURN *FP -> POI++ = C;
		   }
		BREAK;
	CASE SCHREIBEN | KENN | ASCMOD:
		IF ( FP -> POI < FP -> EPOI )
		   {
		   FP -> FCBTAB.ART |= GEAEN;
		   IF ( C + ( -'\N') )
			RETURN *FP -> POI++ = C;
		   *FP -> POI ++ = '\R';
		   IF ( FP -> POI < FP -> EPOI )
			RETURN *FP -> POI++ = '\N';
		   }
		ELSE
		   XXXMER = 1;
		BREAK;
	DEFAULT:
		RETURN EOF;
	}
   IF (FP -> FCBTAB.ART & VORSOLL)
	   {
	   IF (PUFPRO (FP) )
		{
		XXXMER = 0;
		RETURN EOF;
		}
	   }
   ELSE
	   {
	   DMA = FP -> BUFF;
	   R = RECANZ = (FP -> POI - FP->BUFF) >> 7;
	   WHILE (RECANZ -- )
		{
		BDOS (DMA, _DMA);
		IF (BDOS (FP -> FCBTAB.FCB, _WRSEQ) & 255)
		   {
		   XXXMER = 0;
		   RETURN EOF;
		   }
		DMA += RECLAE;
		++ *((LONG *) &FP -> FSIZE) ;
		}
	   *((LONG *) &FP -> FREC) += R;
	   FP -> POI = FP -> BUFF;
	   }
   FP -> FCBTAB.ART |= GEAEN;
   IF ( XXXMER )
	{
	XXXMER = 0;
	   IF ( C + ( -'\N' ) ) ;
	   ELSE
		*FP -> POI++ = '\R';
	}
   RETURN *FP -> POI ++ = C;
}

PUFPRO(HFP)
FILE *HFP;
{
   STATIC UNSIGNED R, DMA, OVSAVE;
   STATIC LONG RECSAVE;
   STATIC FILE *FP;
   STATIC INT RECANZ;
   FP = HFP;
   RECSAVE = *((LONG *) &FP -> FREC) + 
		(RECANZ = (FP->EPOI - FP->BUFF) >> 7);
   IF ( FP -> FCBTAB.ART & GEAEN )
	{
	IF ( FP -> FCBTAB.ART & VORIST )  ;
	ELSE
	   {
	   R = FP -> BUFF - FP -> POI & 127;
	   WHILE ( R-- )
		*FP -> POI ++ = 0X1A;
	   FP -> EPOI = FP -> POI;
	   RECSAVE= *((LONG *) &FP->FREC) + 
		(RECANZ= (FP->EPOI - FP->BUFF) >> 7);
	   }
	DMA = FP -> BUFF;
	*((LONG *) &FP -> FCBTAB.FCB.RECORD) = 
		*((LONG *) &FP -> FREC);
	WHILE ( RECANZ -- )
	   {
	   BDOS (DMA, _DMA);
	   IF ( BDOS ( FP -> FCBTAB.FCB, _WRRAN) & 255)
		{
		FP -> POI = FP -> EPOI;
		RETURN EOF;
		}
	   ++ *((LONG *) &FP -> FCBTAB.FCB.RECORD);
	   DMA += RECLAE;
	   }
	IF ( *((LONG *) &FP -> FCBTAB.FCB.RECORD) > 
			*((LONG *) &FP -> FSIZE) )
	   *((LONG *) &FP -> FSIZE) =
		*((LONG *) &FP -> FCBTAB.FCB.RECORD);
	FP -> EPOI = FP -> BUFF + BUFFLAE;
	FP -> FCBTAB.ART &= ~(GEAEN | VORIST);
	}
   FP -> POI = FP -> BUFF;
   *((LONG *) &FP -> FCBTAB.FCB.RECORD) = 
		*((LONG *) &FP -> FREC) = RECSAVE;
   IF ( FP -> FCBTAB.ART & VORSOLL )
	{
	FP -> FCBTAB.ART |= VORIST;
	DMA = FP -> BUFF;
	RECANZ = BUFFLAE/RECLAE;
	WHILE ( RECANZ -- )
	   {
	   BDOS(DMA, _DMA);
	   IF ( BDOS (FP -> FCBTAB.FCB, _REARAN ) & 255 )
		BREAK;
	   DMA += RECLAE;
	   ++ *((LONG *) &FP -> FCBTAB.FCB.RECORD);
	   }
	IF ( (FP -> EPOI = DMA) == FP -> BUFF)
	   {
	   FP -> EPOI = FP -> BUFF + RECLAE;
	   FP -> FCBTAB.ART &= ~VORIST;
	   IF ( *((LONG *) &FP -> FCBTAB.FCB.RECORD) >= 
			*((LONG *) &FP -> FSIZE))
	     IF ((FP->FCBTAB.ART & (LESEN|SCHREIBEN)) != (LESEN|SCHREIBEN))
		{
		FP -> FCBTAB.ART &= ~VORSOLL;
	   	FP -> EPOI = FP -> BUFF + BUFFLAE;
		}
	   }
	}
   RETURN 0;
}

/*		*/
/*
#INCLUDE IODEF.C
*/

LSEEK(HFD, OFFSET, ORIGIN)
STRUCT   SFCBTAB *HFD;
LONG OFFSET;
INT ORIGIN;
{
   STATIC STRUCT   SFCBTAB *FD;
   STATIC LONG LREC;
   STATIC INT IOFF;
   IF (((FD= HFD)->ART & ~(KMASK & ~UNPUFF )) + (-(KENN | UNPUFF)))
	RETURN -1;
   SWITCH ( ORIGIN )
	{
	CASE 0:
		* ((LONG *) &FD -> FCB.RECORD) = 0;
		FD -> OFFSET = 0;
		BREAK;
	CASE 2:
		BDOS ( &FD -> FCB, _SIZFIL);
		FD -> OFFSET = 0;
	CASE 1:
		BREAK;
	} 
   LREC = ( OFFSET >> 7 ) + *((LONG *) &FD -> FCB.RECORD);
   IOFF = FD -> OFFSET + (OFFSET & 127);
   IF ( IOFF > 127 )
	LREC = LREC + 1;
   FD -> OFFSET = IOFF & 127;
   IF ( *(((INT *) &LREC) + 1) < 0 )
	{
	* ((LONG *) &FD -> FCB.RECORD) = 0;
	FD -> OFFSET = 0;
	RETURN 0;
	}
   IF ( *(((INT *) &LREC) + 1) > 0X3 )
	RETURN -1;
   *((LONG *)&FD -> FCB.RECORD) = LREC;
   RETURN 0;
}

ISEEK(FD, OFFSET, ORIGIN)
STRUCT SFCBTAB *FD;
INT OFFSET;
INT ORIGIN;
{
#IFDEF MIZE318
   RETURN LSEEK( FD, OFFSET, 0, ORIGIN);
#ELSE
   RETURN LSEEK( FD, (LONG) OFFSET, ORIGIN);
#ENDIF
}

REWIND ( FD)
STRUCT SFCBTAB *FD;
{
  RETURN  ISEEK(FD,0,0);
}

/*		*/
/*
#INCLUDE IODEF.C
*/
STATIC CHAR RBUFF[128];  /* READ, WRITE RESERVEPUFFER */

OPEN(NAME, ART)
CHAR *NAME;
INT ART;
{
   STATIC STRUCT SFCBTAB *FCBPOI;
   IF ( BDOS(0, _VERS) < 0X20 )
	RETURN -1;
   IF ( ( FCBPOI = CALLOC(1, SIZEOF(STRUCT SFCBTAB) )) == NULL)
	RETURN -1;
   SWITCH (ART)
	{
	CASE 0:
	CASE 1:
	CASE 2: IF ( XOPEN(FCBPOI, NAME, 0) )
			GOTO OPFEHL;
LAB:		FCBPOI -> ART = (KENN | UNPUFF) + (ART&3) + 1;
		BREAK;
	CASE 4:
	CASE 5:
	CASE 6: IF ( XOPEN(FCBPOI, NAME, 2) );
		ELSE GOTO LAB;
	DEFAULT:
OPFEHL:		CFREE (FCBPOI);
		RETURN -1;
	}
   RETURN FCBPOI;
}

CREAT (NAME, TYP)
CHAR *NAME;
INT TYP;
{
   RETURN OPEN (NAME, TYP+4);
}

WRITE (HFD, HBUF, LAE)
CHAR *HBUF;
STRUCT SFCBTAB *HFD;
UNSIGNED LAE;
{
   STATIC CHAR *BUF;
   STATIC STRUCT SFCBTAB *FD;
   STATIC UNSIGNED N;
   STATIC UNSIGNED ANZAHL, I;
   N=LAE;
   BUF=HBUF;
   IF ( (FD=HFD) -> ART == WSTDOUT )
	{
	ANZAHL = N;
	WHILE ( ANZAHL -- )
	   PUTCHAR( *BUF++);
	RETURN N;
	}
   I = ANZAHL = 0;
   IF ((FD->ART & ~(KMASK & ~SCHREIBEN & ~UNPUFF )) 
		+ (-(KENN | SCHREIBEN | UNPUFF)))
	RETURN 0;
   IF ( FD -> OFFSET )
	IF ( N )
	   {
	   BDOS (RBUFF, _DMA);
	   BDOS ( &FD -> FCB, _REARAN) ;
	   WHILE ( FD -> OFFSET & (RECLAE - 1))
		{
		IF ( N )
		   {
		   RBUFF[FD -> OFFSET++] = *BUF++;
		   -- N;
		   ++ ANZAHL;
		   }
		ELSE
		   BREAK;
		}
	   IF ( BDOS ( &FD -> FCB, _WRRAN ) )
		RETURN 0;
	   IF ( FD -> OFFSET & 127 ) ;
	   ELSE
		++ *((LONG *) &FD -> FCB.RECORD);
	   }
   WHILE ( N >= RECLAE )
	{
	BDOS ( BUF,_DMA );
	IF (BDOS (&FD -> FCB, _WRRAN) )
	   RETURN ANZAHL;
	N	-= RECLAE;
	BUF	+= RECLAE;
	ANZAHL	+= RECLAE;
	++ *((LONG *) &FD -> FCB.RECORD);
	}
   FD -> OFFSET &= 127;
   IF ( N )
	{
	BDOS ( RBUFF, _DMA );
	BDOS ( &FD -> FCB, _REARAN);
	WHILE ( N )
	   {
	   RBUFF[I++] = *BUF++;
	   ++ FD ->OFFSET;
	   -- N;
	   }
	IF ( BDOS ( &FD -> FCB, _WRRAN ) )
		RETURN ANZAHL;
	ANZAHL += I;
   }
   RETURN ANZAHL;
}

READ (HFD, HBUF, LAE)
CHAR *HBUF;
STRUCT SFCBTAB *HFD;
UNSIGNED LAE;
{
   STATIC CHAR *BUF;
   STATIC STRUCT SFCBTAB *FD;
   STATIC UNSIGNED N;
   STATIC UNSIGNED ALTEXT, ANZAHL;
   STATIC LONG DATLAE, ALTREC;
   N=LAE;
   BUF=HBUF;
   ANZAHL = 0;
   IF ( (FD= HFD) -> ART == WSTDIN )
	{
	ANZAHL = N;
	WHILE ( ANZAHL -- )
	   *BUF++ = GETCHAR();
	RETURN N - ANZAHL + 1 ;
	}
   IF ((FD->ART & ~(KMASK & ~LESEN & ~UNPUFF )) 
		+ (-(KENN | LESEN | UNPUFF)))
	RETURN -1;
   IF ( FD -> OFFSET )
	IF ( N )
	   {
	   BDOS (RBUFF, _DMA);
	   IF ( BDOS ( &FD -> FCB, _REARAN) )
READFE:		{
		ALTEXT = FD -> FCB.EXT;
		ALTREC = *((LONG *) &FD -> FCB.RECORD);
		BDOS ( &FD -> FCB, _CLOSFIL);
		BDOS ( &FD -> FCB, _SIZFIL);
		DATLAE = *((LONG *) &FD -> FCB.RECORD);
		FD -> FCB.EXT = ALTEXT;
		BDOS ( &FD -> FCB, _OPFIL);
		IF ( DATLAE <= ALTREC )
		   RETURN ANZAHL;
		RETURN -1;
		}
	   WHILE ( FD -> OFFSET & (RECLAE  - 1) )
		{
		IF ( N )
		   {
		   *BUF ++ =  RBUFF[FD -> OFFSET++] ;
		   -- N;
		   ++ ANZAHL;
		   }
		ELSE
		   BREAK;
		}
	   IF ( FD -> OFFSET & 127 ) ;
	   ELSE
		++ *((LONG *) &FD -> FCB.RECORD);
	   }
   WHILE ( N >= RECLAE )
	{
	BDOS ( BUF,_DMA );
	IF (BDOS (&FD -> FCB, _REARAN) )
	   GOTO READFE;
	N	-= RECLAE;
	BUF	+= RECLAE;
	ANZAHL	+= RECLAE;
	++ *((LONG *) &FD -> FCB.RECORD);
	}
   FD -> OFFSET &= 127;
   IF ( N )
	{
	BDOS ( RBUFF, _DMA );
	IF ( BDOS ( &FD -> FCB, _REARAN) )
	   GOTO READFE;
	WHILE ( N )
	   {
	   *BUF++ = RBUFF[FD -> OFFSET ++];
	   ++ ANZAHL;
	   -- N;
	   }
   }
   RETURN ANZAHL;
}

/*		*/
/*
#INCLUDE IODEF.C
*/

CLOSE(FD)
STRUCT SFCBTAB *FD;
{
   IF ((FD->ART & ~(KMASK & ~UNPUFF )) + (-(KENN | UNPUFF)))
	RETURN -1;
   IF ( FD -> ART & SCHREIBEN )
	IF ( (BDOS (&FD -> FCB, _CLOSFIL) & 255) == 255 )
	   {
	   XCLOSE (FD);
	   RETURN -1;
	   }
   XCLOSE (FD);
   RETURN 0;
}

/*		*/
/*
#INCLUDE IODEF.C
*/
EXTERN FILE *XXXDAT ;
EXTERN INT CPVERS;

XOPEN (HFCBTPOI, NAME, ART)
STRUCT SFCBTAB *HFCBTPOI;
CHAR *NAME;
INT ART;
{
   STATIC STRUCT SFCBTAB *FCBTPOI;
   IF ( NAMEIN (NAME, (FCBTPOI= HFCBTPOI) -> FCB ) )
	RETURN -1;
   FCBTPOI -> FCB.RECORD = 0;
   FCBTPOI -> FCB.OVERFL = 0;
   FCBTPOI -> FCB.EXT = 0;
   SWITCH  (ART)
	{
	CASE 3:
		IF ( CPVERS )
		   BDOS( &FCBTPOI -> FCB, _SIZFIL );
		ART= 0;
	CASE 0:
	CASE 1:
	   FCBTPOI -> FCB.EXT = 0;
	   IF ((BDOS ( &FCBTPOI -> FCB, _OPFIL) & 255)==255)
		RETURN -1;
	   IF ( ! ART )
		BREAK;
	CASE 2:
	   BDOS ( &FCBTPOI -> FCB, _DELFIL);
	   IF ((BDOS ( &FCBTPOI -> FCB, _MAKFIL) & 255)==255)
		RETURN -1;
	}
   FCBTPOI -> FCB.CR = 0;
   FCBTPOI -> OFFSET = 0;
   FCBTPOI -> NEXT = XXXDAT;
   XXXDAT = FCBTPOI;
   RETURN 0;
}

/*		*/
/*
#INCLUDE IODEF.C
*/
/* FILE *XXXDAT = NULL; */
EXTERN FILE *XXXDAT;

XCLOSE (HFOPD)
FILE *HFOPD;
{
   STATIC STRUCT SFCBTAB *OPDAT;
   STATIC FILE *FOPD;
   IF ((OPDAT = XXXDAT) == (FOPD = HFOPD) )
	{
	XXXDAT = FOPD -> FCBTAB.NEXT;
	GOTO FREI;
	}
   WHILE ( OPDAT != NULL )
	{
	IF ( OPDAT -> NEXT == FOPD )
	   {
	   OPDAT -> NEXT = FOPD -> FCBTAB.NEXT;
FREI:	   CFREE (FOPD);
	   RETURN 0;
	   }
	ELSE
	   OPDAT = OPDAT -> NEXT;
	}
   RETURN 1;
}

/*		*/
/*
#INCLUDE IODEF.C
*/

NAMEIN (HNAME, FCBPOI)
CHAR *HNAME;
STRUCT SFCB *FCBPOI;
{
   STATIC CHAR *NAME;
   STATIC INT LEN, C, K;
   STRCPY(FCBPOI -> NAME,"           ");
   IF ((LEN= STRLEN(NAME= HNAME)) > 3 &&
	 (NAME[1] == ':' ) && *NAME )
	   {
	   IF ( *NAME >= 'A' && TOUPPER(*NAME) <= 'P' )
		FCBPOI -> DRIVE = *NAME & 31;
	   ELSE
		RETURN -1;
	   NAME += 2;
	   LEN -= 2;
	   }
   ELSE
	FCBPOI -> DRIVE = 0;
   IF (LEN)
	{
	K = 0;
	WHILE ( C= *NAME++ )
	   {
	   IF ( C == '.' )
		{
		K= 0;
		WHILE (C= * NAME++)
		   {
		   IF (K < 3) 
			FCBPOI -> TYPE[K] = TOUPPER(C);
		   ++K;
		   }
		RETURN 0;
		}
	   IF ( K < 8 )
		FCBPOI -> NAME[K] = TOUPPER (C);
	   ++K;
	   }
	RETURN 0;
	}
   RETURN -1;
}

UNLINK(NAME)
CHAR *NAME;
{
   STATIC STRUCT SFCB UNLFCB;
   NAMEIN (NAME, &UNLFCB);
   BDOS ( &UNLFCB, _DELFIL);
}

/*		*/
/*
#INCLUDE IODEF.C
*/

GETS (HBUFF)
CHAR *HBUFF;
{	STATIC INT K, J;
	STATIC CHAR *BUFF;
	*(BUFF = HBUFF) = 80;
	BDOS(BUFF,10);
	PUTCHAR('\N');
	K = J = BUFF[1];
	WHILE (K--)
		*BUFF = *( BUFF++ +2 );
	*BUFF = 0;
	RETURN J;
}

PUTS(BUFFER)
CHAR *BUFFER;
{	STATIC INT C;
	WHILE(C= *BUFFER++) PUTCHAR(C);
	PUTCHAR('\R'); PUTCHAR('\N');
}

/*		*/
/*
#INCLUDE IODEF.C
*/
INT CPVERS;	/* CP/M VERSIONSNR. */
/* STATIC INT XXXZEI = 0; */
EXTERN INT XXXZEI;
STATIC INT UNGVAR;	
			
PUTCHAR(C)
INT C;
{
   BDOS( C, _CONOUT);
   RETURN C;
}

APUTCHAR(C)
INT C;
{
   IF ( C + (-'\N') ) ;
   ELSE
	PUTCHAR('\R');
   RETURN PUTCHAR(C);
}

GETCHAR()
{
   IF (XXXZEI)
	{
	XXXZEI = 0;
	RETURN UNGVAR;
	}
   RETURN ( BDOS( 1, _CONIN) & 127);
}

AGETCHAR()
{
   STATIC INT C;
   IF ( (C = GETCHAR()) + (-'\R'))
	IF (C + (-0X1A))
	   RETURN C;
	ELSE
	   RETURN EOF;
   ELSE
	RETURN PUTCHAR('\N');
}

UNGETCHAR(C)
INT C;
{
   UNGVAR = C;
   XXXZEI = 1;
   RETURN C;
}

CHRRDY()
{ 
   RETURN BDOS(0,11) & 1;
}

_EXIT ()
{
   BDOS (0, _SYSRES);
}

/*	CP/M SUPPORT ROUTINE  V3.XX
;	RETURNS H=B, L=A
*/
BDOS (DE,C)
CHAR *DE; INT C;
{
#ASM
	POP H		; RETURN ADDRESSE
	POP D		; DE REGISTER
	POP B		; BDOS FUNCTION 
	PUSH B
	PUSH D		
	PUSH H
	CALL 5		; CP/M BDOS
	MOV H,B		;FUER CP/M 1.4
	MOV L,A
#ENDASM
}

/*		*/
