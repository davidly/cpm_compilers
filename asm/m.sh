str=${1^^}

rm $str.HEX 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm -c ASM $str
ntvcm -c LOAD $str

rm $str.HEX 2>/dev/null
rm $str.PRN 2>/dev/null

