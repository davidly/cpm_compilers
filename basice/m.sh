str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.INT 2>/dev/null

ntvcm BASIC $str.BAS
ntvcm -p RUN $str.INT
