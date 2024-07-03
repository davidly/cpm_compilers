str=${1^^}

rm $str.REL 2>/dev/null
rm $str.LST 2>/dev/null

ntvcm FOR $str
ntvcm LOADER $str/M/S/L,MLIB

rm $str.REL 2>/dev/null
rm $str.LST 2>/dev/null


