str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAC 2>/dev/null
rm $str.OUT 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CC -p $str.C >$str.OUT
# delete the first line of the output file
tail -n +2 $str.OUT > $str.MAC
unix2dos -f $str.MAC

ntvcm M80 $str=$str
ntvcm L80 $str,CLIB/s,$str/N/E

rm $str.MAC 2>/dev/null
rm $str.OUT 2>/dev/null
rm $str.REL 2>/dev/null

