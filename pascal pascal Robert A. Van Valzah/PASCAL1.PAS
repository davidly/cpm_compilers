(*

  TITLE         Pascal Compiler (pascal self compiler)

  FILENAME      PASCAL1.PAS

  AUTHOR	Robert A. Van Valzah   9/01/79

  LAST REVISOR  Robert A. Van Valzah   1/05/80

  REASON        Repaired bug in Var parameters

*)

(*
This is a single pass pascal subset compiler.  Source code
is read from the input device and a listing is produced.
A label addressed p-code is used so that forward references
are no problem.  The use of theses labels removes the need for
"backplugging", and with it, the need to keep the generated
p-codes around in core.  This cuts down on memory requirements
and allows the compiler to write the p-code to disk as it is
generated.  The overall design uses recursive descent where
ever possible.

internal structure
==================
The compiler can be broken down into the major functional units
shown in the table below.  In this compiler, code generation is
rolled right in with the parsing routines.  As soon as a valid
construct is recognized, code for it is emitted.

Block nesting and function is shown below.

	FUNCTION		ROUTINE NAME
	========		============
	error processing	error, test
	symbol table routines	enter, position
	token scanner		getsym
	  char scanner		getch, getline, etc.
	semantic routines	block
	  declaritive		const, typ, var dcl
	  statement scanner	statement
	    expression scanner	epxression, sexp, term, factor
main line
*)

const
	vhu	= 0;	(* version number hundreds *)
	vtn	= 0;	(* tens *)
	vun	= 8;	(* units *)
	devrel	= 'r';	(* development or release version *)
	norw	= 29;	(* number of reserved words *)
	al	= 8;	(* length of identifiers *)
	alm1	= 7;	(* length of id minus 1 *)
	llen	= 80;	(* max input line length *)
	symax	= 300;	(* max number of symbol table entrys *)
	ordminchar = 0;	(* minimum legal char ord value *)
	ordmaxchar = 127; (* maximum legal char ord value *)
	intsize	= 2;	(* size of integer in stack units *)
	charsize = 1;	(* size of character *)
	boolsize = 2;	(* size of boolean *)
	alfasize = 8;	(* size of alfa *)
	true	= 1;	(* kludge until implemented in compiler *)
	false	= 0;

type	symbol	= (	(* symbol tokens *)
		nul, ident, number, charcon,
		plus, minus, times,
		slash, eql, lss, gtr, lparen, rparen,
		comma, semicolon, period, lbrack, rbrack,
		colon, pound,
		andsym, arraysym,
		beginsym, casesym, constsym,
		divsym, dosym, downtosym, elsesym,
		endsym, forsym, funcsym, getsy,
		ifsym, modsym, notsym, ofsym,
		orsym, procsym, progsym, putsym, recordsym,
		repeatsym, thensym, tosym, typesym,
		untilsym, varsym, whilesym
		);
	object	= ( (* types of symbol table entrys *)
		notype, constant, prozedure, funktion,
		simpvar, arrayvar, tipe, simptype, varparm
		);
	pops	= ( (* p-op codes *)
		cal, jpc, jmp, lit, opr, lod, sto, int,
		csp, lodx, stox, alit, alod, asto,
		alodx, astox, pshf, clod, csto,
		clodx, cstox, halt, lab,
		peof, (* end of p-code file *)
		laa, lodi, stoi, clodi, cstoi, alodi, astoi,
		indx, aindx, cindx
		);
	exptyp	= ( (* possible expression types *)
		wurd, alpha, chars, dontcare
		);

	(* define all array types needed
	this is a temporary kludge until the compiler
	will accept arrays in var declarations
	*)

	rwwtyp	= array[0..norw]   of word;
	rwatyp	= array[0..norw]   of alfa;
	alatyp	= array[0..alm1]    of word;
	chatyp	= array[ordminchar..ordmaxchar] of word;
	linetyp	= array[0..llen]   of word;
	statyp	= array[0..symax]  of alfa;
	stwtyp	= array[0..symax]  of word;
	
var
	(* indexed by reserved word number *)
	wsym	: rwwtyp;	(* gives token of type symbol *)
	rword	: rwatyp;	(* holds reserved word in order *)

	(* indexed by ascii character value *)
	ssym	: chatyp;	(* gives token of type sybol *)

	(* indexed by character number 0 .. *)
	ccon	: linetyp;	(* last character constant read *)

	(* symbol table *)
	(* indexed by tx *)
	stname	: statyp;	(* symbol table entry name *)
	stkind	: stwtyp;	(* symbol table entry kind *)
	stlev	: stwtyp;	(* symbol table entry level *)
	stadr	: stwtyp;	(* symbol table address *)
	stlen	: stwtyp;	(* symbol table length *)
	(* stname allways contains name, contents of stkind
	  determines meaning of other arrays:
	  stkind	stlev		stadr		stlen
	  ======	=====		=====		=====
	  constant	0=declared	const value	--
			1=scalar element
	  prozedure	lexical level	label number	parm len
	  funktion	"		"		"
	  simpvar	lexical level	stack disp	length
	  arrayvar	lexical level	base stack disp	type ptr
	  simptype	--		cardinality	length
	  tipe		0=array		element length	total length

	  notes:  type ptr is index of symbol table entry for
	  declared type of array.  this is a kludge to save
	  symbol table space.
	*)

	(* global scanner result variables *)
	cclen	: word;		(* length of last character
				   constant *)
	ch	: word;		(* last character read *)
	sym	: symbol;	(* last symbol read *)
	num	: word;		(* last number read *)
	id	: alfa;		(* last identifier read *)

	(* temp used in getsym *)
	aw	: alatyp;

	(* global pointers *)
	tx	: word;		(* index of last st entry *)
	nl	: word;		(* last assigned label number *)

	errflag	: word;		(* error occured in last line *)
	listing	: word;		(* 13 if no listing wanted *)

	erestyp	: exptyp;	(* result type of expression *)

	(* global variables for procedure getsym for speed *)
	gsi, gsk, gsj	: word;

	(* global variables for function position for speed *)
	posi	: word;

procedure error(n: word); (* parameter is error number *)

	begin
	errflag:=true;
	put#1('>','>',n#,7,'<','<')
	end;

(* scan next token from input stream.  set global variables
based on result of scan.
token scaned
============
identifier	sym=ident, id=<value of identifier>
number		sym=number, num=<value of number>
character const	sym=charcon, cclen=<length of constant>,
		ccon=<characters of constant>
special symbol	sym=<token for special symbol>
resreved word	sym=<token for reserved word>
*)

procedure getsym;
	
	(* see global variables for local var declaration *)

	procedure getch;
	
		begin
		get#0(ch);
		if listing<>13 then put#1(ch);
		if ch>=97 then ch:=ch-32;
		if ch<32 then begin (* this is for speed *)
			if ch=13 then begin
				(* get & ignore the line feed *)
				get#0(ch); if listing<>13 then
				  put#1(ch);
				if errflag=true then begin
				  errflag:=false;
				  put#1('********',13,10);
				  get#1(ch)
				  end
				end;
			ch:=32
			end
		end; (* getch *)
	
	begin (* getsym *)
	while ch=' ' do getch;
	if (ch>='A') and (ch<='Z') then
		begin (* id or reserved word *)
		gsk:=0;
		repeat	if gsk<al then
				begin
				aw[gsk]:=ch; gsk:=gsk+1
				end;
			getch
		until ((ch<'A')or(ch>'Z'))and((ch<'0')or(ch>'9'));
		(* blank remainder of aw *)
		while gsk<al do begin aw[gsk]:=' '; gsk:=gsk+1 end;
		(* pack aw word array into a alfa simple variable *)
		gsj:=0;
		for gsi:=0 to 3 do begin
			id[gsi]:=aw[gsj]+aw[gsj+1]*256;
			gsj:=gsj+2
			end;
		(* perform binary search for symbol in rword *)
		gsi:=1; gsj:=norw;
		repeat	gsk:=(gsi+gsj)/2;
			if id<=rword[gsk] then gsj:=gsk-1;
			if id>=rword[gsk] then gsi:=gsk+1
		until gsi>gsj;
		if gsi-1>gsj then sym:=wsym[gsk] else sym:=ident
		end
	else if (ch>='0') and (ch<='9') then begin (* number *)
		num:=0; sym:=number;
		repeat num:=num*10+(ch-'0'); getch
		until (ch<'0') or (ch>'9')
		end
	else if ch='(' then begin
		getch;
		if ch='*' then begin (* inside of comment *)
			repeat
				repeat
					getch
				until ch='*';
				getch
			until ch=')';
			getch;
			getsym
			end
		else
			sym:=lparen
		end
	else if ch='''' then begin (* character constant *)
		sym:=charcon; gsk:=0;
		repeat
			repeat
				getch;
				ccon[gsk]:=ch; gsk:=gsk+1
			until ch='''';
			getch
		until ch<>'''';
		cclen:=gsk-1
		end
	else begin (* special symbol *)
		sym:=ssym[ch]; getch
		end
end; (* getsym *)

(* test for present symbol equal to first argument, error
number of second argument is issued if not.  also gets next
symbol if desired symbol was present
*)
procedure test(s1, errn: word);

	begin
	if sym<>s1 then
		error(errn)
	else
		getsym
	end;

(* emit the p-instruction passed in the arguments.
*)
procedure gen(op: pops; lev,adr: word);

	begin
	put#0(op, lev, adr, adr/256)
	end; (* gen *)

(* enter an identifier into the symbol table with the
attributes passed as arguments
*)
procedure enter(nam: alfa; kind,lev,adr,len: word);

	begin
	tx:=tx+1;
	if tx>symax then put#1('*SY OVER')
	else begin
		stname[tx]:=nam; stkind[tx]:=kind;
		stlev[tx]:=lev; stadr[tx]:=adr;
		stlen[tx]:=len
		end
	end; (* enter *)

(* returns the symbol table index of the identifier in id.
gives error 104 if not found and returns 0.
*)
function position;
	
	(* see global variables for local var declaration *)

	begin
	stname[0]:=id;
	posi:=tx;
	while stname[posi]<>id do posi:=posi-1;
	if posi=0 then error(104);
	position:=posi
	end; (* position *)

(* returns the next available label number *)
function nlab;

	begin
	nl:=nl+1; nlab:=nl
	end;

(* semantic routine to compile a block *)
procedure block(lev, plab: word);

	var	(* values returned by typ *)
		ttype	: object; (* type type (simple or not) *)
		tadr	: word;
		tlen	: word;

		dx	: word; (* data allocation index *)
		px	: word; (* parameter allocation index *)
		btype	: object; (* block type (func or proc) *)
		tx0	: word;	(* table index at start of block *)
		tx1	: word;	(* table index at start of
				nested proc/func *)
		i	: word;	(* temp used in fwd ref *)

	(* emit the p-instruction passed in the first argument,
	taking the level and address from the symbol table
	entry passed in the second argument.
	*)
	procedure genlev(op: pops; i: word);

		var	stl	: word;

		begin
		stl:=stlev[i];
		if stl=1 (* only if global variable ref *)
			then gen(op,255,stadr[i])
			else gen(op,lev-stl,stadr[i])
		end; (* genlev *)

	function compcon; (* returned value is a compile time constant *)

		var 	i	: word;

		begin
		case sym of
		number:	begin compcon:=num; getsym end;
		charcon: begin compcon:=ccon[0]; getsym end;
		ident:	begin
			i:=position;
			if stkind[i]<>constant then error(103);
			compcon:=stadr[i];
			getsym;
			while sym=plus do begin
				getsym;
				compcon:=stadr[i]+compcon
				end
			end (* case ident *)
		else	error(50)
		end (* case sym of *)
		end; (* function compcon *)

	procedure constdcl;

		var	ctx	: word;

		begin
		test(ident,2);
		enter(id,constant,0,0,0);
		ctx:=tx;
		test(eql,16);
		stadr[ctx]:=compcon
		end; (* constdcl *)

	procedure typ;

		var	scard	: word; (* array subscript cardinality *)

		procedure styp;

			var	i	: word;

			begin
			ttype:=simptype;
			if sym=ident then begin
				i:=position;
				if (stkind[i]=simptype) or
				   (stkind[i]=tipe) then begin
				  ttype:=stkind[i];
				  tadr:=stadr[i];
				  tlen:=stlen[i];
				  getsym
				  end
				else if stkind[i]=constant then begin
				  i:=compcon;
				  test(period,20); test(period,20);
				  tadr:=compcon-i+1; tlen:=intsize
				  end
				else error(103)
				end
			else if sym=lparen then begin
				i:=0;
				repeat
				  getsym;
				  test(ident,2);
				  enter(id,constant,intsize,i,0);
				  i:=i+1
				until sym<>comma;
				tadr:=i; tlen:=intsize;
				test(rparen,4)
				end
			else begin
				i:=compcon;
				test(period,20);
				test(period,20);
				tadr:=compcon-i+1; tlen:=intsize
				end
			end; (* styp *)

		begin (* typ *)
		if sym<>arraysym then styp
		else begin
			getsym; test(lbrack,11);
			styp; scard:=tadr; (* save subscript cardinality *)
			test(rbrack,12);
			test(ofsym,8); styp;
			ttype:=tipe;
			tadr:=tlen; tlen:=tlen*scard
			end
		end; (* typ *)

	procedure typedcl;

		var	tid	: alfa; (* type identifer *)

		begin
		test(ident,2);
		tid:=id;
		test(eql,16);
		typ;
		enter(tid,ttype,lev,tadr,tlen)
		end; (* typdcl *)

	procedure vardcl;

		var	i	: word;
			tx0	: word;
			tlen	: word; (* total length *)
			vkind	: word; (* variable type *)
			len	: word;

		begin
		test(ident,2);
		enter(id,notype,lev,0,0);
		tx0:=tx;
		while sym=comma do begin
			getsym;
			test(ident,2);
			enter(id,notype,lev,0,0)
			end;
		test(colon,5);
		test(ident,2);
		i:=position;
		tlen:=stlen[i]; (* total length of variable *)
		vkind:=stkind[i];
		if vkind=simptype then begin
			vkind:=simpvar;
			len:=tlen
			end
		else if vkind=tipe then begin
			vkind:=arrayvar;
			len:=i (* pointer to array type info *)
			end
		else error(103);
		for i:=tx0 to tx do begin
			stkind[i]:=vkind; stlen[i]:=len;
			if lev=1 then stadr[i]:=dx
			else	stadr[i]:=dx+tlen;
			dx:=dx+tlen
			end
		end; (* vardcl *)

	procedure statement;

		var	i, elab, flab, tlab, op, updn	: word;

		procedure expression; forward;

		procedure call(i: word);

		var	j	: word;

		begin
		getsym;
		if sym=lparen then begin
			getsym;
			if sym<>varsym then begin
				expression(dontcare);
				while sym=comma do begin
				  getsym;
				  expression(dontcare)
				  end
				end
			else (* procedure has var parameters *)
				repeat
				  getsym; test(ident,2);
				  j:=position;
				  if stkind[j]=varparm
				    then genlev(lod,j)
				    else genlev(laa,j)
				until sym<>comma;
			test(rparen,4)
			end;
		gen(cal,lev-stlev[i],stadr[i]);
		gen(int,0,0-stlen[i])
		end; (* procedure call *)

		procedure expression(etyp: exptyp); backward;

		procedure chetyp(destyp: exptyp);

			begin
			if etyp=dontcare then
				etyp:=destyp
			else if etyp<>destyp then
				error(129)
			end; (* chetyp *)

		procedure sexp;

		var	addop	: symbol;

		procedure term;

		var	mulop	: symbol;

		procedure factor;

			var	i	: word;
				op	: pops;

			begin (* factor *)
			case sym of
			number:	begin (* load constant *)
				gen(lit,0,num);
				chetyp(wurd);
				getsym
				end; (* case number *)
			charcon: begin (* load string literal *)
				if cclen=1 then begin
					gen(lit,0,ccon[0]);
					chetyp(wurd) end
				else begin
					chetyp(alpha);
					gen(alit,0,0);
					gen(ccon[7],ccon[6],
					 ccon[5]+ccon[4]*256);
					gen(ccon[3],ccon[2],
					 ccon[1]+ccon[0]*256)
					end;
				getsym
				end; (* case charcon *)
			lparen:	begin (* get sub expression *)
				getsym; expression(etyp);
				chetyp(erestyp);
				test(rparen,4)
				end; (* case lparen *)
			ident:	begin
				i:=position;
				case stkind[i] of
				arrayvar: begin (* index into array var *)
				  getsym;
				  test(lbrack,11);
				  expression(wurd);
				  test(rbrack,12);
				  case stadr[stlen[i]] of
				  intsize: begin
				    op:=lodx; chetyp(wurd) end;
				  alfasize: begin
				    op:=alodx; chetyp(alpha) end;
				  charsize: begin
				    op:=clodx; chetyp(wurd) end
				  end; (* case *)
				  genlev(op,i);
				  end; (* case arrayvar *)
				constant: begin (* load constant *)
				  gen(lit,0,stadr[i]);
				  chetyp(wurd);
				  getsym
				  end; (* case constant *)
				varparm: begin (* load from var parameter *)
				  getsym; genlev(lod,i);
				  gen(lodi,0,0);
				  chetyp(wurd)
				  end; (* case varparm *)
				simpvar: begin (* load from simple var *)
				  getsym;
				  case stlen[i] of
				  intsize:  begin
				    op:=lod; chetyp(wurd) end;
				  alfasize: 
				    if sym=lbrack then begin
				      getsym; expression(wurd);
				      test(rbrack,12); op:=lodx;
				      chetyp(wurd) end
				    else begin
				      op:=alod; chetyp(alpha)
				      end;
				  charsize: begin
				    op:=clod; chetyp(wurd) end
				  end; (* case stlen[i] *)
				  genlev(op,i)
				  end; (* case simpvar *)
				funktion: begin (* function reference *)
				    gen(int,0,intsize);
				    call(i);
				    chetyp(wurd)
				  end (* case funktion *)
				end (* case stkind[i] of *)
				end (* case ident *)
			else	error(58)
			end (* case sym of *)
			end; (* factor *)

			begin (* term *)
			factor;
			while (sym=times) or (sym=slash) or
				(sym=andsym) do begin
				if sym=andsym then
					gen(pshf,0,0);
				mulop:=sym;
				getsym; factor;
				if mulop=times then gen(opr,0,4)
				else if mulop=slash then gen(opr,0,5)
				else gen(opr,0,15)
				end
			end; (* term *)

			begin (* sexp *)
			if (sym=plus) or (sym=minus) then begin
				addop:=sym; getsym; term;
				if addop=minus then gen(opr,0,1)
				end
			else term;
			while (sym=plus) or (sym=minus) or
				(sym=orsym) do begin
				if sym=orsym then
					gen(pshf,0,0);
				addop:=sym; getsym; term;
				if addop=plus then gen(opr,0,2)
				else if addop=minus then gen(opr,0,3)
				else gen(opr,0,14)
				end
			end; (* sexp *)

			begin (* expression *)
			sexp;
			if sym=lss then begin
				getsym;
				if sym=eql then begin
					getsym; sexp;
					gen(opr,etyp,13) end
				else if sym=gtr then begin
					getsym; sexp;
					gen(opr,etyp,9) end
				else begin
					sexp; gen(opr,etyp,10) end
				end
			else if sym=gtr then begin
				getsym;
				if sym=eql then begin
					getsym; sexp;
					gen(opr,etyp,11) end
				else begin
					sexp; gen(opr,etyp,12) end
				end
			else if sym=eql then begin
				getsym; sexp; gen(opr,etyp,8) end;
			erestyp:=etyp
			end; (* expression *)

		begin (* statement *)
		case sym of
		ident:	begin (* could be anything *)
			i:=position;
			case stkind[i] of
			arrayvar: begin (* array assignment *)
				getsym; test(lbrack,11);
				expression(wurd);
				test(rbrack,12);
				test(colon,51); test(eql,51);
				expression(dontcare);
				case stadr[stlen[i]] of
				charsize: op:=cstox;
				intsize:  op:=stox;
				alfasize: op:=astox
				end; (* case stadr[stlen[i]] of *)
				genlev(op,i)
				end; (* case arrayvar *)
			varparm: begin (* var parameter assignment *)
				getsym; genlev(lod,i);
				test(colon,51); test(eql,51);
				expression(dontcare);
				gen(stoi,0,0)
				end; (* case varparm *)
			simpvar: begin (* simple variable assignment *)
				getsym;
				if sym=lbrack then begin
				  getsym; expression(dontcare);
				  test(rbrack,12) end;
				test(colon,51); test(eql,51);
				expression(dontcare);
				if erestyp=wurd then
				  case stlen[i] of
				  alfasize: op:=stox;
				  intsize:  op:=sto;
				  charsize: op:=csto
				  end (* case stlen[i] of *)
				else op:=asto;
				genlev(op,i)
				end; (* case simpvar *)
			prozedure: begin (* procedure call *)
				call(i)
				end; (* case prozedure *)
			funktion: begin (* function return value *)
				getsym;
				test(colon,51); test(eql,51);
				expression(dontcare);
				gen(sto,0,0-stlen[i]-6)
				end (* case funktion *)
			else error(103)
			end (* case stkind[i] *)
			end; (* case ident *)
		ifsym:	begin getsym; expression(dontcare);
			test(thensym,52);
			flab:=nlab; gen(jpc,0,flab);
			statement;
			if sym=elsesym then begin
				elab:=nlab; gen(jmp,0,elab);
				gen(lab,0,flab);
				getsym;
				statement;
				gen(lab,0,elab)
				end
			else gen(lab,0,flab)
			end; (* case ifsym *)
		forsym:	begin getsym;
			test(ident,2); i:=position;
			test(colon,51); test(eql,51);
			expression(dontcare);
			genlev(sto,i);
			if sym=tosym then begin
				getsym; updn:=19; op:=11 end
			else if sym=downtosym then begin
				getsym; updn:=20; op:=13 end
			else error(55);
			expression(dontcare);
			test(dosym,54);
			tlab:=nlab; gen(lab,0,tlab);
			gen(opr,0,21);
			genlev(lod,i);
			gen(opr,0,op);
			elab:=nlab; gen(jpc,0,elab);
			statement;
			genlev(lod,i);
			gen(opr,0,updn);
			genlev(sto,i);
			gen(jmp,0,tlab);
			gen(lab,0,elab); gen(int,0,0-intsize)
			end; (* case forsym *)
		repeatsym: begin
			tlab:=nlab; gen(lab,0,tlab);
			repeat
				getsym; statement
			until sym<>semicolon;
			test(untilsym,53); expression(dontcare);
			gen(jpc,0,tlab)
			end; (* case repeatsym *)
		casesym: begin
			getsym; expression(dontcare);
			if sym<>ofsym then error(8);
			elab:=nlab; (* end label *)
			repeat
				getsym;
				gen(opr,0,21); (* dup *)
				gen(lit,0,compcon);
				test(colon,5);
				gen(opr,0,8); (* equal relop *)
				flab:=nlab; gen(jpc,0,flab);
				statement;
				gen(jmp,0,elab);
				gen(lab,0,flab)
			until (sym=elsesym) or (sym=endsym);
			if sym=elsesym then begin
				getsym;
				statement
				end;
			test(endsym,13);
			gen(lab,0,elab);
			gen(int,0,0-intsize)
			end; (* case casesym *)
		getsy:	begin
			getsym; test(pound,99);
			i:=compcon;
			test(lparen,9); test(ident,2);
			gen(csp,i,0);
			i:=position;
			genlev(sto,i);
			test(rparen,4)
			end; (* case getsy *)
		putsym:	begin
			getsym;
			test(pound,99);
			i:=compcon;
			if sym<>lparen then error(9);
			repeat
				getsym; expression(dontcare);
				if erestyp=wurd then op:=1
				else op:=8;
				if sym=pound then begin
					getsym; op:=3 end;
				gen(csp,i,op)
			until sym<>comma;
			test(rparen,4)
			end; (* case putsym *)
		beginsym: begin
			repeat
				getsym; statement
			until sym<>semicolon;
			test(endsym,13)
			end; (* case beginsym *)
		whilesym: begin
			getsym;
			tlab:=nlab; gen(lab,0,tlab);
			expression(dontcare);
			elab:=nlab;
			gen(jpc,0,elab);
			test(dosym,54);
			statement;
			gen(jmp,0,tlab); gen(lab,0,elab);
			end (* case whilesym *)
		end (* case *)
		end; (* statement *)

	(* scan a parameter list for a func or proc call and
	allocate variables for parameters
	*)
	procedure plist;

		var	tx0, tx1, i, j	: word;
			ptyp		: object;

		begin
		tx0:=tx;
		repeat
			tx1:=tx;
			ptyp:=notype;
			repeat
				getsym;
				if sym=varsym then begin
					getsym; ptyp:=varparm
					end;
				test(ident,2);
				enter(id,notype,lev+1,0,0)
			until sym<>comma;
			test(colon,5);
			test(ident,2);
			i:=position;
			if ptyp=notype then
				if stkind[i]=simptype
					then ptyp:=simpvar
					else ptyp:=arrayvar;
			for j:=tx1+1 to tx do begin
				stkind[j]:=ptyp;
				stlen[j]:=stlen[i];
				stadr[j]:=px+stlen[i]-6;
				px:=px+stlen[i]
				end;
		until sym<>semicolon;
		for j:=tx0+1 to tx do
			stadr[j]:=stadr[j]-px;
		test(rparen,4)
		end; (* plist *)

	begin (* block *)
	dx:=0; tx0:=tx;
	if sym=constsym then begin
		getsym;
		repeat
			constdcl;
			test(semicolon,14)
		until sym<>ident
		end;
	if sym=typesym then begin
		getsym;
		repeat
			typedcl;
			test(semicolon,14)
		until sym<>ident
		end;
	if sym=varsym then begin
		getsym;
		repeat
			vardcl;
			test(semicolon,14)
		until sym<>ident
		end;
	while (sym=procsym) or (sym=funcsym) do begin
		if sym=procsym
			then btype:=prozedure
			else btype:=funktion;
		getsym;
		enter(id,btype,lev,nlab,0);
		test(ident,2);
		tx1:=tx; px:=0;
		if sym=lparen then plist;
		stlen[tx1]:=px; (* arg len into proc *)
		test(semicolon,14);
		if id='FORWARD '
		then getsym
		else
			if id='BACKWARD' then begin
				getsym;
				test(semicolon,14);
				i:=1; id:=stname[tx1];
				while id<>stname[i] do
					i:=i+1;
				stname[i]:='********';
				stadr[tx1]:=stadr[i];
				block(lev+1,stadr[i])
				end
			else
				block(lev+1,nl);
		tx:=tx1; (* leave only proc name in table *)
		test(semicolon,14)
		end;
	test(beginsym,17);
	gen(lab,0,plab);
	if lev<>1 then gen(int,0,dx);
	statement;
	while sym=semicolon do begin
		getsym;
		statement
		end;
	if lev<>1 then gen(opr,0,0);
	test(endsym,13);
	if sym=comma then begin
		getsym;
		for tx1:=1 to tx do
			put#1(13,10,tx1#, ' ',stname[tx1],
			' ',stkind[tx1]#, ' ',stlev[tx1]#,
			' ', stadr[tx1]#, ' ',stlen[tx1]#)
		end;
	tx:=tx0
	end; (* block *)

	begin (* main line *)
	(* init special symbol token array *)
	for ch:=ordminchar to ordmaxchar do ssym[ch]:=nul;
	ssym['+']:=plus;	ssym['-']:=minus;
	ssym['*']:=times;	ssym['/']:=slash;
	ssym[':']:=colon;	ssym[';']:=semicolon;
	ssym['=']:=eql;		ssym['#']:=pound;
	ssym['<']:=lss;		ssym['>']:=gtr;
	ssym['(']:=lparen;	ssym[')']:=rparen;
	ssym['[']:=lbrack;	ssym[']']:=rbrack;
	ssym['.']:=period;	ssym[',']:=comma;

	(* init reserved word arrays *)
	(* must be in alpahbetical order for binary search *)
	rword[ 1]:='AND     ';	wsym[ 1]:=andsym;
	rword[ 2]:='ARRAY   ';	wsym[ 2]:=arraysym;
	rword[ 3]:='BEGIN   ';	wsym[ 3]:=beginsym;
	rword[ 4]:='CASE    ';	wsym[ 4]:=casesym;
	rword[ 5]:='CONST   ';	wsym[ 5]:=constsym;
	rword[ 6]:='DIV     ';	wsym[ 6]:=divsym;
	rword[ 7]:='DO      ';	wsym[ 7]:=dosym;
	rword[ 8]:='DOWNTO  ';	wsym[ 8]:=downtosym;
	rword[ 9]:='ELSE    ';	wsym[ 9]:=elsesym;
	rword[10]:='END     ';	wsym[10]:=endsym;
	rword[11]:='FOR     ';	wsym[11]:=forsym;
	rword[12]:='FUNCTION';	wsym[12]:=funcsym;
	rword[13]:='GET     ';	wsym[13]:=getsy;
	rword[14]:='IF      ';	wsym[14]:=ifsym;
	rword[15]:='MOD     ';	wsym[15]:=modsym;
	rword[16]:='NOT     ';	wsym[16]:=notsym;
	rword[17]:='OF      ';	wsym[17]:=ofsym;
	rword[18]:='OR      ';	wsym[18]:=orsym;
	rword[19]:='PROCEDUR';	wsym[19]:=procsym;
	rword[20]:='PROGRAM ';	wsym[20]:=progsym;
	rword[21]:='PUT     ';	wsym[21]:=putsym;
	rword[22]:='RECORD  ';	wsym[22]:=recordsym;
	rword[23]:='REPEAT  ';	wsym[23]:=repeatsym;
	rword[24]:='THEN    ';	wsym[24]:=thensym;
	rword[25]:='TO      ';	wsym[25]:=tosym;
	rword[26]:='TYPE    ';	wsym[26]:=typesym;
	rword[27]:='UNTIL   ';	wsym[27]:=untilsym;
	rword[28]:='VAR     ';	wsym[28]:=varsym;
	rword[29]:='WHILE   ';	wsym[29]:=whilesym;

	errflag:=false; (* clear line error flag *)
	tx:=0; (* init table pointers *)
	put#1('ppc rev ',vhu#,'.',vtn#,vun#,devrel,13,10);
	put#1('Listing?'); get#1(listing);

	(* define standard type identifiers *)
	enter('INTEGER ',simptype,0,0,intsize);
	enter('CHAR    ',simptype,0,0,charsize);
	enter('BOOLEAN ',simptype,0,0,boolsize);
	enter('BYTE    ',simptype,0,0,charsize);
	enter('WORD    ',simptype,0,0,intsize);
	enter('ALFA    ',simptype,0,0,alfasize);
	ch:=' '; (* init the character scanner *)
	getsym;
	nl:=1; gen(jmp,0,1);
	block(1,1);
	gen(csp,0,9);
	gen(peof,0,0);
	if sym<> period then error(20)
end.
eof
