str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null

ntvcm -c C309.COM $str.C -O -LF -DHISOFTC

