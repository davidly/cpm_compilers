IMPLEMENTATION MODULE Kernel;

FROM	Processes IMPORT PROCESS,NEWPROCESS,TRANSFER,IOTRANSFER;
FROM	Storage IMPORT ALLOCATE,DEALLOCATE;
FROM	SYSTEM  IMPORT ADDRESS,SIZE,TSIZE;
FROM	PortIO IMPORT DisableInterrupts,EnableInterrupts;
(*FROM	Terminal IMPORT WriteString,WriteLn;*)

(*	The constant TicksPerClock gives the number of hardware clock 
	interrupts that are to pass before one clock tick is executed.

	This speeds up processing somewhat if there are a lot of clock 
	ticks.
*)
CONST	TicksPerClock=18;	(*approc 1 second on IBM pc *)
TYPE	Task=POINTER TO TaskRecord;
	TaskRecord=RECORD
		Proc:PROCESS;	(ˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇnge packet*)
		Next:Task;	(*pointer to next task in IO queue*)
		Priority:CARDINAL;
		WorkArea:ADDRESS;
		WorkSize:CARDINAL;
		ClockTick:CARDINAL; (*The clock counter which the task
			is blocked until. *)
		END;
	Semaphore=RECORD
		Counter:INTEGER;	(*the resource units*)
		Head,Tail:Task;
		END;
	pMessage=POINTER TO Message;
	Message=RECORD
		NextMessage:pMessage;
		Length:CARDINAL;
		Message:ARRAY[0..2000] OF BYTE;
		END;
	MailBox=RECORD
		Mutex,MessageCount:Semaphore;
		Head,Tail:pMessage;
		END;
VAR	RoundRobin,Blocked:ARRAY[1..PriorityLevels+1] OF Task;
	i,j:CARDINAL;	
	ClockCounter:CARDINAL;
	DosSemaphore:Semaphore;
	ClockQueue:Task;
	ClockTask:Task;
	MultiTasking:BOOLEAN;
PROCEDURE Reschedule;
(*	Schedule the highest priority task available

	CurrentTask is the task currently executing but this may be NIL if
	that task has just deleted itself.
*)
VAR	i:CARDINAL;
	p,q:Task;
	proc:PROCESS;
BEGIN
(*		WriteString(' reschedule');WriteLn;*)
	DisableInterrupts;
	i:=1;
	WHILE (RoundRobin[i]=NIL) AND (i<=HIGH(RoundRobin)) DO
		INC(i);
		END;
	p:=CurrentTask;
	q:=RoundRobin[i];
	RoundRobin[i]:=q^.Next;
	IF CurrentTask=q THEN RETURN END;
	IF CurrentTask=NIL THEN
		CurrentTask:=q;
		TRANSFER(proc,q^.Proc);
	ELSE
		CurrentTask:=q;
		TRANSFER(p^.Proc,q^.Proc);
		END;
	EnableInterrupts;
	END Reschedule;
PROCEDURE InsertTask(t:Task);

(*	Insert a task in the appropriate round-robin chain.

	The round-robin is a circular list, so we have to find the
	end of the list so that the new entry can be inserted at the
	head of the list *)
VAR	p:Task;
BEGIN
(*	WriteString(' inserting task');WriteLn;*)
	DisableInterrupts;
	WITH t^ DO
		Next:=RoundRobin[Priority];
		RoundRobin[Priority]:=t;
		IF Next=NIL THEN 
			Next:=t;
			EnableInterrupts;
			RETURN
			END;
		END;
	p:=t^.Next;
	WHILE (p^.Next<>NIL) AND (p^.Next<>t^.Next) DO p:=p^.Next END;
	p^.Next:=t;
	EnableInterrupts;
	END InsertTask;
PROCEDURE AddTask(p:PROC;Prio:CARDINAL;Work:CARDINAL);

(*	Create a new task and schedule it at the given priority level. *)
VAR	t:Task;
	a:ADDRESS;
BEGIN
	NEW(t);
	ALLOCATE(a,Work);
	WITH t^ DO
		NEWPROCESS(p,a,Work,Proc);
		IF Prio<1 THEN Prio:=1
		ELSIF Prio>PriorityLevels THEN Prio:=PriorityLevels END;
		Priority:=Prio;
		WorkArea:=a;
		WorkSize:=Work;
		END;
	InsertTask(t);
	END AddTask;
PROCEDURE RemoveTask(t:Task):BOOLEAN;

(*	Remove a task from its current round-robin queue *)

VAR	p:Task;
BEGIN
(*	WriteString(' Removing task');WriteLn;*)
	WITH t^ DO

		(*	first, find the task on the priority queues *)
		p:=RoundRobin[Priority];
		WHILE (p<>NIL) AND (p^.Next<>RoundRobin[Priority]) AND (p^.Next<>t) DO
			p:=p^.Next
			END;
		IF (p=NIL) OR (p^.Next<>t) THEN 
			RETURN FALSE
			END;
		p^.Next:=t^.Next;
		IF RoundRobin[Priority]=t THEN
			IF t^.Next=t THEN RoundRobin[Priority]:=NIL
			ELSE RoundRobin[Priority]:=t^.Next END;
			END;
		END;
	RETURN TRUE (*it succeeded*)
	END RemoveTask;

PROCEDURE DeleteTask(t:Task):BOOLEAN;

(*	Delete a task. To delete the current task, pass the variable
	CurrentTask, which is exported from this module. In this case, 
	the routine never returns.
*)

VAR	p:Task;
	Proc:PROCESS;
BEGIN
	DisableInterrupts;
	IF NOT RemoveTask(t) THEN 
		EnableInterrupts;
		RETURN FALSE 
		END;
	DEALLOCATE(t^.WorkArea,t^.WorkSize);
	IF t=CurrentTask THEN (*terminate the current task *)
		CurrentTask:=NIL;
		DISPOSE(t);
		EnableInterrupts;
		Reschedule; (*this never returns*)
		END;
	DISPOSE(t);
	EnableInterrupts;
	RETURN TRUE;
	END DeleteTask;
PROCEDURE Wait(Time:CARDINAL);

(*	Wait for the given amount of time to elapse. The time interval used 
	depends upon the clock tick routine which you may want to modify. 
	In the released version, it is clock ticks.
	
	If Time is zero, a reschedule is forced but the task will get 
	control back again immediately if it is the only task at the 
	highest priority level that can be executed.
*)

VAR	p:Task;
	b:BOOLEAN;
BEGIN
	p:=CurrentTask;
	IF Time=0 THEN Reschedule;RETURN END;
	b:=RemoveTask(CurrentTask);
	p^.Next:=ClockQueue;
	p^.ClockTick:=Time;
	ClockQueue:=p;
	Reschedule;
	END Wait;
	

PROCEDURE Clock():CARDINAL;

(*	Returns the current time in clock ticks (or whatever units you are 
	using for the clock). *)
	
BEGIN
	RETURN ClockCounter;
	END Clock;	
VAR	StartProc:PROCESS;
PROCEDURE StartTasking;

(*	Starts the multi-tasking executive. *)
BEGIN
	MultiTasking:=TRUE;
	CurrentTask:=ClockTask;
	TRANSFER(StartProc,ClockTask^.Proc);
	END StartTasking;

PROCEDURE EndTasking;

(*	Ends the multi-tasking executive.  This call is intended as a 
	general cleanup, so you may want to add extra code of your own to 
	clean up your application. *)

BEGIN
	MultiTasking:=FALSE;	
	TRANSFER(StartProc,StartProc);
	END EndTasking;
PROCEDURE StartDosCall;

(*	The program is about to call DOS. This locks DOS so that no
	other task will attempt to call DOS while this task is in there.
	Remember that CP/M and MS-DOS are NOT re-entrant so this is a VERY
	good idea! *)
BEGIN
	IF MultiTasking THEN LockSemaphore(DosSemaphore) END;
	END StartDosCall;
PROCEDURE EndDosCall;

(*	End DOS call. DOS is now available again. *)

BEGIN
	IF MultiTasking THEN UnlockSemaphore(DosSemaphore) END;
	END EndDosCall;


PROCEDURE InitMailBox(VAR b:MailBox);

(*	Initialize a Mailbox.  You must call this for every Mailbox. *)
BEGIN
	WITH b DO
		InitSemaphore(Mutex,1);
		InitSemaphore(MessageCount,0);
		Head:=NIL;
		Tail:=NIL;
		END;
	END InitMailBox;
PROCEDURE SendMessage(VAR b:MailBox;Message:ARRAY OF BYTE);

(*	Send a message to the given Mailbox.  The contents of the message 
	are user defined.  A copy is made of the message on the heap. *)
VAR	i:CARDINAL;
	p:pMessage;
BEGIN
	ALLOCATE(p,TSIZE(pMessage)+TSIZE(CARDINAL)+SIZE(Message));
	p^.Length:=SIZE(Message);
	FOR i:=0 TO HIGH(Message) DO p^.Message[i]:=Message[i] END;
	LockSemaphore(b.Mutex);
	IF b.Head=NIL THEN
		b.Head:=p;
	ELSE
		b.Tail^.NextMessage:=p;
		END;
	b.Tail:=p;
	p^.NextMessage:=NIL;
	UnlockSemaphore(b.Mutex);
	UnlockSemaphore(b.MessageCount);
	END SendMessage;
PROCEDURE ReceiveMessage(VAR b:MailBox;VAR Message:ARRAY OF BYTE);

(*	Receive a message.  If no message is available, the task waits
	until a message becomes available. *)
VAR	i,j:CARDINAL;
	p:pMessage;
BEGIN
	LockSemaphore(b.MessageCount);
	LockSemaphore(b.Mutex);
	p:=b.Head;
	IF p^.Length<SIZE(Message) THEN j:=p^.Length ELSE j:=SIZE(Message) END;
	IF j=0 THEN j:=1 END;
	FOR i:=0 TO j-1 DO Message[i]:=p^.Message[i] END;
	b.Head:=p^.NextMessage;
	UnlockSemaphore(b.Mutex);
	DEALLOCATE(p,TSIZE(pMessage)+TSIZE(CARDINAL)+p^.Length);
	END ReceiveMessage;
PROCEDURE MessageCount(VAR b:MailBox):INTEGER;

(*	Return number of messages pending on a Mail-box. The returned value 
	is positive if there are messages in the Mailbox. It is negative if 
	there are tasks waiting for messages. *)

BEGIN
	RETURN Waiters(b.MessageCount)
	END MessageCount;


(*	The following types and procedures implement semaphores. *)

PROCEDURE InitSemaphore(VAR s:Semaphore;SimUsers:CARDINAL);
BEGIN
	WITH s DO
		Counter:=SimUsers;
		Head:=NIL;
		Tail:=NIL;
		END;
	END InitSemaphore;

PROCEDURE LockSemaphore(VAR s:Semaphore);
VAR	b:BOOLEAN;
BEGIN
(*	WriteString(' Lock Semaphore');WriteLn;*)
	DisableInterrupts;
	IF s.Counter=0 THEN
		b:=RemoveTask(CurrentTask);
		CurrentTask^.Next:=NIL;
		IF s.Head=NIL THEN 
			s.Head:=CurrentTask;
			s.Tail:=CurrentTask
		ELSE
			s.Tail^.Next:=CurrentTask;
			s.Tail:=CurrentTask;
			END;
		EnableInterrupts;
		Reschedule;
		DisableInterrupts;
		END;
	DEC(s.Counter);
	EnableInterrupts;
	END LockSemaphore;

PROCEDURE UnlockSemaphore(VAR s:Semaphore);
VAR	p:Task;
BEGIN
(*	WriteString(' unlock semaphore');WriteLn;*)
	DisableInterrupts;
	INC(s.Counter);
	IF s.Head<>NIL THEN
		p:=s.Head;
		s.Head:=p^.Next;
		InsertTask(p);
		EnableInterrupts;
		Reschedule;
	ELSE
		EnableInterrupts;
		END;
	END UnlockSemaphore;

PROCEDURE Waiters(VAR s:Semaphore):INTEGER;
VAR	p:Task;
	i:CARDINAL;
BEGIN
	DisableInterrupts;
	i:=s.Counter;
	IF s.Counter=0 THEN
		p:=s.Head;
		i:=0;
		WHILE p<>NIL DO 
			DEC(i);
			p:=p^.Next;	
			END;
		END;
	EnableInterrupts;
	RETURN i
	END Waiters;

PROCEDURE IdleLoop;

(*	This task is always ready.  It is called whenever no other task
	can be found to be executed.  For this reason, it is always at the 
	lowest priority level.  On operating systems with their own "wait"s,
	this kind of looping would be very wasteful but single-user CPUs
	don't care. *)
BEGIN
	LOOP
		Reschedule;
		END;
	END IdleLoop;
VAR	PreviousTask:Task;

PROCEDURE DoIO(IOInfo:IORecord;VAR Previous:Task);
(*	Perform an Input-output operation. The task is suspended until the 
	operation is complete. This routine should be used rather than
	doing direct IOTRANSFERS. *)
VAR	p,q:Task;
	i:CARDINAL;
	b:BOOLEAN;
	proc:PROCESS;
BEGIN
	DisableInterrupts;
	IF Previous<>NIL THEN
		q:=Previous;
	ELSE
		i:=1;
		WHILE (RoundRobin[i]=NIL) AND (i<=HIGH(RoundRobin)) DO
			INC(i);
			END;
		q:=RoundRobin[i];
		RoundRobin[i]:=q^.Next;
		END;
	p:=CurrentTask;
	b:=RemoveTask(CurrentTask);
	CurrentTask:=q;
	
	(*	We have to be careful here. The task that is executing when
		we return is not neccessarily the same as that which was 
		executing when we left.

		This is why we use a local variable for the iotransfer
		statement. *)

	proc:=q^.Proc;
	IOTRANSFER(p^.Proc,proc,IOInfo.IntNo,IOInfo.IntStub);
	Previous:=CurrentTask;
	CurrentTask^.Proc:=proc;
	CurrentTask:=p;
	InsertTask(p);
	EnableInterrupts;
	END DoIO;

PROCEDURE ClockProc;
(*	This routine gets control every clock tick. It looks for anything
	on the clock wait queue and decrements the timer for those values.

	If any process has its clock wait counter go to zero, it is 
	rescheduled.

	You should avoid doing too many time slices per second. The overhead
	involved in rescheduling is large.
*)
VAR	r:IORecord;
	Previous,p,q,s:Task;
	Ticks:CARDINAL;
BEGIN
	r.IntNo:=1ch;
	Previous:=NIL;
	LOOP
		(*	Wait for required number of ticks to pass *)

		Ticks:=0;
		REPEAT
			DoIO(r,Previous);
			INC(Ticks);
			UNTIL Ticks>TicksPerClock;


		(*	The next statement forces a reschedule on every clock 
			'tick'.

			An alternative strategy would be to only force a 
			reschedule when something is removed from the clock 
			wait queue. In that case, you will be relying on
			interrupts to do your scheduling. *)

		Previous:=NIL; (*force a reschedule every clock*)
		INC(ClockCounter);
		p:=ClockQueue;
		q:=NIL;
		WHILE p<>NIL DO
			DEC(p^.ClockTick);
			IF p^.ClockTick=0 THEN
				IF q=NIL THEN ClockQueue:=p^.Next
				ELSE q^.Next:=p^.Next END;
				s:=p^.Next;
				InsertTask(p);
				p:=s;
			ELSE
				q:=p;
				p:=p^.Next;
				END
			END;
		END; (*LOOP*)
	END ClockProc;

BEGIN	(*initialisation of Kernel routines *)
	FOR i:=1 TO HIGH(RoundRobin) DO RoundRobin[i]:=NIL END;
	FOR i:=1 TO HIGH(Blocked) DO Blocked[i]:=NIL END;
	ClockCounter:=0;
	InitSemaphore(DosSemaphore,1);
	ClockQueue:=NIL;

	(*	We now add the idle loop. This is always at a priority
		1 less than the lowest priority so that it is never executed
		except when nothing else is ready.

		This must always be the first Task created since we move its
		pointer from the highest prority level to the lowest +1 *)

	AddTask(IdleLoop, 1, 500);
	RoundRobin[HIGH(RoundRobin)]:=RoundRobin[1];
	RoundRobin[1]:=NIL;
	AddTask(ClockProc, 1, 500);
	ClockTask:=RoundRobin[1];
	MultiTasking:=FALSE;
	END Kernel.
9iâÉ  CHKDSK  EXE            `ÁÅ–%  CLEANUP COM           Aá… D  