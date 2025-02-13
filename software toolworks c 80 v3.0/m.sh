str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.ASM 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm C $str
ntvcm AS $str.ASM

rm $str.ASM 2>/dev/null

