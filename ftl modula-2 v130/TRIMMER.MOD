MODULE Trimmer;

(*	This module processes information produced by the linker to
	trim a module.

	The linker produces a table of label references. Each label
	reference produces a pair of labels - the label of the 
	procedure from which the call is made and the label of the 
	procedure that is being called.

	A graph closure is performed to determine which labels are 
	actually reachable in a given program. This information is
	then output in a form which a subsequent linker run can use.

	Notice that the list is of labels (procedures) that can be 
	reached. If a procedure is imported but never used, it will
	not be included.

	Copyright (C) Dave Moore, FTL Modula-2 October 1986
*)
FROM SYSTEM IMPORT BYTE,ADR;
FROM Terminal IMPORT ReadString,WriteString,WriteLn;
FROM Streams IMPORT Connect,ReadRec,Disconnect,Direction,STREAM,WriteRec,EOS;
FROM Files IMPORT FILE,Lookup,Create;
FROM Strings IMPORT Concat;
FROM Storage IMPORT ALLOCATE,DEALLOCATE;
FROM SmallIO IMPORT WriteCard,WriteInt;
CONST	MaxLabel=200;
	MaxModules=50;

	InputDataExt='.LRL';
	OutputDataExt='.TRM';
TYPE	PProcRef=POINTER TO ProcRef;
	PLabelRef=POINTER TO LabelRef;
	PModule=POINTER TO Module;

	ProcRef=RECORD
		ProcNo:BYTE;
		LabList:PLabelRef;
		Next:PProcRef;
		END;
	LabelRef=RECORD
		Module:BYTE;
		To:BYTE;
		Next:PLabelRef;
		END;
	LabelSet=SET OF [0..MaxLabel];
	Alfa=ARRAY[1..8] OF CHAR;
	Module=RECORD
		Id:Alfa;
		StaticData:CARDINAL;
		ProcList:PProcRef;
		Reachable:LabelSet;
		LabList:PLabelRef;
		Next:PModule;
		END;
VAR	ModuleCnt:CARDINAL;
	Modules:ARRAY[0..MaxModules] OF PModule;
	ModuleName:ARRAY[0..60] OF CHAR;
PROCEDURE ReadModuleRefs;

(*		Read in the file of label references. This file takes the
		form of a sequence of tables. Each table starts with an
		identifying BYTE:

		255 - end of file.
		254 - Module definition record
		253 - Start of procedure
		252 - Start of module mainline
		ELSE- label
		
		Table 254

		The Module definition record is output at the end of the 
		module. It consists of:
		Module Number. (1 byte)
		Name of Module (8 bytes, blank filled)
		Bytes of Static Data (2 bytes)
		BitMap of procedure labels referenced in mainline. 
		The first byte of the bitmap give the number of bytes
		actually output. The remaining bytes are the bytes of 
		the bitmap output BACKWARDS (it easier).

		Table 253

		The start of procedure table contains 2 byte - the label of
		the procedure being started, and the level of the procedure.

		Table 252

		The mainline reference contains 1 byte - the level number.

		The label reference contains two bytes: The number of the 
		module containing the label and the label number. 

		Note that modules do not neccessarily appear in the tables
		in order of their module numbers - these numbers are 
		allocated when the module is first referenced.
		
*)
VAR	reply:INTEGER;
	s:STREAM;
	f:FILE;
	Buffer:ARRAY [0..127] OF BYTE;
	Len:INTEGER;
	b:BYTE;
	CurrentProc,ModNo:CARDINAL;
	i:CARDINAL;
	BitMap:ARRAY[0..MaxLabel DIV 8-1] OF BYTE;
	LabRef:PLabelRef;
	Proc,OurProcs:PProcRef;
	FileName:ARRAY[0..60] OF CHAR;
	MainBlocks:ARRAY[0..10] OF PModule;
	Main:PModule;
PROCEDURE ReadNext;
BEGIN
	IF reply>=Len THEN
		ReadRec(s,ADR(Buffer),SIZE(Buffer),Len);
		reply:=0;
		END;
	b:=Buffer[reply];
	INC(reply);
	END ReadNext;
PROCEDURE ReadNextCard(VAR i:CARDINAL);
BEGIN
	(*	notice that this routine assumes that cardinals
		are byte swapped - beware for 68000 version *)
	ReadNext;
	i:=b;
	ReadNext;
	i:=256*ORD(b)+i;
	END ReadNextCard;
TYPE	Firsts=SET OF [0..255];
VAR	First:Firsts;
	Trace:BOOLEAN;
	Counter:CARDINAL;
	CurrentLevel:CARDINAL;
	SuspendedLabels:PLabelRef;
BEGIN
	Counter:=0;
	First:=Firsts{};
	WriteString(' Enter name of module to trim :');
	ReadString(ModuleName);
	Concat(ModuleName,InputDataExt,FileName);
	Lookup(f,FileName,reply);
	IF reply<>0 THEN
		WriteString(' File not found:');
		WriteString(FileName);
		WriteLn;
		HALT;
		END;
	Connect(s,f,input);
	reply:=SIZE(Buffer);
	Len:=reply;
	ModuleCnt:=0;
	FOR i:=0 TO HIGH(Modules) DO Modules[i]:=NIL END;
	OurProcs:=NIL;
	FOR i:=0 TO HIGH(MainBlocks) DO MainBlocks[i]:=NIL END;
	Trace:=FALSE;
	SuspendedLabels:=NIL;
	CurrentLevel:=3;
	Main:=NIL;
	LOOP
		IF Len=0 THEN 
			WriteString(' Input file seems to be truncated');WriteLn;
			EXIT 
			END;
		ReadNext;
		IF Trace THEN
			WriteString(' next table=');WriteCard(b,4);
			WriteString(' level = ');WriteCard(CurrentLevel,4);
			END;
		CASE b OF
			255:EXIT|
			254:(*module definition record. Output when the 
				mainline for the module is encountered
				or else the end of the module if no mainline*)
				ReadNext;
				ModNo:=b;
				CurrentLevel:=1;
				IF ModNo>ModuleCnt THEN ModuleCnt:=ModNo END;
				IF Main=NIL THEN
					NEW(Main);
					Main^.LabList:=SuspendedLabels;
					SuspendedLabels:=NIL;
					END;
				Modules[ModNo]:=Main;
				Main:=NIL;
				CurrentLevel:=0;
				WITH Modules[ModNo]^ DO
					ProcList:=OurProcs;
					OurProcs:=NIL;
					FOR i:=1 TO 8 DO
						ReadNext;
						Id[i]:=b;
						END;
					ReadNextCard(StaticData);
					Reachable:=LabelSet{};
					Next:=NIL;
					WriteString(Id);
					WriteCard(ModNo,4);
					IF NOT Trace THEN WriteLn END;
					END; (*WITH*)
				|
			253: (*start of a procedure *)
				Counter:=2;
				ReadNext;	(*label no*)
				IF Trace THEN WriteString(' label ');WriteCard(ORD(b),4) END;
				CurrentProc:=b;
				ReadNext;	(*level*)
				CurrentLevel:=b;
				IF b<=2 THEN
					NEW(Proc);
					Proc^.Next:=OurProcs;
					OurProcs:=Proc;
					Proc^.ProcNo:=CurrentProc;
					Proc^.LabList:=SuspendedLabels;
					SuspendedLabels:=NIL;
					END;
				|
			252: (*start of a nested main block *)
				ReadNext;	(*block level or surrounding scope*)
				CurrentLevel:=b;
				IF b=1 THEN
					IF Main=NIL THEN
						NEW(Main);
						Main^.LabList:=SuspendedLabels;
						SuspendedLabels:=NIL;
						Main^.Next:=NIL;
						END;
					END;
				|
			ELSE  (*its a label reference *)
			    IF b=3 THEN ReadNext
			    ELSE
				NEW(LabRef);
				WITH LabRef^ DO
					IF CurrentLevel=0 THEN
						Next:=Modules[ModNo]^.LabList;
						Modules[ModNo]^.LabList:=LabRef;
					ELSIF (Main<>NIL) AND (CurrentLevel=1) THEN
						Next:=Main^.LabList;
						Main^.LabList:=LabRef;
					ELSIF CurrentLevel>2 THEN
						Next:=SuspendedLabels;
						SuspendedLabels:=LabRef;
					ELSE
						Next:=Proc^.LabList;
						Proc^.LabList:=LabRef;
						END;
					Module:=b;
					ReadNext;
					IF Trace THEN WriteString(' label ');WriteCard(ORD(b),4) END;
					To:=b;
					END;		
				END
			    END; (*CASE*)
			IF Trace THEN WriteLn END;
		END; (*LOOP*)
	Disconnect(s,TRUE);
	END ReadModuleRefs;
PROCEDURE Closure;

(*	Perform closure operation on reference lists.
	This goes around and around adding labels to the reachable sets 
	until a complete pass is made without adding any labels

 *)

VAR	Closed:BOOLEAN;
	i:CARDINAL;
	Proc:PProcRef;
	Lab:PLabelRef;
	Mod:PModule;
BEGIN
    FOR i:=0 TO ModuleCnt DO
	IF Modules[i]<>NIL THEN
		WITH Modules[i]^ DO
			Lab:=LabList;
			WHILE Lab<>NIL DO
				IF Modules[Lab^.Module]=NIL THEN
					(*WriteString('Reference to NIL module pointer');
					WriteCard(Lab^.Module,4);
					WriteCard(Lab^.To,4);
					WriteLn;*)
					
				ELSE 
					INCL(Modules[Lab^.Module]^.Reachable,Lab^.To);
					END;
				Lab:=Lab^.Next;
				END;
			END;
		END;
	END;
	(*	Set maps for all modules with no procedures to be
		all labels selected since they are probably in assembler*)
    FOR i:=0 TO ModuleCnt DO
	IF Modules[i]<>NIL THEN
	     WITH Modules[i]^ DO
		IF ProcList=NIL THEN Reachable:=LabelSet{0..MaxLabel} END
		END;
	    END;
	END;
    REPEAT
	Closed:=TRUE;
	WriteString('.');
	FOR i:=0 TO ModuleCnt DO
	    IF Modules[i]<>NIL THEN
		WITH Modules[i]^ DO
		    Proc:=ProcList;
		    WHILE Proc<>NIL DO
			IF Proc^.ProcNo IN Reachable THEN
			    Lab:=Proc^.LabList;
			    WHILE Lab<>NIL DO
				IF NOT (Lab^.To IN Modules[Lab^.Module]^.Reachable) THEN
			    	    INCL(Modules[Lab^.Module]^.Reachable,Lab^.To);
				    Closed:=FALSE;
				    END;
				Lab:=Lab^.Next;
				END;
			    END; (*IF ProcNo IN Reachable*)
			Proc:=Proc^.Next;
			END;
		    END; (*WITH Modules[i]^ DO*)
		END; (*IF <>NIL*)
	    END (*FOR*)
	UNTIL Closed;	
    END Closure;

PROCEDURE OutputResults;

(*	Create a file, called filename.TRM *)
VAR	FileName:ARRAY[0..60] OF CHAR;
	s:STREAM;
	f:FILE;
	i,j:CARDINAL;
	reply:INTEGER;
PROCEDURE CheckIO(b:BOOLEAN);
BEGIN	
	IF NOT b THEN
		WriteString(' Could not totally output file :');
		WriteString(FileName);
		WriteLn;
		END;
	END CheckIO;
BEGIN
	WriteLn;
	Concat(ModuleName,OutputDataExt,FileName);
	Create(f,FileName,reply);
	IF reply<>0 THEN
		WriteString(' Could not create file:');
		WriteString(FileName);
		WriteLn;
		HALT;
		END;
	Connect(s,f,output);
	WriteString(' Putting results on file ');WriteString(FileName);
	WriteLn;
	FOR i:=0 TO ModuleCnt DO
		IF Modules[i]<>NIL THEN
			WITH Modules[i]^ DO
				WriteRec(s,ADR(Id),SIZE(Id),reply);
				WriteString(Id);
				CheckIO(reply=SIZE(Id));
				WriteRec(s,ADR(Reachable),SIZE(Reachable),reply);
				CheckIO(reply=SIZE(Reachable));
				IF Reachable=LabelSet{0..MaxLabel} THEN
					WriteString(' Probably assembler');
				ELSE
					FOR j:=0 TO 200 DO
						IF j IN Reachable THEN
							WriteCard(j,3);
							END;
						END;
					END;
				WriteLn;
				END;
			END;
		END;
	Disconnect(s,TRUE);
	END OutputResults;
BEGIN
	WriteString(' Trimmer v 1.0');WriteLn;
	WriteLn;
	WriteString(' Copyright (C) Dave Moore, FTL Modula-2, October 1986');
	WriteLn; 
	ReadModuleRefs;
	Closure;
	OutputResults;
	END Trimmer.
rrectly! Please be aware while 
debugging of the possibilty of bugs