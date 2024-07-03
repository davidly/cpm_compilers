str=${1^^}

ntvcm FORT $str
ntvcm FRUN $str.c

rm $str.LST 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvcm $str

