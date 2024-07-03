str=${1^^}

rm $str.MAC 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CC $str
ntvcm M80 =$str/Z
ntvcm L80 $str/N,CRUNLIB.REL,$str,/S/E

rm $str.MAC 2>/dev/null
rm $str.REL 2>/dev/null
