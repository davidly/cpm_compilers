(***************************************************************************)
(*                                                                         *)
(*                       IMPLEMENTATION MODULE SeqIO			   *)
(*                                                                         *)
(*                                                                         *)
(*                    Modula-2 Standard Library Module			   *)
(*                                                                         *)
(*                                for the				   *)
(*                                                                         *)
(*                     Modula-2 System for Z80 / CP/M 			   *)
(*                                                                         *)
(*                                   by					   *)
(*                                                                         *)
(*                        Hochstrasser Computing AG			   *)
(*                           Leonhardshalde 21				   *)
(*                              8001 Zuerich				   *)
(*                              Switzerland				   *)
(*                                                                         *)
(*                                                                         *)
(* created     Aug - 25 - 1984 pwh                                         *)
(* updated     Oct - 13 - 1984 pwh                                         *)
(*             Mar - 23 - 1985 pwh                                         *)
(***************************************************************************)
IMPLEMENTATION MODULE SeqIO;

  FROM SYSTEM IMPORT 
	ADDRESS, 
	ADR, ALLOCATE, DEALLOCATE;

  FROM ASCII IMPORT
	nul, sub;

  FROM OpSys IMPORT
	Bdos, FCBFileName, FCB;

  FROM Moves IMPORT
        Fill, MoveLeft;

  FROM FileNames IMPORT
	NameState,
	StrToFCB;


  CONST
    conIn  = 1;          (* CON: input *)
    kbdIn  = 6;          (* KBD: input *)
    rdrIn  = 3;          (* RDR: input *)

    conOut = 2;          (* CON: output *)
    lstOut = 5;          (* LST: output *)
    punOut = 4;          (* PUN: output *)
    trmOut = 6;          (* TRM: output *)

    DefaultBufferSize = 8;	(* default: make 1k buffers *)
    SectorSize = 128;		(* CP/M sector size *)
    open     = 15;
    close    = 16;
    delete   = 19;
    readSeq  = 20;
    writeSeq = 21;
    create   = 22;
    rename   = 23;
    setDMA   = 26;

  TYPE 
    CharPtr = POINTER TO CHAR;

    FILE = POINTER TO File;
    File = RECORD
	     nextByte,
	     lastByte	: CharPtr;
	     status	: FileState;
	     fcb	: FCB;
	     usage	: FileUsage;
             handler    : FileHandler;
	     buffer	: ADDRESS; 
	     bufferSize : CARDINAL;
	   END;
  VAR
    i, j      : CARDINAL;
    tempState : FileState;
    ch        : CHAR;

MODULE BufferSizeHandler;

  IMPORT SectorSize;

  EXPORT SetBufferSize, BufferSize;

  VAR
    bufferSectors: CARDINAL;

  PROCEDURE SetBufferSize(sectors: CARDINAL);
  BEGIN
    IF (sectors # 0) & (sectors < 129) THEN
      bufferSectors := sectors;
    END;
  END SetBufferSize;

  PROCEDURE BufferSize(): CARDINAL;
  BEGIN
    RETURN SectorSize * bufferSectors;
  END BufferSize;

END BufferSizeHandler;

  PROCEDURE Assign(VAR f:File; name: ARRAY OF CHAR);
  VAR
    res: NameState;
  BEGIN
    Fill(ADR(f.fcb), 36, nul);   (* zero out FCB. *)
    f.fcb.name.text := '            ';
    f.fcb.name.disk := nul;
    res := StrToFCB(name, f.fcb.name);
    f.status := FileOK;
    f.handler := DummyHandler;
    CASE res OF
       NameOK  : f.usage  := ReadFile;	(* important is: File operation *)
    |  DeviceOK: CASE f.fcb.name.disk OF
                   'C' : f.usage := TextDev; (* CON: *)
	         | 'L','T','P': f.usage := WriteDev;(* LST:, TRM:, PUN: *)
	         | 'K','R'    : f.usage := ReadDev; (* KBD:, RDR: *)
	         END;
    | WildOK   : f.status := DirOpsOK;
    END;
  END Assign;

(*-------------------------------------------------------------------------*)

  PROCEDURE Open(VAR f:FILE; name: ARRAY OF CHAR): FileState;
  BEGIN
    NEW(f);
    Assign(f^,name);
    WITH f^ DO
      IF status = FileOK THEN
        IF usage = ReadFile THEN 	
          Bdos(open, ADR(fcb), i);
          IF i = 255 THEN 
            status := DeviceError;
          ELSE				               (* successfull open *)
	    i := BufferSize(); bufferSize := i;
            ALLOCATE(buffer, i);
            lastByte := CharPtr(0);
            nextByte := CharPtr(0);
            ReadBlock(f);               (* just to get EOF(f) TRUE before *)
          END;                       (* first invalid character gets read *)
        END;
      END;
      IF status # FileOK THEN
        tempState := status;
        DISPOSE(f); 
        RETURN tempState;
      END;
    END;
    RETURN FileOK;
  END Open;


(*--------------------------------------------------------------*)
(* PROCEDURE Create -- open 'f' for writing.                    *)
(*        errors: bad file name, create error.			*)
(*--------------------------------------------------------------*)
PROCEDURE Create(VAR f:FILE; name: ARRAY OF CHAR): FileState;
BEGIN
  NEW(f);
  Assign(f^,name);
  WITH f^ DO
    IF status = FileOK THEN
      IF usage = ReadFile THEN 	(* set this way by Assign; important: File *)
        Bdos(delete, ADR(fcb), i);
        Bdos(create, ADR(fcb), i);
        IF i = 255 THEN 
          status := DeviceError;
        ELSE				                (* successful open *)
	  i := BufferSize(); bufferSize := i;
          ALLOCATE(buffer, i);
          lastByte := CharPtr(i + buffer - 1);
          nextByte := CharPtr(buffer);
          usage := WriteFile;
        END;
      ELSIF usage = ReadDev THEN (* do not CREATE something you read from! *)
        status := UseError;
      END;
    END;
    IF status # FileOK THEN
      tempState := status;
      DISPOSE(f); 
      RETURN tempState;
    END;
  END;
  RETURN FileOK;
END Create;


PROCEDURE TestAccess(VAR f: File);
BEGIN
  IF f.status <= DirOpsOK THEN
    IF f.usage # ReadFile THEN
      f.status := NameError;	(* do not delete or rename devices... *)
    END;
  END;
END TestAccess;


(*--------------------------------------------------------------*)
(* PROCEDURE Delete -- delete file named 'name'.                *)
(*        errors: bad file name, file not found.                *)
(*--------------------------------------------------------------*)
PROCEDURE Delete(name: ARRAY OF CHAR): FileState;
VAR
  f: File;
BEGIN
  Assign(f,name);
  TestAccess(f);
  IF f.status <= DirOpsOK THEN
    Bdos(delete, ADR(f.fcb), i);
    IF i = 255 THEN RETURN DeviceError; END;
  END;
  RETURN f.status;
END Delete;


(*--------------------------------------------------------------*)
(* PROCEDURE Rename -- rename file 'old' to 'new'.		*)
(*        errors: bad file name, file not found.                *)
(*--------------------------------------------------------------*)
PROCEDURE Rename(old, new: ARRAY OF CHAR): FileState;
VAR
  f: File;
  newName: ARRAY [0..10] OF CHAR;
BEGIN
  Assign(f,new); 			      (* test if new name is valid *)
  TestAccess(f);
  IF f.status = FileOK THEN 
    MoveLeft(ADR(f.fcb.name.text[1]),ADR(newName), 11); (* save new name *)
    Assign(f,old);
    TestAccess(f);
    IF f.status = FileOK THEN
      f.fcb.rest := '';			(* clear out rest of FCB *)
      MoveLeft(ADR(newName), ADR(f.fcb.d[1]), 11);
      Bdos(rename, ADR(f.fcb), i);
      IF i = 255 THEN f.status := DeviceError; END;
    END;
  END;
  RETURN f.status;			(* FileOK, NameError, DeviceError *)
END Rename;


(*-------------------------------------------------------------------------*)

  PROCEDURE NewStatus(VAR f: FILE; newState: FileState);
  BEGIN
    f^.status := newState;
    f^.handler(f);            (* invoke handler to announce an error *)
  END NewStatus;

(*-------------------------------------------------------------------------*)

  PROCEDURE WriteBlock(VAR f: FILE);
  VAR
    s :CARDINAL;
  BEGIN
    WITH f^ DO
      j := (CARDINAL(nextByte) - buffer + SectorSize-1) DIV SectorSize; 
      s := 0;
      WHILE j # 0 DO
        Bdos(setDMA, s + buffer, i);
        Bdos(writeSeq, ADR(fcb), i);
        IF i > 0 THEN NewStatus(f, DeviceError); RETURN; END;
        s := s + SectorSize;
        j := j - 1;
      END;
      nextByte := CharPtr(buffer); 		      (* mark buffer empty *)
    END;
  END WriteBlock; 	

(*-------------------------------------------------------------------------*)

  PROCEDURE ReadBlock(f: FILE);
  BEGIN
    j := 0;
    WITH f^ DO
      LOOP
        Bdos(setDMA, j + buffer, i);
        Bdos(readSeq, ADR(fcb), i);
        IF i > 0 THEN
          IF j = 0 THEN status := EndError; END;      (* read past EOF *)
	  EXIT;
        END;
        j := j + SectorSize;			   (* next 128 byte sector *)
        IF j >= bufferSize THEN EXIT; END;
      END;
      lastByte := CharPtr(j + buffer - 1);
      nextByte := CharPtr(buffer);	       	       (* mark buffer full *)
    END; (* WITH *)
  END ReadBlock; 	

(*-------------------------------------------------------------------------*)

PROCEDURE Close(VAR f:FILE): FileState;
BEGIN
  WITH f^ DO
    status := FileOK;
    tempState := FileOK;
    IF usage = WriteFile THEN
      IF (CARDINAL(nextByte) <= CARDINAL(lastByte)) & 
         (CARDINAL(nextByte) # CARDINAL(buffer)) THEN
        Fill(ADR(nextByte^), 
	      CARDINAL(lastByte) - CARDINAL(nextByte) + 1 , sub);
      END;
      WriteBlock(f);
      Bdos(close, ADR(fcb), i);
      IF i = 255 THEN tempState := DeviceError END; 
    END;
    IF usage <= WriteFile THEN
      DEALLOCATE(buffer, bufferSize);
    END;
  END;
  DISPOSE(f);
  RETURN tempState;
END Close;

(*-------------------------------------------------------------------------*)

PROCEDURE Write(VAR f: FILE; info: CHAR);
BEGIN
  WITH f^ DO
    IF usage >= TextDev THEN
      CASE fcb.name.text[0] OF
        'C': Bdos(conOut, ORD(info), i);
      | 'L': Bdos(lstOut, ORD(info), i);
      | 'P': Bdos(punOut, ORD(info), i);
      | 'T': Bdos(trmOut, ORD(info), i);
      END;     
    ELSIF usage = WriteFile THEN
      nextByte^ := info;		(* put char in buffer *)
      INC(nextByte);
      (* if buffer full write it to disk	*)
      IF CARDINAL(nextByte) > CARDINAL(lastByte) THEN WriteBlock(f) END;
    ELSE
      NewStatus(f, UseError);
    END;
  END;
END Write;

(*-------------------------------------------------------------------------*)

PROCEDURE Read(VAR f: FILE; VAR info: CHAR);
BEGIN
  WITH f^ DO
    IF (usage = TextDev) OR (usage = ReadDev) THEN
      CASE fcb.name.text[0] OF
        'C': Bdos(conIn, 0, i);
      | 'K': REPEAT Bdos(kbdIn, 0FFH, i); UNTIL i # 0; (* poll *)
      | 'R': Bdos(rdrIn, 0, i);
      END;     
      info := CHR(i);
    ELSIF usage = ReadFile THEN
      IF status # FileOK THEN 
        handler(f); (* trap EOF *) 
      ELSE
        info := nextByte^;
        IF CARDINAL(nextByte) >= CARDINAL(lastByte) THEN
          ReadBlock(f);			(* fill buffer if empty	*)
        ELSE
  	  INC(nextByte);
        END;
      END;
    ELSE
      NewStatus(f, UseError);
    END;
  END;
END Read;

(*-------------------------------------------------------------------------*)

  PROCEDURE EOF(f: FILE): BOOLEAN;
  BEGIN
    RETURN (f^.usage = ReadFile) & (f^.status = EndError);
  END EOF;

(*-------------------------------------------------------------------------*)

  PROCEDURE DummyHandler(VAR f: FILE);
  BEGIN
    (* doesn't do too much.. *)
  END DummyHandler;

(*-------------------------------------------------------------------------*)

  PROCEDURE FileStatus(f: FILE): FileState;
  BEGIN
    RETURN f^.status;
  END FileStatus;

(*-------------------------------------------------------------------------*)

  PROCEDURE SetFileHandler(f: FILE; handler: FileHandler);
  BEGIN
    f^.handler := handler;
  END SetFileHandler;

(*-------------------------------------------------------------------------*)

  PROCEDURE GetFileName(f: FILE; VAR name: ARRAY OF CHAR);

    PROCEDURE PutCh(ch: CHAR);
    BEGIN
      IF i <= HIGH(name) THEN
        name[i] := ch;
        i := i + 1;
      END;
    END PutCh;

    PROCEDURE GetPutCh(VAR n: FCBFileName);
    BEGIN
      IF n.text[j] # ' ' THEN
        PutCh(n.text[j]);
      END;
    END GetPutCh;

  BEGIN
    i := 0;
    WITH f^.fcb DO
      IF f^.usage <= WriteFile THEN                 (* File, get file name *)
        IF name.text[0] # nul THEN                  (* not on default drive *)
          PutCh(CHR(ORD(name.text[0]) + 40H));
          PutCh(':');
        END;
        FOR j := 1 TO 8 DO GetPutCh(name); END;
        PutCh('.');    
        FOR j := 9 TO 11 DO GetPutCh(name); END;
      ELSE                                      (* Device, get device name *)
        FOR j := 0 TO 2 DO GetPutCh(name); END;
        PutCh(':');
      END;
    END;
    PutCh(nul);
  END GetFileName;

  PROCEDURE FileUse(f: FILE): FileUsage;
  BEGIN
    RETURN f^.usage;
  END FileUse;

BEGIN
  SetBufferSize(DefaultBufferSize);
END SeqIO.
