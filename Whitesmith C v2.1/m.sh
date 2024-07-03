str=${1^^}

rm $str.COM 2>/dev/null
rm $str.S 2>/dev/null
rm $str.O 2>/dev/null
rm $str.TM1 2>/dev/null
rm $str.TM2 2>/dev/null

ntvcm CPP -x -o $str.TM1 $str.C
ntvcm CP1 -b0 -n8 -o $str.TM2 $str.TM1
ntvcm CP2 -o $str.S $str.TM2
ntvcm A80 -o $str.O $str.S
ntvcm LNK -eb__memory -tb0x100 -htr -o $str.COM CRTX.O $str.O LIBC.80

rm $str.S 2>/dev/null
rm $str.O 2>/dev/null
rm $str.TM1 2>/dev/null
rm $str.TM2 2>/dev/null
