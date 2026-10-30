str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.INT 2>/dev/null

ntvcm JRTPAS3 $str
ntvcm -p EXEC $str.int


