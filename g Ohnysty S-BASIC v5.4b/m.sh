str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null

ntvcm -8 SBASIC $str.BAS
ntvcm -c -p -n $str

