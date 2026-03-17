@echo off
setlocal

IF "%~1"=="" GOTO usage

if not exist "%~1.cow" GOTO usage

ntvcm init
rem note that tokenise fails if data past the soft eof is ^z. 0 works. hack is in ntvcm.
ntvcm tokenise b:runtime0.cow b:runtime1.cow b:runtime2.cow %1.cow

ntvcm parser
ntvcm typechck

del iops.dat
ren iopsout.dat iops.dat
ntvcm backend

del iops.dat
ren iopsout.dat iops.dat
ntvcm classify
ntvcm blockify

del iops.dat
ren iopsout.dat iops.dat
ntvcm codegen
del iops.dat
ren iopsout.dat iops.dat
ntvcm placer
del iops.dat
ren iopsout.dat iops.dat
ntvcm emitter

del %1.com
ren cow.com %1.com

goto :eof

:usage
echo Error: No source file argument provided or found.
echo Usage: %0 ^<source file^>
exit /B 1

