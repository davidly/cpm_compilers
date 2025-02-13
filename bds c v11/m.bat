@echo off
setlocal

del %1.crl 1>nul 2>nul
del %1.com 1>nul 2>nul

ntvcm cc1 %1.c -o
echo:
ntvcm cc2 %1 -o
echo:
ntvcm clinkc %1 -s
echo:

del %1.crl 1>nul 2>nul

