@echo off
del %1.com 1>nul 2>nul

rem compile
ntvcm -8 f80 %1,%1=%1

rem link
ntvcm -8 l80 %1,%1/N/E

rem run
rem ntvcm -8 -p %1.com

