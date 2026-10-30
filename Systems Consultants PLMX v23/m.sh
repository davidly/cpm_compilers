str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.MAC 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.SYS 2>/dev/null

ntvcm PLMX $str ;C+L+
ntvcm M80 =$str /L
ntvcm LINK $str,BDOSCALL,RLIB[S]

rm $str.REL 2>/dev/null
rm $str.MAC 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.SYS 2>/dev/null
