str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.CRL 2>/dev/null

ntvcm CC1.COM $str.C -o
ntvcm CC2.COM $str -o
ntvcm CLINKC.COM $str -s

rm $str.CRL 2>/dev/null

echo 
