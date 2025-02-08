/* Use of form routines:

    Call CRT_FormStart to clear out any existing form and initialize.

    Add fields to the form with CRT_FormInt and CRT_FormChars:
	line - screen line for start of prompt
	col - screen column for start of prompt
	len - screen length for chars or int value (max 6 for int)
	header - header to left of input area
	pChanged - pointer to variable, which after CRT_FormRead, will
	    contain 'true' if that field was changed
	ptr - pointer to buffer holding value
	check - routine to call to check new values

    Call CRT_FormRead:
	header - multiline header to center at top of screen
	flags - byte of flags:
	    FORMHEADERS - display headers on this call
	    FORMSKIP - use autoskip on input fields
	    FORMINPUT - allow input (otherwise just display)
	    FORMOUTPUT - display values (otherwise assume they are there)
	terminators - string of characters allowed to terminate input of
	    a field. The following should be present to enable their
	    functions, but will never be returned:
		CONTROL-R - used to force reset of a field
		CONTROL-Z - used to force reset of all fields
	    The following are normally present to enable their functions:
		CONTROL-Q - used to do a quick exit
		ESCAPE - used to reset all fields and exit
	The character returned is the character from 'terminators' that the
	use typed which caused an exit. Carriage return (CONTROL-M) is the
	most likely, i.e. the user filled in all fields and fell off the end.
*/

char
    CONTROL_Q = '\(0x11)',
    CONTROL_R = '\(0x12)',
    CONTROL_Z = '\(0x1a)',
    ESCAPE    = '\(0x1b)';

*char TERMINATORS = "\(CONTROL_Q)\(CONTROL_R)\(CONTROL_Z)\(ESCAPE)";

extern
    CRT_FormIntOK(int n)bool,
    CRT_FormCharsOK(*char p)bool,
    CRT_FormStart()void,
    CRT_FormInt(ushort line, col, len; *char header;
		*bool pChanged; *int ptr;
		proc(int n)bool check)void,
    CRT_FormChars(ushort line, col, len; *char header;
		  *bool pChanged; *char ptr;
		   proc(*char p)bool check)void,
    CRT_FormRead(*char header; byte flags; *char terminators)char;

byte
    FORMHEADERS = 0x01,
    FORMSKIP = 0x02,
    FORMINPUT = 0x04,
    FORMOUTPUT = 0x08;
