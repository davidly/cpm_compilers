(* **********  Window Management System   ********** *)
(* **********  Version 1.1   2/10/87      ********** *)
(* **********  Written by : Bob Catiller  ********** *)
(*                                                             *)
(*(C)Copyright 1987 Bob Catiller all commercial rights reserved*)
(*                                                             *)
(* ********** constant and variable declarations ********** *)

IMPLEMENTATION MODULE Windows;

  FROM SYSTEM
    IMPORT ADDRESS, ADR, FILL, MOVE, TSIZE;
  FROM STORAGE
    IMPORT ALLOCATE, DEALLOCATE;
  FROM Strings
    IMPORT Length;
  FROM Terminal
    IMPORT GotoXY,
    WriteChar, WriteString, Highlight, Normal;
  FROM TermAtt
    IMPORT  GraphicOn, GraphicOff,
    GraphicChar, RevVideo, NormVideo;

  CONST
    wxa = 1; (*min col*)
    wya = 1; (*min row*)
    wyz = 23; (*max row*)
    wlz = 1840; (*max length*)

  VAR
    wzr: INTEGER;

  TYPE
    wpt = POINTER TO wcb;
    wcb = RECORD (*window control block*)
            wbt, (*window border type*)
            wx, (*window col*)
            wy, (*window row*)
            ww, (*window width*)
            wh: INTEGER;
            (*window height*)
            wxo, (*window origin col*)
            wyo, (*window origin row*)
            wl: INTEGER;(*window length*)
            wb: BOOLEAN;(*window border flag*)
            wc, (*window cols*)
            wr, (*window rows*)
            wrh: INTEGER; (*window row highlighted*)
            wrp: ARRAY [wya..wyz] OF INTEGER;
            (*window row positions*)
            wbc: ARRAY [1..8] OF CHAR;
            wch: ARRAY [0..wlz-1] OF CHAR;
            (*window contents*)
          END;
    wino = ARRAY [0..9] OF wpt;

    (* for use by window management services *)
    (* Pointer array used to allocate, deallocate, and access windows *)
    (* 10 windows maximum are allowed, numbered 0 thru 9 *)
    VAR
      wno: wino;

  (* ********** internal functions and procedures ********** *)

  (* **********  wiBord1  ********* *)
  (* set up border parameters  in window record *)

(* Graphics characters for Wyse 50 terminal *)
  (* 0  line upper left & right corner *)
  (* 1  line lower left corner *)
  (* 2  line upper left corner *)
  (* 3  line upper right corner *)
  (* 4  line upper & lower left corner *)
  (* 5  line lower right corner *)
  (* 6  line vertical *)
  (* 7  block dense *)
  (* 8  line vertical & horizontal *)
  (* 9  line upper & lower right corner *)
  (* :  line horizontal *)
  (* ;  block medium *)
  (* <  line double horizontal *)
  (* =  line lower left & right corner *)
  (* >  line double vertical *)
  (* ?  block light *)
(* The ASCII characters listed above will be *)
(* stored in the window as border characters. *)
(* They will be automatically be displayed as *)
(* graphic characters by the wiShow routine. *)

  VAR
    i: INTEGER;
    c: CARDINAL;

  PROCEDURE wiBord1(no: INTEGER);
  BEGIN
    WITH wno[no]^ DO

(* The following CASE statement will load the border *)
(* graphic character string in the wbc array of the *)
(* window record. You may create your own border types *)
(* by adding lines to the case statement. The meaning *)
(* of the characters in the string is as follows: *)
(* 	Character 1 = left border character *)
(*	Character 2 = right border character *)
(*	Character 3 = top border character *)
(*	Character 4 = bottom border character *)
(*	Character 5 = top left corner character *)
(*	Character 6 = top right corner character *)
(*	Character 7 = bottom left corner character *)
(*	Character 8 = bottom right corner character *)

      c := CARD(wbt);(* window border type *)
      CASE c OF
        | 1 : wbc := '77777777'(* type 1 = dense blocks *)
        | 2 : wbc := ';;;;;;;;'(* type 2 = medium blocks *)
        | 3 : wbc := '????????'(* type 3 = light blocks *)
        | 4 : wbc := '>><<2315'(* type 4 = double line *)
        | 5 : wbc := '66::2315'(* type 5 = single line *)
        | 6 : wbc := '88888888'(* type 6 = cross hatch *)
        | 7 : wbc := '94=02315'(* type 7 = hatch out *)
        | 8 : wbc := '490=2315'(* type 8 = hatch in *)
        | 9 : wbc := '>><<;;;;'(* type 9 = mixed line *)
        | 10 : wbc := ';;;;2315'(* type 10 = mixed block *)
      ELSE
        wbt := 0
      END;(* CASE *)
      IF wbt <> 0 THEN
        wb := TRUE;
        wc := ww-4;
        wr := wh-2;
        FOR i := wya TO wyz DO
          wrp[i] := ((i*ww)+2)
        END;(* FOR *)
      ELSE
        wb := FALSE;
        wc := ww;
        wr := wh;
        FOR i := wya TO wyz DO
          wrp[i] := ((i-1)*wc);
        END;(* FOR *)
      END;(* IF *)
    END;(* WITH *)
  END wiBord1;

  (* **********  wiBord2  ********* *)
  (* insert border characters into window *)

  PROCEDURE wiBord2(no: INTEGER);

    VAR
      i: INTEGER;

  BEGIN
    WITH wno[no]^ DO
      IF (wb) THEN
        FOR i := 0 TO wh-1 DO
          (* Fill left border. *)
          wch[(i)*ww] := wbc[1];
          (* Fill right border. *)
          wch[(((i)*ww)+ww)-1] := wbc[2];
        END;
        FOR i := 0 TO ww-1 DO
          (* Fill top border. *)
          wch[i] := wbc[3];
          (* Fill bottom border. *)
          wch[(wl-ww+i)] := wbc[4];
        END;
        (* Fill top left corner *)
        wch[0] := wbc[5];
        (* Fill top right corner *)
        wch[ww-1] := wbc[6];
        (* Fill bottom left corner *)
        wch[wl-ww] := wbc[7];
        (* Fill bottom right corner *)
        wch[wl-1] := wbc[8];

      END;
    END;
  END wiBord2;

  (* **********  wiOut  ********** *)
  (* store string to window at current window position *)
  (* optionally, write string to screen at current screen position *)

  PROCEDURE wiOut(no: INTEGER; st: wst; out: BOOLEAN);

  VAR
      i, x, y: INTEGER;
  BEGIN
    wiStatus := FALSE;
    wiEoln := FALSE;
    wiEow := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF (wy > wr) THEN
          wiInsln(no, wy);
          IF (out) THEN
            wiShow(no)
          END;
        END;
        i := 0;
        WHILE (i < INTEGER(Length(st))) AND (wx <= wc) DO
          wch[(wrp[wy]+wx)-1] := st[i];
          IF (out) THEN
            x := INTEGER((wxo+wx)+1);
            y := INTEGER(wyo+wy);
            IF ( NOT wb) THEN
              x := x-2;
              y := y-1;
            END;
            IF ((x >= wxa) OR (x <= wxz))
             AND ((y >= wya) OR (y <= wyz)) THEN
              GotoXY(x, y);
              WriteChar(st[i]);
            END;
          END;
          wx := wx+1;
          i := i+1;
        END;
        IF (wx > wc) THEN
          wx := 1;
          wy := wy+1;
          wiEoln := TRUE;
          IF (wy > wr) THEN
            wiEow := TRUE
          END;
        END;
        wiStatus := TRUE;
      END;
    END;
  END wiOut;

  (* *********  wiOutln  ********** *)
  (* store string to window at current window position *) 
  (* optionally, write string to screen at current screen position *)

  PROCEDURE wiOutln(no: INTEGER; st: wst; out: BOOLEAN);

  VAR
    temp1, temp2: INTEGER;

  BEGIN
    wiOut(no, st, out);(* display text *)
    IF (wiStatus) THEN
      WITH wno[no]^ DO
        IF (wx > 1) THEN
          FILL(ADR(wch[(wrp[wy]+wx)-1]), CARD(wc-wx), ' ');
          IF (out) THEN
	    temp1 := (wxo+wx)-1;
	    temp2 := (wyo+wx)-1;
            IF ((temp1 >= wxa) OR (temp1 <= wxz))
             AND ((temp2 >= wya) OR (temp2 <= wyz)) THEN
              wiClreol(no);
            END;
          END;
          wx := 1;
          wy := (wy)+1;
          wiEoln := TRUE;
          IF (wy > wr) THEN
            wiEow := TRUE
          END;
        END;
      END;
    END;
  END wiOutln;

(* ********** wiOutGt ************ *)
  (* Outputs text string as graphic characters *)
  PROCEDURE wiOutGt(st: wst);

  BEGIN
(* initiate graphics mode *)
    GraphicOn();
(* The following string of characters will be *)
(* displayed as graphic characters. *)
    WriteString(st);
(* return to normal display mode. *)
    GraphicOff();
  END wiOutGt;

  (* **********  wiSher  ********* *)
  (* show/erase window from screen *)

  PROCEDURE wiSher(no: INTEGER; show: BOOLEAN);

    VAR

      h, i, j, k, x, y: INTEGER;
      st: wst;
      temp5: ADDRESS;

  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        j := (wxo+ww)-1;
        IF (j <= wxz) THEN
          j := INTEGER(ww)
        ELSE
          j := ww-(j-wxz)
        END;(* IF *)
        IF (wxo >= 1) THEN
          k := 1;
          x := wxo;
        ELSE
          j := (wxo+ww)-1;
          k := (ww-j)+1;
          x := 1;
        END;(* IF *)
        IF (j > 0) THEN
          FILL(ADR(st[0]), CARD(j), CHR(0));
            FOR i := 1 TO wh DO
              y := (wyo+i)-1;
              IF ((x >= wxa) OR (x <= wxz))
               AND ((y >= wya) OR (y <=wyz)) THEN
                GotoXY(x, y);
                IF (NOT show) THEN
                  FILL(ADR(st[0]), CARD(j), ' ');
                  WriteString(st);
                ELSE
                  temp5 := ADR(wch[((i-1)*ww)+k-1]);
                  MOVE(temp5, ADR(st[0]), CARD(j));
                  IF (wb) THEN
                    IF (i=1) OR (i=wh) THEN
                      (* Display graphics for top & bottom borders *)
                      wiOutGt(st);
                    ELSE
                      GraphicChar(st[0]);(* left border *)
                      IF ((wrh+1) = i) AND (wrh <> 0) THEN
                        RevVideo();
                      ELSE
                        NormVideo();
                      END;(* IF *)
                      FOR h:= 2 TO (ww-3) DO
                        WriteChar(st[h]);(* text *)
                      END;(* FOR *)
                      NormVideo();
                      GraphicChar(st[ww-1]);(* right border *)
                    END;(* IF *)
                  ELSE
                    IF ((wrh+1) = i) AND (wrh <> 0) THEN
                      Highlight;
                    END;(* IF *)
                    WriteString(st);
                    IF ((wrh+1) = i) AND (wrh <> 0) THEN
                      Normal;
                    END;(* IF *)
                  END;(* IF *)
                END;(* IF *)
              END;(* IF *)
            END;(* FOR *)
        END;(* IF *)
        wiStatus := TRUE;
      END;(* WITH *)
    END;(* IF *)
  END wiSher;

(* ***** End of internal functions & procedures ***** *)

  (* **********  Window Management Services  ********** *)

  (* *********  wiDelln  ********** *)
  (* delete line from window *)

  PROCEDURE wiDelln(no, y: INTEGER);

    VAR
      i: INTEGER;
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF  NOT ((y >= 1) OR (y <= wr)) THEN
          wiStatus := FALSE
        ELSE
          (* Move all lines below deleted line up one line. *)
          FOR i := y TO wr-1 DO
            MOVE(ADR(wch[wrp[i+1]]),
             ADR(wch[wrp[i]]),
              CARD(wc))
          END;
          (* Fill bottom line with blanks. *)
          FILL(ADR(wch[wrp[wr]]), CARD(wc), ' ');
          wx := 1;
          wy := y;
          wiStatus := TRUE;
        END;
      END;
    END; 
  END wiDelln;

  (* **********  wiInsln  ********** *)
  (* insert line into window *)

  PROCEDURE wiInsln(no, y: INTEGER);

    VAR
      i: INTEGER;
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF  NOT ((y >= 1) OR (y <= wr)) THEN
          IF (y < 1) THEN
            wiStatus := FALSE
          ELSE
            wiDelln(no, 1);
            wy := wr;
          END
        ELSE
          FOR i := wr TO y BY -1 DO
            MOVE(ADR(wch[wrp[i-1]]),
              ADR(wch[wrp[i]]),
               CARD(wc))
          END;
          FILL(ADR(wch[wrp[y]]), CARD(wc), ' ');
          wy := y;
          wx := 1;
          wiStatus := TRUE;
        END;
      END;
    END;
  END wiInsln;

  (* **********  wiClreol  ********** *)
  (* clear from current window position to end of line *)

  PROCEDURE wiClreol(no: INTEGER);
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF ((wy >= 1) OR (wy <= wr))
         AND ((wx >= 1) OR (wx <= wc)) THEN
          FILL(ADR(wch[(wrp[wy]+wx)-1]), CARD(wc-wx), ' ');
          wiStatus := TRUE;
        END;
      END;
    END;
  END wiClreol;

  (* **********  wiClear  ********* *)
  (* blank window contents *)

  PROCEDURE wiClear(no: INTEGER);
  BEGIN 
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        (* Blank entire window. *)
        FILL(ADR(wch[0]), CARD(wl), ' ');
        wch[wl] := CHR(0);
        wx := 1;
        wy := 1;
        (* Restore border. *)
        wiBord2(no);
      END;
      wiStatus := TRUE;
    END;
  END wiClear;

  (* *********  wiHome  ********** *)
  (* set window position to beginning of first line *)

  PROCEDURE wiHome(no: INTEGER);
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        (* Set origin to row 1, column 1. *)
        wx := 1;
        wy := 1;
      END;
      wiStatus := TRUE;
    END;
  END wiHome;

  (* *********  wiBorder ********** *)
  (* set/reset window border type *)
  (* overlay *)

  PROCEDURE wiBorder(no, bt: INTEGER);
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        wbt := bt;(* set new border type *)
        wiBord1(no);(* set up border parameters *)
        IF (wb) THEN
          wiBord2(no);(* insert new border in window *)
          wiStatus := TRUE;
        END;
      END;
    END;
  END wiBorder;

  (* *********  wiOpen  ********** *)
  (* open window - allocate dynamic memory for window control block *)
  (* overlay *)

  PROCEDURE wiOpen(no, x, y, w, h, bt: INTEGER);

    VAR
      i, l: INTEGER;
  BEGIN
    wiStatus := FALSE;
    IF ((w >= wxa) OR (w <= wxz))
     AND ((h >= wya) OR (h <= wyz))
      AND  NOT (wno[no] <> NIL) THEN
      l := w*h;
      ALLOCATE(wno[no], ((INTEGER(TSIZE(wcb))-wlz)+l+1));
      WITH wno[no]^ DO
	wbt := bt;
	wx := 1;
        wy := 1;
        wxo := x;
        wyo := y;
        ww := w;
        wh := h;
        wl := l;
        wrh := 0;
        wiBord1(no);(* set up border parameters *)
      END;
      wiClear(no);
    END;
  END wiOpen;

  (* **********  wiClose  ********** *)
  (* close window - release dynamic memory *)
  (* overlay *)

  PROCEDURE wiClose(no: INTEGER);
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      DEALLOCATE(wno[no],(((TSIZE(wcb))-wlz)+CARD(wno[no]^.wl)));
      wiStatus := TRUE;
    END;
  END wiClose;

  (* **********  wiGetpos  ********** *)
  (* get window position *)
  (* overlay *)

  PROCEDURE wiGetpos(no: INTEGER;
                     VAR x, y: INTEGER);
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        x := INTEGER(wx);
        y := INTEGER(wy);
      END;(* WITH *)
      wiStatus := TRUE;
    END;(* IF *)
  END wiGetpos;

  (* *********  wiGetorg  ********** *)
  (* get window screen origin *)
  (* overlay *)

  PROCEDURE wiGetorg(no: INTEGER;
                     VAR x, y: INTEGER);
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        x := wxo;
        y := wyo;
      END;(* WITH *)
      wiStatus := TRUE;
    END;(* IF *)
  END wiGetorg; (*wiGetorg*)

  (* **********  wiSetpos  ********** *)
  (* set window position *)

  PROCEDURE wiSetpos(no, x, y: INTEGER); 
  BEGIN 
    wiStatus := FALSE; 
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF ((x >= 1) OR (x <= wc)) AND ((y >=1) OR (y <= wr)) THEN
          wx := x;
          wy := y;
          wiStatus := TRUE;
        ELSE
          wiStatus := FALSE
        END;
      END;
    END;
  END wiSetpos;

  (* **********  wiSetorg  ********** *)
  (* set window screen origin *)

  PROCEDURE wiSetorg(no, x, y: INTEGER);
  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        wxo := x;
        wyo := y;
      END;
      wiStatus := TRUE;
    END;
  END wiSetorg;

  (* **********  wiPut  ********* *)
  (* store string in window *)

  PROCEDURE wiPut(no: INTEGER;
                  st: wst);
  BEGIN
    wiOut(no, st, FALSE);
  END wiPut;

  (* *********  wiPutln  ********* *)
  (* store string in window *)

  PROCEDURE wiPutln(no: INTEGER;
                    st: wst);
  BEGIN
    wiOutln(no, st, FALSE);
  END wiPutln;

  (* *********  wiWrite  ********* *)
  (* write string to screen thru window *)

  PROCEDURE wiWrite(no: INTEGER;
                    st: wst);
  BEGIN
    wiOut(no, st, TRUE);
  END wiWrite;

  (* *********  wiWriteln  ********** *)
  (* write string to screen thru window *)

  PROCEDURE wiWriteln(no: INTEGER;
                      st: wst);
  BEGIN
    wiOutln(no, st, TRUE);
  END wiWriteln;

  (* **********  wiShow  ********* *)
  (* display window to screen *)

  PROCEDURE wiShow(no: INTEGER);
  BEGIN
    wiSher(no, TRUE);
  END wiShow;

  (* *********  wiErase  ********** *)
  (* blank window region on screen *)

  PROCEDURE wiErase(no: INTEGER);
  BEGIN
    wiSher(no, FALSE);
  END wiErase;

(* ********** wiHlup ************ *)
  (* Rotates highlighting to next line up. *)
  (* Moves to bottom line if at top line. *)

  PROCEDURE wiHlup(no: INTEGER);

  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF wrh <> 0 THEN
          IF wrh = 1 THEN
            wrh := wr;
          ELSE
            wrh := wrh-1;
          END;(* IF *)
          wiShow(no);
        END;(* IF *)
      END;(* DO *)
    END;(* IF *)
  END wiHlup;

(* ********** wiHldown ************ *)
  (* Rotates highlighting to next line down. *)
  (* Moves to top line if at bottom line. *)
  PROCEDURE wiHldown(no: INTEGER);

  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF wrh <> 0 THEN
          IF wrh = wr THEN
            wrh := 1;
          ELSE
            wrh := wrh+1;
          END;(* IF *)
          wiShow(no);
        END;(* IF *)
      END;(* DO *)
    END;(* IF *)
  END wiHldown;

(* ********** wiSethl ************ *)
  (* Selects row to be highlighted in window *)
  (* 0 selects no highlighting *)

  PROCEDURE wiSethl(no, rh: INTEGER);

  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
        IF (rh > wr) OR (rh < 0) THEN
          wrh := 0;
        ELSE
          wrh := rh;
        END;(* IF *)
      END;(* DO *)
      wiShow(no);
      wiStatus := TRUE;
    END;(* IF *)
  END wiSethl;

(* ********** wiGethl ************ *)
  (* Gets row number of currently highlighted *)
  (* row. Returns 0 if no highlighting. *)

  PROCEDURE wiGethl(no: INTEGER);

  VAR
    rh: INTEGER;

  BEGIN
    wiStatus := FALSE;
    IF (wno[no] <> NIL) THEN
      WITH wno[no]^ DO
          y := wrh;
      END;(* DO *)
      wiStatus := TRUE;
    END;(* IF *)
  END wiGethl;


(* **********  End of Window Management Services  ********* *)
END Windows.
