@echo off
setlocal
pushd "%~dp0" || exit /b 1
ntvcm -c M2CL.COM %* <nul
set "result=%errorlevel%"
popd
exit /b %result%
