rem pascal1 reads one character from the console
echo x | ntvcm -c pascal1 %1.pas %1.pco
ntvcm -c pascal2 %1.pco %1.oco
del %1.pco
copy /b pascal3.com + filler.dat + %1.oco %1.com
del %1.oco

