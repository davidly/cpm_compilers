@echo off
setlocal
pushd "%~dp0" || exit /b 1
ntvcm -c TURBOCL.COM %* <nul
set "result=%errorlevel%"
popd
exit /b %result%
