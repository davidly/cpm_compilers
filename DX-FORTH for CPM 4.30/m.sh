str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null

ntvcm -c -p FORTH.COM - include $str.F $str bye
