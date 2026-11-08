@echo off
rem Build e.g. "m sieve" with Intel PL/M-80 4.1 through the ntvcm plm80 tools.
rem Set NTVCM to the ntvcm repository (default: ..\..\ntvcm).
setlocal
if not defined NTVCM set "NTVCM=..\..\ntvcm"
if not defined PYTHON set "PYTHON=py -3"
%PYTHON% "%NTVCM%\plm80\compile.py" %1.PLM -o %1.COM
