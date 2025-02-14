VAR z, p, mc, l, al, be, wi, st, v, re = INTEGER
dim INTEGER b(9)
dim INTEGER sp(10)
dim INTEGER sv(10)
dim INTEGER sa(10)
dim INTEGER sb(10)

    mc = 0
    for l = 1 to 1
    mc = 0
    al = 2
    be = 9
    b(0) = 1
    gosub 4000
    al = 2
    be = 9
    b(0) = 0
    b(1) = 1
    gosub 4000
    al = 2
    be = 9
    b(1) = 0
    b(4) = 1
    gosub 4000
    b(4) = 0
    next l
    print l; " iterations"
    print "final move count "; mc
    end

2000 wi = b( 0 )
    if 0 = wi then goto 2100
    if wi = b( 1 ) and wi = b( 2 ) then return
    if wi = b( 3 ) and wi = b( 6 ) then return
2100 wi = b( 3 )
    if 0 = wi then goto 2200
    if wi = b( 4 ) and wi = b( 5 ) then return
2200 wi = b( 6 )
    if 0 = wi then goto 2300
    if wi = b( 7 ) and wi = b( 8 ) then return
2300 wi = b( 1 )
   if 0 = wi then goto 2400
   if wi = b( 4 ) and wi = b( 7 ) then return
2400 wi = b( 2 )
    if 0 = wi then goto 2500
    if wi = b( 5 ) and wi = b( 8 ) then return
2500 wi = b( 4 )
    if 0 = wi then return
    if wi = b( 0 ) and wi = b( 8 ) then return
    if wi = b( 2 ) and wi = b( 6 ) then return
    wi = 0
    return

3000 for z = 0 to 8
     print b(z) ;
     next z
     print ""
     return

function odd( x = integer ) = integer
    var d, result = integer
    d = x / 2
    result = x - ( d * 2 )
end = result

4000 st = 0
     v = 0
     re = 0
4100 mc = mc + 1
     rem gosub 3000
     if st < 4 then goto 4150
     gosub 2000
     if 0 = wi then goto 4140
     if wi <> 1 then goto 4115
     re = 6
     goto 4280
4115 re = 4
     goto 4280
4140 if st <> 8 then goto 4150
     re = 5
     goto 4280
4150 if odd( st ) then v = 2 else v = 9
     p = 0
4180 if 0 <> b(p) then goto 4500
     if odd( st ) then b(p) = 1 else b(p) = 2
     sp(st) = p
     sv(st) = v
     sa(st) = al
     sb(st) = be
     st = st + 1
     goto 4100
4280 st = st - 1
     p = sp(st)
     v = sv(st)
     al = sa(st)
     be = sb(st)
     b(p) = 0
     if odd( st ) then goto 4340
     if re = 4 then goto 4530
     if re < v then v = re
     if v < be then be = v
     if be <= al then goto 4520
     goto 4500
4340 if re = 6 then goto 4530
     if re > v then v = re
     if v > al then al = v
     if al >= be then goto 4520
4500 p = p + 1
     if p < 9 then goto 4180
4520 re = v
4530 if st = 0 then return
     goto 4280

