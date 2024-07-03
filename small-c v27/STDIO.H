/*
** STDIO.H -- Standard Small-C Defs
**
** 3/24/86 -- F. A. Scacchitti
*/

/*
** I/O paths
*/
#define stdin    0
#define stdout   1
#define stderr   2

/*
** special codes
*/
#define ERR   (-2)
#define EOF   (-1)

/*
** logical states
*/
#define YES      1
#define NO       0
#define TRUE     1
#define FALSE    0

/*
** ascii characters
*/
#define NULL     0
#define CR      13
#define LF      10
#define BELL     7
#define SPACE  ' '
#define NEWLINE CR

/*
** special types
*/
#define FILE int

