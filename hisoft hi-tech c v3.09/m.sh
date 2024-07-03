str=${1^^}

rm $str.COM 2>/dev/null

ntvcm -c C309.COM $str.C -LF -DHISOFTC

