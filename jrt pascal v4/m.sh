str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.INT 2>/dev/null

ntvcm PAS4 $str
ntvcm -p EXEC4 $str.int


