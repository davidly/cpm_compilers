str=${1^^}

rm $str.ASM 2>/dev/null
rm $str.O 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CII $str.C
ntvcm AS $str.ASM
ntvcm LN $str.O LIBC.LIB

rm $str.ASM 2>/dev/null
rm $str.O 2>/dev/null
