str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null

ntvcm PAS $str.PAS
ntvcm LOCATE $str.OBJ

rm $str.OBJ 2>/dev/null
rm $str.PRN 2>/dev/null

