program Main;

(***********************************************************)
(* START OF PASLIB for BLS Pascal 1.0/1.2 with CP/M access *)
(***********************************************************)

const FileVar= 36;
      IOEndOfFile = 1; (* ReadFile *)
      
      IOError_DirFull = 1;(* WriteFile *)
      IOError_ReadingUnwrittenData = 1; (* ReadFileRecord *)
      IOError_DiscFull = 2;
      IOError_CannotCloseEntent = 3; (* WriteFileRecord *)
      IOError_ReadingUnwrittenExtent = 4; (* ReadFileRecord *)
      IOError_RecordNumberOutOfRange = 6; (* ReadFileRecord *)
      IOError_InvalidFCB = 9;
      IOError_DiskChanged = 10;
      IOError_InvalidFileName = 11;
      IOError_OpenError = 12; 
      IOError_CloseError = 13; 
      IOError_ReadError = 14; 
      IOError_WriteError = 15; 
      IOError_CreateError = 16; 
      IOError_DeleteError = 17;
      IOError_GetFileRCError = 18; 
      IOError_RenameError = 19;
      
var bdosRes, bdosResAddr: integer;
    IORes: integer; 

(* screen procs *)

procedure ClrScr;
(* Clear Screen *)
begin
   write(chr(12));
end;

procedure Cursor(b: boolean);
(* turn on/off the cursor on screen *)
begin
   if b then write(chr(25)) else write(chr(26));
end;

(* string procs *)

function UpCase(c: integer): integer;
(* convert char value to Upper Case. eg. if Chr(UpCase(keyboard)) = 'A' then ... *)
begin 
   if (c >= ord('a')) and (c <= ord('z')) then c := c - ord('a') + ord('A');
   UpCase := c;
end;

function ValReal(s:string[16]): real;
var r,f: real;
    p: integer; 
    ch: string[1];
    neg, decpoint: boolean;
   procedure nextchar;
   begin p:= p+1; ch :=mid(s, p, 1); end;
begin
  r := 0; p := 0; neg := false; decpoint := false;
  f := 1; nextchar;
  if ch = '-' then begin
     neg := true; 
     nextchar; 
  end;
  while (ch >= '0') and (ch <= '9') do begin
     r := r * 10.0 + (ord(ch) - 48);
     if decpoint then f := f * 10.0;
     nextchar;
     if (ch='.') and not decpoint then begin
        decpoint := true; 
        nextchar; 
     end; 
  end; 
  if neg then ValReal := -r/f else ValReal := r/f;
end;

function ValInt(s:string[8]): integer;
var n: integer;
    p: integer; 
    ch: string[1];
    neg: boolean;
   procedure nextchar;
   begin p:= p+1; ch :=mid(s, p, 1); end;
begin
  n := 0; p := 0; neg := false; 
  nextchar;
  if ch = '-' then begin
     neg := true; 
     nextchar; 
  end;
  while (ch >= '0') and (ch <= '9') do begin
     n := n * 10 + (ord(ch) - 48);
     nextchar;
  end; 
  if neg then ValInt := -n else ValInt := n;
end;

function ValHex(s:string[4]): integer;
var n, nH, nL, d: integer;
    p, len: integer; 
    ch: string[1];
   procedure nextchar;
   begin 
      if p >= len then begin
         d := -1 
      end else begin
         p:= p+1; 
         ch := mid(s, p, 1); 
         d := (UpCase(ord(ch)) - 48);
         if d > 9 then d := d + 48 - ord('A') + 10;
      end;
   end;
begin
  nL := 0; nH := 0; len := length(s); p := 0;
  nextchar;
  while (d >= 0) and (d <= 15) do begin
     nL := nL * 16 + d;
     nH := nH * 16 + (nL div 256);           
     nL := nL and 255;
     nextchar;         
  end;
  p := addr(n);
  mem[p+0] := nL;
  mem[p+1] := nH;
  ValHex := n;
end;  


function StrInt(n: integer): string[8];
label ProcEnd;
var d: integer; 
    ch: string[1];
    neg: boolean;
    s: string[8];
begin
   s := ''; neg := false;
   if n < 0 then begin
      neg := true;
      n := -n;
   end;
   repeat
      d := n mod 10;
      n := n div 10;
      ch := chr(48+d);
      s := concat(ch, s);
   until n = 0;
   if neg then s := concat('-', s);
   ProcEnd:
   StrInt := s;
end; 

function StrHex(n, len: integer): string[4];
var d: integer; 
    ch: string[1];
    s: string[4];
begin
   s := '';
   while len > 0 do begin
      d := n and 15;
      n := n shift -4;
      if d <= 9 then ch := chr(48+d) 
                else ch := chr(ord('A')-10+d);
      s := concat(ch, s);
      len := len -1;
   end; 
   StrHex := s;
end;


(* system procs *)

procedure bdos(c, de: integer);
(* call cp/m bdos function c, with de param. Return values in a,hl *)
var m: array[0..9] of integer;
    bdoscall: integer; 
begin
   INIT m TO 256, 0, 4352, 0, 1485, 8704, 2048, 562, 8, 201;
   m[1] := c;
   m[3] := de;
   bdoscall := addr(m[0]);
   call (bdoscall);
   bdosRes     := mem[2050];
   bdosResAddr := mem[2048] + 256*mem[2049];
end;

function BlsPascalVersion: integer; 
begin
   BlsPascalVersion := mem[$0100 + 5] * 10 + mem[$0100 + 6];
   (* return 10 for v1.0, 12 for v1.2, etc *)
end; 

procedure Halt; 
begin
   if BlsPascalVersion = 10 then call(-7845);
   if BlsPascalVersion = 12 then call(8524);
   bdos(0,0);
end; 

function ParamCount: integer; 
var n, i, c0, c: integer; 
begin
   n := 0;
   c:= 32;
   if mem[$0080] > 0 then for i := 0 to mem[$0080]-1 do begin
      c0 := c;
      c := mem[$0081 + i];
      if (c0 = 32) and (c <> 32) then n := n + 1; 
   end;
   ParamCount := n;
end; 

function ParamStr(nParam: integer): string[80];
label ProcEnd;
var n, c0, c, nLen, i, i1, i2: integer; 
    s: string[80];
begin
   if nParam < 1 then goto ProcEnd;
   nLen := mem[$0080]; 
   if nLen = 0 then goto ProcEnd;
   c:= 32;
   s := '';
   i := 0; i1 := -1; 
   while (i < nLen) do begin
      c0 := c;
      c := mem[$0081 + i];
      if (c0 = 32) and (c <> 32) then n := n + 1; 
      if n = nParam then begin
         if i1 < 0 then begin
            i1 := i;
            i2 := i+1;
         end;
         if c = 32 then begin
            i := nLen;
         end else begin
            i2 := i+1;
         end; 
      end;
      i := i + 1;
   end;
   if i1 < 1 then goto ProcEnd;
   if i2-i1 >= 80 then i2 := i1 + 80;
   for i := i1 to i2-1 do begin
      c := mem[$0081 + i];
      s := concat(s, chr(c));
   end;
   ProcEnd: ParamStr := s; 
end;

function GetHiMem: integer;
var PMTP, p: integer; 
begin
   p := addr(PMTP);
   (* PMTP = $0c94-95 = Highest RAM address the WSP of running program can access *)
   mem[p+0] := mem[3220];
   mem[p+1] := mem[3221]; 
   GetHiMem := PMTP
end; 

procedure SetHiMem(m: integer);
begin
   mem[3221] := m div 256; (* Sets firts the hi value *)
   mem[3220] := m and 255;
end; 

function MemAvail: integer;
var WSP, p: integer; 
begin
   p := addr(WSP);
   (* WSP = $0c92-93 = Program WorkSpace Stack Pointer *)
   mem[p+0] := mem[3218];
   mem[p+1] := mem[3219]; 
   MemAvail := GetHiMem - WSP;
end; 

(* file I/O procs *)

procedure bdosfile(c: integer; var file: string[FileVar]); 
(* DBOS call with FCB *)
var fcb: integer;
begin
   fcb := addr(file) + 1; (* skip string length byte *)
   bdos(c, fcb);  
   if bdosRes <> 255 then IORes := 0;
end;

procedure bdosfilebuf(c: integer; var file: string[FileVar]; BufAddr:integer); 
(* DBOS call with FCB and SetDMA *)
begin
   bdos(26, BufAddr); (* Set DMA to File Record Buffer *)   
   bdosfile(c, file);
   IORes := bdosRes;
end;

procedure bdosfilerc(c: integer; var file: string[FileVar]; var CurrentRecord: integer); 
var fcbrc: integer;
begin
   IORes := IOError_GetFileRCError;
   bdosfile(c, file);
   fcbrc := addr(file) + 1 + 33;
   CurrentRecord := mem[fcbrc] + 256 * (mem[fcbrc+1] and 127); 
   (* only 32K records allowed -> 32K * 128 bytes -> max file size = 4M *)
end;

procedure AssignFile(var file: string[FileVar]; fn: string[14]);
(* file var size = 36 (FCB)
   fn = filename = [A:]filename.ext = 2 + 8 + 1 + 3 = 14 chars max*)
label ProcEnd, endfn, endext;
const FcbDrive = 1;
      FcbFileName = 2;
      FcbFileExt = 10;
      FcbFileRc = 34;
var n, n1, c: integer; 
    f: integer;
begin
   IORes := IOError_InvalidFileName;
   if fn = '' then goto ProcEnd;
   f := addr(file);
   (* clear all: FCB and BUF *)
   mem[f] := FileVar;
   for n := 1 to FileVar do mem[f+n] := 0; 
   (* clear filename -> set it to spaces *)
   for n := FcbFileName to FcbFileExt+2 do mem[f+n] := 32;
   (* check drive letter *)
   n1 := 1;
   if mid(fn, 2, 1) = ':' then begin
      c := ord(mid(fn, 1, 1));
      n := UpCase(c) - Ord('A') + 1;
      if (n < 1) or (n > 16) then goto ProcEnd;
      mem[f+FcbDrive] := n;
      n1 := 3; 
   end;
   (* copy filename to FCB *)
   n := 0;
   c := 0;
   repeat
      if n1 > length(fn) then goto endfn;
      c := ord(mid(fn, n1, 1));
      n1 := n1 + 1;
      c := UpCase(c);
      if c <= 32 then goto ProcEnd; (* invalid character *);
      if c = ord('?') then goto ProcEnd; (* invalid character *)
      if c = ord('*') then goto ProcEnd; (* invalid character *)
      if c = ord('.') then goto endfn;
      (* valid filename char *)
      if n >= 8 then goto ProcEnd; (* filename too long *)
      mem[f+FcbFileName+n] := c; 
      n := n + 1; 
   until false;   
   endfn:
   if n = 0 then goto ProcEnd; (* no filename *)
   (* copy extension to FCB *)
   if c <> ord('.') then goto endext;
   n := 0;
   c := 0;
   repeat
      if n1 > length(fn) then goto endext;
      c := ord(mid(fn, n1, 1));
      n1 := n1 + 1;
      c := UpCase(c);
      if c <= 32 then goto ProcEnd; (* invalid character *);
      if c = ord('?') then goto ProcEnd; (* invalid character *)
      if c = ord('*') then goto ProcEnd; (* invalid character *)
      if c = ord('.') then goto ProcEnd; (* invalid character *)
      (* valid filename char *)
      if n >= 3 then goto ProcEnd; (* extension too long *)
      mem[f+FcbFileExt+n] := c; 
      n := n + 1; 
   until false;   
  endext:
   IORes := 0;
  ProcEnd: 
   n := 0;
end;

procedure CreateFile(var file: string[FileVar]); 
begin
   IORes := IOError_CreateError;
   bdosfile(22, file);
end;

procedure OpenFile(var file: string[FileVar]); 
begin
   IORes := IOError_OpenError;
   bdosfile(15, file);
end; 

procedure CloseFile(var file: string[FileVar]); 
begin
   IORes := IOError_CloseError;
   bdosfile(16, file);
end;

procedure ReadFile(var file: string[FileVar]; BufAddr:integer); 
begin
   bdosfilebuf(20, file, BufAddr);
   if IORes = 255 then IORes := IOError_ReadError;
end;

procedure WriteFile(var file: string[FileVar]; BufAddr:integer); 
begin
   bdosfilebuf(21, file, BufAddr);
   if IORes = 255 then IORes := IOError_WriteError;
end;

function FilePos(var file: string[FileVar]): integer; 
var RecordCound: integer; 
begin
   (* return sequential current record *)
   bdosfilerc(36, file, RecordCound);
   FilePos := RecordCound;
end;

function FilePosRecord(var file: string[FileVar]): integer; 
var fcbrc: integer;
begin
   (* return randon current record *)
   fcbrc := addr(file) + 1 + 33;
   FilePosRecord := mem[fcbrc] + 256 * (mem[fcbrc+1] and 127); 
   (* only 32K records allowed -> 32K x 128 bytes -> max file size = 4M *)
end;

procedure SeekFileRecord(var file: string[FileVar]; CurrentRecord: integer); 
var fcbrc: integer;
begin
   (* set random current record *)
   fcbrc := addr(file) + 1 + 33;
   mem[fcbrc]   := CurrentRecord and 255;
   mem[fcbrc+1] := (CurrentRecord shift -8) and 127;
   mem[fcbrc+2] := 0; (* sorry only 15b for record count *)
end;

procedure ReadFileRecord(var file: string[FileVar]; BufAddr:integer); 
begin
   bdos(26, BufAddr); 
   bdosfile(33, file);
   IORes := bdosRes;
   if IORes = 255 then IORes := IOError_ReadError;
end;

procedure WriteFileRecord(var file: string[FileVar]; BufAddr:integer); 
begin
   bdos(26, BufAddr); 
   bdosfile(34, file);
   IORes := bdosRes;
   if IORes = 255 then IORes := IOError_WriteError;
end;

procedure SeekFile(var file: string[FileVar]; CurrentRecord: integer); 
var buf: string[128];
begin
   (* set sequential current record: 1. set randon current and then *)
   (* 2. make a random read to set the current sequental record *) 
   SeekFileRecord(file, CurrentRecord); 
   ReadFileRecord(file, addr(buf));
end;

(* file management procs *)

procedure GetFileSize(var file: string[FileVar]; var RecordCound: integer); 
begin
   bdosfilerc(35, file, RecordCound);
end;
   
procedure DeleteFile(fn: string[14]); 
label ProcEnd;
var file: string[FileVar];
begin
   AssignFile(file, fn);
   if IORes <> 0 then goto ProcEnd;
   IORes := IOError_DeleteError;
   bdosfile(19, file);
   ProcEnd:
end;

procedure RenameFile(fn1, fn2: string[14]); 
(* rename fn1 to fn2, should be in same drive *)
label ProcEnd;
const FcbDrive = 1;
      FcbFileExt = 10;
var file1, file2: string[FileVar];
    f1, f2, n: integer; 
begin
   AssignFile(file1, fn1);
   if IORes <> 0 then goto ProcEnd;
   AssignFile(file2, fn2);
   if IORes <> 0 then goto ProcEnd;
   f1 := addr(file1);
   f2 := addr(file2);
   (* copy filename from file2 to file1 *)
   for n := FcbDrive to FcbFileExt+2 do mem[f1+n+16] := mem[f2+n]; 
   IORes := IOError_RenameError;
   (* now rename *)
   bdosfile(23, file1);
   ProcEnd:
end;

procedure CopyFile(fn1, fn2: string[14]); 
(* copy fn1 to fn2, can be in different drives *)
label ProcEnd, ProcEnd2;
var file1, file2: string[FileVar];
    f1, f2: integer; 
    buf: string[128];
    pbuf, svIORes: integer; 
begin
   AssignFile(file1, fn1);
   if IORes <> 0 then goto ProcEnd;
   AssignFile(file2, fn2);
   if IORes <> 0 then goto ProcEnd; 
   OpenFile(file1);
   if IORes <> 0 then goto ProcEnd;
   DeleteFile(fn2);
   (* No cares if delete has error, eg fn2 does not exists *)
   CreateFile(file2);
   if IORes <> 0 then goto ProcEnd;
   pbuf := addr(buf);
   repeat
      ReadFile(file1, pbuf);
      if IORes= 1 then begin 
         IORes := 0; (* Clear EOF indication *)
         goto ProcEnd2;
      end;
      if IORes <> 0 then goto ProcEnd2;
      WriteFile(file2, pbuf);
      if IORes <> 0 then goto ProcEnd2;
   until false;
   ProcEnd2:
   svIORes := IORes;
   CloseFile(file1);
   CloseFile(file2);
   if svIORes <> 0 then IORes := svIORes;
   ProcEnd:
end;

(*********************************************************)
(* END OF PASLIB for BLS Pascal 1.0/1.2 with CP/M access *)
(*********************************************************)


begin
   (* put your program here! *)
end.