IMPLEMENTATION MODULE FileSys;     (* Feb - 31 - 1985 pwh *)


  FROM SYSTEM IMPORT 
	ADR, TSIZE;

  FROM OpSys IMPORT
	FCBFileName, FCB,
	Bdos;

  FROM Moves IMPORT
	MoveLeft, Fill;

  FROM Terminal IMPORT
	Write, WriteLn, WriteString;

  FROM Strings IMPORT
	STRING;

  FROM ASCII IMPORT
	sub;


  CONST
    buffLength = 512;	(* I/O buffer size *)

    openFile   = 15;	(* BDOS call function numbers. *)
    closeFile  = 16;
    deleteFile = 19;
    readSeq    = 20;
    writeSeq   = 21;
    makeFile   = 22;
    renameFile = 23;
    setDma     = 26;


  TYPE

    FileDesc = RECORD
      bufptr: CARDINAL;
      maxValidByte: CARDINAL;
      endFile: BOOLEAN;
      fcb: FCB;
      buf: ARRAY [0..buffLength-1] OF CHAR;
    END;

    File = POINTER TO FileDesc;


  VAR 
    i, dma: CARDINAL;
    searchPath: PathType;


  PROCEDURE SetSearchPath(newSearchPath: PathType);
  VAR
    ch: CHAR;
  BEGIN
    FOR i := 0 TO searchPathLength - 1 DO
      ch := newSearchPath[i]; 
      IF ch = 0C THEN Š	searchPath[i] := 377C;
      ELSE
	searchPath[i] := CHR(ORD(ch) - 40H);
      END;
    END; (* FOR *)
  END SetSearchPath;


  PROCEDURE AssignName(VAR f: File; fname: FCBFileName);
  BEGIN
    NEW(f);
    WITH f^.fcb.name DO
      Fill(ADR(disk), TSIZE(FCB), 0C);
      text := fname.text;
    END; (* WITH *)
  END AssignName;
  
    
  PROCEDURE CreateFile(f: File);
  BEGIN
    IF f^.fcb.name.disk = '@' THEN
      f^.fcb.name.disk := searchPath[0];
    END;
    Bdos(deleteFile, ADR(f^.fcb), result); (* delete it first *)
    Bdos(makeFile, ADR(f^.fcb), result);   (* create new one now *)
    TestAbort(result = 255, 'create', f);
    f^.bufptr := 0;
    f^.maxValidByte := 0;
    f^.endFile := FALSE;
  END CreateFile;
  
  
  PROCEDURE OpenFile(f: File);
  BEGIN
    f^.bufptr := buffLength;	        (* force read on first access *)
    f^.maxValidByte := buffLength;
    f^.endFile := FALSE;
					(* now search on search path *)
    result := 255;			(* if there is no search path *)
    IF f^.fcb.name.disk = '@' THEN
      i := 0;				(* searchPatch Index *)
      LOOP
        IF (searchPath[i] = 377C) OR (i = searchPathLength) THEN EXIT; END;
        f^.fcb.name.disk := searchPath[i];
        Bdos(openFile, ADR(f^.fcb), result); (* open the file. *)
        IF result # 255 THEN RETURN; END;
        i := i + 1;
      END;
    ELSE				(* just try it *)
      Bdos(openFile, ADR(f^.fcb), result);
    END;
  END OpenFile;
  
  
  PROCEDURE CloseFile(f: File);
  BEGIN
    FOR i := 0 TO 127 - (f^.bufptr+127) MOD 128 DO 
      WriteByte(f, sub); (* fill rest of 128 bytes with ^Z *)
    END; (* FOR *)
    i := f^.bufptr DIV 128; (* flush buffer *)
    dma := ADR(f^.buf);Š    LOOP
      IF i = 0 THEN EXIT END; 
      Bdos(setDma, dma, result); Bdos(writeSeq, ADR(f^.fcb), result);
      INC(dma, 128); 
      i := i - 1;
      TestAbort(result # 0, 'write to', f);
    END;
    Bdos(closeFile, ADR(f^.fcb), result); 
    TestAbort(result = 255, 'close', f);
  END CloseFile;
  
  
  PROCEDURE DeleteFile(VAR f: File);
  BEGIN
    Bdos(deleteFile, ADR(f^.fcb), result);
    DISPOSE(f);
  END DeleteFile;
  

  PROCEDURE Delete(name: FCBFileName);
  VAR
    file: File;
  BEGIN
    AssignName(file, name);
    DeleteFile(file);
  END Delete;


  PROCEDURE RenameFile(file: File; newName: FCBFileName);
  BEGIN
    Fill(ADR(file^.fcb.d[0]), 16, 0C);	(* move name & type *)
    MoveLeft(ADR(newName.text[1]), ADR(file^.fcb.d[1]), 11);
    Bdos(renameFile, ADR(file^.fcb), result);
    TestAbort(result = 255, 'rename', file);
  END RenameFile;

  
  PROCEDURE Rename(oldName, newName: FCBFileName);
  VAR
    f: File;
  BEGIN
    AssignName(f, oldName);
    RenameFile(f, newName);
    DISPOSE(f);
  END Rename;


  PROCEDURE ReadByte(f: File; VAR ch: CHAR);
  BEGIN
    IF f^.bufptr = f^.maxValidByte THEN     
      IF f^.maxValidByte < buffLength-1 THEN 
        f^.endFile := TRUE
      ELSE 
        dma := ADR(f^.buf);
        i := buffLength DIV 128; (* # of sectors to read. *)
        REPEAT
          Bdos(setDma, dma, result);
          Bdos(readSeq, ADR(f^.fcb), result);
          INC(dma, 128);
          IF result = 0 THEN 
            i := i - 1;Š          END;
        UNTIL (i = 0) OR (result # 0);
        IF i = buffLength DIV 128 THEN
          f^.endFile := TRUE; f^.maxValidByte := 1;
        ELSE 
          f^.maxValidByte := buffLength - i * 128; (* remaining part *)
        END;
        f^.bufptr := 0;
      END;
    END;
    IF f^.endFile THEN ch := sub; result := 1;
    ELSE
      ch := f^.buf[ f^.bufptr ]; 
      INC(f^.bufptr); 
      result := 0;
    END;
  END ReadByte;
  

  PROCEDURE EOF(f: File): BOOLEAN;
  BEGIN
    RETURN f^.endFile
  END EOF;


  PROCEDURE WriteByte(f: File; b: CHAR);
  BEGIN
    result := 0;
    f^.buf[ f^.bufptr ] := b;
    INC(f^.bufptr);
    IF f^.bufptr = buffLength THEN (* have to write it. *)
      i := buffLength DIV 128;    
      dma := ADR(f^.buf);
      REPEAT
        Bdos(setDma, dma, result);
        Bdos(writeSeq, ADR(f^.fcb), result);
        INC(dma, 128);
        i := i - 1;
      UNTIL (i = 0) OR (result # 0);
      TestAbort(result # 0, 'write to', f);
      f^.bufptr := 0;
    END;
  END WriteByte;
  

  PROCEDURE TestAbort(abortCondition: BOOLEAN; action: STRING; file: File);
  BEGIN
    IF abortCondition THEN
      WriteLn; WriteString('---- cannot '); WriteString(action);
      WriteString(' file "'); 
      IF file^.fcb.name.disk # 0C THEN	(* write drive *)
        INC(file^.fcb.name.disk, ORD('@'));
        Write(file^.fcb.name.disk); Write(':');
      END;
      FOR i := 0 TO 7 DO Write(file^.fcb.name.name[i]); END;
      Write('.');
      FOR i := 0 TO 2 DO Write(file^.fcb.name.type[i]); END;
      Write('"');
      HALT;
    END;
  END TestAbort;Š

  PROCEDURE MakeFile(VAR file: File; name: FCBFileName);
  BEGIN
    AssignName(file, name);
    CreateFile(file);
  END MakeFile;


  PROCEDURE UsesFile(VAR file: File; name: FCBFileName);
  BEGIN
    AssignName(file, name);
    OpenFile(file);
    TestAbort(result = 255, 'open', file);
  END UsesFile;


  PROCEDURE DisposeFile(VAR f: File);
  BEGIN
    DISPOSE(f);
  END DisposeFile;


BEGIN
  SetSearchPath('@');
END FileSys.
