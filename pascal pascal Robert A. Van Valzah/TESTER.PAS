(*

  TITLE         Pascal Compiler TESTER program

  FILENAME      TESTER.PAS

  AUTHOR        Robert A. Van Valzah    8/01/80

  LAST REVISOR  Robert A. Van Valzah   15/01/80

  REASON        Added Repeat and While testing

*)

(* check that all legal declaraton syntax is accepted *) 
(* semantics can be checked only by inspection of the
   generated code *)

const
        c1      = 'x';
        c2      = 13;
        c3      = c2;
        c4      = c3+13;
        c5      = c2+c3+c4;
        amax    = 513; (* max array subsript tested *)
        
type
        t1      = c1..c2;
        t2      = 0 ..c2;
        t3      = c1..99;
        t4      = t3;
        t5      = (zero,one,two);
        t6      = 0..99;
        t7      = array [t1] of t6;
        watyp   = array [0..amax] of word;
        aatyp   = array [0..amax] of alfa;

var
        v1      : t1;
        v2,v3   : t2;
        v4      : t6;
        gi      : word; (* global variables used below *)
        gj      : word;
        gwa     : watyp; (* global word array *)
        gaa     : aatyp; (* global alfa array *)
        apatr   : alfa;  (* alfa test pattern *)

procedure fortest;

        var     i : word;

        procedure crlf; (* test nested procedures *)
                begin put#1(13,10) end;

        begin
        put#1('for test',13,10);
        put#1('lcl 1-10');
        for i:=1 to 10 do put#1(' ',i#);
        crlf;
        put#1('gbl 1-10');
        for gi:=1 to 10 do put#1(' ',gi#);
        crlf;
        put#1('lcl 10-1');
        for i:=10 downto 1 do put#1(' ',i#);
        crlf;
        end; (* procedure fortest *)

procedure repttest;

        var     i : word;

        begin
        put#1('rpt 1-10');
        i:=1;
        repeat
                put#1(' ',i#); i:=i+1
        until i>10;
        put#1(13,10)
        end; (* procedure repttest *)

procedure whiltest;

        var     i : word;

        begin
        put#1('whl 1-10');
        i:=1;
        while i<=10 do begin
                put#1(' ',i#); i:=i+1 end;
        put#1(13,10)
        end; (* procedure whiltest *)

procedure simpvar; (* test simple variables *)

        var     i,j : word;
                a,b : alfa;

        begin
        put#1('testing ','simpvars',13,10);
        i:=513;j:=1027; (* adjacent vars unique? *)
        if i<>513 then put#1('nope  i=',i#);
        if j<>1027 then put#1('nope  j=',j#);
        a:='abcdefgh';
        if a<>'abcdefgh' then put#1('alfacmpr');
        (* test simple alfa subscripting hack *)
        a[2]:='5'+'6'*256; (* a should = 'abcd56gh' *)
(*
        if (a<>'abcd56gh') or (a[2]<>'5'+'6'*256) then
                put#1('alfa sub')
*)
        end; (* simpvar *)

procedure arytest; (* test array variables *)

        var     i: word; (* index to test arrays *)

        (* return word array test data based on subscript *)
        function pattern(i: word);

                begin pattern:=amax-i+13 end;

        procedure wordary; (* test word arrays *)

                var     lwa: watyp; (* local word array *)

                begin
                put#1('lwordary');
                (* fill array with test pattern *)
                for i:=0 to amax do lwa[i]:=pattern(i);
                for i:=0 to amax do
                  if lwa[i]<>pattern(i) then
                    put#1('lwa fail',i#);
                for i:=0 to amax do gwa[i]:=pattern(i);
                for i:=0 to amax do
                  if gwa[i]<>pattern(i) then
                    put#1('gwa fail ',i#);
                put#1(13,10)
                end; (* procedure wordary *)

        procedure alfaary; (* test alfa arrays *)

                var     laa: aatyp;
                        a: alfa;

                (* return alfa array test data based in apatr *)
                procedure alfapatr(i: word);

                        begin
                        apatr[3]:=i*3;
                        apatr[2]:=i*5;
                        apatr[1]:=i*7;
                        apatr[0]:=i*9
                        end; (* procedure alfapatr *)

                begin (* procedure alfaary *)
                put#1(13,10,'lalfaary');
                for i:=0 to amax do begin
                  put#1('-');
                  alfapatr(i); laa[i]:=apatr end;
                for i:=0 to amax do begin
                  alfapatr(i);
                  if laa[i]<>apatr
                    then put#1('laa fail',i#)
                    else put#1('.') end;

                put#1(13,10,'galfaary');
                for i:=0 to amax do begin
                  put#1('-');
                  alfapatr(i); gaa[i]:=apatr end;
                for i:=0 to amax do begin
                  alfapatr(i);
                  if gaa[i]<>apatr
                    then put#1('gaa fail',i#)
                    else put#1('.') end;
                put#1(13,10)
                end; (* procedure alfaary *)
        
        begin (* procedure arytest *)
        wordary;
        alfaary
        end; (* procedure arytest *)

begin (* main line *)
fortest;
repttest;
whiltest;
simpvar;
arytest;
end.
