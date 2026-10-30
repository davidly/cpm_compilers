str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.HEX 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvcm BCPL $str
ntvcm LINK DRIVE2,BCPL2,$str,BRTS,RTS2 /U

mv DRIVE2.HEX $str.HEX
ntvcm LOAD $str

rm $str.HEX 2>/dev/null
rm $str.OBJ 2>/dev/null

