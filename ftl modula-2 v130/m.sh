str=${1^^}

rm $str.REL 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm M2 $str.MOD $str.REL
ntvcm ML $str

rm $str.REL 2>/dev/null

