str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.LST 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm -c Z80ASM $str/SXA

rm $str.LST 2>/dev/null

