#include "bdscio.h"
#include "pacdefs.h"

update()
{
	char	str[10];

	sprintf(str, "%6d", pscore);
	SPLOT(0, 53, str);
	sprintf(str, "%6d", goldcnt);
	SPLOT(21, 53, str);
}

reinit()
{
	register int locx, locy;
	register char tmp;

	for (locy = 0; locy < BRDY; locy++)
	{
		for (locx = 0; locx < BRDX; locx++)
		{
			tmp = initbrd[locy][locx];
			brd[locy][locx] = tmp;
			if ((display[locy][locx] = tmp) == CHOICE)
			{
				display[locy][locx] = GOLD;
			};
		};
	};
	goldcnt = GOLDCNT;
	delay -= (delay / 10);	/* hot it up */
}

errgen(string)
char	*string;
{
	SPLOT(23,45,string);
}

dokill(mnum)
	int mnum;
{
	register struct pactyp *mptr;

	PLOT(0, 0, BEEP);
	if (pacptr->danger == TRUE)
	{
		if (++killcnt == MAXMONSTER)
		{
			if (display[TRYPOS][TRXPOS] == GOLD)
			{
				goldcnt--;
			};
			display[TRYPOS][TRXPOS] = TREASURE;
			PLOT(TRYPOS, TRXPOS, TREASURE);
			killcnt = 0;
		};
		SPLOT(5, 45, "MONSTER ERLEDIGT: ");
		sprintf(message, "%1d", killcnt);
		SPLOT(5, 62, message);
		mptr = (&monst[mnum]);
		mptr->ypos = MSTARTY;
		mptr->xpos = MSTARTX + (2 * mnum);
		mptr->stat = START;
		PLOT(mptr->ypos, mptr->xpos, MONSTER);
		pscore += KILLSCORE;
		return(GOTONE);
	};
	return(TURKEY);
}

/*
 * clr -- issues an escape sequence to clear the display
 */

clr()
{
	puts(CLEARS);
	nap(4);
}

/*
 *	display initial instructions
 */

instruct()
{
	clr();
	POS(0, 0);
printf("Du bist in einem Labyrinth, gejagt von MONSTERN!\r\n\n");
printf("Im Labyrinth sind Goldmuenzen verteilt (markiert durch \".\"),\r\n");
printf("die Du aufsammeln musst, bevor Dich die Monster erwischen.\r\n");
printf("An den Stellen, die durch \"\%\" markiert sind, ist ein\r\n");
printf("Zaubertrank, der Dir fuer kurze Zeit erlaubt, die Monster\r\n");
printf("auszuschalten.\r\n");
printf("Wenn Du erwischt wirst, hast Du noch %d Chancen.\r\n", MAXPAC);
printf("Wenn Du alle Monster erledigt hast, erscheint noch ein weiterer\r\n");
printf("Schatz (markiert durch \"$\").\r\n\n\n");

	printf("     Eingabe:   Pfeile  - Bewegen in diese Richtung\r\n");
	printf("                HOME    - Anhalten\r\n");
	printf("                E       - Spielende\r\n\n");
      instrsel();
}

instrsel()
{       
	printf("                1       - Normales Spiel\r\n");
	printf("                2       - Blinkende Monster\r\n");
	printf("                3       - Intelligente Monster\r\n");
	printf("                4       - Blinkende intelligente Monster\r\n\n");
        printf("Bitte 1-4 auswaehlen: ");


}

/*
 * over -- game over processing
 */

over()
{
	register int i, j, inx;
	register int line;
	int scorefile;
        char ok;
	char spieler [80];

	sleep(10);	/* for slow readers */
	poll(0);	/* flush and discard input from player */
	clr();
	/* high score to date processing */
	if (game != 0)
	{
		POS (4, 10);
		inx = -1;
		j = game-1;
		ok =  ((scorefile = open(MAXSCORE, 2)) != -1);
		if (ok && (read(scorefile, scoresave, 2) != -1))
		{
		for (i = MSSAVE - 1; i >= 0; i--) {
			if (scoresave[j][i].score < pscore)
			{
				if (i < MSSAVE - 1)
				{
				scoresave[j][i + 1].score =
					scoresave[j][i].score;
				strcpy (scoresave[j][i + 1].name,
					scoresave[j][i].name);
				};
			inx = i;
			};
		  }
                }
                else {
                        scorefile = creat (MAXSCORE);
                        for (j=0; j<MGTYPE; j++)
                           for (i = MSSAVE-1; i>= 0; i--)
                              {
                              scoresave [j][i].score = 0;
                              scoresave [j][i].name[0] = 0;
                              };
			inx = 0;
                     };

		if (inx >= 0)
			{
			puts ("Wie heisst Du ? ");
			gets (spieler);
			spieler [9] = 0;

			scoresave[game - 1][inx].score = pscore;
			strcpy (scoresave[game - 1][inx].name, spieler);
			}
			else puts ("Na ja...");

		seek(scorefile, 0, 0);
		write(scorefile, scoresave, 2);
		close(scorefile);

		line = 7;
		POS(line++, 20);
		printf(" ___________________________ ");
		POS(line++, 20);
		printf("|                           |");
		POS(line++, 20);
		printf("| S P I E L   E N D E       |");
		POS(line++, 20);
		printf("|                           |");
		POS(line++, 20);
		printf("| Spielart: %1d               |",game);
		POS(line++, 20);
		printf("| Hoechste Punktzahl bisher |");
		for (i = 0; i < MSSAVE; i++)
		{
			POS(line++, 20);
			printf("| Spieler: %-8s  %5u  |", 
				scoresave[game - 1][i].name,
				scoresave[game - 1][i].score);
		};

		POS(line++, 20);
		printf("|                           |");
		POS(line++, 20);
		printf("| Deine Punkte: %-5u       |", pscore);
		POS(line, 20);
		printf("|___________________________|");
	};
	leave();
}

/*
 * leave -- flush buffers,kill the Child, reset tty, and delete tempfile
 */

leave()
{
   puts (CURSORON);
}

/*
 * init -- does global initialization and spawns a child process to read
 *      the input terminal.
 */

init(again)
   char again;
{
	register int tries;

	tries = 0;
	TTYMode(0);	/* Tell cio.c to be REALLY raw! */
	initPOS();	/* initialize the fixed part of posnstr */
	pacsymb = PACMAN;
	pacptr = &pac;

	strcpy(initbrd[0], "#######################################");
	strcpy(initbrd[1], "# . . . * . . . . ### . . . . * . . . #");
	strcpy(initbrd[2], "# % ### . ##### . ### . ##### . ### % #");
	strcpy(initbrd[3], "# * . . * . * . * . . * . * . * . . * #");
	strcpy(initbrd[4], "# . ### . # . ########### . # . ### . #");
	strcpy(initbrd[5], "# . . . * # . . . ### . . . # * . . . #");
	strcpy(initbrd[6], "####### . ##### . ### . ##### . #######");
	strcpy(initbrd[7], "      # . # . . * . . * . . # . #      ");
	strcpy(initbrd[8], "      # . # . ### - - ### . # . #      ");
	strcpy(initbrd[9], "####### . # . #         # . # . #######");
	strcpy(initbrd[10],"        * . * #         # * . *        ");
	strcpy(initbrd[11],"####### . # . #         # . # . #######");
	strcpy(initbrd[12],"      # . # . ########### . # . #      ");
	strcpy(initbrd[13],"      # . # * . . . . . . * # . #      ");
	strcpy(initbrd[14],"####### . # . ########### . # . #######");
	strcpy(initbrd[15],"# . . . * . * . . ### . . * . * . . . #");
	strcpy(initbrd[16],"# % ### . ##### . ### . ##### . ### % #");
	strcpy(initbrd[17],"# . . # * . * . * . . * . * . * # . . #");
	strcpy(initbrd[18],"### . # . # . ########### . # . # . ###");
	strcpy(initbrd[19],"# . * . . # . . . ### . . . # . . * . #");
	strcpy(initbrd[20],"# . ########### . ### . ########### . #");
	strcpy(initbrd[21],"# . . . . . . . * . . * . . . . . . . #");
	strcpy(initbrd[22],"#######################################");

	strcpy(brd[0], "#######################################");
	strcpy(brd[1], "# . . . * . . . . ### . . . . * . . . #");
	strcpy(brd[2], "# % ### . ##### . ### . ##### . ### % #");
	strcpy(brd[3], "# * . . * . * . * . . * . * . * . . * #");
	strcpy(brd[4], "# . ### . # . ########### . # . ### . #");
	strcpy(brd[5], "# . . . * # . . . ### . . . # * . . . #");
	strcpy(brd[6], "####### . ##### . ### . ##### . #######");
	strcpy(brd[7], "      # . # . . * . . * . . # . #      ");
	strcpy(brd[8], "      # . # . ### - - ### . # . #      ");
	strcpy(brd[9], "####### . # . #         # . # . #######");
	strcpy(brd[10],"        * . * #         # * . *        ");
	strcpy(brd[11],"####### . # . #         # . # . #######");
	strcpy(brd[12],"      # . # . ########### . # . #      ");
	strcpy(brd[13],"      # . # * . . . . . . * # . #      ");
	strcpy(brd[14],"####### . # . ########### . # . #######");
	strcpy(brd[15],"# . . . * . * . . ### . . * . * . . . #");
	strcpy(brd[16],"# % ### . ##### . ### . ##### . ### % #");
	strcpy(brd[17],"# . . # * . * . * . . * . * . * # . . #");
	strcpy(brd[18],"### . # . # . ########### . # . # . ###");
	strcpy(brd[19],"# . * . . # . . . ### . . . # . . * . #");
	strcpy(brd[20],"# . ########### . ### . ########### . #");
	strcpy(brd[21],"# . . . . . . . * . . * . . . . . . . #");
	strcpy(brd[22],"#######################################");

	strcpy(display[0], "#######################################");
	strcpy(display[1], "# . . . . . . . . ### . . . . . . . . #");
	strcpy(display[2], "# % ### . ##### . ### . ##### . ### % #");
	strcpy(display[3], "# . . . . . . . . . . . . . . . . . . #");
	strcpy(display[4], "# . ### . # . ########### . # . ### . #");
	strcpy(display[5], "# . . . . # . . . ### . . . # . . . . #");
	strcpy(display[6], "####### . ##### . ### . ##### . #######");
	strcpy(display[7], "      # . # . . . . . . . . # . #      ");
	strcpy(display[8], "      # . # . ### - - ### . # . #      ");
	strcpy(display[9], "####### . # . #         # . # . #######");
	strcpy(display[10],"        . . . #         # . . .        ");
	strcpy(display[11],"####### . # . #         # . # . #######");
	strcpy(display[12],"      # . # . ########### . # . #      ");
	strcpy(display[13],"      # . # . . . . . . . . # . #      ");
	strcpy(display[14],"####### . # . ########### . # . #######");
	strcpy(display[15],"# . . . . . . . . ### . . . . . . . . #");
	strcpy(display[16],"# % ### . ##### . ### . ##### . ### % #");
	strcpy(display[17],"# . . # . . . . . . . . . . . . # . . #");
	strcpy(display[18],"### . # . # . ########### . # . # . ###");
	strcpy(display[19],"# . . . . # . . . ### . . . # . . . . #");
	strcpy(display[20],"# . ########### . ### . ########### . #");
	strcpy(display[21],"# . . . . . . . . . . . . . . . . . . #");
	strcpy(display[22],"#######################################");

	killcnt = 0;
      if (!again)
	srand(0);	/* start rand randomly */
	delay = 2000;
	/*
	 * New game starts here
	 */
	game = 0;

      clr();

      if (!again)
	instruct();
        else { clr(); pos (0, 0); instrsel(); };
	aborted = 0;

	while ((game == 0) && !aborted)
		poll(1);

	goldcnt = GOLDCNT;
	pscore = 0;
	clr();
	puts(CURSOROFF);
}

/*
 * poll -- read characters sent by input subprocess and set global flags
 */

poll(sltime)
{
	int stop;
	int command;

	if(!kbhit())
		return;

        while ((command = getchar()) == ' ');

	switch(command)
	{

	case LEFT:
		pacptr->dirn = DLEFT;
		break;

	case RIGHT:
		pacptr->dirn = DRIGHT;
		break;

	case NORTH:
	case NNORTH:
		pacptr->dirn = DUP;
		break;

	case DOWN:
	case NDOWN:
		pacptr->dirn = DDOWN;
		break;

	case HALT:
		pacptr->dirn = DNULL;
		break;

	case ABORT:
	case DELETE:
	case QUIT:
		aborted = 1;
		break;

	case GAME1:
		game = 1;
		break;

	case GAME2:
		game = 2;
		break;

	case GAME3:
		game = 3;
		break;

	case GAME4:
		game = 4;
		break;

	default:
		putchar (7);
	}
}


getrand(range)
	int range;
{
	unsigned q;

	q = rand();
	return(q % range);
}

/*
 * Dummy nap() function
 */
nap(x)
{
	int i;
	for(i=0;i<20*x;i++);
}

/*
 * The PLOT function is normally defined using a preprocessor macro:
 * #define PLOT(A,B,C)  POS(A,B);putchar(C)
 */
PLOT(row,col,ch)
int row,col;
char ch;
{
	POS (row, col);
	putchar(ch);
}

/*
 * The SPLOT function is normally defined as:
 * #define SPLOT(A,B,S) POS(A,B);printf("%s",s)
 */
SPLOT(row,col,str)
int row,col;
char *str;
{
	POS (row, col);
	sputs(str);
}

/* This function is called at initialization time to set up
 * the fixed portion of the cursor positioning string.
 */
initPOS()
{
	posnstr[0] = ESC;
	posnstr[1] = '=';
	posnstr[4] = '\0';
}

/*
 * The POS function us normally defined, using termcap, as:
 * #define POS(row,col) tputs(tgoto(vs_cm,(col),(row),1,putch)
 */
POS(row,col)
int row,col;
{
	posnstr[2] = 32 + row;
	posnstr[3] = 32 + col;
	puts(posnstr);
}

sputs (str)
   char *str;
   {  char ch;

      while (ch = *str++)
         {  putchar (ch);
         }
   }
