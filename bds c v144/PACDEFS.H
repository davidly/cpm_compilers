#define GAME1	'1'
#define GAME2	'2'
#define GAME3	'3'
#define GAME4	'4'
#define MAXSCORE	"0/a:pacman.log"
#define MSSAVE	5	/* maximum scores saved per game type */
#define MGTYPE	4	/* Maximum game types */
#define	MAXPAC	3	/* maximum number of pacmen to start */
#define	MAXMONSTER	4	/* max number of monsters */
#define EMPTY	'E'
#define FULL	'F'
#define LEFT	0x08 /* LEFT..NDOWN changed for TVI 925 !!! */
#define RIGHT	0x0c
#define	NORTH	0x0b /* means UP, but UP defined in vsinit() */
#define NNORTH	0x0b
#define	DOWN	0x16
#define NDOWN	0x16
#define HALT	0x0c /* change from 0x0c to 0x015 */
#define DELETE	'\177'
#define ABORT	'\34'
#define QUIT	'e'
#define CNTLS	'\23'
#define BUF_SIZE	32
#define	TRUE	1
#define	FALSE	0
#define	UPINT	(-1)
#define	DOWNINT	1
#define	LEFTINT	(-2)
#define	RIGHTINT	2
#define	PACMAN	'@'
#define	MONSTER	'M'
#define	RUNNER	'S'
#define	TREASURE	'$'
#define	CHOICE		'*'
#define	GOLD		'.'
#define	POTION		'%'
#define	VACANT		' '	/* space */
#define	WALL		'#'
#define	GATE		'-'
#define	START	0
#define	RUN	1
#define	FAST	1
#define	SLOW	0
#define	PSTARTX	18
#define	PSTARTY	17
#define	MSTARTX	16	/* monster starting position */
#define	MSTARTY	10	/* monster starting position */
#define	MBEGINX	18	/* monster beginning position */
#define	MBEGINY	7	/* monster beginning position */
#define	TRYPOS	13
#define	TRXPOS	20
#define	GOTONE	1
#define	TURKEY	(-1)
#define	DUP	1
#define	DDOWN	4
#define	DRIGHT	3
#define	DLEFT	2
#define	DNULL	0
#define	BRDX	40
#define	BRDY	23
#define XWRAP	38
#define	TREASVAL	20
#define	KILLSCORE	10
#define	BEEP		'\07'	/* ctrl-g */
#define	MSTARTINTVL	10
#define	POTINTVL	25
#define GOLDCNT	185
#define PUP	'^'
#define PDOWN	'v'
#define PLEFT	'<'
#define PRIGHT	'>'

struct	pactyp
{
	int	xpos;	/* horizontal position */
	int	ypos;	/* vertical   position */
	int	dirn;	/* direction of travel */
	int	speed;	/* FAST/SLOW	       */
	int	danger;	/* TRUE if can eat     */
	int	stat;	/* status		*/
};

int	rscore[MAXMONSTER];

struct pactyp
	monst[MAXMONSTER];

int	pacsymb,
	rounds,		/* time keeping mechanism */
	killflg,
	delay,
	potion,
	goldcnt,		/* no. of gold pieces remaining */
	potioncnt;

char    aborted;

struct pactyp
	pac;

struct pactyp
	*pacptr;

/*
 * initbrd is used to re-initialize the display
 * array once a new game is started.
 */
char	initbrd[BRDY][BRDX];

/* brd is kept for historical reasons.
 * It should only be used in the routine "which"
 * to determine the next move for a monster or
 * in the routine "monster" to determine if it
 * was a valid move. Admittedly this is redundant
 * and could be replaced by initbrd, but it is kept
 * so that someday additional intelligence or
 * optimization could be added to the choice of
 * the monster's next move. Hence, note the symbol
 * CHOICE at most points that a move decision
 * logically HAS to be made.
 */
char	brd[BRDY][BRDX];

/*
 * display reflects the screen on the player's
 * terminal at any point in time.
 */
char
	display[BRDY][BRDX];

char
	message[81];	/* temporary message buffer */

int	game,
	killcnt;

unsigned
	pscore;

struct uscore
{
	unsigned score;	/* same type as pscore */
	char name [9];  /* name of player */
} scoresave [MGTYPE][MSSAVE];

char
	dummydummy [128]; /* safety area for reading of scoresave */

char
	posnstr[10]; /* cursor positioning string, made extern for speed */

