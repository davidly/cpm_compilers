str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.CRL 2>/dev/null
rm $str.SYM 2>/dev/null

ntvcm CC1.COM $str.C -o
ntvcm CLINK.COM $str -sw

rm $str.CRL 2>/dev/null
rm $str.SYM 2>/dev/null

echo 
