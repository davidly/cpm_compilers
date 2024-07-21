# I can't find documentation and I can't figure out to generate an .int file. So this is a workaround:

str=$(tr '[a-z]' '[A-Z]' <<< $1)

cp MODULA.LIB $str.LIB

# compile the file and put the code in %1.lib along with everything else in modula.lib
ntvcm MODULA $str=$str

# execute the library (dot) app name, which isn't a filename but the syntax for running an app in a library
ntvcm -p MEX.COM $str.$str
