del %1.com 2>nul
del a.pco 2>nul
del a.oco 2>nul

ntvcm ppc %1.pas a.pco
ntvcm pfet a.pco a.oco

del a.pco
copy /b rtp.com+a.oco %1.com
