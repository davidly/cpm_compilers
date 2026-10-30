str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null

ntvcm HP80 $str


