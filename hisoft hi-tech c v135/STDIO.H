/*****************************/
/*         Hisoft C          */
/* Standard Function Library */
/*          HEADER           */
/*                           */
/* Copyright (C) 1984 Hisoft */
/* Last changed  15 Aug 1985 */
/*****************************/

#list-
#define  MAXARGS 10 /* max number of command line args - change as needed */

#define  NULL    0 /* for use with pointers  */
#define  FALSE   0 /* for Boolean operations */
#define  TRUE    1
#define  EOF    -1 /* end of file value      */
#define  ERROR  -1
#define  FAST	static
#define  _SAFETY 50 /* for sbrk() */
#define  void  int /* for functions which return no value */
#define  stdin   1
#define  stdout  2
#define  stderr  3

#define LD_A_from  0x3A
#define LD_A_into  0x32
#define LD_A_with  0x3E
#define LD_HL_from 0x2A
#define LD_HL_into 0x22
#define LD_HL_with 0x21
#define LD_DE_from 0x5BED
#define LD_DE_into 0x53ED
#define LD_DE_with 0x11
#define LD_BC_from 0x4BED
#define LD_BC_into 0x43ED
#define LD_IX_from 0x2ADD
#define RLA        0x17
#define LD_L_A     0x6F
#define LD_H_with  0x26
#define RL_L       0x15CB
#define LD_B_with  0x06
#define JR_Z       0x28
#define JR_NC      0x30
#define JP_HL      0xE9
#define INC_B      0x04
#define PUSH_HL    0xE5
#define PUSH_IX    0xE5DD
#define POP_IX     0xE1DD
#define PUSH_IY    0xE5FD
#define POP_IY     0xE1FD
#define CALL       0xCD
#define DI         0xF3
#define EI         0xFB
#define ADD_HL_DE  0x19

#define PC_TO_HL   0x135  /* call this address to load hl with pc */

/*  File system Structure */

typedef int  FILE;



/*  Storage Allocation Structure and Variables */

struct  _header
{
  struct _header * _ptr;
  unsigned  _size;
};

typedef struct _header  HEADER, * HEADER_PTR;

HEADER  _base, *_allocp;



/*  Z80 register cache for inline code  */

unsigned  reg_hl, reg_de, reg_bc;
char      reg_a;


/*  Forward declarations for non-int library functions  */

extern char *strcat(), *strncat(), *strcpy(), *strncpy(), *strchr(), *strrchr(),
            *strpbrk(), *calloc(), *malloc(), *sbrk(),    *fgets(),  *gets();
extern unsigned strlen();


/*  Two variadic arithmetic functions (see manual for details)  */

int max(param_byte_count)  auto
{
  static int argc, *argv, max;

  argc = param_byte_count/2 - 1;
  argv = &param_byte_count  + argc;
  max  = -32767;

  while (argc--)
    {
      if (*argv > max) max = *argv;
      --argv;
    }

  return max;
}


int min(param_byte_count)  auto
{
  static int argc, *argv, min;

  argc = param_byte_count/2 - 1;
  argv = &param_byte_count  + argc;
  min  = 32767;

  while (argc--)
    {
      if (*argv < min) min = *argv;
      --argv;
    }

  return min;
}

#list+

/*****************************/
/*         Hisoft C          */
/* Standard Function Library */
/*        End Header         */
/*****************************/
      Hisoft C          */
/* Standard Function Library */
/*        End Header         */
/******