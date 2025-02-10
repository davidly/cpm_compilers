

/*
	"STONE"
	(otherwise known as"Awari")

	This version written by
		Terry Hayes & Clark Baker
		Real-Time Systems Group
		MIT Lab for Computer Science
	(and hacked up a little by Leor Zolman)

	The algorithm used for STONE is a common one
	to Artificial Intelligence people: the"Alpha-
	Beta" pruning heuristic. By searching up and down 
	a tree of possible moves and keeping record of
	the minimum and maximum scores from the
	terminal static evaluations, it becomes possible
	to pinpoint move variations which can in no way
	affect the outcome of the search. Thus, those
	variations can be simply discarded, saving
	expensive static evaluation time.

	To have the program print out some search
	statistics for every move evaluation, type the
	command as

		A> stones -d

	To also see a move-by-move trace of each terminal
	evaluation, type

		A> stones -a

	THIS is the kind of program that lets C show its
	stuff; Powerful expression operators and recursion
	combine to let a powerful algorithm be implemented
	painlessly.

	And it's fun to play!


	Rules of the game:

	Each player has six pits in front of him and a
	"home" pit on one side (the computer's home pit
	is on the left; your home pit is on the right.)

	At the start of the game, all pits except the home
	pits are filled with n stones, where n can be anything
	from 1 to 6.

	To make a move, a player picks one of the six pits
	on his side of the board that has stones in it, and
	redistributes the stones one-by-one going counter-
	clockwise around the board, starting with the pit
	following the one picked. The opponent's HOME pit is
	never deposited into.

	If the LAST stone happens to fall in that player's
	home pit, he moves again.

	If the LAST stone falls into an empty pit on the
	moving player's side of  board, then any stones in the
	pit OPPOSITE to that go into the moving
	player's home pit.

	When either player clears the six pits on his
	side of the board, the game is over. The other player
	takes all stones in his six pits and places them in
	his home pit. Then, the player with the most stones
	in his home pit is the winner.

	The six pits on the human side are numbered one
	to six from left to right; the six pits on the	
	computer's side are numbered one to six right-to-
	left.

	The standard game seems to be with three stones;
	Less stones make it somewhat easier (for both you
	AND the computer), while more stones complicate
	the game. As far as difficulty goes, well...it
	USED to be on a scale of 1 to 50, but I couldn't
	win it at level 1. So I changed it to 1-300, and
	couldn't win at level 1. So I changed it to 1-1000,
	and if I STILL can't win it at level 1, I think
	I'm gonna commit suicide.

	Good Luck!!!
*/

int DEPTH, MAXDEPTH;
unsigned CALLS, TOTDEPTH, WIDTH,TERM;
unsigned total;
int ab, db;
char string[80];

unsigned COUNT;
int NUM;


main(argc,argv) int argc;
char **argv;
{
	int  hum,com,y,inp;
	char board[14];
	ab = 0;
	db = 0;
	if (argc > 1) { inp = 0;
loop:			switch(argv[1][inp++]) {
			case '\0': break;
			case 'D' : db++; goto loop;
			case 'A' : db++; ab++; goto loop;
			default:   goto loop;
			}
		}
new:	srand1("\nDifficulty (1-1000): ");
	inp = atoi(gets(string));
	if (inp<1 || inp>1000) goto new;
	printf("Number of stones (1-6): ");
	NUM = atoi(gets(string));
	COUNT = inp * 65;
	initb(board);
	printf("Do you want to go first (y or n)? ");
	inp = toupper(getchar());
	printf("\n\n");
	if (inp ==  'N') goto first;
	y = 0;
	while(notdone(board)) {
		printf("Move: ");
		for (;;) {
			inp = getchar() - '0';
			if (toupper(inp+'0')=='Q')goto new;
			if (inp < 1 || inp > 6 || !board[inp]) {
				printf("\tIllegal!!\n?");
				continue;
			 }
			y++;
			break;
		}
		if (!dmove(board,inp)) continue;
first:
		y = 0;
		while (notdone(board)) {
			inp = comp(board);
			printf("Computer moves: ");
			printf("%d\n",inp-7);
			y++;
			if (dmove(board,inp)) break;
		}
		y = 0;
	}
	com = board[0]; 
	hum = board[7];
	for (inp = 1; inp < 7; inp++) { 
		hum += board[inp];
		com += board[inp+7];
	}
	printf("Score:   me %d  you %d . . . ",com,hum);
	if (com>hum) switch (rand() % 4) {
		case 0: printf("Gotcha!!");
			break;
		case 1:	printf("Chalk one up for the good guys!");
			break;
		case 2: printf("Automation does it again!");
			break;
		case 3: printf("I LOVE to WIN!");
		}
	else if (hum==com) printf("How frustrating!!");
	else printf("Big Deal! Try a REAL difficulty!");
	putchar('\n');
	printf("New Game (y or n): ");
	if (toupper(getchar()) == 'Y') goto new;
	exit(0);
}

mmove(old,new,move) char *old;	char *new; int move;
{
	 int i; 
	int who;
	total++;

	for (i = 0; i < 14; ++i) new[i] = old[i];
	if ((move < 1) || (move > 13) || (move == 7) || !new[move])
		printf("Bad arg to mmove: %d",move);
	who = (move < 7 ? 1 : 0);
	i = old[move];
	new[move] = 0;
	while (i--) {
		move = mod(move,who);
		++new[move];
	}
	if (new[move] == 1 && who == (move < 7 ? 1 : 0) && move && move != 7)
	{
		new[who*7] += new[14-move];
		new[14-move] = 0;
	}
	if (move == 0 || move == 7) return(0);
	else return(1);
}

dmove(new,move)  char *new; int move;
{
	 int i;
	int j;
	int who;
	i = mmove(new,new,move);
	printb(new);
	return(i);
}

mod(i,j)  int i,j;
{
	++i;
	if (i == 7) return( j ? 7 : 8);
	if (i > 13) return ( j ? 1 : 0);
	return(i);
}

initb(board)  char *board;
{
	 int i,j;
	for (i= 0; i <14; ++i) board[i] = NUM;
	board[0] = board[7] = 0;
	printb(board);
	return;
}

printb(board)  char *board;
{
	 int i;
	printf("\n ");
	for (i = 13; i > 7; --i) printf("    %2d",board[i]);
	printf("\n%2d                                      %2d\n",board[0],board[7]);
	putchar(' ');
	for (i = 1; i < 7; ++i) printf("    %2d",board[i]);
	printf("\n\n");
}

comp(board)  char *board;
{
	 int score;
	int bestscore,best;
	char temp[14];
	 int i;
	unsigned nodes;
	DEPTH = MAXDEPTH = CALLS = TOTDEPTH = WIDTH = TERM = 0;
	total = 0;

	if ((i = countnodes(board,8)) == 1)
		for (best = 8; best < 14; ++best)
			if (board[best]) return(best);
	nodes = COUNT/i;
	bestscore = -10000;
	for (i = 13; i > 7; --i) if (board[i]) {
		score = mmove(board,temp,i);
		score = comp1( temp, score, nodes,
				db? -10000 : bestscore, 10000);
		if (db) {
			printf("MOVE: %2d	SCORE: %5d",
				i-7,
			 (score>=1000)?(score-1000):
			  ((score<= -1000)?(score+1000):score));
			if (score > 1000 || score < -1000) printf("  for SURE");
			printf("\n");
		}

		if (score > bestscore) {
			bestscore = score;
			best = i;
		}
	}
	if (bestscore > 1000)
		printf("I'VE GOT YOU!\n"); 
	if (bestscore < -1000)
		printf("YOU'VE GOT ME!\n");
	if (db) {
		printf("\nCount: %u\n",total);
		printf("Maximum depth: %d\nAverage depth: %u\n",
		MAXDEPTH,TOTDEPTH/CALLS);
		printf("Terminal Evaluations: %u\nPlayed out: %u\n",WIDTH,TERM);
	}

	return(best);
}

comp1(board,who,count,alpha,beta)
 char *board; int who; int alpha,beta;
unsigned count; 
{
	 int i;
	int turn,new;
	char temp[14];
	unsigned nodes;
	++DEPTH;
	MAXDEPTH = max(MAXDEPTH,DEPTH); 

	if (count < 1) {
		++CALLS;
		TOTDEPTH += DEPTH;
		++WIDTH;
		--DEPTH;

		new = board[0]-board[7];
		for (i = 1; i < 7; ++i) { turn = min(7-i,board[i]);
					  new -= 2*turn - board[i]; }
		for (i = 8; i < 14; ++i) { turn = min(14-i,board[i]);
					   new += 2*turn - board[i]; }
		if (board[0] > 6*NUM) new += 1000;
		if (board[7] > 6*NUM) new -= 1000;
		return(new);
	}
	if (!notdone(board)) {
		++CALLS;
		TOTDEPTH += DEPTH;
		++TERM;
		--DEPTH;

		new = board[0]+board[8]+board[9]+board[10]
		    +board[11]+board[12]+board[13]-board[1]-board[2]
		    -board[3]-board[4]-board[5]-board[6]-board[7];
		if ( new < 0) return (new - 1000);
		if ( new > 0) return (new + 1000);
		return(0);
	}
	nodes = count/countnodes(board,8-who*7);
	for (i = 7*(1-who)+6; i > 7*(1-who); --i)
		if (board[i]) {
			turn = mmove(board,temp,i);
			new = comp1(temp,(turn ? 1-who : who),nodes,alpha,beta);
			if (ab) printf("DEPTH: %2d  MOVE: %2d  NEW: %4d  ALPHA: %6d  BETA: %6d\n",DEPTH,i,new,alpha,beta);
			if (who) {
			   beta = min(new,beta);
			   if (beta <= alpha) { DEPTH--; return(beta); }}
			else {
			    alpha = max(new,alpha);
			    if (alpha >= beta) { DEPTH--; return(alpha); }}
		}
	--DEPTH;

	return(who ? beta : alpha);
}

min(i,j)  int i,j;
{
	return(i < j ? i : j);
}

max(i,j)  int i,j;
{
	return(i > j ? i : j);
}

notdone(board)	char *board;
{
	return (board[1] || board[2] || board[3] || board[4]
		|| board[5] || board[6]) &&
	       (board[8] || board[9] || board[10] || board[11]
		|| board[12] || board[13]);
}

countnodes(board,start) int start; char *board; 
{
	int i;
	int num;
	num = 0;
	for (i = start; i< start + 6; ++i)
		num += (board[i] ? 1 : 0);
	return(num);
}

rd; 
{
	int i;
	int num;
	num = 0;
	for (i = start; i< start + 6; ++i)
continue;
		oside |= 1;
		s -= dkl;
		if (c>=10) { s -= 4; oside |= 8; }
		}
	if (s< -oside) s= -oside;
	if (side>0) return s+side-7+10*ok;
	if (i==1 || i==6) {s--; side++;}
	if (j==1 || j==6) {s--; side++;}
	if (side>0) return s;
	if (i==2 || i=