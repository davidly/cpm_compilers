MODULE Test;

(*	Test of pattern match module *)

FROM	Terminal IMPORT WriteString,ReadString,WriteLn;
FROM	Pattern IMPORT NodeType,PNode,CreateStringNode,MatchPattern,CharSet,
			CreateAltNode,CreateStringNode,
			CreateAnyOfNode,CreateConcatNode,CreateLimitNode;
FROM	Storage IMPORT ALLOCATE;
VAR	Exp1,Exp,Term,Fact:PNode;
	temp:PNode;
BEGIN
	NEW(Exp);
	NEW(Term);
	Fact:=CreateAltNode(
		CreateAnyOfNode(CharSet{'A'..'Z','0'..'9','a'..'z'},1,30000,TRUE),
		CreateConcatNode(
			CreateConcatNode(
				CreateStringNode('('),
				Exp),
			CreateStringNode(')')
			)
		);
	temp:=CreateAltNode(
		Fact,
		CreateConcatNode(
			Fact,
			CreateConcatNode(
				CreateStringNode('*'),
				Term)
			)
		);
	Term^:=temp^;
	temp:=CreateAltNode(
		    Term,
		    CreateConcatNode(
			Term,
			CreateConcatNode(
				CreateStringNode('+'),
				Exp)
			)
		    );
	Exp^:=temp^;
	Exp1:=CreateConcatNode(
		Exp,
		CreateLimitNode());
	IF MatchPattern(Exp1,'2*2')<>NIL THEN WriteString('1:  OK') END;
	IF MatchPattern(Exp1,'2+3*2')<>NIL THEN WriteString('2:  OK') END;
	IF MatchPattern(Exp1,'2*(2+3)')<>NIL THEN WriteString('3:  OK') END;
	IF MatchPattern(Exp1,'2*2*3*4')<>NIL THEN WriteString('4:  OK') END;
	IF MatchPattern(Exp1,'2*2+3*7')<>NIL THEN WriteString('5:  OK') END;
	IF MatchPattern(Exp1,'2*2+3*4+(9+8)')<>NIL THEN WriteString('6:  OK') END;
	IF MatchPattern(Exp1,'2++2')<>NIL THEN WriteString('7: not ok ') END;
	END Test.
