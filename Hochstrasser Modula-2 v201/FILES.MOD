(***************************************************************************)
(*                                                                         *)
(*                       IMPLEMENTATION MODULE Files			   *)
(*                                                                         *)
(*                                                 		           *)
(*                     Modula-2 Utility Library Module			   *)
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
(* created	Nov -  1 - 1984 pwh                                        *)
(* updated	Nov - 22 - 1984 pwh                                        *)
(*		Apr -  4 - 1985 pwh					   *)
(***************************************************************************)
IMPLEMENTATION MODULE Files;
 

  FROM ASCII     IMPORT nul;
  FROM FileNames IMPORT NameState, StrToFCB;
  FROM Moves     IMPORT Fill, MoveLeft, MoveRight;
  FROM OpSys     IMPORT FCB, FCBFileName, BdosFunctions, Bdos;
  FROM MODLIB    IMPORT CALCR;
  FROM SYSTEM    IMPORT ADDRESS, WORD, ADR, SIZE;



  CONST 
    SectorSize = 128;
    Sectors = 8;
    FileBufferSize = Sectors * SectorSize;

    
  TYPE
    Position = RECORD
	         rec: CARDINAL;
	         r2: CHAR;
	       END;

    FilePos = POINTER TO NewPosition;
    NewPosition = RECORD
		    pos: Position;
		    bufPos: CARDINAL;
	          END;
 
    Buffer = RECORD
	       cur, last: CARDINAL;
	       mustWrite: BOOLEAN;
	       pos: Position;
	       data: ARRAY [0 .. FileBufferSize - 1] OF CHAR;
	     END;

    FILE = POINTER TO File;
    File = RECORD
	     fcb: FCB;
	     curPos: Position;
	     state: FileState;
	     handler: FileHandler;
	     notPos: BOOLEAN;
	     newPos: NewPosition;
	     buf: Buffer;
	   END;


  VAR
    result: INTEGER;		(* GP BDOS result *)
    fcb: FCB;
    state: FileState;


  PROCEDURE EOF(f: FILE): BOOLEAN;
  BEGIN
    RETURN (f^.state = EndError);
  END EOF;


  PROCEDURE FileStatus(f: FILE): FileState;
  BEGIN
    RETURN f^.state;
  END FileStatus;


  PROCEDURE DummyHandler(VAR f: FILE);
  BEGIN
    (* do it straightforward... *)
  END DummyHandler;


  PROCEDURE SetFileHandler(f: FILE; h: FileHandler);
  BEGIN
    f^.handler := h;
  END SetFileHandler;


  PROCEDURE NewStatus(VAR f: FILE; state: FileState);
  BEGIN
    f^.state := state;
    f^.handler(f);
  END NewStatus;


  PROCEDURE PrepareFCB;
  BEGIN
    fcb.name.text := '';
    fcb.rest := '';
  END PrepareFCB;


  PROCEDURE CheckName(name: ARRAY OF CHAR); 
  BEGIN
    PrepareFCB;
    IF StrToFCB(name, fcb.name) = NameOK THEN
      state := FileOK;
    ELSE
      state := NameError;
    END;
  END CheckName;


  PROCEDURE PrepareFile(VAR f: FILE);
  BEGIN
    NEW(f);
    MoveLeft(ADR(fcb), ADR(f^.fcb), SIZE(fcb));
    Fill(ADR(f^.curPos), SIZE(f^)-SIZE(f^.fcb), 0C);
    f^.handler := DummyHandler;
  END PrepareFile;


  PROCEDURE BdosError(func, parm: WORD): BOOLEAN;
  BEGIN
    Bdos(func, parm, result);
    RETURN result = 255;
  END BdosError;


  PROCEDURE Open(VAR f: FILE; name: ARRAY OF CHAR): FileState;
  BEGIN
    CheckName(name);
    IF state = FileOK THEN
      IF BdosError(ORD(openF), ADR(fcb)) THEN
	state := StatusError;
	f := NIL;		(* just security *)
      ELSE			(* ok, create file desc now. *)
	PrepareFile(f);
      END;
    END;
    RETURN state;
  END Open;

      
  PROCEDURE Create(VAR f: FILE; name: ARRAY OF CHAR): FileState;
  BEGIN
    CheckName(name);
    f := NIL;
    IF state = FileOK THEN
      IF NOT BdosError(ORD(openF), ADR(fcb)) THEN (* delete old version *)
	IF BdosError(ORD(deleteF), ADR(fcb)) THEN (* may be R/O *)
	  RETURN StatusError;
	END;
      END;
      IF BdosError(ORD(makeF), ADR(fcb)) THEN
	state := StatusError;
      ELSE				(* ok, create file desc now. *)
	PrepareFile(f);
      END;
    END;
    RETURN state;
  END Create;


(*--------------------------------------------------------------*)
(* PROCEDURE Close -- Close a file. This procedure MAY close    *)
(* a file, if the last operation on the file has been a 'write'.*)
(* If it was a 'read', the only thing to do is to dispose the   *)
(* file descriptor.						*)
(*--------------------------------------------------------------*)
  PROCEDURE Close(VAR f: FILE): FileState;
  VAR
    ch: CHAR;
  BEGIN
    state := f^.state;
    IF (state = FileOK) OR (state = EndError) THEN
      IF f^.buf.mustWrite THEN
        DiskIO(f, FALSE);			(* go flush buffer *)
      END;
      state := f^.state;
      IF (state = FileOK) OR (state = EndError) THEN
	IF BdosError(ORD(closeF), ADR(f^.fcb)) THEN
	  state := StatusError;
	ELSE
	  DISPOSE(f);
	  state := FileOK;
	END;
      END;
    END;
    RETURN state;
  END Close;


  PROCEDURE Release(VAR f: FILE): FileState;
  BEGIN
    Fill(ADR(f^.fcb.rest), SIZE(f^.fcb.rest), 0C);
    IF BdosError(ORD(deleteF), ADR(f^.fcb)) THEN
      RETURN StatusError;
    END;
    RETURN FileOK;
  END Release;


(*--------------------------------------------------------------*)
(* PROCEDURE Delete -- NOTE -- File Names may be ambigous.      *)
(*--------------------------------------------------------------*)
  PROCEDURE Delete(name: ARRAY OF CHAR): FileState;
  BEGIN
    PrepareFCB;
    IF StrToFCB(name, fcb.name) > WildOK THEN 
      RETURN NameError; (* cannot delete Devices or erroneous names *)
    ELSE
      IF BdosError(ORD(deleteF), ADR(fcb)) THEN
	RETURN StatusError;
      ELSE
        RETURN FileOK;
      END;
    END;
  END Delete;


  PROCEDURE Rename(currentName, newName: ARRAY OF CHAR): FileState;
  BEGIN
    PrepareFCB;
    IF StrToFCB(newName, fcb.name) # NameOK THEN
      RETURN NameError;
    ELSE
      MoveLeft(ADR(fcb.name.name), ADR(fcb.d[1]), 
                SIZE(fcb.name.name) + SIZE(fcb.name.type));
      fcb.name.text := '';
      IF StrToFCB(currentName, fcb.name) # NameOK THEN
        RETURN NameError;
      ELSE
        IF BdosError(ORD(renameF), ADR(fcb)) THEN
          RETURN StatusError;
        ELSE
          RETURN FileOK;
        END;
      END;
    END;
  END Rename;


  PROCEDURE InitPos(VAR pos: FilePos);
  BEGIN
    NEW(pos);
    Fill(ADR(pos^), SIZE(pos^), 0C);
  END InitPos;


  PROCEDURE FiniPos(VAR pos: FilePos);
  BEGIN
    DISPOSE(pos);
  END FiniPos;


  PROCEDURE GetPos(f: FILE; VAR pos: FilePos);
  BEGIN
    IF f^.notPos THEN
      pos^ := f^.newPos;
    ELSE
      WITH pos^ DO
        pos := f^.buf.pos;
        bufPos := f^.buf.cur;
      END;
    END;
  END GetPos;


  PROCEDURE GetEOF(f: FILE; VAR pos: FilePos);
  VAR
    momPos: NewPosition;
    index: CARDINAL;
  BEGIN
    momPos.pos := f^.curPos; 
    momPos.bufPos := f^.buf.cur;
    Bdos(ORD(compFSize), ADR(f^.fcb), result);
    WITH pos^ DO
      pos := f^.curPos;  
      bufPos := 0;
    END;
    IF NOT f^.notPos THEN
      SetPos(f,ADR(momPos));	(* reposition *)
    END;
  END GetEOF;


  PROCEDURE SetPos(f: FILE; pos: FilePos);
  BEGIN					(* normalize position *)
    INC(pos^.pos.rec, pos^.bufPos DIV 128);
    pos^.bufPos := pos^.bufPos MOD 128;
    f^.notPos := TRUE;
    f^.newPos := pos^;
  END SetPos;


  PROCEDURE CalcPos(recNum, recSize: CARDINAL; VAR pos: FilePos);
  VAR
    x : CARDINAL;
  BEGIN
    WITH pos^ DO
      bufPos := recNum * recSize MOD SectorSize; (* overflow doesn't care *)
      CALCR(x, pos.rec, recNum, recSize);
      pos.r2 := CHR(x);
    END; (* WITH *)
  END CalcPos;


  PROCEDURE AddPos(position, offset: FilePos; VAR result: FilePos);
  BEGIN
    WITH result^ DO
      WITH pos DO
        r2 := CHR(ORD(position^.pos.rec > MAX(CARDINAL) - offset^.pos.rec) +
	      ORD(position^.pos.r2) + ORD(offset^.pos.r2));
        rec := position^.pos.rec + offset^.pos.rec; (* overflow doesn't care *)
      END;
      bufPos := position^.bufPos + offset^.bufPos;
    END;
  END AddPos;


  VAR 
    dma: ADDRESS;
    pfcb: POINTER TO FCB;
    last: CARDINAL;
    records: CARDINAL;
    pos: Position;
    op1, op2: CARDINAL;
    transRecs: CARDINAL;


(*--------------------------------------------------------------*)
(* PROCEDURE DiskIO -- buffer read/write operations.    	*)
(* Essentially initializes all necessary variables and 		*)
(* positions the file if ncessary to do so.			*)
(*--------------------------------------------------------------*)
  PROCEDURE DiskIO(VAR f: FILE; readBuf: BOOLEAN);
  BEGIN
    dma := ADR(f^.buf.data); 
    pfcb := ADR(f^.fcb);
    result := 0;			(* all ok, right now.		*)
    last := 0;			(* last transferred byte 	*)
        				(* position if necessary 	*)
    IF readBuf THEN
      records := Sectors;		(* try to read full buffer	*)
      pos := f^.newPos.pos;		(* here we get it from		*)
      f^.buf.pos := pos;		(* save it for rewrite it.	*)
      op1 := ORD(readRan);		(* CP/M position file		*)
      op2 := ORD(readSeq);		(* CP/M normal read		*)
      f^.buf.cur := f^.newPos.bufPos; (* here we start the read	*)
      f^.notPos := FALSE;		(* just did position it		*)
    ELSE                    		(* put back home		*)
      records := (f^.buf.cur + SectorSize-1) DIV 128;
      pos := f^.buf.pos;		(* here is "home"		*)
      op1 := ORD(writeRanZF);		(* fill uninit stuff by 0C.	*)
      op2 := ORD(writeSeq);		(* normal write operation	*)
      f^.buf.mustWrite := FALSE;	(* will do it now 		*)
    END;
    transRecs := records;
    IF (f^.curPos.rec # pos.rec) OR (f^.curPos.r2 # pos.r2) THEN
      f^.curPos := pos;
      Bdos(ORD(setDMA), dma, result);	(* position it by random ops	*)
      Bdos(op1, pfcb, result);	(* redone by sequential ops if	*)
      CASE result OF			(* no error.			*)
        0  : NewStatus(f, FileOK);
      | 1,4: f^.state := EndError; (* read past EOF; do not call handler *)
      ELSE
        NewStatus(f, DeviceError);	(* read past end of disk etc.   *)
      END;
    END;
        				(* read or write whole buffer   *)
        				(* sequentially.		*)
    WHILE (result = 0) & (records # 0) DO	(* switch to sequential *)
      Bdos(ORD(setDMA), dma, result);	(* which reads faster   *)
      Bdos(op2, pfcb, result);		(* and more convenient  *)
      IF result = 0 THEN			(* (extent handling).   *)
        last := last + SectorSize;	(* update only if all's ok.	*)
        dma := dma + SectorSize;
        records := records - 1;
      END;
    END; (* WHILE *)				
    INC(pos.rec, transRecs - records);
    f^.curPos := pos;
    IF readBuf THEN
      f^.buf.last := last;		(* set max. read position	*)
      IF f^.buf.cur >= last THEN
        f^.state := EndError;	        (* end of file reached		*)
      END;
    END;			
  END DiskIO;


  PROCEDURE UpdateBuffer(VAR f: FILE);
  CONST
    READ = TRUE;
    WRITE = FALSE;
  BEGIN
    IF f^.buf.mustWrite THEN	(* go write it *)
      DiskIO(f,WRITE);
    END;
    DiskIO(f,READ);
  END UpdateBuffer;


  PROCEDURE ReadAccess(VAR f: FILE): BOOLEAN;
  BEGIN
    IF (NOT f^.notPos) & (f^.buf.last <= f^.buf.cur) THEN 
      (* buffer is empty. Go fetch next one sequentially *)
      f^.notPos := TRUE;
      f^.newPos.pos := f^.curPos;
      f^.newPos.bufPos := 0;
    END;
    IF f^.notPos THEN
      UpdateBuffer(f);
    END;
    RETURN f^.state = FileOK;
  END ReadAccess;


  PROCEDURE Read(VAR f: FILE; VAR ch: CHAR);
  BEGIN
    IF ReadAccess(f) THEN
      ch := f^.buf.data[f^.buf.cur]; 
      INC(f^.buf.cur);
    ELSE
      ch := nul;
    END;
  END Read;


  PROCEDURE ReadBytes(VAR f: FILE; buf: ADDRESS; nBytes: CARDINAL): CARDINAL;
  VAR
    bufBytes: CARDINAL;

    PROCEDURE MoveBuffer(len: CARDINAL);
    BEGIN
      MoveLeft(ADR(f^.buf.data[f^.buf.cur]), buf, len);
      INC(f^.buf.cur, len);
    END MoveBuffer;

  BEGIN
    IF nBytes # 0 THEN
      IF ReadAccess(f) THEN
        bufBytes := f^.buf.last - f^.buf.cur;
        IF nBytes > bufBytes THEN
          MoveBuffer(bufBytes);
          RETURN ReadBytes(f, buf + bufBytes, nBytes - bufBytes) + bufBytes;
        ELSE	(* all in current buffer *)
          MoveBuffer(nBytes);
        END;
      ELSE
        Fill(buf, nBytes, 0C);
        RETURN 0;
      END;
    END;
    RETURN nBytes;
  END ReadBytes;


  PROCEDURE ReadRec(VAR f: FILE; VAR rec: ARRAY OF WORD);
  VAR
    i: CARDINAL;
  BEGIN
    i := ReadBytes(f, ADR(rec), SIZE(rec));
  END ReadRec;


  PROCEDURE WriteAccess(VAR f: FILE): BOOLEAN;
  BEGIN
    IF (f^.buf.cur = HIGH(f^.buf.data) + 1) & (NOT f^.notPos) THEN
      f^.notPos := TRUE;		(* buffer full; write it	*)
      f^.newPos.pos := f^.buf.pos;	(* last file position		*)
      f^.newPos.bufPos := 0;		(* buffer index will be reset	*)
      INC(f^.newPos.pos.rec, Sectors);(* done fully anyway		*)
    END;
    IF f^.notPos THEN UpdateBuffer(f); END;
    RETURN (f^.state = FileOK) OR (f^.state = EndError);
  END WriteAccess;


  PROCEDURE Write(VAR f: FILE; ch: CHAR);
  BEGIN
    IF WriteAccess(f) THEN
      f^.buf.data[f^.buf.cur] := ch;
      INC(f^.buf.cur);
      f^.buf.mustWrite := TRUE;
    END;
  END Write;


  PROCEDURE WriteBytes(VAR f: FILE; buf: ADDRESS; nBytes: CARDINAL): CARDINAL;
  VAR
    bufBytes: CARDINAL;

    PROCEDURE MoveBuffer(len: CARDINAL);
    BEGIN
      MoveLeft(buf, ADR(f^.buf.data[f^.buf.cur]), len);
      INC(f^.buf.cur, len);
    END MoveBuffer;

  BEGIN
    IF nBytes # 0 THEN
      IF WriteAccess(f) THEN
        f^.buf.mustWrite := TRUE;
        bufBytes := HIGH(f^.buf.data) + 1 - f^.buf.cur;
        IF bufBytes < nBytes THEN	(* several buffers *)
          MoveBuffer(bufBytes);
          RETURN WriteBytes(f, buf + bufBytes, nBytes - bufBytes) + bufBytes;
          ELSE	(* all in current buffer *)
            MoveBuffer(nBytes);
          END;
        ELSE
          RETURN 0;
        END;
      END;
    RETURN nBytes;
  END WriteBytes;


  PROCEDURE WriteRec(VAR f: FILE; rec: ARRAY OF WORD);
  VAR
    i: CARDINAL;
  BEGIN
    i := WriteBytes(f, ADR(rec), SIZE(rec));
  END WriteRec;


END Files.
