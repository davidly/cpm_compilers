str=${1^^}

rm $str.REL 2>/dev/null
rm $str.MAC 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CCZ /S0 $str
ntvcm ABBRUCH $str.LST
ntvcm M80 =$str/Z
ntvcm L80 $str/N,XXXMAIN,$str,LIB/S/E

rm $str.REL 2>/dev/null
rm $str.MAC 2>/dev/null
rm $str.LST 2>/dev/null

