(*

  TITLE         Pascal Fast Execution Translator

  FILENAME      PASCAL2.PAS

  AUTHOR        Robert A. Van Valzah    6/10/79

  LAST REVISOR  Robert A. Van Valzah   14/01/80

  REASON        Repaired bug in Astoi code

*)

const
	vhu	= 0;	(* version number hundreds *)
	vtn	= 0;	(* tens *)
	vun	= 8;	(* units *)
	devrel	= 'r';	(* development or release version *)
	nlab	= 500;	(* max number of p-labels *)
	codemax	= 5000;	(* max number of p-instructions *)
	ocode	= 1536;	(* object code base address *)
	rtporg	= 256;	(* run time package base address *)

	(* runtime package entry points *)
	base	= rtporg+3;	cmpr	= base+3;
	cspbase	= cmpr+3;	spalit	= cspbase+30;
	spalod	= spalit+3;	spasto	= spalod+3;
	acmpr	= spasto+3;	opr3	= acmpr+3;
	opr4	= opr3+3;	opr5	= opr4+3;
	opr14	= opr5+3;	opr15	= opr14+3;
	spcal0	= opr15+3;	spcal	= spcal0+3;
	spret	= spcal+3;	br	= spret+3;

	(* 8080 instructions *)
	lhld	= 42;	shld	= 34;
	pushh	= 229;	pushd	= 213;
	pushb	= 197;	pushpsw	= 245;
	poph	= 225;	popd	= 209;
	popb	= 193;

	sphl	= 249;	pchl	= 233;
	xchg	= 235;	xthl	= 227;

	dadh	= 41;	dadsp	= 57;
	dadd	= 25;	dadb	= 9;

	call	= 205;	jmp	= 195;
	jz	= 202;	jnz	= 194;
	jnc	= 210;	jc	= 218;

	mvia	= 62;	adi	= 198;
	mvid	= 22;

	lxih	= 33;	lxid	= 17;
	lxib	= 1;

	movem	= 94;	movdm	= 86;
	movme	= 115;	movmd	= 114;
	movbh	= 68;	movcl	= 77;
	movam	= 126;	movhm	= 102;
	movla	= 111;	movae	= 123;
	cmc	= 63;	sbba	= 159;
	dcra	= 61;	orad	= 178;
	anad	= 162;

	inxsp	= 51;	dcxsp	= 59;
	dcxh	= 43;	inxh	= 35;
type
	pops	= ( (* p-op codes *)
		cal, jpc, jump, lit, opr, lod, sto, int,
		csp, lodx, stox, alit, alod, asto,
		alodx, astox, pshf, clod, csto,
		clodx, cstox, halt, lab,
		peof, (* end of p-code file *)
		laa, lodi, stoi, clodi, cstoi, alodi, astoi,
		indx, aindx, cindx
		);
	fflags	= ( (* flags set when condition is false *)
		ifnz, ifz, ifcz, ifznc, ifnc, ifc
		);
	labtyp	= array[0..nlab] of word;
	codtyp	= array[0..codemax] of word;

var
	label	: labtyp;	(* label p-addresses *)
	adr	: labtyp;	(* label 8080 addresses *)
	fla	: codtyp;	(* p-code function & level *)
	aa	: codtyp;	(* p-code address *)
	f	: word;		(* current instruction function *)
	l	: word;		(* current instruction level *)
	a	: word;		(* current instruction address *)
	coa	: word;		(* code out address *)
	cx	: word;		(* p-code array index *)
	cix	: word;		(* number of p-codes read *)
	glram	: word;		(* base address of global ram *)
	pass	: word;		(* pass number *)
	lfl	: fflags;	(* flags set when last
				translated conditional is
				false *)
	
	(* global variables for procedure getpcd for speed *)
	adlo, adhi	: word;

	(* global variables for function eieiadr for speed *)
	eii, eij, eik	: word;

	(* global variables for procedure trans for speed *)
	transi	: word;

procedure co1b(ch: word);

	begin
	coa:=coa+1;
	if pass=2 then put#0(ch)
	end; (* co1b *)

procedure co2b(c1,c2: word);

	begin
	coa:=coa+2;
	if pass=2 then put#0(c1,c2)
	end; (* co2b *)

procedure co3b(c1,c2,c3: word);

	begin
	coa:=coa+3;
	if pass=2 then put#0(c1,c2,c3)
	end; (* co3b *)

procedure co4b(c1,c2,c3,c4: word);

	begin
	coa:=coa+4;
	if pass=2 then put#0(c1,c2,c3,c4)
	end; (* co4b *)

procedure coad(ad: word);

	begin
	co1b(ad); co1b(ad/256)
	end; (* coad *)

procedure coopad(op,ad: word);

	begin
	co1b(op); coad(ad)
	end; (* coopad *)

procedure getpcd; (* get next p-code to f, l, and a *)

	begin
	if pass=1 then begin
		if cix>codemax then put#1('*cd over');
		get#0(f);
		get#0(l);
		fla[cix]:=f+l*256;
		get#0(adlo); get#0(adhi);
		a:=adlo+adhi*256;
		aa[cix]:=a;
		cix:=cix+1
		end
	else begin (* must be pass 2 *)
		a:=fla[cx]; (* use a as a temp *)
		l:=a/256; f:=a-l*256;
		a:=aa[cx];
		cx:=cx+1
		end
	end; (* getpcd *)

procedure wrsym;

	var 	i	: word;

	begin
	for i:=0 to nlab do begin
		put#1('P',label[i]#);
		put#1(' ',adr[i]#);
		put#1(13,10)
		end
	end; (* wrsym *)

procedure gencmp;

	begin
	if l=0
		then coopad(call,cmpr)
		else coopad(call,acmpr)
	end; (* gencmp *)

procedure varadr;

	var	lev	: word;

	begin
	lev:=l;
	if lev=0 then begin (* local ref *)
		coopad(lxib,0-a);
		coopad(lhld,br); co1b(dadb)
		end
	else if lev=255 then (* global ref *)
		coopad(lxih,a+glram)
	else begin (* intermediate ref *)
		co2b(mvia,lev);
		coopad(call,base); coopad(lxid,0-a);
		co1b(dadd)
		end
	end; (* varadr *)

function eieiadr(pad: word (* p-code address *) );

	begin
	if pass=2 then
		if adr[pad]<>0 then eieiadr:=adr[pad]
		else put#1('P',pad#,'undefind',13,10)
	end; (* eieiadr *)

procedure dw2;

	begin
	co4b(f, l, a, a/256)
	end; (* dw2 *)

procedure flagtoa;

	begin
	case lfl of
	ifnz:	begin
		co4b(adi, 255, cmc, sbba)
		end; (* ifnz *)
	ifz:	begin
		co3b(adi, 255, sbba)
		end; (* ifz *)
	ifcz:	begin
		co2b(mvia, 0);
		coopad(jc,coa+7); coopad(jz,coa+4); co1b(dcra)
		end; (* ifcz *)
	ifznc:	begin
		co2b(mvia, 0);
		coopad(jz,coa+6); coopad(jnc,coa+4); co1b(dcra)
		end; (* ifznc *)
	ifnc:	co1b(sbba);
	ifc:	begin
		co2b(cmc, sbba)
		end (* ifc *)
	end (* case lfl of *)
	end; (* flagtoa *)

procedure trans;

	begin
	case f of
	lit:	begin
		coopad(lxih,a); co1b(pushh)
		end;
	opr:	case a of
		0:	(* procedure return *)
			coopad(jmp,spret);
		2:	(* (top)=(top)+(top-1) *)
			begin
			co4b(popd, poph, dadd, pushh)
			end; (* case opr sub *)
		3:	(* (top)=(top)-(top-1) *)
			coopad(call,opr3);
		4:	(* multiply *)
			coopad(call,opr4);
		5:	(* divide *)
			coopad(call,opr5);
		8:	begin (* (top)=(top-1) conditional *)
			gencmp; lfl:=ifnz
			end; (* opr 8 *)
		9:	begin (* (top)<>(top-1) condtional *)
			gencmp; lfl:=ifz
			end; (* opr 9 *)
		10:	begin (* (top)<(top-1) conditinal *)
			gencmp; lfl:=ifcz
			end; (* opr 10 *)
		11:	begin (* (top-1)>=(top) conditonal *)
			gencmp; lfl:=ifznc
			end; (* opr 11 *)
		12:	begin (* (top-1)>(top) conditionla *)
			gencmp; lfl:=ifnc
			end; (* opr 12 *)
		13:	begin (* (top-1)<=(top) conditional *)
			gencmp; lfl:=ifc
			end; (* opr 13 *)
		14:	begin (* (top)=(top-1) or (top) *)
			flagtoa; co2b(popd, orad);
			lfl:=ifz
			end; (* opr 14 *)
		15:	begin (* (top)=(top-1) and (top) *)
			flagtoa; co2b(popd, anad);
			lfl:=ifz
			end; (* opr 15 *)
		19:	begin (* increment (top) *)
			co3b(poph, inxh, pushh);
			lfl:=ifz
			end; (* opr 19 *)
		20:	begin (* decrement (top) *)
			co3b(poph, dcxh, pushh)
			end; (* opr 20 *)
		21:	begin (* copy (top) *)
			co3b(poph, pushh, pushh)
			end (* case opr 21 *)
		else	put#1('bad opr ',a#,13,10)
		end; (* case opr *)
	lod:	begin
		if l=255 then begin (* global lod *)
			coopad(lhld,a+glram);
			co1b(pushh)
			end (* global *)
		else begin (* intermediate to local *)
			varadr; co4b(movem, inxh, movdm, pushd);
			end
		end; (* case lod *)
	sto:	begin
		if l=255 then begin (* global sto *)
			co1b(poph);
			coopad(shld,a+glram)
			end
		else begin (* intermediate to local *)
			varadr; co4b(popd, movme, inxh, movmd)
			end
		end; (* sto *)
	cal:	begin
		coopad(lxid,eieiadr(a));
		if l=0
			then coopad(call,spcal0)
			else begin
				co2b(mvia, l);
				coopad(call,spcal)
				end;
		end; (* cal *)
	int:	begin
		if (a>=0-4) and (a<=4) then begin
			for transi:= 1 to a do
				co1b(dcxsp);
			for transi:= 0-1 downto a do
				co1b(inxsp)
			end
		else begin
			coopad(lxih,0-a);
			co2b(dadsp, sphl)
			end
		end; (* int *)
	jump:	begin
		coopad(jmp,eieiadr(a))
		end; (* jump *)
	jpc:	begin
		case lfl of
		ifnz:	coopad(jnz,eieiadr(a));
		ifz:	coopad(jz,eieiadr(a));
		ifcz:	begin
			coopad(jc,eieiadr(a));
			coopad(jz,eieiadr(a))
			end; (* ifcz *)
		ifznc:	begin
			coopad(jz,coa+6);
			coopad(jnc,eieiadr(a))
			end; (* ifznc *)
		ifnc:	coopad(jnc,eieiadr(a));
		ifc:	coopad(jc,eieiadr(a))
		end (* case lfl of *)
		end; (* jpc *)
	pshf:	begin
		flagtoa; co1b(pushpsw)
		end; (* pushf *)
	csp:	begin
		co2b(mvia, l);
		coopad(call,cspbase+3*a)
		end; (* csp *)
	lodx:	begin
		varadr; co4b(popd, dadd, dadd, movem);
		co3b(inxh, movdm, pushd)
		end; (* lodx *)
	stox:	begin
		varadr; co4b(popd, popb, dadb, dadb);
		co3b(movme, inxh, movmd)
		end; (* stox *)
	indx:	begin (* index word array *)
		co4b(poph, dadh, popd, dadd);
		co1b(pushh)
		end; (* case indx *)
	clod:	begin
		varadr; co3b(movdm, pushd, inxsp);
		end; (* clod *)
	csto:	begin
		varadr; co3b(popd, dcxsp, movme)
		end; (* csto *)
	clodi:	begin (* character load indirect *)
		co4b(poph, movdm, pushd, inxsp)
		end; (* case clodi *)
	cstoi:	begin (* character store indirect *)
		co4b(popd, dcxsp, poph, movme)
		end; (* case cstoi *)
	cindx:	begin (* character array index *)
		co4b(poph, popd, dadd, pushh)
		end; (* case cindx *)
	clodx:	begin
		varadr; co3b(popd, dadd, movem);
		co3b(mvid, 0, pushd)
		end; (* clodx *)
	cstox:	begin
		varadr; co4b(popd, popb, dadb, movme)
		end; (* cstox *)
	alit:	begin
		coopad(call,spalit);
		getpcd; dw2;
		getpcd; dw2
		end;
	alod:	begin
		varadr; coopad(call,spalod)
		end; (* alod *)
	asto:	begin
		varadr; coopad(call,spasto)
		end; (* asto *)
	aindx:	begin
		co4b(poph, dadh, dadh, dadh);
		co3b(popd, dadd, pushh)
		end; (* case aindx *)
	alodi:	begin (* alfa load indirect *)
		co1b(poph); coopad(call,spalod)
		end; (* case alodi *)
	astoi:	begin (* alfa store indirect *)
		coopad(lxih,8);
		co4b(dadsp, movam, inxh, movhm);
		co1b(movla); coopad(call,spasto);
		co1b(poph)
		end; (* case astoi *)
	alodx:	begin
		varadr; co3b(popd, xchg, dadh);
		co3b(dadh, dadh, dadd);
		coopad(call,spalod)
		end; (* alodx *)
	astox:	begin
		varadr; co1b(xchg); coopad(lxih,8);
		co4b(dadsp, movam, inxh, movhm);
		co3b(movla, dadh, dadh);
		co2b(dadh, dadd); coopad(call,spasto);
		co1b(poph)
		end; (* case astox *)
	laa:	begin
		varadr; co1b(pushh)
		end; (* case laa *)
	lodi:	begin (* load word indirect *)
		co4b(poph,movem,inxh,movdm);
		co1b(pushd)
		end; (* case lodi *)
	stoi:	begin (* store word indirect *)
		co4b(popd,poph,movme,inxh);
		co1b(movmd)
		end; (* case stoi *)
	peof:	begin (* do nothing *)
		end (* case peof *)
	else	put#1('bad p-op',f#,13,10)
	end (* case f of *)
	end; (* trans *)

procedure pass12(ps: word);

	begin
	pass:=ps;
	coa:=ocode;
	repeat
		getpcd;
		if f<>lab then trans
		else if pass=1 then
				if a>nlab then put#1('*lb over')
				else adr[a]:=coa
			else (* pass = 2 *)
				if adr[a]<>coa then
					put#1('Phase er',
					'ror    P',a#)
	until f=peof;
	if pass=1 then glram:=coa
	end; (* pass12 *)

begin (* main line *)
	(* zero all addresses for undefined label detection *)
	(* use cix as temp index *)
	put#1('pfet rev',' ',vhu#,'.',vtn#,vun#,devrel,13,10);
	for cix:=0 to nlab do adr[cix]:=0;
	cix:=0;
	put#1('Pass 1  ',13,10);
	pass12(1);
	put#1(cix#,' p-codes', ' read   ',13,10);
	cx:=0;
	put#1('Pass 2  ',13,10);
	pass12(2);
	put#1('done!   ',13,10)
end.
