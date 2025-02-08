/*
 * Q.G - include file for Quest globals.
 */

/*
 * screen routines.
 */

type

    /* type for two-character map area displays: */

    C2 = [2]char;

extern
    scInit()void,
    scPut(char ch)void,
    scPrompt(*char prompt)void,
    scRead(*char buffer)void,
    scNewMap(proc(int l, c)C2 scenery; word oldObj)word,
    scWindow(int line, column)void,
    scNew(int id, line, column; C2 chars)void,
    scAt(int line, column)C2,
    scMove(int id, line, column)void,
    scDelete(int id)void,
    scNumber(int id; *char name; ushort line, column, len; *int ptr)void,
    scString(int id; *char name; ushort line, column, len; **char ptr)void,
    scMult(int id; *char name; ushort line, column, lines;
	   proc(bool first)*char gen)void,
    scUpdate(int id)void,
    scRemove(int id)void;

/*
 * parser routines.
 */

type
    FORMTYPE = enum {REQID, REQTYPE, OPTID, OPTTYPE, MULTIPLE};

extern
    psInit(bool prefixEnabled)void,
    psWord(int id; *char txt; int typ)void,
    psDel(int id)void,
    psgBegin(int id)void,
    psgWord(FORMTYPE form; int data)void,
    psgEnd()void,
    psgDel(int id)void,
    psFind(*char txt)int,
    psGet(int id)*char,
    psType(int id)int,
    psParse(*char sentence)int,
    pspBad()*char,
    pspWord(int pos)int,
    pspPref()int;

/*
 * list handling routines.
 */

type
    INTLIST = struct {
	*INTLIST il_next;
	int il_this;
    };

extern
    lInit()void,
    getId()int,
    lAdd(**INTLIST pil; int n)void,
    lAppend(**INTLIST pil; int n)void,
    lDelete(**INTLIST pil; int n)void,
    lGet(*INTLIST il; int n)int,
    lIn(*INTLIST il; int n)bool,
    putProp(int id, prop)void,
    getProp(int id, prop)bool,
    delProp(int id, prop)void,
    putAttr(int id, attr, val)void,
    getAttr(int id, attr)int,
    delAttr(int id, attr)void;
