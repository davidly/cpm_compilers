5 dim o(9)
6 o(1)=0 : o(2)=1 : o(3)=0 : o(4)=1 : o(5)=0
7 o(6)=1 : o(7)=0 : o(8)=1 : o(9)=0
30 dim b(9)
32 dim s1(10)
34 dim s2(10)
36 dim s3(10)
37 dim s4(10)
40 for l = 1 to 10
41 m = 0
42 a1 = 2
43 b1 = 9
44 b(1) = 1
45 gosub 4000
58 a1 = 2
59 b1 = 9
60 b(1) = 0
61 b(2) = 1
62 gosub 4000
68 a1 = 2
69 b1 = 9
70 b(2) = 0
71 b(5) = 1
72 gosub 4000
73 b(5) = 0
80 next l
87 print "final move count ";
88 print m
90 bye
100 end

2000 w1 = b( 1 )
2010 if 0 = w1 then goto 2100
2020 if w1 = b( 2 ) and w1 = b( 3 ) then return
2030 if w1 = b( 4 ) and w1 = b( 7 ) then return
2100 w1 = b( 4 )
2110 if 0 = w1 then goto 2200
2120 if w1 = b( 5 ) and w1 = b( 6 ) then return
2200 w1 = b( 7 )
2210 if 0 = w1 then goto 2300
2220 if w1 = b( 8 ) and w1 = b( 9 ) then return
2300 w1 = b( 2 )
2310 if 0 = w1 then goto 2400
2320 if w1 = b( 5 ) and w1 = b( 8 ) then return
2400 w1 = b( 3 )
2410 if 0 = w1 then goto 2500
2420 if w1 = b( 6 ) and w1 = b( 9 ) then return
2500 w1 = b( 5 )
2510 if 0 = w1 then return
2520 if w1 = b( 1 ) and w1 = b( 9 ) then return
2530 if w1 = b( 3 ) and w1 = b( 7 ) then return
2540 w1 = 0
2550 return

4000 s = 1
4040 v = 0
4060 r = 0
4100 m = m + 1
4104 if s < 5 then goto 4150
4105 gosub 2000
4106 if 0 = w1 then goto 4140
4110 if w1 = 1 then r = 6: goto 4280
4115 r = 4
4116 goto 4280
4140 if s = 9 then r = 5: goto 4280
4150 if o(s) then v = 2 else v = 9
4160 p = 1
4180 if 0 <> b(p) then goto 4500
4200 if o(s) then b(p) = 1 else b(p) = 2
4210 s1(s) = p
4230 s2(s) = v
4245 s3(s) = a1
4246 s4(s) = b1
4260 s = s + 1
4270 goto 4100
4280 s = s - 1
4290 p = s1(s)
4310 v = s2(s)
4325 a1 = s3(s)
4326 b1 = s4(s)
4328 b(p) = 0
4330 if o(s) then goto 4340
4331 if r = 4 then goto 4530
4332 if r < v then v = r
4334 if v < b1 then b1 = v
4336 if b1 <= a1 then goto 4520
4338 goto 4500
4340 if r = 6 then goto 4530
4341 if r > v then v = r
4342 if v > a1 then a1 = v
4344 if a1 >= b1 then goto 4520
4500 p = p + 1
4505 if p < 10 then goto 4180
4520 r = v
4530 if s = 1 then return
4540 goto 4280

