@echo off
setlocal

del %1.rel 2>nul
del %1.prn 2>nul
del %1.com 2>nul

rem this cobol compiler requires the input filename to be in upper case
set str=%1
call :TOUPPERCASE str
goto :compile

:TOUPPERCASE
if not defined %~1 exit /b
for %%a in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z" "„=Ž" "”=™" "=š") do (
call set %~1=%%%~1:%%~a%%
)
exit /b 0

rem compile
:compile
ntvcm cobol %str%,%str%=%str%
echo:
rem link
ntvcm l80 %str%,%str%/N/E
echo:
del %1.rel 2>nul
del %1.prn 2>nul


