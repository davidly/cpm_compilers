str=${1^^}

rm $str.REL 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm COBOL $str,$str=$str

ntvcm L80 $str,$str/N/E

rm $str.REL 2>/dev/null
rm $str.PRN 2>/dev/null
