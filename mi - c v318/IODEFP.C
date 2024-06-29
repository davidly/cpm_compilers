/* STATT BUFFLAE 512 */
/* C-SUPPORT ROUTINES V3.19 */
/* MI - C  v-3.183 (C) COPYRIGHT G. KERSTING / H. ROSE, 1983 */
/*   11/83  */
#DEFINE NULL	0
#DEFINE EOF	-1
#DEFINE UNGETCHAR XUNGE
#DEFINE _EXIT	XEXIT
#DEFINE STRNCMP	STNCMP
#DEFINE STRNCPY	STNCPY
#DEFINE STRNCAT	STNCAT
/*		*/
/* MIT DEN BEIDEN FOLGENDEN ERSETZUNGEN KANN DIE EIN-
  AUSGABE ZUM TERMINAL VEAENDERT WEREN. 
	0X1A (^Z) LIEFERT DANN EOF ZURUECK
	BEI GETCHAR WIRD '\R' SOWIE '\N' ALS '\N'ERKANNT
	PUTCHAR GIBT '\N' ALS '\R' '\N' AUS
*/
/*#DEFINE GETCHAR	AGETCHAR*/
/*#DEFINE PUTCHAR	APUTCHAR*/
/*		*/
/*		*/

/*

STATIC STRUCT STDSTRUCT {INT ART;} SSTDIN = 111;
STATIC STRUCT STDSTRUCT SSTDOUT = 112;
STATIC STRUCT STDSTRUCT *STDIN = &SSTDIN;
STATIC STRUCT STDSTRUCT *STDOUT = &SSTDOUT;
#DEFINE STDERR	STDOUT

*/

/*	*/
TYPEDEF STRUCT FILESTRUCT {
	STRUCT SFCBTAB {
		INT ART;
		STRUCT SFCB
			{
			   CHAR DRIVE,
				NAME[8],
				TYPE[3],
				EXT,
				RESV[2],
				RC,
				SYDX[16],
				CR;
		       UNSIGNED RECORD;
			   INT OVERFL;
			} FCB;
		INT OFFSET;
		STRUCT FILESTRUCT *NEXT;
		       } FCBTAB;
			UNSIGNED FREC;	
			INT	FOVER;
			/* RANDOM 1. REC. IM PUFFER */
			    CHAR *POI;
			    CHAR *EPOI,
				 BUFF[512]; /* BUFFLAE */
			UNSIGNED FSIZE;
			INT	FOSIZE;
			 } FILE;
/*		*/
/* BDOS - FUNKTIONEN */
#DEFINE	_SYSRES		0
#DEFINE	_CONIN		1
#DEFINE	_CONOUT		2
#DEFINE _VERS		12
#DEFINE _OPFIL		15
#DEFINE _CLOSFIL	16
#DEFINE _SEAFIR		17
#DEFINE _SEANEX		18
#DEFINE _DELFIL		19
#DEFINE _REASEQ		20
#DEFINE _WRSEQ		21
#DEFINE _MAKFIL		22
#DEFINE _DMA		26
#DEFINE _REARAN		33
#DEFINE _WRRAN		34
#DEFINE _SIZFIL		35
#DEFINE _SETRRC		36
/*		*/
/* STANDARTGROESSEN */
#DEFINE RECLAE  128
#DEFINE RECMASK 7
#DEFINE BUFFLAE 512
#DEFINE REC_EXT 128
/*		*/
/* MASKEN	*/
#DEFINE KENN		0X5780
#DEFINE LESEN		1
#DEFINE SCHREIBEN	2
#DEFINE UNPUFF		0X10
#DEFINE GEAEN		0X20
#DEFINE VORSOLL		4
#DEFINE VORIST		8
#DEFINE ASCMOD		0X40
#DEFINE KMASK (LESEN | SCHREIBEN | UNPUFF | GEAEN | VORSOLL |\
	 VORIST | ASCMOD)
/*		*/
/*		*/
#DEFINE WSTDIN	111
#DEFINE WSTDOUT 112
#DEFINE WSTDERR 112
/*		*/
#DEFINE MIZE318	1
/*		*/
INE REC_EXT 128
/*		*/
/* MASKEN	*/
#DEFINE KENN		0X5780
#DEFINE LESEN		1
#DEFINE SCHREIBEN	2
#DEFINE UNPUFF		0X10
#DEFINE GEAEN		0X20
#DEFINE VORSOLL		4
#DEFINE VORIST		8
#DEFINE ASCMOD		0X40
#DEFINE KMASK (LESEN | SCHREIBEN | UNPUFF | GEAEN | ееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее