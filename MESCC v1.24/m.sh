str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.HEX 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.ZSM 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CC $str
ntvcm CCOPT $str
ntvcm ZSM $str
ntvcm HEXTOCOM $str

rm $str.HEX 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.ZSM 2>/dev/null
