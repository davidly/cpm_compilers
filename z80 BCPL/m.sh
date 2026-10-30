str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.OUT 2>/dev/null

ntvcm BCPL $str.B $str.OUT
ntvcm LOADB $str.OUT $str.COM

rm $str.OUT 2>/dev/null

