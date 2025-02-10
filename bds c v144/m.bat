@echo off
setlocal

del %1.crl
del %1.sym
del %1.com

ntvcm cc1 %1.c -o
echo:
ntvcm clink %1 -sw
echo:

del %1.crl
del %1.sym

