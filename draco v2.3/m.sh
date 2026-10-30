str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAP 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm draco $str
ntvcm link -a $str

rm $str.MAP 2>/dev/null
rm $str.REL 2>/dev/null
