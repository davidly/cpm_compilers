@echo off
setlocal

set outputfile=test_forth.txt
echo %date% %time% >%outputfile%

set _testlist=e sieve ttt

( for %%t in (%_testlist%) do ( call :testRun %%t ) )

diff baseline_%outputfile% %outputfile%

goto :eof

:testRun

echo   test %~1

echo test case %~1 >>%outputfile%
call m.bat %~1 >>%outputfile%

exit /b 0

:eof


