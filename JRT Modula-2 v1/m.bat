rem I can't find documentation and I can't figure out how to generate an .int file. So this is a workaround:

copy modula.lib %1.lib

rem compile the file and put the code in %1.lib along with everything else in modula.lib
ntvcm modula %1=%1

rem execute the library (dot) app name, which isn't a filename but the syntax for running an app in a library
ntvcm -p MEX.COM %1.%1


