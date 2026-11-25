@echo off
setlocal

IF "%~1"=="" GOTO usage

if not exist "%~1.cow" GOTO usage

ntvcm -r:0 init
rem the cowgol passes read their data files past the soft eof; with ^z fill there,
rem tokenise fails and so can codegen (depending on file sizes). 0 fill works.
ntvcm -r:0 tokenise runtime0.cow runtime1.cow runtime2.cow %1.cow

ntvcm -r:0 parser
ntvcm -r:0 typechck

del iops.dat  >nul 2>&1
ren iopsout.dat iops.dat
ntvcm -r:0 backend

del iops.dat
ren iopsout.dat iops.dat
ntvcm -r:0 classify
ntvcm -r:0 blockify

del iops.dat
ren iopsout.dat iops.dat
ntvcm -r:0 codegen

del iops.dat
ren iopsout.dat iops.dat
ntvcm -r:0 placer

del iops.dat
ren iopsout.dat iops.dat
ntvcm -r:0 emitter

del %1.com  >nul 2>&1
ren cow.com %1.com

goto :eof

:usage
echo Error: No source file argument provided or found.
echo Usage: %0 ^<source file^>
exit /B 1

