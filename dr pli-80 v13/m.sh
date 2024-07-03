str=${1^^}

rm $str.REL 2>/dev/null
rm $str.SYM 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm PLI $str
# ntvcm PLI $str \$L\$I\$S >$str.LST
ntvcm LINK $str

rm $str.REL 2>/dev/null
rm $str.SYM 2>/dev/null
