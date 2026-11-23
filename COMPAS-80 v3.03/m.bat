@echo off
setlocal
pushd "%~dp0" || exit /b 1
ntvcm -c COMPASCL.COM %* <nul
set "result=%errorlevel%"
popd
exit /b %result%
