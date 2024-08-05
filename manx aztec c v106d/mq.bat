@echo off
if "%1" == "" goto :fail

rem apps (unlike ttt) that don't use recrsion can benefit from -Q

ntvcm cc -DAZTECCPM -Q -T -F -DCPMTIME %1.c
ntvcm as -L %1.asm
ntvcm ln -T %1.o m.lib c.lib
goto :done

:fail
echo no input specified

:done

