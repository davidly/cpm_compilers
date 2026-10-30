str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.REL 2>/dev/null

ntvcm PROPAS $str.PAS

rm $str.REL 2>/dev/null

