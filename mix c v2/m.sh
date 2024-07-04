str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MIX 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CC $str.C
ntvcm LINKER $str

rm $str.MIX 2>/dev/null
