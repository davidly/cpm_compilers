@echo off
del %1.s    2>nul
del %1.o    2>nul
del %1.tm1  2>nul
del %1.tm2  2>nul
del %1.com  2>nul

ntvcm pp -x -o %1.tm1 %1.c
ntvcm p1 -b0 -n8 -o %1.tm2 %1.tm1
ntvcm p280 -o %1.s %1.tm2
ntvcm as80 -o %1.o %1.s
ntvcm link -eb__memory -ed__edata -tb0x100 -htr -o %1.com crts.80 %1.o libu.80 libc.80

del %1.s    2>nul
del %1.o    2>nul
del %1.tm1  2>nul
del %1.tm2  2>nul

