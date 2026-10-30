str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null

ntvcm -c -p FORTH - include $str.F $str bye
