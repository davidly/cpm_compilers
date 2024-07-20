str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.INT 2>/dev/null

ntvcm JRTPAS2 $str
ntvcm -p EXEC $str.int


