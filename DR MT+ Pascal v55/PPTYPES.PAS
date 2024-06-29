
CONST
  CR = $0D;
  MAXSYMSIZE = 200;     (* MAX SIZE OF A SYMBOL *)
  MAXSTKSIZE = 100;     (* MAX # OF SYMBOLS CAUSING INDENTATION *)
  MAXKEYLEN  = 10;      (* MAX LENGTH OF A RESERVED WORD *)
  MAXLINSIZE = 72;      (* MAX SIZE OF AN OUTPUT LINE *)
  SLFAIL1  = 48;      (* USE TWO BLANKS AS TAB BEFORE THIS COL *)
  SLFAIL2  = 60;      (* USE ONE BLANK  AS TAB BETWEEN SF1 AND HERE *)
  INDENT1    = 2;
  INDENT2    = 1;
  SPACE = ' ';
  
TYPE
  KEYSYMBOL = (PROGSY,
	       EXTSY,
               FUNCSY,
               PROCSY,
               LABELSY,
               CONSTSY,
               TYPESY,
               VARSY,
               BEGINSY,
               REPEATSY,
               RECORDSY,
               CASESY,
               CASEVARSY,
               OFSY,
               FORSY,
               WHILESY,
               WITHSY,
               DOSY,
               IFSY,
               THENSY,
               ELSESY,
               ENDSY,
               UNTILSY,
               BECOMES,
               OPENCOMMENT,
               CLOSECOMMENT,
               SEMICOLON,
               COLON,
               EQUALS,
               OPENPAREN,
               CLOSEPAREN,
               PERIOD,
               END_OF_FILE,
               ANOTHERSY,
               OTHERSY);
               
  OPTION = (CRSUPPRESS,
            CRBEFORE,
            BLANKLINEBEFORE,
            DINDENTONKEYS,
            DINDENT,
            SPACEBEFORE,
            SPACEAFTER,
            GOBBLESYMBOLS,
            INDENTBYTAB,
            INDENTTOCLP,
            CRAFTER);
            
  OPTIONSET = SET OF OPTION;
  KEYSYMSET = SET OF KEYSYMBOL;

  TABLEENTRY = RECORD
                 OPT              : OPTIONSET;
                 DINDENTSYMBOLS   : KEYSYMSET;
                 GOBBLETERMINATORS: KEYSYMSET
               END;

  OPTIONTABLE = ARRAY [KEYSYMBOL] OF TABLEENTRY;
  
               
  KEY = PACKED ARRAY [1..MAXKEYLEN] OF CHAR;
  
  KEYWORDTABLE = ARRAY [PROGSY..UNTILSY] OF KEY;
  
  SPECIALCHAR = PACKED ARRAY [1..2] OF CHAR;
  
  DBLCHRSET = SET OF BECOMES..OPENCOMMENT;
  
  DBLCTABLE = ARRAY [BECOMES..OPENCOMMENT] OF SPECIALCHAR;
  
  SGLCHARTABLE = ARRAY [OPENCOMMENT..PERIOD] OF CHAR;
  
  STRING = ARRAY [1..MAXSYMSIZE] OF CHAR;
  
  SYMBOL = RECORD
             NAME       :       KEYSYMBOL;
             VALUE      :       STRING;
             LENGTH     :       INTEGER;
             SPACESBEFORE:      INTEGER;
             CRSBEFORE  :       INTEGER
           END;
           
  SYMBOLINFO = {^}SYMBOL;
  
  CHARNAME = (LETTER, DIGIT, BLANK, QUOTE,
             END_OF_LINE, FILEMARK, OTHERCHAR);
             
  CHARINFO = RECORD
               NAME     :       CHARNAME;
               VALUE    :       CHAR
             END;
             
  STACKENTRY = RECORD
                 INDENTSYMBOL : KEYSYMBOL;
                 PREVMARGIN   : INTEGER
               END;
               
  SYMBOLSTACK = ARRAY [1..MAXSTKSIZE] OF STACKENTRY;


