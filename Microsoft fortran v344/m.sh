str=${1^^}
rm $str.COM 2>/dev/null

ntvcm -8 F80 $str,$str=$str

ntvcm -8 L80 $str,$str/N/E

ntvcm -8 -p $str.COM

rm $str.REL 2>/dev/null
rm $str.PRN 2>/dev/null
