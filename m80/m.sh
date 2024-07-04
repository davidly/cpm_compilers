str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.REL 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm M80 =$str.MAC /X /O /L /Z
ntvcm L80 $str,$str/N/E

rm $str.REL 2>/dev/null
rm $str.PRN 2>/dev/null

