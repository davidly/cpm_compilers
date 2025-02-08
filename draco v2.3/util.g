type

    /* structure of a file name in a CP/M file control block: */

    FILENAME = struct {
	unsigned 16 fn_drive;
	[8] char fn_name;
	[3] char fn_type;
    },

    /* result from the string comparison routine: */

    COMPARISON = enum {
	EQUAL,
	LESS,
	GREATER
    };

    /* error codes returned by 'IOerror': */

    ushort
	CH_OK = 0,		/* no error */

	CH_EOF = 1,		/* read past end-of-file indicator */
	CH_CLOSED = 2,		/* use after close */

	CH_NONEXIS = 3,		/* file doesn't exist */
	CH_DISKFULL = 4,	/* disk is full; write failed */
	CH_BADSEEK = 5,		/* bad seek call */

	CH_MISSING = 6,		/* no data on line */
	CH_BADCHAR = 7,		/* bad character for input conversion */
	CH_OVERFLOW = 8;	/* overflow on numeric conversion */

extern

    CharsLen(*char charsPtr)word,
    CharsEqual(*char charsPtr1, charsPtr2)bool,
    CharsCopy(*char dest, source)void,
    CharsCmp(*char charsPtr1, charsPtr2)COMPARISON,
    CharsConcat(*char dest, source)void,
    CharsCopyN(*char dest, source; word n)void,
    CharsIndex(*char subject, object)int,

    exit(int status)void,

    GetPar()*char,
    RescanPars()void,

    RawRead(channel input binary chan; *byte buffer; word count)word,
    RawWrite(channel output binary chan; *byte buffer; word count)word,
    RandomOut(channel output binary chan)void,
    ReOpen(channel input binary ch1; channel output binary ch2)void,
    SeekIn(channel input binary chan; ushort posnHigh; word posnLow)bool,
    SeekOut(channel output binary chan; ushort posnHigh; word posnLow)bool,
    GetIn(channel input binary chan; *ushort pposnHigh)word,
    GetOut(channel output binary chan; *ushort pposnHigh)word,
    GetInMax(channel input binary chan; *ushort pposnHigh)word,
    GetOutMax(channel output binary chan; *ushort pposnHigh)word,
    FlushOut(channel output binary chan)void,

    SetFileName(FILENAME fn; *char name)void,
    GetFileName(FILENAME fn; *char name)void,
    FileCreate(FILENAME fn)bool,
    FileDestroy(FILENAME fn)bool,
    FileRename(FILENAME oldName, newName)bool,

    Malloc(word length)*byte,
    Mfree(*byte region; word length)void,
    Mlist()void,
    Mcheck(proc(*byte region; word length)void handle)void,
    MerrorSet(bool newFlag)void,
    MerrorGet()bool,

    BlockMove(*byte dest, source; word count)void,
    BlockFill(*byte dest; word count; byte valu)void,
    BlockMoveB(*byte dest, source; word count)void;
