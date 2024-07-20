str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.REL 2>/dev/null
rm $str.SYM 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CB80 $str
ntvcm LK80 $str = $str

rm $str.REL 2>/dev/null
rm $str.SYM 2>/dev/null


